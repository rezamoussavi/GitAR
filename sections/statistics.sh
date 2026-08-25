#!/bin/bash
# ==========================================
# Report Section: Statistics
# ==========================================


section_statistics()
{
    ui_section "Statistics (last $SUMMARY_DAYS days)"

    print_debug "Statistics duration: $SUMMARY_DAYS days."

    if ! data_ensure "$SUMMARY_DAYS"; then
        return 1
    fi


    # ------------------------------------------
    # Commit-level statistics
    # ------------------------------------------

    awk \
        -F '\t' '

function comma(num, result) {
    result = ""

    while (length(num) > 3) {
        result = "," substr(num, length(num) - 2, 3) result
        num = substr(num, 1, length(num) - 3)
    }

    return num result
}


{
    commits++

    type = $5
    insertions = $6
    deletions = $7
    total = $8

    total_insertions += insertions
    total_deletions += deletions


    if (type == "feat") {
        features++
    } else if (type == "fix") {
        fixes++
    } else {
        others++
    }


    if (total > largest_commit) {
        largest_commit = total
        largest_commit_date = $2
        largest_commit_time = $3
        largest_commit_subject = $9
    }
}


END {
    printf "Total commits             : %s\n", comma(commits)

    printf "\n"

    printf "Features                  : %s\n", comma(features)
    printf "Fixes                     : %s\n", comma(fixes)
    printf "Other                     : %s\n", comma(others)

    printf "\n"

    printf "Lines added               : %s\n", comma(total_insertions)
    printf "Lines deleted             : %s\n", comma(total_deletions)
    printf "Total lines changed       : %s\n", \
        comma(total_insertions + total_deletions)

    printf "\n"

    printf "Largest commit            : %s lines\n", \
        comma(largest_commit)

    printf "Largest commit date       : %s %s\n", \
        largest_commit_date, \
        largest_commit_time

    printf "Largest commit message    : %s\n", \
        largest_commit_subject
}
' "$DATA_COMMITS_FILE"


    printf '\n'


    # ------------------------------------------
    # Daily statistics
    # ------------------------------------------

    awk \
        -F '\t' \
        -v cg="$C_GREY" \
        -v cgr="$C_GREEN" \
        -v cy="$C_YELLOW" \
        -v cr="$C_RED" \
        -v cz="$C_RESET" \
        -v period="$SUMMARY_DAYS" '

function comma(num, result) {
    result = ""

    while (length(num) > 3) {
        result = "," substr(num, length(num) - 2, 3) result
        num = substr(num, 1, length(num) - 3)
    }

    return num result
}


function day_word(num) {
    if (num == 1) {
        return "day"
    }

    return "days"
}


{
    date = $1
    commits = $2
    total = $5
    band = $6

    active_days++
    total_commits += commits
    total_changed += total


    if (commits > largest_commit_count) {
        largest_commit_count = commits
        largest_commit_day = date
    }


    if (total > largest_day_total) {
        largest_day_total = total
        largest_day_date = date
    }


    if (band == "grey") {
        grey_days++
    } else if (band == "green") {
        green_days++
    } else if (band == "yellow") {
        yellow_days++
    } else if (band == "red") {
        red_days++
    }
}


END {
    if (active_days > 0) {
        average_commits = total_commits / active_days
        average_lines = total_changed / active_days
    } else {
        average_commits = 0
        average_lines = 0
    }


    printf "Period                    : %d days\n", period
    printf "Active days               : %s\n", comma(active_days)

    printf "Average commits / day     : %.2f\n", \
        average_commits

    printf "Most commits in one day   : %s (%s)\n", \
        comma(largest_commit_count), \
        largest_commit_day

    printf "Average lines / active day: %s\n", \
        comma(int(average_lines))

    printf "Largest day               : %s lines (%s)\n", \
        comma(largest_day_total), \
        largest_day_date

    printf "\n"

    printf "Daily workload\n"

    printf "  Grey   < 1,000         : %s%s %s%s\n", cg, comma(grey_days), day_word(grey_days), cz
    printf "  Green  1,000 - 5,000   : %s%s %s%s\n", cgr, comma(green_days), day_word(green_days), cz
    printf "  Yellow 5,001 - 10,000  : %s%s %s%s\n", cy, comma(yellow_days), day_word(yellow_days), cz
    printf "  Red    > 10,000        : %s%s %s%s\n", cr, comma(red_days), day_word(red_days), cz
}
' "$DATA_DAYS_FILE"
}
