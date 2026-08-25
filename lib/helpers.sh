#!/bin/bash
# ==========================================
# Common Helper Functions
# ==========================================


print_debug()
{
    if [ "$VERBOSE" = true ]; then
        printf '[DEBUG] %s\n' "$1"
    fi
}


section_enabled()
{
    local target="$1"
    local section

    for section in "${SELECTED_SECTIONS[@]}"
    do
        if [ "$section" = "$target" ]; then
            return 0
        fi
    done

    return 1
}


is_positive_integer()
{
    [[ "$1" =~ ^[1-9][0-9]*$ ]]
}