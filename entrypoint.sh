#!/bin/bash
# Docker Entrypoint
set -e

echo "In entrypoint.sh"

if [[ ! -z "${USER}" ]] && [[ "${USER}" != $(whoami) ]]; then
  # Create the user and run the command as the user
  useradd -ms /bin/bash "${USER}"
  exec gosu "${USER}" "$@"

else
  # Run the command as the current user
  exec "$@"
fi
