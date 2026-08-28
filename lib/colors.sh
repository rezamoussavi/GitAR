#!/bin/bash
# ==========================================
# Terminal Colors
# ==========================================

if [ -t 1 ] && [ "$ENABLE_COLORS" = true ]; then

    C_RESET="\033[0m"
    C_REVERSE="\033[7m"

    C_RED="\033[0;31m"
    C_GREEN="\033[0;32m"
    C_YELLOW="\033[0;33m"
    C_BLUE="\033[0;34m"
    C_PURPLE="\033[0;35m"
    C_CYAN="\033[0;36m"
    C_GREY="\033[0;90m"

else

    C_RESET=""
    C_REVERSE=""
    C_RED=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_PURPLE=""
    C_CYAN=""
    C_GREY=""

fi