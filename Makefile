.PHONY: build shell

build:
	docker build --platform linux/amd64 --pull --tag std-dev-env:local .

shell: build
	docker run --rm -it --platform linux/amd64 --env USER=${USER} std-dev-env:local
