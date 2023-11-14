#!/usr/bin/env dry-wit
# Copyright 2023-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

DW.import nix-flake;

# fun: main
# api: public
# txt: Main logic. Gets called by dry-wit.
# txt: Returns 0/TRUE always, but may exit due to errors.
# use: main
function main() {
  local _org;
  logDebug -n "Extracting org from ${FLAKE_FILE}";
  if extract_org "${FLAKE_FILE}"; then
    _org="${RESULT}";
    logDebugResult SUCCESS "${_org}";
  else
    logDebugResult FAILURE "error";
    exitWithErrorCode CANNOT_EXTRACT_ORG_FROM_FLAKE "${_flakeFile}";
  fi

  local _repo;
  logDebug -n "Extracting repo from ${FLAKE_FILE}";
  if extract_repo "${FLAKE_FILE}"; then
    _repo="${RESULT}";
    logDebugResult SUCCESS "${_repo}";
  else
    logDebugResult FAILURE "error";
    exitWithErrorCode CANNOT_EXTRACT_REPO_FROM_FLAKE "${_flakeFile}";
  fi

  local -i _updateSha256=${FALSE};
  DW.import file;

  if fileContains "${FLAKE_FILE}" "sha256 ="; then
    _updateSha256=${TRUE};
  fi

  logDebug -n "Updating version in ${FLAKE_FILE}";
  if update_version_in_flake "${FLAKE_FILE}" "${PROJECT_VERSION}"; then
    logDebugResult SUCCESS "done";
  else
    logDebugResult FAILURE "error";
    exitWithErrorCode CANNOT_UPDATE_VERSION_IN_FLAKE "${_FLAKE_FILE} ${PROJECT_VERSION}";
  fi

  if isTrue ${_updateSha256}; then
    local _sha256;
    local _url="https://github.com/${_org}/${_repo}";
    logDebug -n "Fetching sha256 of ${_url}, rev ${PROJECT_VERSION}"
    if fetch_sha256 "${_url}" "${PROJECT_VERSION}"; then
      _sha256="${RESULT}";
      logDebugResult SUCCESS "${_sha256}";
    else
      logDebugResult FAILURE "error";
      exitWithErrorCode CANNOT_FETCH_SHA256_FROM_URL "${_url} ${PROJECT_VERSION}";
    fi

    logDebug -n "Updating sha256 in ${FLAKE_FILE}";
    if update_sha256_in_flake "${FLAKE_FILE}" "${_sha256}"; then
      logDebugResult SUCCESS "done";
    else
      logDebugResult FAILURE "error";
      exitWithErrorCode CANNOT_UPDATE_SHA256_IN_FLAKE "${_FLAKE_FILE} ${_sha256}";
    fi
  fi

  if isTrue ${_updateSha256}; then
    logInfo "Updated version and sha256 in ${FLAKE_FILE}"
  else
    logInfo "Updated version in ${FLAKE_FILE}"
  fi
}

## Script metadata and CLI settings.
setScriptDescription "Updates the version and sha256 hash of a PythonEDA-specific Nix flake";
setScriptLicenseSummary "Distributed under the terms of the GNU General Public License v3";
setScriptCopyright "Copyleft 2023-today Automated Computing Machinery S.L.";

addCommandLineFlag "version" "V" "The version" MANDATORY EXPECTS_ARGUMENT;
addCommandLineFlag "flake" "f" "The Nix flake" MANDATORY EXPECTS_ARGUMENT;

checkReq nix-prefetch-git;
checkReq jq;
checkReq sed;
checkReq grep;

addError CANNOT_EXTRACT_ORG_FROM_FLAKE "Cannot extract the 'org' value from ";
addError CANNOT_EXTRACT_REPO_FROM_FLAKE "Cannot extract the 'repo' value from ";
addError CANNOT_FETCH_SHA256_FROM_URL "Cannot fetch the sha256 hash from ";
addError CANNOT_UPDATE_VERSION_IN_FLAKE "Cannot update the 'version' value in ";
addError CANNOT_UPDATE_SHA256_IN_FLAKE "Cannot update the 'sha256' value in ";

function dw_parse_version_cli_flag() {
  export PROJECT_VERSION="${1}";
}

function dw_parse_flake_cli_flag() {
  export FLAKE_FILE="${1}";
}
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
