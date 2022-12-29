FROM ubuntu:22.04

SHELL ["/bin/bash", "-c"]

# Install system packages
RUN apt-get update && apt-get install -y \
    gosu \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /opt/std-dev-env/
COPY home /etc/skel

ENTRYPOINT [ "/opt/std-dev-env/entrypoint.sh" ]
CMD [ "/bin/bash", "--login" ]
