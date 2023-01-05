#!/bin/bash
# Docker Entrypoint
set -e
cd "$(dirname "$0")"

echo "In entrypoint.sh"

if [[ -n "${HOST_UID}" ]] && [[ "${HOST_UID}" != $(id -u) ]]; then
  # Create the host user's group in the container, if it doesn't exist
  getent group "${HOST_GID}" 1>/dev/null 2>&1 || groupadd -g "${HOST_GID}" "${HOST_GROUP}"

  # Create the host user in the container
  useradd -u "${HOST_UID}" -g "${HOST_GID}" -s /bin/bash "${HOST_USER}"

  # If present, change the owner of the Docker SSH-agent socket
  [[ -n "${SSH_AUTH_SOCK}" ]] && chown "${HOST_UID}:${HOST_GID}" "${SSH_AUTH_SOCK}"

  # Setup the user's home directory
  ./setup-home.sh

  # Run the command as the user
  cd "/home/${HOST_USER}" && exec gosu "${HOST_USER}" "$@"

else
  # Run the command as the current user
  exec "$@"
fi
