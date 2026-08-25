#!/bin/bash
# ==========================================
# GitAR - Git Activity Reporter
# Shared Data Layer
# ==========================================
#
# Each duration gets its own cached dataset:
#
#   $DATA_ROOT/7/commits.tsv
#   $DATA_ROOT/7/days.tsv
#
#   $DATA_ROOT/14/commits.tsv
#   $DATA_ROOT/14/days.tsv
#
# Current section-facing variables:
#
#   DATA_COMMITS_FILE
#   DATA_DAYS_FILE
#   DATA_DURATION
# ==========================================


DATA_ROOT=""

DATA_COMMITS_FILE=""
DATA_DAYS_FILE=""
DATA_DURATION=""


# ------------------------------------------
# Cleanup
# ------------------------------------------

data_cleanup()
{
    if [ -n "$DATA_ROOT" ] && [ -d "$DATA_ROOT" ]; then
        rm -rf "$DATA_ROOT"
    fi

    DATA_ROOT=""

    DATA_COMMITS_FILE=""
    DATA_DAYS_FILE=""
    DATA_DURATION=""
}


# ------------------------------------------
# Root temp directory
# ------------------------------------------

data_prepare_root()
{
    if [ -n "$DATA_ROOT" ] && [ -d "$DATA_ROOT" ]; then
        return 0
    fi

    DATA_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/gitar.XXXXXX")" || {
        ui_error "Unable to create temporary report-data directory."
        return 1
    }

    print_debug "Data root: $DATA_ROOT"

    return 0
}


# ------------------------------------------
# Resolve paths for a duration
# ------------------------------------------

data_set_duration_paths()
{
    local duration="$1"
    local duration_dir

    duration_dir="$DATA_ROOT/$duration"

    DATA_DURATION="$duration"
    DATA_COMMITS_FILE="$duration_dir/commits.tsv"
    DATA_DAYS_FILE="$duration_dir/days.tsv"
}


# ------------------------------------------
# Prepare one duration directory
# ------------------------------------------

data_prepare_duration()
{
    local duration="$1"
    local duration_dir

    data_prepare_root || return 1

    duration_dir="$DATA_ROOT/$duration"

    if [ ! -d "$duration_dir" ]; then
        mkdir -p "$duration_dir" || {
            ui_error "Unable to create dataset directory for $duration days."
            return 1
        }
    fi

    data_set_duration_paths "$duration"

    return 0
}


# ------------------------------------------
# Commit dataset
# ------------------------------------------

data_generate_commits()
{
    local duration="$1"

    local since_date

    since_date="$(date -d "$((duration - 1)) days ago" '+%Y-%m-%d 00:00:00')" || {
        ui_error "Unable to calculate report start date."
        return 1
    }

    git -C "$REPO_PATH" log \
        --all \
        --since="$since_date" \
        --format="__COMMIT__%x1f%H%x1f%cd%x1f%ct%x1f%s" \
        --date=format:'%Y-%m-%d %H:%M' \
        --numstat |
    awk \
        -v output="$DATA_COMMITS_FILE" '

BEGIN {
    US = "\037"
    have_commit = 0
}


function classify(subject) {
    if (subject ~ /^feat:/ || subject ~ /^feat\([^)]*\):/) {
        return "feat"
    }

    if (subject ~ /^fix:/ || subject ~ /^fix\([^)]*\):/) {
        return "fix"
    }

    return "other"
}


function clean_subject(subject) {
    gsub(/\t/, " ", subject)
    gsub(/\r/, " ", subject)

    return subject
}


function emit_commit(total) {
    if (!have_commit) {
        return
    }

    total = insertions + deletions

    printf "%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%s\n", \
        hash, \
        commit_date, \
        commit_time, \
        epoch, \
        commit_type, \
        insertions, \
        deletions, \
        total, \
        clean_subject(subject) >> output
}


/^__COMMIT__/ {
    emit_commit()

    split($0, fields, US)

    hash = fields[2]

    split(fields[3], datetime_parts, " ")

    commit_date = datetime_parts[1]
    commit_time = datetime_parts[2]

    epoch = fields[4]
    subject = fields[5]

    commit_type = classify(subject)

    insertions = 0
    deletions = 0

    have_commit = 1

    next
}


{
    if (!have_commit) {
        next
    }

    split($0, stat, "\t")

    if (stat[1] ~ /^[0-9]+$/) {
        insertions += stat[1]
    }

    if (stat[2] ~ /^[0-9]+$/) {
        deletions += stat[2]
    }
}


END {
    emit_commit()
}
'

    local pipeline_status=("${PIPESTATUS[@]}")

    if [ "${pipeline_status[0]}" -ne 0 ]; then
        print_debug "git log failed with status ${pipeline_status[0]}."
        return "${pipeline_status[0]}"
    fi

    if [ "${pipeline_status[1]}" -ne 0 ]; then
        print_debug "Commit-data parser failed with status ${pipeline_status[1]}."
        return "${pipeline_status[1]}"
    fi

    return 0
}


# ------------------------------------------
# Daily dataset
# ------------------------------------------

data_generate_days()
{
    awk \
        -F '\t' \
        -v output="$DATA_DAYS_FILE" '

{
    date = $2

    if (!(date in seen)) {
        seen[date] = 1
        order[++day_count] = date

        commits[date] = 0
        insertions[date] = 0
        deletions[date] = 0
    }

    commits[date]++
    insertions[date] += $6
    deletions[date] += $7
}


END {
    for (i = 1; i <= day_count; i++) {
        date = order[i]

        total = insertions[date] + deletions[date]

        if (total < 1000) {
            band = "grey"
        } else if (total <= 5000) {
            band = "green"
        } else if (total <= 10000) {
            band = "yellow"
        } else {
            band = "red"
        }

        printf "%s\t%d\t%d\t%d\t%d\t%s\n", \
            date, \
            commits[date], \
            insertions[date], \
            deletions[date], \
            total, \
            band >> output
    }
}
' "$DATA_COMMITS_FILE"
}


# ------------------------------------------
# Build one duration
# ------------------------------------------

data_build()
{
    local duration="$1"

    print_debug "Building normalized dataset for $duration days."

    data_prepare_duration "$duration" || return 1

    : > "$DATA_COMMITS_FILE"
    : > "$DATA_DAYS_FILE"


    if ! ui_run \
        "Building Git activity data ($duration days)" \
        data_generate_commits "$duration"
    then
        ui_error "Unable to build $duration-day commit dataset."
        return 1
    fi


    if ! data_generate_days; then
        ui_error "Unable to build $duration-day daily dataset."
        return 1
    fi


    print_debug "Commit dataset: $DATA_COMMITS_FILE"
    print_debug "Daily dataset: $DATA_DAYS_FILE"

    return 0
}


# ------------------------------------------
# Ensure one duration exists
# ------------------------------------------

data_ensure()
{
    local duration="$1"

    data_prepare_root || return 1

    data_set_duration_paths "$duration"


    if [ -f "$DATA_COMMITS_FILE" ] &&
       [ -f "$DATA_DAYS_FILE" ]; then

        print_debug "Reusing existing $duration-day dataset."
        return 0
    fi


    data_build "$duration"
}