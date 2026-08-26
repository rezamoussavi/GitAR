#!/usr/bin/env bash

gitar_update() {
    local install_marker="$SCRIPT_DIR/.gitar-managed-install"
    local current_version
    local new_version
    local local_commit
    local remote_commit

    printf '\n'
    printf 'GitAR Update\n'
    printf '\n'

    # Only installations created by install.sh may self-update.
    if [[ ! -f "$install_marker" ]]; then
        printf 'This GitAR copy is not a managed installation.\n'
        printf '\n'
        printf 'Self-update is intended for GitAR installations created by install.sh.\n'
        printf '\n'

        if [[ "$SCRIPT_DIR" != "$HOME/.local/share/gitar" ]]; then
            printf 'You appear to be running a development or manually cloned copy.\n'
            printf 'Update that copy with Git instead.\n'
        fi

        printf '\n'
        return 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        printf 'ERROR: Git is required to update GitAR.\n'
        printf '\n'
        return 1
    fi

    if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
        printf 'ERROR: The GitAR installation is not a Git repository.\n'
        printf '\n'
        return 1
    fi

    if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
        current_version="$(<"$SCRIPT_DIR/VERSION")"
    else
        current_version="unknown"
    fi

    printf 'Current version: %s\n' "$current_version"
    printf 'Checking for updates...\n'
    printf '\n'

    # Managed installations should never contain user modifications.
    if [[ -n "$(git -C "$SCRIPT_DIR" status --porcelain)" ]]; then
        printf 'ERROR: The GitAR installation contains local changes.\n'
        printf '\n'
        printf 'Update was stopped to avoid overwriting files.\n'
        printf '\n'
        return 1
    fi

    if ! git -C "$SCRIPT_DIR" fetch origin main --quiet; then
        printf 'ERROR: Could not contact the GitAR repository.\n'
        printf '\n'
        return 1
    fi

    local_commit="$(git -C "$SCRIPT_DIR" rev-parse HEAD)"
    remote_commit="$(git -C "$SCRIPT_DIR" rev-parse origin/main)"

    if [[ "$local_commit" == "$remote_commit" ]]; then
        printf 'GitAR is already up to date.\n'
        printf '\n'
        printf 'Version: %s\n' "$current_version"
        printf '\n'
        return 0
    fi

    printf 'Update available.\n'
    printf 'Installing...\n'
    printf '\n'

    if ! git -C "$SCRIPT_DIR" merge --ff-only origin/main; then
        printf '\n'
        printf 'ERROR: GitAR could not be updated safely.\n'
        printf '\n'
        return 1
    fi

    chmod +x "$SCRIPT_DIR/gitar" 2>/dev/null || true

    if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
        new_version="$(<"$SCRIPT_DIR/VERSION")"
    else
        new_version="unknown"
    fi

    printf '\n'
    printf 'GitAR updated successfully.\n'
    printf '\n'
    printf 'Previous version: %s\n' "$current_version"
    printf 'Current version : %s\n' "$new_version"
    printf '\n'
}

gitar_check_for_update() {
    local install_marker="$SCRIPT_DIR/.gitar-managed-install"
    local state_dir="$HOME/.local/state/gitar"
    local state_file="$state_dir/update-check"
    local current_month
    local current_timestamp
    local last_month=""
    local line
    local local_commit
    local remote_commit
    local fetch_ok=false

    # Background checks only apply to installations created by install.sh.
    [[ -f "$install_marker" ]] || return 0

    # A background update check must never interfere with normal reports.
    command -v git >/dev/null 2>&1 || return 0
    [[ -d "$SCRIPT_DIR/.git" ]] || return 0

    current_month="$(date '+%Y-%m')" || return 0

    # Read the month of the previous check.
    if [[ -f "$state_file" ]]; then
        while IFS= read -r line; do
            case "$line" in
                month=*)
                    last_month="${line#month=}"
                    ;;
            esac
        done < "$state_file"
    fi

    # Already checked during this calendar month.
    if [[ "$last_month" == "$current_month" ]]; then
        return 0
    fi

    mkdir -p "$state_dir" 2>/dev/null || return 0

    # Try the network check silently.
    #
    # Failure must never prevent GitAR from producing a report.
    if git -C "$SCRIPT_DIR" fetch origin main --quiet 2>/dev/null; then
        fetch_ok=true
    fi

    # Record exactly when this check attempt happened.
    current_timestamp="$(date '+%Y-%m-%d %H:%M:%S')" || return 0

    {
        printf 'month=%s\n' "$current_month"
        printf 'checked_at=%s\n' "$current_timestamp"
    } > "$state_file" 2>/dev/null || true

    # Do not inspect a stale origin/main if fetch failed.
    [[ "$fetch_ok" == true ]] || return 0

    local_commit="$(git -C "$SCRIPT_DIR" rev-parse HEAD 2>/dev/null)" || return 0
    remote_commit="$(git -C "$SCRIPT_DIR" rev-parse origin/main 2>/dev/null)" || return 0

    if [[ "$local_commit" != "$remote_commit" ]]; then
        printf '\n'
        printf 'GitAR update available.\n'
        printf 'Run: gitar --update\n'
        printf '\n'
    fi

    return 0
}

gitar_last_update_check() {
    local state_file="$HOME/.local/state/gitar/update-check"
    local line
    local checked_at=""

    [[ -f "$state_file" ]] || return 1

    while IFS= read -r line; do
        case "$line" in
            checked_at=*)
                checked_at="${line#checked_at=}"
                ;;
        esac
    done < "$state_file"

    [[ -n "$checked_at" ]] || return 1

    printf '%s\n' "$checked_at"
}