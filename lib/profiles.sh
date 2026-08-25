#!/bin/bash
# ==========================================
# GitAR - Git Activity Reporter
# Profile Manager
# ==========================================


ACTIVE_PROFILE="default"

DEFAULT_REPO_PATH=""
DEFAULT_COMMITS_DAYS=""
DEFAULT_SUMMARY_DAYS=""
DEFAULT_UI_MODE=""
DEFAULT_DO_SYNC=""
DEFAULT_SHOW_LEGEND=""
DEFAULT_VERBOSE=false
DEFAULT_SECTIONS=()


profile_error()
{
    printf 'ERROR: %s\n' "$1" >&2
    return 1
}


profile_validate_boolean()
{
    case "$1" in
        true|false)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}


profile_validate_days()
{
    [[ "$1" =~ ^[1-9][0-9]*$ ]]
}


profile_validate_ui()
{
    case "$1" in
        dots|normal|quiet)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}


profile_parse_sections()
{
    local value="$1"
    local section

    if [ -z "$value" ]; then
        profile_error "Profile sections cannot be empty."
        return 1
    fi

    IFS=',' read -r -a SELECTED_SECTIONS <<< "$value"

    for section in "${SELECTED_SECTIONS[@]}"
    do
        if ! validate_section_name "$section"; then
            profile_error "Unknown section in profile: $section"
            return 1
        fi
    done

    return 0
}


profile_apply_file()
{
    local profile_name="$1"
    local profile_file="$SCRIPT_DIR/profiles/${profile_name}.conf"

    local key
    local value

    if [[ ! "$profile_name" =~ ^[A-Za-z0-9_-]+$ ]]; then
        profile_error "Invalid profile name: $profile_name"
        return 1
    fi

    if [ ! -f "$profile_file" ]; then
        profile_error "Profile not found: $profile_name"
        return 1
    fi


    while IFS='=' read -r key value
    do
        # Support Windows-edited profile files.
        key="${key//$'\r'/}"
        value="${value//$'\r'/}"

        # Ignore blank lines and comments.
        case "$key" in
            ""|\#*)
                continue
                ;;
        esac


        case "$key" in

            repo_path)
                if [ -z "$value" ]; then
                    profile_error "Profile '$profile_name': repo_path cannot be empty."
                    return 1
                fi

                REPO_PATH="$value"
                ;;


            sections)
                profile_parse_sections "$value" || return 1
                ;;


            commits_days)
                if ! profile_validate_days "$value"; then
                    profile_error "Profile '$profile_name': commits_days must be a positive whole number."
                    return 1
                fi

                COMMITS_DAYS="$value"
                ;;


            summary_days)
                if ! profile_validate_days "$value"; then
                    profile_error "Profile '$profile_name': summary_days must be a positive whole number."
                    return 1
                fi

                SUMMARY_DAYS="$value"
                ;;


            ui)
                if ! profile_validate_ui "$value"; then
                    profile_error "Profile '$profile_name': invalid UI mode '$value'."
                    return 1
                fi

                UI_MODE="$value"
                ;;


            sync)
                if ! profile_validate_boolean "$value"; then
                    profile_error "Profile '$profile_name': sync must be true or false."
                    return 1
                fi

                DO_SYNC="$value"
                ;;


            legend)
                if ! profile_validate_boolean "$value"; then
                    profile_error "Profile '$profile_name': legend must be true or false."
                    return 1
                fi

                SHOW_LEGEND="$value"
                ;;


            verbose)
                if ! profile_validate_boolean "$value"; then
                    profile_error "Profile '$profile_name': verbose must be true or false."
                    return 1
                fi

                VERBOSE="$value"
                ;;


            *)
                profile_error "Profile '$profile_name': unknown key '$key'."
                return 1
                ;;

        esac

    done < "$profile_file"

    return 0
}


profile_capture_defaults()
{
    DEFAULT_REPO_PATH="$REPO_PATH"
    DEFAULT_COMMITS_DAYS="$COMMITS_DAYS"
    DEFAULT_SUMMARY_DAYS="$SUMMARY_DAYS"
    DEFAULT_UI_MODE="$UI_MODE"
    DEFAULT_DO_SYNC="$DO_SYNC"
    DEFAULT_SHOW_LEGEND="$SHOW_LEGEND"
    DEFAULT_VERBOSE="$VERBOSE"

    DEFAULT_SECTIONS=("${SELECTED_SECTIONS[@]}")
}


profile_load_default()
{
    # Establish empty initial runtime state.
    REPO_PATH=""
    COMMITS_DAYS=""
    SUMMARY_DAYS=""
    UI_MODE=""
    DO_SYNC=""
    SHOW_LEGEND=""
    VERBOSE=false
    SELECTED_SECTIONS=()

    profile_apply_file "default" || return 1

    # default.conf must define all required values.
    if [ -z "$REPO_PATH" ] ||
       [ -z "$COMMITS_DAYS" ] ||
       [ -z "$SUMMARY_DAYS" ] ||
       [ -z "$UI_MODE" ] ||
       [ -z "$DO_SYNC" ] ||
       [ -z "$SHOW_LEGEND" ] ||
       [ "${#SELECTED_SECTIONS[@]}" -eq 0 ]; then

        profile_error "profiles/default.conf is missing required values."
        return 1
    fi

    ACTIVE_PROFILE="default"

    profile_capture_defaults

    return 0
}


profile_load()
{
    local profile_name="$1"

    if [ "$profile_name" = "default" ]; then
        ACTIVE_PROFILE="default"
        return 0
    fi

    # Reset to true defaults first, then overlay selected profile.
    REPO_PATH="$DEFAULT_REPO_PATH"
    COMMITS_DAYS="$DEFAULT_COMMITS_DAYS"
    SUMMARY_DAYS="$DEFAULT_SUMMARY_DAYS"
    UI_MODE="$DEFAULT_UI_MODE"
    DO_SYNC="$DEFAULT_DO_SYNC"
    SHOW_LEGEND="$DEFAULT_SHOW_LEGEND"
    VERBOSE="$DEFAULT_VERBOSE"
    SELECTED_SECTIONS=("${DEFAULT_SECTIONS[@]}")

    profile_apply_file "$profile_name" || return 1

    ACTIVE_PROFILE="$profile_name"

    print_debug "Loaded profile: $profile_name"

    return 0
}


profile_list()
{
    local file
    local name

    printf 'Available profiles:\n'

    for file in "$SCRIPT_DIR"/profiles/*.conf
    do
        [ -e "$file" ] || continue

        name="$(basename "$file" .conf)"

        if [ "$name" = "default" ]; then
            printf '  %-16s %s\n' "$name" '(default)'
        else
            printf '  %s\n' "$name"
        fi
    done
}


profile_show_defaults()
{
    local sections

    sections="$(IFS=','; printf '%s' "${DEFAULT_SECTIONS[*]}")"

    printf 'GitAR - Default Profile\n\n'

    printf 'Profile        : default\n'
    printf 'Repository     : %s\n' "$DEFAULT_REPO_PATH"
    printf 'Sections       : %s\n' "$sections"
    printf 'Commit days    : %s\n' "$DEFAULT_COMMITS_DAYS"
    printf 'Summary days   : %s\n' "$DEFAULT_SUMMARY_DAYS"
    printf 'Sync           : %s\n' "$DEFAULT_DO_SYNC"
    printf 'Legend         : %s\n' "$DEFAULT_SHOW_LEGEND"
    printf 'UI mode        : %s\n' "$DEFAULT_UI_MODE"
    printf 'Verbose        : %s\n' "$DEFAULT_VERBOSE"

    printf '\nEquivalent explicit command:\n\n'

    printf '  gitar'
    printf ' --sections %s' "$sections"
    printf ' --commits-days %s' "$DEFAULT_COMMITS_DAYS"
    printf ' --summary-days %s' "$DEFAULT_SUMMARY_DAYS"
    printf ' --ui %s' "$DEFAULT_UI_MODE"

    if [ "$DEFAULT_DO_SYNC" = true ]; then
        printf ' --sync'
    else
        printf ' --no-sync'
    fi

    if [ "$DEFAULT_SHOW_LEGEND" = true ]; then
        printf ' --legend'
    else
        printf ' --no-legend'
    fi

    if [ "$DEFAULT_VERBOSE" = true ]; then
        printf ' --verbose'
    fi

    printf '\n'

    printf '\nDefault profile file:\n\n'
    printf '  %s/profiles/default.conf\n' "$SCRIPT_DIR"
}