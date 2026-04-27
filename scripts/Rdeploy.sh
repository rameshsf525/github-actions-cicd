#!/bin/bash
# Salesforce deployment script - NoTestRun mode
#
# Usage:
#   deploy.sh <sf_target_org> <deploy_id> <publish_path>

sf_target_org=$1
deploy_id=$2
publish_path=$3
build_dir="/tmp/deployment"

cd ${build_dir}

echo "🚀 Starting Salesforce deployment (NoTestRun mode)..."
echo "Target Org: $sf_target_org"
echo "Publish Path: $publish_path"

# Always do direct deployment with NoTestRun
# (dry-run validation IDs cannot be used for quick deploy)
echo "📦 Deploying package without tests..."
sf project deploy start \
    --manifest ${build_dir}/manifest/package.xml \
    --target-org ${sf_target_org} \
    --test-level NoTestRun \
    --ignore-warnings \
    --ignore-conflicts \
    --wait 60 \
    --verbose \
    --json > ${publish_path}/deploy.json 2>&1

deploy_exit_code=$?

echo "=== DEPLOYMENT RESULT (exit code: $deploy_exit_code) ==="
cat ${publish_path}/deploy.json
echo "========================="

deploy_status=$(jq -r '.status // "1"' < ${publish_path}/deploy.json 2>/dev/null)

if [[ "$deploy_exit_code" -eq 0 ]] && [[ "$deploy_status" == "0" ]]; then
    echo "✅ Deployment succeeded!"
    exit 0
else
    echo "❌ Deployment failed!"
    echo ""
    echo "=== Component Failures ==="
    jq -r '.result.details.componentFailures[]? | "- \(.problemType): \(.fullName) - \(.problem)"' ${publish_path}/deploy.json 2>/dev/null || true
    
    echo ""
    echo "=== Error Message ==="
    jq -r '.message // empty' ${publish_path}/deploy.json 2>/dev/null || true
    exit 1
fi
