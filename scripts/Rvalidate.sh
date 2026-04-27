#!/bin/bash
# Enhanced Salesforce validation script for GitHub Actions
# Prints per-class code coverage and highlights classes below required coverage

sf_target_org=$1
publish_path=$2
build_dir="/tmp/deployment"
required_coverage=86

cd ${build_dir}

echo "🔍 Starting Salesforce validation..."
echo "Target Org: $sf_target_org"
echo "Publish Path: $publish_path"

# Check if there are any files to validate
if [ ! -d "${build_dir}/force-app/main/default" ] || [ -z "$(find ${build_dir}/force-app/main/default -type f -print -quit)" ]; then
    echo "[[INFO]]: No changes found in ${build_dir}/force-app/main/default. Skipping Salesforce Validation."
    echo "validation-status=skipped" >> $GITHUB_OUTPUT
    exit 0
fi

# Check if there are any .cls files (Apex classes) in the commit
cls_count=$(find "${build_dir}/force-app/main/default/classes" -name "*.cls" 2>/dev/null | wc -l)
if [ "$cls_count" -eq 0 ]; then
    echo "[[INFO]]: No Apex class (.cls) files found in commit. Skipping test class validation."
    echo "validation-status=skipped" >> $GITHUB_OUTPUT
    exit 0
fi

test_classes=""

# Search for test classes
echo "=== SEARCHING FOR TEST CLASSES ==="
if [ -d "${build_dir}/force-app/main/default/classes" ]; then
    echo "Classes directory exists. Files found:"
    find ${build_dir}/force-app/main/default/classes -name "*.cls" | sort
    echo "Searching for test classes (pattern: *Test.cls)..."
    find ${build_dir}/force-app/main/default/classes -iname "*Test.cls" ! -name "*-meta.xml" -exec basename {} .cls \;
    test_classes=$(find ${build_dir}/force-app/main/default/classes -iname "*Test.cls" ! -name "*-meta.xml" -exec basename {} .cls \; | paste -sd " " -)
    echo "Test classes found: '$test_classes'"
else
    echo "Classes directory does not exist."
fi

if [ -d "${build_dir}/force-app/main/default/triggers" ]; then
    echo "Triggers directory exists. Files found:"
    find ${build_dir}/force-app/main/default/triggers -name "*.trigger" | sort
    echo "Searching for test triggers (pattern: *Test.trigger)..."
    find ${build_dir}/force-app/main/default/triggers -iname "*Test.trigger" ! -name "*-meta.xml" -exec basename {} .trigger \;
    triggers_tests=$(find ${build_dir}/force-app/main/default/triggers -iname "*Test.trigger" ! -name "*-meta.xml" -exec basename {} .trigger \; | paste -sd " " -)
    if [[ -n "$triggers_tests" ]]; then
        test_classes="$test_classes $triggers_tests"
    fi
    echo "Trigger tests found: '$triggers_tests'"
else
    echo "Triggers directory does not exist."
fi

echo "Final test_classes variable: '$test_classes'"
echo "=== END TEST CLASS SEARCH ==="
echo "TEST_CLASSES=$test_classes" >> $GITHUB_ENV

echo "###################################"
echo $test_classes
echo "###################################"
echo "**********************************"
cat ${build_dir}/manifest/package.xml
echo "**********************************"

if [[ -n "$test_classes" ]]; then
    echo "🧪 Running validation with specific test classes: $test_classes"
    sf project deploy validate \
        --manifest ${build_dir}/manifest/package.xml \
        --target-org ${sf_target_org} \
        --test-level RunSpecifiedTests \
        --tests ${test_classes} \
        --ignore-warnings \
        --wait 60 \
        --json > ${publish_path}/validation.json
    deployId=$(jq -r '.result.id' < ${publish_path}/validation.json)
    status=$(jq -r '.status' < ${publish_path}/validation.json)
    echo "Deploy status: $status"
    echo "DEPLOY_ID=$deployId" >> $GITHUB_ENV
    echo "Deploy ID: $deployId"

    # ===== CODE COVERAGE ENFORCEMENT SECTION =====
    coverage_json="${publish_path}/validation.json"

    covered_lines=$(jq '[.result.details.runTestResult.codeCoverage[]? | .numLocations - .numLocationsNotCovered] | add // 0' "$coverage_json")
    total_lines=$(jq '[.result.details.runTestResult.codeCoverage[]? | .numLocations] | add // 0' "$coverage_json")

    if [[ "$total_lines" -gt 0 ]]; then
        coverage_percent=$(awk "BEGIN { printf \"%.2f\", ($covered_lines / $total_lines) * 100 }")
    else
        coverage_percent=0
    fi

    echo "Code Coverage: $coverage_percent%"

    echo "==== Per-Class Code Coverage Report ===="
    jq -r '
      .result.details.runTestResult.codeCoverage[]? 
      | "\(.name): \((.numLocations - .numLocationsNotCovered)/.numLocations*100 | floor)% (\(.numLocations - .numLocationsNotCovered)/\(.numLocations) lines covered)"
    ' "$coverage_json"

    echo "==== Classes Below Required Coverage ($required_coverage%) ===="
    jq --argjson req_cov $required_coverage '
      .result.details.runTestResult.codeCoverage[]?
      | {
          name, 
          percent: ((.numLocations - .numLocationsNotCovered)/.numLocations*100)
        }
      | select(.percent < $req_cov)
      | "\(.name): \(.percent | floor)%"
    ' "$coverage_json"

    if (( $(echo "$coverage_percent < $required_coverage" | bc -l) )); then
        echo "❌ Code coverage $coverage_percent% is below the required threshold of $required_coverage%."
        echo "validation-status=failed" >> $GITHUB_OUTPUT
        exit 1
    else
        echo "✅ Code coverage $coverage_percent% meets the required threshold."
    fi
    # ===== END CODE COVERAGE ENFORCEMENT SECTION =====

else
    apex_exists=false
    if [ -d "${build_dir}/force-app/main/default/classes" ] && [ "$(find ${build_dir}/force-app/main/default/classes -name "*.cls" | wc -l)" -gt 0 ]; then
        apex_exists=true
    fi
    if [ -d "${build_dir}/force-app/main/default/triggers" ] && [ "$(find ${build_dir}/force-app/main/default/triggers -name "*.trigger" | wc -l)" -gt 0 ]; then
        apex_exists=true
    fi

    if [[ "$apex_exists" == "true" ]]; then
        echo "❌ ERROR: Apex code detected, but no specific test classes found. You must commit at least one test class (ending with *Test.cls or *Test.trigger) for validation."
        echo "validation-status=failed" >> $GITHUB_OUTPUT
        exit 1
    else
        echo "ℹ️  No Apex code found. Checking if this is metadata-only deployment..."
        has_apex_in_package=$(grep -E "(ApexClass|ApexTrigger)" ${build_dir}/manifest/package.xml | wc -l)
        if [[ "$has_apex_in_package" == "0" ]]; then
            echo "📋 Pure metadata deployment detected (WebLinks, Custom Fields, Flows, etc.)"
            echo "ℹ️  Attempting deployment without test execution to avoid org compilation issues"
            sf project deploy validate \
                --manifest ${build_dir}/manifest/package.xml \
                --target-org ${sf_target_org} \
                --test-level NoTestRun \
                --ignore-warnings \
                --wait 60 \
                --json > ${publish_path}/validation.json

            validation_status=$(jq -r '.status' < ${publish_path}/validation.json)

            if [[ "$validation_status" == "0" ]]; then
                echo "✅ Metadata-only validation succeeded without tests"
                deployId=$(jq -r '.result.id' < ${publish_path}/validation.json)
                status=$(jq -r '.status' < ${publish_path}/validation.json)
                echo "Deploy status: $status"
                echo "DEPLOY_ID=$deployId" >> $GITHUB_ENV
                echo "Deploy ID: $deployId"
                echo "=== VALIDATION RESULT ==="
                cat ${publish_path}/validation.json
                echo "========================="
                echo "validation-status=success" >> $GITHUB_OUTPUT
                exit 0
            else
                echo "❌ Metadata validation without tests failed."
                echo "validation-status=failed" >> $GITHUB_OUTPUT
                exit 1
            fi
        else
            echo "❌ ERROR: Apex metadata found in package.xml but no test classes. Validation cannot proceed."
            echo "validation-status=failed" >> $GITHUB_OUTPUT
            exit 1
        fi
    fi
fi

echo "=== VALIDATION RESULT ==="
cat ${publish_path}/validation.json
echo "========================="

validation_status=$(jq -r '.status' < ${publish_path}/validation.json)
deploy_id_check=$(jq -r '.result.id' < ${publish_path}/validation.json)

echo "Validation Status: $validation_status"
echo "Deploy ID from validation: $deploy_id_check"

if [[ "$validation_status" == "0" ]]; then
    if [[ -n "$deploy_id_check" && "$deploy_id_check" != "null" && "$deploy_id_check" != "" ]]; then
        echo "✅ Validation succeeded with valid deploy ID: $deploy_id_check"
        echo "validation-status=success" >> $GITHUB_OUTPUT
    else
        echo "⚠️  Validation completed but no valid deploy ID generated"
        echo "validation-status=success" >> $GITHUB_OUTPUT
    fi
else
    echo "❌ Validation failed with status: $validation_status"
    echo -e "ERRORINFO:: \n $(jq -r '.message' < ${publish_path}/validation.json)"
    echo "validation-status=failed" >> $GITHUB_OUTPUT
    exit 1
fi
