#!/bin/bash
# ==========================================
# User Interface Functions
# ==========================================


ui_clear_line()
{
    if [ -t 1 ]; then
        printf '\r\033[2K'
    else
        printf '\r'
    fi
}


ui_start()
{
    local message="$1"

    case "$UI_MODE" in

        dots)
            printf '... %s' "$message"
            ;;

        normal)
            printf '%s\n' "$message"
            ;;

        quiet)
            ;;

    esac
}


ui_success()
{
    local message="$1"

    case "$UI_MODE" in

        dots)
            ui_clear_line
            printf '%b✓%b %s\n' "$C_GREEN" "$C_RESET" "$message"
            ;;

        normal)
            printf '%b✓%b %s\n' "$C_GREEN" "$C_RESET" "$message"
            ;;

        quiet)
            ;;

    esac
}


ui_warning()
{
    ui_clear_line
    printf '%b⚠%b %s\n' "$C_YELLOW" "$C_RESET" "$1"
}


ui_error()
{
    ui_clear_line
    printf '%b✗%b %s\n' "$C_RED" "$C_RESET" "$1" >&2
}


ui_info()
{
    case "$UI_MODE" in

        quiet)
            ;;

        *)
            printf '%s\n' "$1"
            ;;

    esac
}


ui_section()
{
    printf '\n'
    printf '======================================\n'
    printf '%s\n' "$1"
    printf '======================================\n'
}


# ==========================================
# Run command with progress animation
#
# Usage:
#
#   ui_run "Fetching repository" command args...
#
# Returns the real exit status of the command.
# ==========================================

ui_run()
{
    local message="$1"
    shift

    local command_pid
    local command_status
    local dot_count=0
    local max_dots=6


    # ------------------------------------------
    # Quiet mode
    # ------------------------------------------

    if [ "$UI_MODE" = "quiet" ]; then
        "$@"
        return $?
    fi


    # ------------------------------------------
    # Normal mode
    # ------------------------------------------

    if [ "$UI_MODE" = "normal" ]; then

        printf '%s...\n' "$message"

        "$@"
        command_status=$?

        return "$command_status"
    fi


    # ------------------------------------------
    # Dots mode
    # ------------------------------------------

    "$@" &
    command_pid=$!


    while kill -0 "$command_pid" 2>/dev/null
    do
        ui_clear_line

        printf '%s' "$message"

        local i
        for ((i = 0; i < dot_count; i++))
        do
            printf '.'
        done

        dot_count=$((dot_count + 1))

        if [ "$dot_count" -gt "$max_dots" ]; then
            dot_count=1
        fi

        sleep 0.15
    done


    wait "$command_pid"
    command_status=$?


    ui_clear_line

    return "$command_status"
}