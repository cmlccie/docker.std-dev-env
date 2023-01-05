.PHONY: build shell shell-root

build:
	docker build --pull \
		--tag std-dev-env:local \
		.

shell: build
	docker run --rm -it \
		--platform linux/amd64 \
		--ulimit nofile=2048:2048 \
		--env HOST_UID=$$(id -u) \
		--env HOST_USER=$$(id -u -n) \
		--env HOST_GID=$$(id -g) \
		--env HOST_GROUP=$$(id -g -n) \
		-v "${HOME}/repos:/home/${USER}/repos" \
		-v "${HOME}/tf:/home/${USER}/tf" \
		-v "${HOME}/.aws:/home/${USER}/.aws" \
		-v "${HOME}/.secrets:/home/${USER}/.secrets" \
		-v "/run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock" \
		-e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" \
		std-dev-env:local

shell-root: build
	docker run --rm -it --platform linux/amd64 std-dev-env:local
