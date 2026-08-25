#!/bin/bash
# ==========================================
# Report Section: Daily Summary
# ==========================================


section_daily_summary()
{
    ui_section "Daily Summary (last $SUMMARY_DAYS days)"

    print_debug "Daily summary duration: $SUMMARY_DAYS days."

    if ! data_ensure "$SUMMARY_DAYS"; then
        return 1
    fi


    awk \
        -F '\t' \
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
    date = $1
    commits = $2
    insertions = $3
    deletions = $4
    total = $5
    band = $6


    if (band == "grey") {
        stat_color = cg
    } else if (band == "green") {
        stat_color = cgr
    } else if (band == "yellow") {
        stat_color = cy
    } else {
        stat_color = cr
    }


printf "%s : %s%7s%s  [ %d Commits ]  Lines changed [+%d, -%d]\n", \
    date, \
    stat_color, \
    comma(total), \
    cz, \
    commits, \
    insertions, \
    deletions
}
' "$DATA_DAYS_FILE"
}