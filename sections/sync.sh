#!/bin/bash
# ==========================================
# Report Section: Repository Sync
# ==========================================


section_sync()
{
    local branch_name=""
    local upstream=""
    local ahead_count=0
    local behind_count=0
    local working_tree_status=""
    local modified_count=0
    local remote_count=0

    # ------------------------------------------
    # Inspect local repository state
    # ------------------------------------------

    branch_name="$(git -C "$REPO_PATH" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"

    working_tree_status="$(git -C "$REPO_PATH" status --porcelain 2>/dev/null || true)"

    if [ -n "$working_tree_status" ]; then
        modified_count="$(printf '%s\n' "$working_tree_status" | awk 'NF { count++ } END { print count + 0 }')"
    fi

    remote_count="$(git -C "$REPO_PATH" remote 2>/dev/null | awk 'NF { count++ } END { print count + 0 }')"

    printf '\nRepository\n'

    if [ -n "$branch_name" ]; then
        printf '  Branch: %s\n' "$branch_name"
    else
        printf '  Branch: detached HEAD\n'
    fi

    if [ "$modified_count" -eq 0 ]; then
        printf '  Working tree: clean\n'
    elif [ "$modified_count" -eq 1 ]; then
        printf '  Working tree: 1 changed file\n'
    else
        printf '  Working tree: %d changed files\n' "$modified_count"
    fi

    # ------------------------------------------
    # No remote available
    # ------------------------------------------

    if [ "$remote_count" -eq 0 ]; then
        printf '  Remote: no remote configured\n'
        return 0
    fi

    # ------------------------------------------
    # Refresh remote knowledge only
    # ------------------------------------------

    if ! ui_run \
        "Fetching repository" \
        git -C "$REPO_PATH" fetch --all --quiet
    then
        ui_warning "Remote refresh failed."
        return 0
    fi

    # ------------------------------------------
    # Detached HEAD has no branch upstream
    # ------------------------------------------

    if [ -z "$branch_name" ]; then
        printf '  Remote: detached HEAD\n'
        return 0
    fi

    # ------------------------------------------
    # Resolve configured upstream
    # ------------------------------------------

    upstream="$(git -C "$REPO_PATH" rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' 2>/dev/null || true)"

    if [ -z "$upstream" ]; then
        printf '  Remote: no upstream configured\n'
        return 0
    fi

    # ------------------------------------------
    # Compare local branch with configured upstream
    # ------------------------------------------

    read -r behind_count ahead_count < <(
        git -C "$REPO_PATH" rev-list --left-right --count "$upstream...HEAD" 2>/dev/null
    )

    behind_count="${behind_count:-0}"
    ahead_count="${ahead_count:-0}"

    if [ "$ahead_count" -eq 0 ] && [ "$behind_count" -eq 0 ]; then
        printf '  Remote: up to date with %s\n' "$upstream"

    elif [ "$ahead_count" -gt 0 ] && [ "$behind_count" -eq 0 ]; then
        printf '  Remote: %d commit' "$ahead_count"

        if [ "$ahead_count" -ne 1 ]; then
            printf 's'
        fi

        printf ' ahead of %s\n' "$upstream"

    elif [ "$ahead_count" -eq 0 ] && [ "$behind_count" -gt 0 ]; then
        printf '  Remote: %d commit' "$behind_count"

        if [ "$behind_count" -ne 1 ]; then
            printf 's'
        fi

        printf ' behind %s\n' "$upstream"

    else
        printf '  Remote: diverged — %d local / %d remote commits (%s)\n' \
            "$ahead_count" \
            "$behind_count" \
            "$upstream"
    fi

    return 0
}