#!/usr/bin/env sh
#
# Sentry error reporting for postgresql-backup-restore-fs scripts.
# This file should be sourced, not executed directly.

# Replace password values in a message so they are never sent to Sentry.
# Usage: filtered=$(filter_sensitive_values "message")
filter_sensitive_values() {
    msg="$1"
    for val in "${DB_ROOTPASSWORD}" "${DB_USERPASSWORD}"; do
        if [ -n "${val}" ]; then
            msg="${msg//"${val}"/[FILTERED]}"
        fi
    done
    echo "${msg}"
}

# Send an error event to Sentry. Does nothing if SENTRY_DSN is not set.
# Never fails, so it cannot change the exit status of the calling script.
# Usage: error_to_sentry "error message" "database_name" "status_code"
error_to_sentry() {
    error_message=$(filter_sensitive_values "$1")
    db_name="$2"
    status_code="$3"

    if [ -z "${SENTRY_DSN}" ]; then
        return 0
    fi

    # Expected format: https://key@host/project_id
    if ! echo "${SENTRY_DSN}" | grep -Eq '^https://[^@]+@[^/]+/[0-9]+$'; then
        echo "${MYNAME}: WARN: Invalid SENTRY_DSN format - Sentry logging skipped"
        return 0
    fi

    if sentry-cli send-event \
        --message "${MYNAME}: ${error_message}" \
        --level error \
        --tag "database:${db_name}" \
        --tag "status:${status_code}" > /dev/null; then
        echo "${MYNAME}: INFO: Error sent to Sentry"
    else
        echo "${MYNAME}: WARN: Failed to send error to Sentry"
    fi

    return 0
}

# Log a fatal error, report it to Sentry, and exit.
# Usage: fatal "error message" exit_code
fatal() {
    echo "${MYNAME}: FATAL: $1"
    error_to_sentry "$1" "${DB_NAME}" "$2"
    exit "$2"
}
