#!/usr/bin/env bash

set -u

DEFAULT_REPO_URL="https://github.com/rezamoussavi/GitAR.git"
REPO_URL="${GITAR_REPO_URL:-$DEFAULT_REPO_URL}"

INSTALL_DIR="$HOME/.local/share/gitar"
BIN_DIR="$HOME/.local/bin"
COMMAND_PATH="$BIN_DIR/gitar"

printf '\n'
printf 'GitAR - Git Activity Reporter\n'
printf 'Installer\n'
printf '\n'

if [[ "$REPO_URL" != "$DEFAULT_REPO_URL" ]]; then
    printf '[DEV] Installation source: %s\n' "$REPO_URL"
fi

# --------------------------------------------------
# Requirements
# --------------------------------------------------

if ! command -v git >/dev/null 2>&1; then
    printf 'ERROR: Git was not found.\n'
    printf '\n'
    printf 'GitAR requires Git to be installed first.\n'
    exit 1
fi

if ! command -v bash >/dev/null 2>&1; then
    printf 'ERROR: Bash was not found.\n'
    printf '\n'
    printf 'GitAR requires Bash.\n'
    exit 1
fi

printf '[OK] Git found\n'
printf '[OK] Bash found\n'

# --------------------------------------------------
# Directories
# --------------------------------------------------

mkdir -p "$HOME/.local/share" || {
    printf 'ERROR: Could not create ~/.local/share\n'
    exit 1
}

mkdir -p "$BIN_DIR" || {
    printf 'ERROR: Could not create ~/.local/bin\n'
    exit 1
}

USER_PROFILE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gitar/profiles"

mkdir -p "$USER_PROFILE_DIR" || {
    printf 'ERROR: Could not create the GitAR user profile directory.\n'
    exit 1
}

printf '[OK] User profile directory ready\n'

# --------------------------------------------------
# Install / update application
# --------------------------------------------------

if [[ -d "$INSTALL_DIR/.git" ]]; then
    printf '\n'
    printf 'Existing GitAR installation found.\n'
    printf 'Updating...\n'

    if ! git -C "$INSTALL_DIR" pull --ff-only; then
        printf 'ERROR: GitAR could not be updated.\n'
        exit 1
    fi
else
    if [[ -e "$INSTALL_DIR" ]]; then
        printf 'ERROR: Installation path already exists:\n'
        printf '  %s\n' "$INSTALL_DIR"
        printf '\n'
        printf 'Please remove or rename it before installing GitAR.\n'
        exit 1
    fi

    printf '\n'
    printf 'Downloading GitAR...\n'

    if ! git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"; then
        printf 'ERROR: GitAR could not be downloaded.\n'
        exit 1
    fi
fi

touch "$INSTALL_DIR/.gitar-managed-install" || {
    printf 'ERROR: Could not mark the GitAR installation.\n'
    exit 1
}

chmod +x "$INSTALL_DIR/gitar"

# --------------------------------------------------
# Global command wrapper
# --------------------------------------------------

cat > "$COMMAND_PATH" <<EOF
#!/usr/bin/env bash
exec "$INSTALL_DIR/gitar" "\$@"
EOF

chmod +x "$COMMAND_PATH"

printf '[OK] GitAR command installed\n'

# --------------------------------------------------
# Shell / PATH setup
# --------------------------------------------------

case ":$PATH:" in
    *":$BIN_DIR:"*)
        PATH_READY=true
        ;;
    *)
        PATH_READY=false
        ;;
esac

USER_SHELL="${SHELL:-}"
SHELL_NAME="${USER_SHELL##*/}"
SHELL_SOURCE=""

case "$SHELL_NAME" in
    zsh)
        ZSHRC="$HOME/.zshrc"
        touch "$ZSHRC"

        if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$ZSHRC"; then
            {
                printf '\n'
                printf '# GitAR / user-local commands\n'
                printf 'export PATH="$HOME/.local/bin:$PATH"\n'
            } >> "$ZSHRC"

            printf '[OK] Added ~/.local/bin to zsh PATH\n'
        fi

        SHELL_SOURCE="source ~/.zshrc"
        ;;

    bash)
        BASHRC="$HOME/.bashrc"
        BASH_PROFILE="$HOME/.bash_profile"

        touch "$BASHRC"
        touch "$BASH_PROFILE"

        if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC"; then
            {
                printf '\n'
                printf '# GitAR / user-local commands\n'
                printf 'export PATH="$HOME/.local/bin:$PATH"\n'
            } >> "$BASHRC"

            printf '[OK] Added ~/.local/bin to Bash PATH\n'
        fi

        if ! grep -Fq 'source "$HOME/.bashrc"' "$BASH_PROFILE"; then
            {
                printf '\n'
                printf '# Load Bash configuration\n'
                printf 'if [[ -f "$HOME/.bashrc" ]]; then\n'
                printf '    source "$HOME/.bashrc"\n'
                printf 'fi\n'
            } >> "$BASH_PROFILE"

            printf '[OK] Configured Bash login startup\n'
        fi

        SHELL_SOURCE="source ~/.bashrc"
        ;;

    *)
        PROFILE="$HOME/.profile"
        touch "$PROFILE"

        if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$PROFILE"; then
            {
                printf '\n'
                printf '# GitAR / user-local commands\n'
                printf 'export PATH="$HOME/.local/bin:$PATH"\n'
            } >> "$PROFILE"

            printf '[OK] Added ~/.local/bin to shell PATH\n'
        fi

        SHELL_SOURCE="source ~/.profile"
        ;;
esac

# --------------------------------------------------
# Complete
# --------------------------------------------------

printf '\n'

if [[ -x "$INSTALL_DIR/gitar" ]]; then
    VERSION="$("$INSTALL_DIR/gitar" --version 2>/dev/null)"
else
    VERSION="GitAR"
fi

printf '%s installed successfully.\n' "$VERSION"
printf '\n'

if [[ "$PATH_READY" == true ]]; then
    printf 'You can now run:\n'
    printf '\n'
    printf '  gitar\n'
else
    printf 'Open a new terminal, then run:\n'
    printf '\n'
    printf '  gitar\n'
    printf '\n'
    printf 'Or enable it in this terminal now with:\n'
    printf '\n'
    printf '  %s\n' "$SHELL_SOURCE"
fi

printf '\n'
printf 'Run GitAR from inside any Git repository.\n'
printf '\n'