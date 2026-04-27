#!/usr/bin/env bash
# GitHub Actions version of sfdelta.sh
# Handles delta deployment preparation with GitHub Actions environment variables
#
# FIXES:
# 1) Use BASE_SHA..HEAD_SHA range (not just HEAD~1..HEAD)
# 2) Do NOT cd into $GITHUB_WORKSPACE/$repo_name (workspace is already repo root)
# 3) Copy entire Aura bundle when any file in the bundle changes (same as LWC)

set -euo pipefail
set -x

echo "Preparing Salesforce Components for deployments..."

# Create required directories
mkdir -p /tmp/deployment/force-app/main/default

base_dir="/tmp/deployment"
sf_base_dir="${base_dir}"

# Inputs from workflow (these are SHAs in your workflow)
base_ref="${1:-}"
head_ref="${2:-}"
delta_mode="${3:-commit}"

if [[ -z "${base_ref}" || -z "${head_ref}" ]]; then
  echo "ERROR: Missing required args."
  echo "Usage: $0 <base_sha_or_ref> <head_sha_or_ref> <delta_mode>"
  exit 1
fi

echo "Base Ref:  ${base_ref}"
echo "Head Ref:  ${head_ref}"
echo "Delta Mode: ${delta_mode}"

# Repository root in GitHub Actions
repo_root="${GITHUB_WORKSPACE:-$(pwd)}"

##############################################
# FUNCTIONS
##############################################

function updateMetaxmlfiles() {
  cd "${repo_root}"

  if [[ ! -f "${base_dir}/latest_commit_delta.txt" ]]; then
    echo "WARNING: ${base_dir}/latest_commit_delta.txt not found; nothing to update."
    return 0
  fi

  # NOTE: Original behavior kept (splits on whitespace)
  for file_path in $(cat "${base_dir}/latest_commit_delta.txt"); do
    check_file_path=$(grep -F "${file_path}-meta.xml" "${base_dir}/latest_commit_delta.txt" || true)
    if [[ -z "$check_file_path" ]]; then
      echo "${file_path}-meta.xml" >> "${base_dir}/latest_commit_delta.txt"
    else
      echo "Meta for the ${file_path} exists in latest_commit_delta.txt"
    fi
  done
}

function generateDeltaFileList() {
  cd "${repo_root}"

  git fetch --all --prune >/dev/null 2>&1 || true

  if ! git cat-file -e "${head_ref}^{commit}" 2>/dev/null; then
    echo "ERROR: head ref does not exist locally: ${head_ref}"
    exit 1
  fi

  if ! git cat-file -e "${base_ref}^{commit}" 2>/dev/null; then
    echo "WARNING: base ref does not exist locally: ${base_ref}"
    echo "Falling back to: ${head_ref}^"
    base_ref="$(git rev-parse "${head_ref}^" 2>/dev/null || true)"
  fi

  if [[ -z "${base_ref}" ]]; then
    echo "ERROR: Unable to determine a valid base ref."
    exit 1
  fi

  echo "Computing delta files for range: ${base_ref}..${head_ref}"
  git diff --name-only "${base_ref}" "${head_ref}" > "${base_dir}/latest_commit_delta.txt"
}

function stageDeltaFiles() {
  cd "${repo_root}"

  echo "=== DELTA FILES FOUND ==="
  cat "${base_dir}/latest_commit_delta.txt" || true
  echo "Total delta files: $(wc -l < "${base_dir}/latest_commit_delta.txt" | tr -d ' ')"
  echo "Class files in delta: $(grep -c '\.cls$' "${base_dir}/latest_commit_delta.txt" || echo 0)"
  echo "Trigger files in delta: $(grep -c '\.trigger$' "${base_dir}/latest_commit_delta.txt" || echo 0)"
  echo "========================="

  rm -rf "${base_dir}/force-app/main/default/lwc/"* || true
  mkdir -p "${base_dir}/force-app/main/default/lwc/"

  echo "Copying delta files from $(pwd) to ${sf_base_dir}..."

  declare -A lwc_parents
  declare -A aura_parents  # ← NEW: track Aura bundles
  while IFS= read -r change; do
    [[ -z "$change" ]] && continue
    echo "Processing file: $change"

    if [[ "$change" == force-app/main/default/lwc/*/* ]]; then
      lwc_parent=$(echo "$change" | awk -F'/' '{print $1"/"$2"/"$3"/"$4"/"$5}')
      lwc_parents["$lwc_parent"]=1
      echo "Marked LWC parent for copying: $lwc_parent"
    elif [[ "$change" == force-app/main/default/aura/*/* ]]; then  # ← NEW
      aura_parent=$(echo "$change" | awk -F'/' '{print $1"/"$2"/"$3"/"$4"/"$5}')
      aura_parents["$aura_parent"]=1
      echo "Marked Aura parent for copying: $aura_parent"
    else
      if [[ -e "$change" ]]; then
        echo "Copying file: $change"
        mkdir -p "${sf_base_dir}/$(dirname "$change")"
        cp "$change" "${sf_base_dir}/$change"

        if [[ -e "${change}-meta.xml" ]]; then
          echo "Copying meta file: ${change}-meta.xml"
          cp "${change}-meta.xml" "${sf_base_dir}/${change}-meta.xml"
        fi
      else
        echo "File not found, might be deleted: $change"
      fi
    fi
  done < "${base_dir}/latest_commit_delta.txt"

  for lwc_parent in "${!lwc_parents[@]}"; do
    if [[ -d "$lwc_parent" ]]; then
      echo "Copying entire LWC folder: $lwc_parent"
      mkdir -p "${sf_base_dir}/$(dirname "$lwc_parent")"
      cp -r "$lwc_parent" "${sf_base_dir}/$lwc_parent"
    fi
  done

  # ← NEW: Copy entire Aura bundle (same as LWC — Salesforce requires the full bundle)
  for aura_parent in "${!aura_parents[@]}"; do
    if [[ -d "$aura_parent" ]]; then
      echo "Copying entire Aura folder: $aura_parent"
      mkdir -p "${sf_base_dir}/$(dirname "$aura_parent")"
      cp -r "$aura_parent" "${sf_base_dir}/$aura_parent"
    fi
  done

  updateMetaxmlfiles

  echo "=== DEPLOYMENT PREPARATION COMPLETE ==="
  echo "Source files copied to: ${sf_base_dir}"
}

##############################################
# MAIN
##############################################

echo "Starting delta deployment preparation..."
generateDeltaFileList
stageDeltaFiles

# Stage destructiveChanges.xml if present in repo manifest
if [[ -f "${repo_root}/manifest/destructiveChanges.xml" ]]; then
  mkdir -p "${base_dir}/manifest"
  cp "${repo_root}/manifest/destructiveChanges.xml" "${base_dir}/manifest/destructiveChanges.xml"

  if [[ -f "${repo_root}/manifest/package.xml" ]]; then
    cp "${repo_root}/manifest/package.xml" "${base_dir}/manifest/package.xml"
  else
    cat > "${base_dir}/manifest/package.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <version>64.0</version>
</Package>
EOF
  fi

  echo "Staged destructiveChanges.xml for deployment."
fi

echo "✅ Delta deployment preparation completed successfully"
