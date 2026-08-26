#!/bin/bash
# ==========================================
# Command Line Argument Parser
# ==========================================


argument_error()
{
    printf 'ERROR: %s\n\n' "$1" >&2
    printf 'Run "gitar --help" for usage.\n' >&2
    exit 1
}


require_value()
{
    local option="$1"
    local value="${2:-}"

    if [ -z "$value" ] || [[ "$value" == --* ]]; then
        argument_error "$option requires a value."
    fi
}


validate_days()
{
    local option="$1"
    local value="$2"

    if ! is_positive_integer "$value"; then
        argument_error "$option must be a positive whole number."
    fi
}


validate_ui_mode()
{
    case "$1" in
        dots|normal|quiet)
            return 0
            ;;

        *)
            argument_error "Unknown UI mode '$1'. Valid modes: dots, normal, quiet."
            ;;
    esac
}


parse_section_list()
{
    local value="$1"

    IFS=',' read -r -a SELECTED_SECTIONS <<< "$value"

    if [ "${#SELECTED_SECTIONS[@]}" -eq 0 ]; then
        argument_error "--sections requires at least one section."
    fi
}


parse_arguments()
{
    while [[ $# -gt 0 ]]
    do
        case "$1" in

            --days|-d)
                require_value "$1" "${2:-}"
                validate_days "$1" "$2"

                COMMITS_DAYS="$2"
                SUMMARY_DAYS="$2"

                shift 2
                ;;


            --commits-days|-c)
                require_value "$1" "${2:-}"
                validate_days "$1" "$2"

                COMMITS_DAYS="$2"

                shift 2
                ;;


            --summary-days|-y)
                require_value "$1" "${2:-}"
                validate_days "$1" "$2"

                SUMMARY_DAYS="$2"

                shift 2
                ;;


            --sections|-s)
                require_value "$1" "${2:-}"

                parse_section_list "$2"

                shift 2
                ;;


            --ui|-u)
                require_value "$1" "${2:-}"
                validate_ui_mode "$2"

                UI_MODE="$2"

                shift 2
                ;;

            --sync)
                DO_SYNC=true
                shift
                ;;


            --no-sync|-n)
                DO_SYNC=false
                shift
                ;;

            --profile|-p)
                require_value "$1" "${2:-}"

                profile_load "$2" || exit 1

                shift 2
                ;;

            --profiles)
                profile_list
                exit 0
                ;;

            --defaults)
                profile_show_defaults
                exit 0
                ;;

            --verbose|-v)
                VERBOSE=true
                shift
                ;;

            --legend|-l)
                SHOW_LEGEND=true
                shift
                ;;

            --no-legend)
                SHOW_LEGEND=false
                shift
                ;;

            --version)
                printf 'GitAR %s\n' "$GITAR_VERSION"
                exit 0
                ;;

            --update)
                gitar_update
                exit $?
                ;;

            --doctor)
                gitar_doctor
                exit $?
                ;;

            --help|-h)
                show_help
                exit 0
                ;;


            *)
                argument_error "Unknown option '$1'."
                ;;

        esac
    done
}

show_help()
{
    cat <<'EOF'
GitAR - Git Activity Reporter

Usage:
  gitar [options]

Options:
  -h, --help                 Show this help
  -v, --verbose              Show diagnostic information
  -s, --sections LIST        Run only selected sections
                             Sections: header,sync,commits,daily-summary,statistics
  -d, --days N               Set all time-based sections to N days
  -c, --commits-days N       Set commit detail duration (default: 7)
  -y, --summary-days N       Set daily summary duration (default: 14)
  -n, --no-sync              Skip repository synchronization
  -u, --ui MODE              UI mode: dots, normal, quiet
  -l, --legend               Show report legends (hidden by default)
      --no-legend            Hide report legends
  -p, --profile NAME         Load saved profiles from profiles/NAME.conf

      --defaults             Show default values and equivalent command
      --sync                 Enable repository synchronization
      --doctor               Check GitAR installation and environment
      --version              Show GitAR version
      --update               Update a managed GitAR installation

Examples:
  gitar
  gitar -l
  gitar -s commits
  gitar -s header,commits,daily-summary
  gitar -d 30
  gitar -d 30 -c 7
  gitar -c 7 -y 30
  gitar -n
  gitar -u quiet
  gitar -v -s commits
  gitar -n -c 7 -y 30 -s header,commits,daily-summary

Profiles:
  Profiles are stored in git-report/profiles/*.conf.
  default.conf defines the behavior of plain "gitar".
  Other profiles inherit default.conf and override selected values.
  CLI arguments override profile values when specified afterward.

  Example:
    gitar --profile weekly
    gitar -p detailed
    gitar -p weekly -c 3

Defaults:
  Run "gitar --defaults" to show all current defaults and the
  explicit command equivalent to running "gitar" with no options.

Notes:
  --sections replaces the default section list.
  --no-sync disables sync even if sync is selected.
  Later options override earlier ones, e.g. "-d 30 -c 7".
EOF
}