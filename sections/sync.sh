#!/bin/bash
# ==========================================
# Report Section: Repository Sync
# ==========================================


section_sync()
{
    # ------------------------------------------
    # Fetch remote changes
    # ------------------------------------------

    if ! ui_run \
        "Fetching repository" \
        git -C "$REPO_PATH" fetch --all --quiet
    then
        ui_error "Git fetch failed."
        return 1
    fi


    # ------------------------------------------
    # Protect local uncommitted work
    # ------------------------------------------

    if [ -n "$(git -C "$REPO_PATH" status --porcelain)" ]; then

        ui_warning "Repository has uncommitted local changes."

        printf '  Automatic pull skipped to protect local work.\n'
        printf '  Commit or stash the changes before pulling.\n'

        return 0
    fi


    # ------------------------------------------
    # Safe fast-forward-only pull
    # ------------------------------------------

    if ui_run \
        "Updating local branch" \
        git -C "$REPO_PATH" pull origin main --ff-only --quiet
    then

        ui_success "Repository synchronized"
        return 0

    fi


    # ------------------------------------------
    # Pull was not safe
    # ------------------------------------------

    ui_warning "Automatic pull was skipped."

    printf '  Local commits may need to be pushed, or branches may have diverged.\n'
    printf '  Resolve the Git state manually before pulling.\n'

    return 0
}