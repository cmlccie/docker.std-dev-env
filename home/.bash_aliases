#!/bin/bash
# Bash aliases

alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias la='ls -A --color=auto'
alias ll='ls -laF --color=auto'
alias tfi='terraform init -upgrade'
alias tfp='terraform plan -out local.plan'
alias tfa='terraform apply local.plan'
alias tfr='terraform refresh'
alias tfs='terraform show local.plan | grep \#'
alias tff='terraform fmt'
alias grep='grep --color=auto --exclude-dir=.svn --exclude-dir=.terraform --exclude-dir=.git'
alias nb='switch-aws aws-okta-base'
