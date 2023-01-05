#!/usr/bin/env bash

echo "In .bash_profile"

# Load secrets
[[ -f "${HOME}/.secrets" ]] && source "${HOME}/.secrets"

# Load the .bashrc file for the login shell
[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"
