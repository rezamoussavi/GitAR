#!/usr/bin/env bash

gitar_doctor() {
    local problems=0
    local warnings=0
    local repo_path="${REPO_PATH:-.}"
    local resolved_repo=""
    local command_path=""
    local update_state=""
    local update_checked_at=""
    local update_line=""

    printf '\n'
    printf 'GitAR Environment Check\n'
    printf '\n'

    # --------------------------------------------------
    # GitAR version
    # --------------------------------------------------

    printf '[OK]   GitAR version: %s\n' "${GITAR_VERSION:-unknown}"

    # --------------------------------------------------
    # Bash
    # --------------------------------------------------

    if command -v bash >/dev/null 2>&1; then
        printf '[OK]   Bash found: %s\n' "$(command -v bash)"
    else
        printf '[FAIL] Bash was not found\n'
        problems=$((problems + 1))
    fi

    # --------------------------------------------------
    # Git
    # --------------------------------------------------

    if command -v git >/dev/null 2>&1; then
        printf '[OK]   Git found: %s\n' "$(command -v git)"
    else
        printf '[FAIL] Git was not found\n'
        problems=$((problems + 1))
    fi

    # --------------------------------------------------
    # awk
    # --------------------------------------------------

    if command -v awk >/dev/null 2>&1; then
        printf '[OK]   awk found: %s\n' "$(command -v awk)"
    else
        printf '[FAIL] awk was not found\n'
        problems=$((problems + 1))
    fi

    # --------------------------------------------------
    # GitAR installation
    # --------------------------------------------------

    if [[ -f "$SCRIPT_DIR/.gitar-managed-install" ]]; then
        printf '[OK]   Managed GitAR installation detected\n'
    else
        printf '[INFO] Development or manual GitAR copy\n'
    fi

    # --------------------------------------------------
    # Update-check state
    # --------------------------------------------------

    if [[ -f "$SCRIPT_DIR/.gitar-managed-install" ]]; then
        update_state="$HOME/.local/state/gitar/update-check"

        if [[ -f "$update_state" ]]; then
            while IFS= read -r update_line; do
                case "$update_line" in
                    checked_at=*)
                        update_checked_at="${update_line#checked_at=}"
                        ;;
                esac
            done < "$update_state"

            if [[ -n "$update_checked_at" ]]; then
                printf '[OK]   Last update check: %s\n' "$update_checked_at"
            else
                printf '[INFO] No automatic update check recorded yet\n'
            fi
        else
            printf '[INFO] No automatic update check recorded yet\n'
        fi
    fi

    # --------------------------------------------------
    # Global command
    # --------------------------------------------------

    if command -v gitar >/dev/null 2>&1; then
        command_path="$(command -v gitar)"
        printf '[OK]   gitar command available: %s\n' "$command_path"
    else
        printf '[WARN] gitar is not available globally in PATH\n'
        warnings=$((warnings + 1))
    fi

    # --------------------------------------------------
    # Default profile
    # --------------------------------------------------

    if [[ -f "$SCRIPT_DIR/profiles/default.conf" ]]; then
        printf '[OK]   Default profile found\n'
    else
        printf '[FAIL] Default profile is missing\n'
        problems=$((problems + 1))
    fi

    # --------------------------------------------------
    # Repository
    # --------------------------------------------------

    if [[ -d "$repo_path" ]]; then
        if git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            resolved_repo="$(cd "$repo_path" 2>/dev/null && pwd)"
            printf '[OK]   Git repository found: %s\n' "$resolved_repo"
        else
            printf '[WARN] Current location is not a Git repository\n'
            warnings=$((warnings + 1))
        fi
    else
        printf '[FAIL] Repository path does not exist: %s\n' "$repo_path"
        problems=$((problems + 1))
    fi

    # --------------------------------------------------
    # Summary
    # --------------------------------------------------

    printf '\n'

    if (( problems > 0 )); then
        printf 'GitAR found %d problem(s)' "$problems"

        if (( warnings > 0 )); then
            printf ' and %d warning(s)' "$warnings"
        fi

        printf '.\n'
        printf '\n'
        printf 'Resolve the problems above before running a report.\n'
        printf '\n'
        return 1
    fi

    if (( warnings > 0 )); then
        printf 'GitAR is installed correctly, with %d warning(s).\n' "$warnings"
        printf '\n'

        if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            printf 'To create a report, move into a Git repository and run:\n'
            printf '\n'
            printf '  gitar\n'
            printf '\n'
        fi

        return 0
    fi

    printf 'Everything looks good.\n'
    printf '\n'
    printf 'GitAR is ready to create a report.\n'
    printf '\n'
    return 0
}