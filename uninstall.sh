#!/usr/bin/env bash

set -u

INSTALL_DIR="$HOME/.local/share/gitar"
BIN_DIR="$HOME/.local/bin"
COMMAND_PATH="$BIN_DIR/gitar"
STATE_DIR="$HOME/.local/state/gitar"
USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gitar"

printf '\n'
printf 'GitAR - Git Activity Reporter\n'
printf 'Uninstaller\n'
printf '\n'

removed_something=false

# --------------------------------------------------
# Global command
# --------------------------------------------------

if [[ -f "$COMMAND_PATH" ]]; then
    rm -f "$COMMAND_PATH" || {
        printf 'ERROR: Could not remove:\n'
        printf '  %s\n' "$COMMAND_PATH"
        exit 1
    }

    printf '[OK] Removed gitar command\n'
    removed_something=true
fi

# --------------------------------------------------
# Application files
# --------------------------------------------------

if [[ -d "$INSTALL_DIR" ]]; then
    if [[ -f "$INSTALL_DIR/.gitar-managed-install" ]]; then
        rm -rf "$INSTALL_DIR" || {
            printf 'ERROR: Could not remove GitAR installation:\n'
            printf '  %s\n' "$INSTALL_DIR"
            exit 1
        }

        printf '[OK] Removed GitAR application files\n'
        removed_something=true
    else
        printf '[WARN] Installation directory exists but is not marked as managed:\n'
        printf '  %s\n' "$INSTALL_DIR"
        printf '\n'
        printf 'It was left untouched for safety.\n'
    fi
fi

# --------------------------------------------------
# Update-check state
# --------------------------------------------------

if [[ -d "$STATE_DIR" ]]; then
    rm -rf "$STATE_DIR" || {
        printf 'ERROR: Could not remove GitAR state directory:\n'
        printf '  %s\n' "$STATE_DIR"
        exit 1
    }

    printf '[OK] Removed GitAR update state\n'
    removed_something=true
fi

# --------------------------------------------------
# User configuration
# --------------------------------------------------

if [[ -d "$USER_CONFIG_DIR" ]]; then
    printf '\n'
    printf 'Your personal GitAR profiles were NOT removed:\n'
    printf '\n'
    printf '  %s\n' "$USER_CONFIG_DIR"
    printf '\n'
    printf 'This protects your own configuration if you reinstall GitAR later.\n'
fi

# --------------------------------------------------
# Complete
# --------------------------------------------------

printf '\n'

if [[ "$removed_something" == true ]]; then
    printf 'GitAR was uninstalled successfully.\n'
else
    printf 'No managed GitAR installation was found.\n'
fi

printf '\n'