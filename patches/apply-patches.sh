#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Zikri Afnan <zmafnan@aristotle>
# SPDX-License-Identifier: Apache-2.0
#
# apply-patches.sh — Apply device-tree patches to upstream source trees.
#
# Called from device.mk via:
#   $(shell bash device/xiaomi/aristotle/patches/apply-patches.sh)
#
# The Makefile invokes this from the Android build root (infinity/), so
# $PWD == <android-root> when this script runs.
#
# Patch filenames encode the target repo path with '/' replaced by '_':
#   packages_modules_Connectivity.patch  →  packages/modules/Connectivity/
#
# Add new entries to REPO_MAP below whenever a new patch is added.
# Patches are applied with `git apply`. Already-applied patches are
# detected via `git apply --check` and silently skipped (idempotent).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# When called from device.mk, $PWD is the Android build root (infinity/).
# When called manually, the user should `cd <android-root>` first.
ANDROID_ROOT="${PWD}"

# -------------------------------------------------------------------------
# REPO_MAP: patch basename (without .patch) → repo path inside ANDROID_ROOT
# -------------------------------------------------------------------------
declare -A REPO_MAP=(
    ["packages_modules_Connectivity"]="packages/modules/Connectivity"
    ["frameworks_base"]="frameworks/base"
    ["system_netd"]="system/netd"
    ["packages_apps_Settings"]="packages/apps/Settings"
    ["hardware_mediatek"]="hardware/mediatek"
    ["frameworks_av"]="frameworks/av"
    ["system_media"]="system/media"
)

apply_patch() {
    local patch_file="$1"
    local patch_basename
    patch_basename="$(basename "${patch_file}" .patch)"

    local repo_path="${REPO_MAP[${patch_basename}]:-}"

    if [[ -z "${repo_path}" ]]; then
        echo "[WARN] No REPO_MAP entry for '${patch_basename}', skipping." >&2
        return 0
    fi

    local target="${ANDROID_ROOT}/${repo_path}"

    if [[ ! -d "${target}" ]]; then
        echo "[WARN] Target '${repo_path}' not found in build root '${ANDROID_ROOT}', skipping." >&2
        return 0
    fi

    if [[ ! -d "${target}/.git" ]]; then
        echo "[WARN] '${repo_path}' is not a git repo, skipping '${patch_basename}'." >&2
        return 0
    fi

    # Dry-run: if --check fails, the patch was already applied → skip silently.
    if git -C "${target}" apply --check "${patch_file}" 2>/dev/null; then
        git -C "${target}" apply "${patch_file}"
        echo "[INFO] Applied: ${patch_basename} → ${repo_path}" >&2
    else
        echo "[INFO] Already applied: ${patch_basename} (skipping)" >&2
    fi
}

echo "=== Applying aristotle device-tree patches (root: ${ANDROID_ROOT}) ===" >&2
for f in "${SCRIPT_DIR}"/*.patch; do
    [[ -f "${f}" ]] || continue
    apply_patch "${f}"
done
echo "=== Done ===" >&2
