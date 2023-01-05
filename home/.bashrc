#!/bin/bash

echo "In .bashrc"
shopt -q login_shell && echo "Login Shell"
[[ $- == *i* ]] && echo "Interactive Shell"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


## Shell configuration

HISTTIMEFORMAT="%F %T "
HISTFILESIZE=-1
HISTSIZE=-1
shopt -s histappend
shopt -s checkwinsize

# Bind the up and down arrow keys to search the command line history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Cloud team custom prompt
export  PS1='\n(\[\033[00;36m\]${AWS_ACCOUNT-none}${AWS_MFA-}:\[\033[01;34m\]$(aws_exp)\[\033[00m\]:${AWS_DEFAULT_REGION})\[\033[00;33m\]$(__git_ps1 \(git:%s\))\n\[\033[0;31m\][C]\[\033[00;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]:$ '

# Bash completion scripts
[[ -f /etc/bash_completion ]] && ! shopt -oq posix && source /etc/bash_completion
command -v terraform-docs 1>/dev/null 2>&1 && eval "$(terraform-docs completion bash)"


## Tools

# switch-aws
[[ -f "${HOME}/repos/github.com/foxcorp-mb-infra/utilities-scripts/switch-aws.sh" ]] && source "${HOME}/repos/github.com/foxcorp-mb-infra/utilities-scripts/switch-aws.sh"

# pre-commit
[[ -f "${HOME}/repos/github.com/foxcorp-mb-infra/utilities-scripts/pre_commit.sh" ]] && source "${HOME}/repos/github.com/foxcorp-mb-infra/utilities-scripts/pre_commit.sh"


## Shell Functions

aws_exp() {
    if [ -z "${AWS_OKTA_SESSION_EXPIRATION}" ]; then
        return
    else
        echo -n "$(printf '%(%T)T' ${AWS_OKTA_SESSION_EXPIRATION})"
    fi
}

# Search for a string in terraform files recursively in the current directory.
# Ex: tfgrep bucketname
tfgrep() {
    grep -r --include "*.tf" "$1" .
}

# Get list of AWS IAM actions by service
# Example 'iam_actions | grep kms:'
iam_actions ()
{
    curl --header 'Connection: keep-alive' --header 'Pragma: no-cache' --header 'Cache-Control: no-cache' --header 'Accept: */*' --header 'Referer: https://awspolicygen.s3.amazonaws.com/policygen.html' --header 'Accept-Language: en-US,en;q=0.9' --silent --compressed 'https://awspolicygen.s3.amazonaws.com/js/policies.js' | cut -d= -f2 | jq -r '.serviceMap[] | .StringPrefix as $prefix | .Actions[] | "\($prefix):\(.)"' | sort | uniq
}


## Bash Aliases

[[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"
