#!/bin/bash
# Setup a user's home directory
set -e
cd "$(dirname "$0")"

STD_HOME="/opt/std-dev-env/home"
USER_HOME="/home/${HOST_USER}"

# Install the contents of the standard home directory to the user directory,
# if they don't already exist (e.g. from a bind mount).
(cd "${STD_HOME}" && find . -type f -exec install -Dp -o "${HOST_UID}" -g "${HOST_GID}" -m 755 "{}" "${USER_HOME}/{}" \;)

# Change ownership and set permissions for home directory contents
chown "${HOST_UID}:${HOST_GID}" "${USER_HOME}"
chmod 755 "${USER_HOME}"

chown "${HOST_UID}:${HOST_GID}" "${USER_HOME}/.ssh"
chmod 700 "${USER_HOME}"
