#!/bin/bash
# ==========================================
# Report Section Manager
# ==========================================


section_function_name()
{
    local section_name="$1"

    section_name="${section_name//-/_}"

    printf 'section_%s' "$section_name"
}


validate_section_name()
{
    case "$1" in
        header|sync|commits|daily-summary|statistics)
            return 0
            ;;

        *)
            return 1
            ;;
    esac
}


load_section()
{
    local section_name="$1"
    local section_file="$SCRIPT_DIR/sections/${section_name}.sh"

    if ! validate_section_name "$section_name"; then
        ui_error "Unknown report section: $section_name"
        return 1
    fi

    if [ ! -f "$section_file" ]; then
        ui_error "Section file not found: $section_file"
        return 1
    fi

    source "$section_file"
}


run_section()
{
    local section_name="$1"
    local function_name

    if [ "$section_name" = "sync" ] && [ "$DO_SYNC" != true ]; then
        print_debug "Skipping sync section because --no-sync was specified."
        return 0
    fi

    load_section "$section_name" || return 1

    function_name="$(section_function_name "$section_name")"

    if ! declare -F "$function_name" >/dev/null 2>&1; then
        ui_error "Section '$section_name' does not implement $function_name()."
        return 1
    fi

    print_debug "Running section: $section_name"

    "$function_name"
}


run_selected_sections()
{
    local section_name

    for section_name in "${SELECTED_SECTIONS[@]}"
    do
        run_section "$section_name" || return 1
    done
}