#!/bin/bash
# ==========================================
# GitAR - Git Activity Reporter
# Preflight Validation
# ==========================================


preflight_check_git()
{
    if ! command -v git >/dev/null 2>&1; then
        ui_error "Git is not installed or is not available in PATH."
        return 1
    fi

    print_debug "Git executable: $(command -v git)"

    return 0
}


preflight_check_repo_path()
{
    if [ -z "$REPO_PATH" ]; then
        ui_error "REPO_PATH is not configured."
        return 1
    fi

    if [ ! -d "$REPO_PATH" ]; then
        ui_error "Repository directory does not exist:"
        printf '  %s\n' "$REPO_PATH" >&2
        return 1
    fi

    return 0
}


preflight_check_git_repo()
{
    if ! git -C "$REPO_PATH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        printf '\n'
        printf 'GitAR could not find a Git repository here.\n'
        printf '\n'
        printf 'Current location:\n'
        printf '  %s\n' "$(pwd)"
        printf '\n'
        printf 'Move into the folder containing your Git project, for example:\n'
        printf '\n'
        printf '  cd /path/to/your-project\n'
        printf '  gitar\n'
        printf '\n'
        printf 'Tip: a Git repository usually contains a hidden .git folder.\n'
        printf '\n'
        return 1
    fi

    return 0
}


run_preflight_checks()
{
    print_debug "Running preflight checks."

    preflight_check_git || return 1
    preflight_check_repo_path || return 1
    preflight_check_git_repo || return 1

    print_debug "Preflight checks passed."

    return 0
}