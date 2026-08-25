#!/bin/bash
# ==========================================
# Report Section: Commit Details
# ==========================================


section_commits()
{
    ui_section "Commit Details (last $COMMITS_DAYS days)"

    print_debug "Commit detail duration: $COMMITS_DAYS days."

    if ! data_ensure "$COMMITS_DAYS"; then
        return 1
    fi


    awk \
        -F '\t' \
        -v cc="$C_CYAN" \
        -v cp="$C_PURPLE" \
        -v cg="$C_GREY" \
        -v cgr="$C_GREEN" \
        -v cy="$C_YELLOW" \
        -v cr="$C_RED" \
        -v cz="$C_RESET" '

function comma(num, result) {
    result = ""

    while (length(num) > 3) {
        result = "," substr(num, length(num) - 2, 3) result
        num = substr(num, 1, length(num) - 3)
    }

    return num result
}


{
    commit_date = $2
    commit_time = $3
    commit_type = $5

    insertions = $6
    deletions = $7
    total = $8

    subject = $9


    if (last_date != "" && last_date != commit_date) {
        print ""
    }

    last_date = commit_date


    if (commit_type == "feat") {
        message_color = cc
    } else if (commit_type == "fix") {
        message_color = cp
    } else {
        message_color = cz
    }


    if (total < 1000) {
        stat_color = cg
    } else if (total <= 5000) {
        stat_color = cgr
    } else if (total <= 10000) {
        stat_color = cy
    } else {
        stat_color = cr
    }


    printf "%s %s : %s%7s%s : %s%s%s ", \
        commit_date, \
        commit_time, \
        stat_color, \
        comma(total), \
        cz, \
        message_color, \
        subject, \
        cz


    if (total == 0) {
        printf "%s[No changes]%s\n", \
            cg, \
            cz
    } else {
        printf "%s[+%d, -%d]%s\n", \
            stat_color, \
            insertions, \
            deletions, \
            cz
    }
}
' "$DATA_COMMITS_FILE"
}