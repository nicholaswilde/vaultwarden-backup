#!/bin/bash

# Use the value of the corresponding environment variable, or the
# default if none exists.
: ${VAULTWARDEN_ROOT:="$(realpath "${0%/*}"/..)"}
: ${SQLITE3:="/usr/bin/sqlite3"}
: ${RCLONE:="/usr/bin/rclone"}
: ${GPG:="/usr/bin/gpg"}
: ${AGE:="/usr/local/bin/age"}
: ${APPRISE:="/usr/bin/apprise"}

# --- Configuration ---
readonly SCRIPT_TAG="vaultwarden-backup"
readonly LOG_FACILITY="local1" # Use local1 facility

readonly DATA_DIR="data"
readonly SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
readonly BACKUP_ROOT="${VAULTWARDEN_ROOT}/$(basename ${SCRIPT_DIR})"
readonly BACKUP_TIMESTAMP="$(date '+%Y%m%d-%H%M')"
readonly BACKUP_DIR_NAME="vaultwarden-${BACKUP_TIMESTAMP}"
readonly BACKUP_DIR_PATH="${BACKUP_ROOT}/${BACKUP_DIR_NAME}"
readonly BACKUP_FILE_DIR="archives"
BACKUP_FILE_NAME="${BACKUP_DIR_NAME}.tar.xz"
BACKUP_FILE_PATH="${BACKUP_ROOT}/${BACKUP_FILE_DIR}/${BACKUP_FILE_NAME}"
readonly DB_FILE="db.sqlite3"

source "${BACKUP_ROOT}"/backup.conf

function command_exists(){
  command -v "${1}" &> /dev/null
}

log_message() {
  local level="$1" # e.g., info, warning, err
  local message="$2"
  echo "$(date '+%Y/%m/%d %H:%M:%S') ${level^^}  : ${message}" 
  logger -p "${LOG_FACILITY}.${level}" -t "$SCRIPT_TAG" -- "$message" 
}

function create_temp_dir(){
  cd "${VAULTWARDEN_ROOT}"
  mkdir -p "${BACKUP_DIR_PATH}"
}

function get_sync_status(){
  if [ -f "${DATA_DIR}/${DB_FILE}" ]; then
    checksum=$(md5sum "${DATA_DIR}/${DB_FILE}" | awk '{print $1}')
    log_message "info" "${DB_FILE}: ${checksum}"
    if [ -f "/tmp/checksum" ]; then
      checksum2=$(cat /tmp/checksum)
      log_message "info" "/tmp/checksum: ${checksum2}"
      if [[ "${checksum}" == "${checksum2}" ]]; then
        log_message "info" "Checksums are the same"
        exit 0
      fi
    fi
  else
    log_message "err" "${DATA_DIR}/${DB_FILE} doesn't exist"
    exit 1
  fi
}

function check_rclone(){
  if ! command_exists rclone; then
    log_message "err" "rclone is not installed"
    exit 1
  fi
}

function check_sqlite(){
  if ! command_exists sqlite3; then
    log_message "err" "sqlite3 is not installed"
    exit 1
  fi
}

function backup_sqlite(){
  local busy_timeout=30000 # in milliseconds
  log_message "info" "Backing up sqlite3"
  ${SQLITE3} -cmd ".timeout ${busy_timeout}" \
             "file:${DATA_DIR}/${DB_FILE}?mode=ro" \
             ".backup '${BACKUP_DIR_PATH}/${DB_FILE}'"
}

function backup_data_files(){
  log_message "info" "Backing up data files"
  backup_files=()
  for f in attachments config.json rsa_key.der rsa_key.pem rsa_key.pub.der rsa_key.pub.pem sends; do
    if [[ -e "${DATA_DIR}"/$f ]]; then
      backup_files+=("${DATA_DIR}"/$f)
    fi
  done
  cp -a "${backup_files[@]}" "${BACKUP_DIR_PATH}"
  tar -cJf "${BACKUP_FILE_PATH}" -C "${BACKUP_ROOT}" "${BACKUP_DIR_NAME}"
  rm -rf "${BACKUP_DIR_PATH}"
}

function encrypt_files(){
  if [[ -n ${GPG_FINGERPRINT} ]]; then
    log_message "info" "Encrypting files"
    ${GPG} --yes --batch -e -r "${GPG_FINGERPRINT}" --cipher-algo "${GPG_CIPHER_ALGO}" "${BACKUP_FILE_PATH}"
    BACKUP_FILE_NAME+=".gpg"
    BACKUP_FILE_PATH+=".gpg"
  elif [[ -n ${GPG_PASSPHRASE} ]]; then
    # https://gnupg.org/documentation/manuals/gnupg/GPG-Esoteric-Options.html
    # Note: Add `--pinentry-mode loopback` if using GnuPG 2.1.
    log_message "info" "Encrypting files"
    printf '%s' "${GPG_PASSPHRASE}" |
    ${GPG} --yes -c --cipher-algo "${GPG_CIPHER_ALGO}" --batch --passphrase-fd 0 "${BACKUP_FILE_PATH}"
    BACKUP_FILE_NAME+=".gpg"
    BACKUP_FILE_PATH+=".gpg"
  elif [[ -n ${AGE_FILE_PATH} ]]; then
    log_message "info" "Encrypting files"
    ${AGE} -e -i ${AGE_FILE_PATH} -o "${BACKUP_FILE_PATH}.age" "${BACKUP_FILE_PATH}"
    BACKUP_FILE_NAME+=".age"
    BACKUP_FILE_PATH+=".age"
  elif [[ -n ${AGE_PASSPHRASE} ]]; then
    log_message "info" "Encrypting files"
    export AGE_PASSPHRASE
    ${AGE} -p -o "${BACKUP_FILE_PATH}.age" "${BACKUP_FILE_PATH}"
    BACKUP_FILE_NAME+=".age"
    BACKUP_FILE_PATH+=".age"
  fi
  export BACKUP_FILE_NAME
  export BACKUP_FILE_PATH
}

function rclone_copy(){
  log_message "info" "Copying to remote using rclone"
  success=0
  for dest in "${RCLONE_DESTS[@]}"; do
    if ${RCLONE} --syslog -vv --no-check-dest copy "${BACKUP_FILE_PATH}" "${dest}"; then
      (( success++ ))
    fi
  done
  export success
}

function send_notification(){
  local message="$1"
  if command -v "${APPRISE}" > /dev/null 2>&1 && [[ -n "${APPRISE_EMAIL+x}" ]]; then
    log_message "info" "Sending notification"
    "${APPRISE}" \
      -t "[$(hostname)] ${BACKUP_FILE_NAME}" \
      -b "${message}" \
      "${APPRISE_EMAIL}"
  fi
}

function show_status(){
  if [[ ${success} == ${#RCLONE_DESTS[@]} ]]; then
    log_message "info" "Backup successfully copied to all destinations."
    send_notification "Backup successfully copied to all destinations."
    echo "${checksum}" > /tmp/checksum
    exit 0
  else
    log_message "err" "Backup successfully copied to ${success} of ${#RCLONE_DESTS[@]} destinations."
    send_notification "Backup successfully copied to ${success} of ${#RCLONE_DESTS[@]} destinations."
    exit 1
  fi  
}

function main(){
  create_temp_dir
  get_sync_status
  check_rclone
  check_sqlite
  backup_sqlite
  backup_data_files
  encrypt_files
  rclone_copy
  show_status
}

main "@"
