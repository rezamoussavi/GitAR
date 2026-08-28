#!/bin/bash
# ==========================================
# Report Section: Header
# ==========================================


section_header()
{
    local report_date
    local last_update_check=""

    report_date="$(date '+%Y-%m-%d %H:%M')"

    if [[ -f "$SCRIPT_DIR/.gitar-managed-install" ]]; then
        last_update_check="$(gitar_last_update_check 2>/dev/null || true)"
    fi

    # ------------------------------------------
    # Optional author / legend presentation
    # ------------------------------------------

    if [ "$SHOW_LEGEND" = true ]; then

        printf '\n'
        printf '     =================================\n'
        printf '     ===                           ===\n'
        printf '     ===           GitAR           ===\n'
        printf '     ===   Git Activity Reporter   ===\n'
        printf '     ===                           ===\n'
        printf '     ===     By: Reza Moussavi     ===\n'
        printf '     ===                           ===\n'
        printf '     =================================\n'

        printf '\n--- Description Legend ---\n'
        printf '%bfeat%b : Cyan\n' "$C_CYAN" "$C_RESET"
        printf '%bfix%b  : Purple\n' "$C_PURPLE" "$C_RESET"
        printf 'Other : Terminal Default\n'

        printf '\n--- Change Size Legend ---\n'

        printf '%b[+X, -Y]%b : Less than 1,000 lines changed\n' \
            "$C_GREY" "$C_RESET"

        printf '%b[+X, -Y]%b : 1,000 to 5,000 lines changed\n' \
            "$C_GREEN" "$C_RESET"

        printf '%b[+X, -Y]%b : 5,000 to 10,000 lines changed\n' \
            "$C_YELLOW" "$C_RESET"

        printf '%b[+X, -Y]%b : More than 10,000 lines changed\n' \
            "$C_RED" "$C_RESET"

        printf '\n'
    fi


    # ------------------------------------------
    # Normal report metadata
    # ------------------------------------------

    printf 'Timestamp : %s\n' "$report_date"

    if [[ -n "$last_update_check" ]]; then
        printf 'GitAR     : update checked %s\n' "$last_update_check"
    fi

    printf 'Customize : gitar -h\n'

    if [ "$ACTIVE_PROFILE" != "default" ]; then
        printf 'Profile   : %s\n' "$ACTIVE_PROFILE"
    fi
}