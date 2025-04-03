#!/bin/bash

# Use the value of the corresponding environment variable, or the
# default if none exists.
: ${VAULTWARDEN_ROOT:="$(realpath "${0%/*}"/..)"}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BACKUP_ROOT="${VAULTWARDEN_ROOT}/$(basename ${SCRIPT_DIR})"
BACKUP_LOGS="${BACKUP_ROOT}/logs"
BACKUP_TIMESTAMP="$(date '+%Y%m%d-%H%M')"
APPRISE="${HOME}/.local/bin/apprise"

source "${BACKUP_ROOT}"/backup.conf

if "${BACKUP_ROOT}"/backup.sh >"${BACKUP_ROOT}"/backup.log 2>&1; then
    RESULT="success"
    EXITCODE=0
else
    RESULT="failure"
    EXITCODE=1
fi

cp -a "${BACKUP_ROOT}"/backup.log "${BACKUP_LOGS}"/backup-${RESULT}-${BACKUP_TIMESTAMP}.log

if command -v "${APPRISE}" > /dev/null 2>&1 && [[ -n "${!APPRISE_EMAIL}" ]]; then
  "${APPRISE}" -t '[$(hostname)]-${RESULT}-${BACKUP_TIMESTAMP}' -b '"${RESULT}-${BACKUP_TIMESTAMP}"' '"${APPRISE_EMAIL}"'
fi

exit ${EXITCODE}
