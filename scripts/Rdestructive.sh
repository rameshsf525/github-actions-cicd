#!/bin/bash
# Salesforce destructive changes script - handles deletion of non-CustomLabel metadata
#
# Usage:
#   Rdestructive.sh <base_sha> <head_sha> <sf_target_org> <publish_path> [mode]
#   mode: "deploy" (default) or "validate" (dry-run)

base_sha=$1
head_sha=$2
sf_target_org=$3
publish_path=$4
mode=${5:-"deploy"}  # Default to "deploy" if not specified
build_dir="/tmp/deployment"
destructive_dir="${build_dir}/destructiveChanges"
destructive_file="${destructive_dir}/destructiveChanges.xml"
destructive_package="${destructive_dir}/package.xml"
NS="http://soap.sforce.com/2006/04/metadata"
DEPLOYMENT_ROOT="force-app/main/default"

echo "🗑️  Detecting deleted metadata for destructive changes..."
echo "Base SHA: $base_sha"
echo "Head SHA: $head_sha"
echo "Target Org: $sf_target_org"

cd "${GITHUB_WORKSPACE}"

##############################################
# FUNCTIONS
##############################################

# Function to map file path/extension to Salesforce metadata type
get_metadata_type() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    local dirname=$(dirname "$filepath")
    local parent_dir=$(basename "$dirname")

    case "$parent_dir" in
        classes)
            echo "ApexClass"
            ;;
        triggers)
            echo "ApexTrigger"
            ;;
        pages)
            echo "ApexPage"
            ;;
        components)
            echo "ApexComponent"
            ;;
        flows)
            echo "Flow"
            ;;
        globalValueSets)
            echo "GlobalValueSet"
            ;;
        customMetadata)
            echo "CustomMetadata"
            ;;
        objects)
            if [[ "$filename" == "*.field-meta.xml" ]]; then
                echo "CustomField"
            else
                echo "CustomObject"
            fi
            ;;
        layouts)
            echo "Layout"
            ;;
        recordTypes)
            echo "RecordType"
            ;;
        reports)
            echo "Report"
            ;;
        dashboards)
            echo "Dashboard"
            ;;
        documents)
            echo "Document"
            ;;
        staticresources)
            echo "StaticResource"
            ;;
        aura)
            echo "AuraDefinitionBundle"
            ;;
        lwc)
            echo "LightningComponentBundle"
            ;;
        email)
            echo "EmailTemplate"
            ;;
        approvalProcesses)
            echo "ApprovalProcess"
            ;;
        workflowRules)
            echo "WorkflowRule"
            ;;
        customSettings)
            echo "CustomSetting"
            ;;
        permissionsets)
            echo "PermissionSet"
            ;;
        profiles)
            echo "Profile"
            ;;
        *)
            ;;
    esac
}

# Function to extract metadata name from file path
get_metadata_name() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    
    # Remove -meta.xml suffix if present
    filename="${filename%-meta.xml}"
    
    # Remove common Salesforce file extensions
    filename="${filename%.cls}"           # ApexClass
    filename="${filename%.trigger}"       # ApexTrigger
    filename="${filename%.page}"          # ApexPage
    filename="${filename%.component}"     # ApexComponent
    filename="${filename%.flow}"          # Flow
    filename="${filename%.resource}"      # StaticResource
    filename="${filename%.email}"         # EmailTemplate
    
    # For custom objects, extract object name from folder
    local parent_dir=$(basename "$(dirname "$filepath")")
    if [ "$parent_dir" = "objects" ]; then
        filename=$(basename "$(dirname "$filepath")")
    fi
    
    echo "$filename"
}

# Function to detect and create destructive changes
function detectDestructiveChanges() {
    echo "============================================"
    echo "Detecting deleted files (excluding CustomLabels)..."
    echo "============================================"

    # Get list of deleted files between BASE and HEAD, EXCLUDING labels directory
    DELETED_FILES=$(git diff --name-only --diff-filter=D "${base_sha}" "${head_sha}" -- "${DEPLOYMENT_ROOT}" 2>/dev/null | grep -v "labels/" || true)

    if [ -z "${DELETED_FILES}" ]; then
        echo "✅ No deleted files detected (excluding CustomLabels)"
        return 0
    fi

    echo "============================================"
    echo "Deleted files detected (excluding CustomLabels):"
    echo "${DELETED_FILES}" | sed 's/^/  ✗ /'
    echo "============================================"

    # Build map of metadata types and their members to delete
    declare -A metadata_map
    declare -A member_seen  # Track what we've already processed
    
    while IFS= read -r filepath; do
        [ -z "$filepath" ] && continue
        
        # Skip -meta.xml paired files that will be handled by their parent
        if [[ "$filepath" == *"-meta.xml" ]]; then
            base_path="${filepath%-meta.xml}"
            if git ls-files --error-unmatch "$base_path" 2>/dev/null | grep -q .; then
                echo "Skipping paired .xml file: $filepath (will be handled with base file)"
                continue
            fi
        fi
        
        metadata_type=$(get_metadata_type "$filepath")
        
        if [ -z "$metadata_type" ]; then
            echo "⚠️ Unknown metadata type for: $filepath (skipping)"
            continue
        fi
        
        metadata_name=$(get_metadata_name "$filepath")
        
        # Create a unique key for this member to avoid duplicates
        member_key="${metadata_type}:${metadata_name}"
        
        # Skip if we've already seen this member
        if [ -n "${member_seen[$member_key]}" ]; then
            echo "Skipping duplicate: $metadata_type :: $metadata_name"
            continue
        fi
        member_seen[$member_key]=1
        
        if [ -z "${metadata_map[$metadata_type]}" ]; then
            metadata_map[$metadata_type]="$metadata_name"
        else
            metadata_map[$metadata_type]="${metadata_map[$metadata_type]}
$metadata_name"
        fi
        
        echo "  ✓ Detected: $metadata_type :: $metadata_name"
    done <<< "$DELETED_FILES"

    # Check if we found any destructive changes
    if [ ${#metadata_map[@]} -eq 0 ]; then
        echo "✅ No recognized metadata types to delete"
        return 0
    fi

    # Create destructiveChanges.xml
    mkdir -p "${destructive_dir}"

    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<Package xmlns="'"${NS}"'">'
        
        for metadata_type in "${!metadata_map[@]}"; do
            echo '  <types>'
            while IFS= read -r member; do
                [ -z "$member" ] && continue
                echo "    <members>$member</members>"
            done <<< "${metadata_map[$metadata_type]}"
            echo "    <name>$metadata_type</name>"
            echo '  </types>'
        done
        
        echo '</Package>'
    } > "${destructive_file}"

    # Create empty package.xml for destructive deploy
    {
        echo '<?xml version="1.0" encoding="UTF-8"?>'
        echo '<Package xmlns="'"${NS}"'">'
        echo '  <version>62.0</version>'
        echo '</Package>'
    } > "${destructive_package}"

    echo ""
    echo "============================================"
    echo "destructiveChanges.xml generated:"
    echo "============================================"
    cat "${destructive_file}"
    echo ""

    MEMBER_COUNT=$(grep -c '<members>' "${destructive_file}" || true)
    TYPE_COUNT=$(grep -c '<name>' "${destructive_file}" || true)
    echo "Destructive changes: ${MEMBER_COUNT} member(s) across ${TYPE_COUNT} metadata type(s) to delete."

    if [ "${MEMBER_COUNT}" -eq 0 ]; then
        echo "⚠️ No members found in destructiveChanges.xml"
        rm -rf "${destructive_dir}"
        return 0
    fi

    echo "HAS_DESTRUCTIVE_METADATA=true" >> "$GITHUB_ENV"
    echo "DESTRUCTIVE_DIR=${destructive_dir}" >> "$GITHUB_ENV"
}

# Function to deploy or validate destructive changes
function deployDestructiveChanges() {
    if [ ! -d "${destructive_dir}" ]; then
        echo "ℹ️ No destructive changes directory found. Skipping destructive operations."
        return 0
    fi

    if [ ! -f "${destructive_file}" ]; then
        echo "ℹ️ No destructiveChanges.xml found. Skipping destructive operations."
        return 0
    fi

    echo ""
    
    # Determine if this is validation (dry-run) or deployment
    if [ "$mode" = "validate" ]; then
        echo "===== VALIDATING destructive changes (dry-run) ====="
        output_file="${publish_path}/destructive_validation.json"
        dry_run_flag="--dry-run"
    else
        echo "===== DEPLOYING destructive changes ====="
        output_file="${publish_path}/destructive_deploy.json"
        dry_run_flag=""
    fi
    
    echo "--- destructiveChanges.xml ---"
    cat "${destructive_file}"
    echo ""
    echo "--- package.xml ---"
    cat "${destructive_package}"
    echo "==================================================="

    # Run the deployment or validation
    sf project deploy start \
        --manifest "${destructive_package}" \
        --post-destructive-changes "${destructive_file}" \
        --target-org "${sf_target_org}" \
        --ignore-warnings \
        --ignore-conflicts \
        --wait 30 \
        --verbose \
        ${dry_run_flag} \
        --json > "${output_file}" 2>&1

    destructive_exit_code=$?

    if [ "$mode" = "validate" ]; then
        echo "=== DESTRUCTIVE VALIDATION RESULT (exit code: $destructive_exit_code) ==="
    else
        echo "=== DESTRUCTIVE DEPLOYMENT RESULT (exit code: $destructive_exit_code) ==="
    fi
    
    cat "${output_file}"
    echo "========================="

    destructive_status=$(jq -r '.status // "1"' < "${output_file}" 2>/dev/null)

    if [[ "$destructive_exit_code" -eq 0 ]] && [[ "$destructive_status" == "0" ]]; then
        if [ "$mode" = "validate" ]; then
            echo "✅ Destructive validation succeeded (dry-run)!"
        else
            echo "✅ Destructive deployment succeeded!"
        fi
        return 0
    else
        if [ "$mode" = "validate" ]; then
            echo "❌ Destructive validation failed!"
        else
            echo "❌ Destructive deployment failed!"
        fi
        echo ""
        echo "=== Component Failures ==="
        jq -r '.result.details.componentFailures[]? | "- \(.problemType): \(.fullName) - \(.problem)"' "${output_file}" 2>/dev/null || true
        
        echo ""
        echo "=== Error Message ==="
        jq -r '.message // empty' "${output_file}" 2>/dev/null || true
        return 1
    fi
}

##############################################
# MAIN EXECUTION
##############################################

echo "Starting destructive changes detection and deployment..."
detectDestructiveChanges
deployDestructiveChanges
echo "✅ Destructive changes script completed"
