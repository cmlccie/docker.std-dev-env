# Version control arguments
ARG python_version=3.9.16
ARG terraform_version=1.3.3
ARG terraform_docs_version=v0.16.0
ARG aws_okta_version=v1.0.11


# aws-okta build image --------------------------------------------------------
FROM --platform=linux/amd64 golang:1.13 AS aws-okta-build
RUN set -eux && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    apt-get install -y --no-install-recommends \
        libusb-1.0-0-dev \
        ca-certificates \
        build-essential \
        git \
        && \
    rm -rf /var/lib/apt/lists/*
ARG aws_okta_version
ENV AWS_OKTA_VERSION=${aws_okta_version}
ENV GOOS="linux"
ENV GOARCH="amd64"
ENV GO111MODULE="on"
RUN set -eux && \
    git clone --depth 1 --branch "${AWS_OKTA_VERSION}" https://github.com/segmentio/aws-okta /build && \
    cd /build && \
    go build -mod=vendor -o aws-okta -ldflags="-X 'main.Version=${AWS_OKTA_VERSION}'"


# Base image ------------------------------------------------------------------
FROM --platform=linux/amd64 ubuntu:22.04 AS base
SHELL ["/bin/bash", "-c"]
ARG python_version
ARG terraform_version
ARG terraform_docs_version
ARG aws_okta_version
ENV PYTHON_VERSION=${python_version}
ENV TERRAFORM_VERSION=${terraform_version}
ENV TERRAFORM_DOCS_VERSION=${terraform_docs_version}
ENV AWS_OKTA_VERSION=${aws_okta_version}


# pyenv Python builder image --------------------------------------------------
FROM base AS pyenv-builder
# Install suggested build environment system packages
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment
RUN set -eux && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    apt-get install -y \
        git \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        curl \
        llvm \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev \
        && \
    rm -rf /var/lib/apt/lists/*
ENV PYTHON_VERSION=${python_version}
ENV PYENV_ROOT="/opt/pyenv"
ENV PATH="${PYENV_ROOT}/versions/${PYTHON_VERSION}/bin:${PYENV_ROOT}/bin:${PATH}"
RUN set -eux && mkdir -p /tmp/downloads && cd /tmp/downloads && \
    curl https://pyenv.run | bash && \
    pyenv install "${PYTHON_VERSION}" && \
    pip install --upgrade pip && \
    rm -rf /tmp/downloads



# Standard Development Environment image --------------------------------------
FROM base AS std-dev-env

# Install system packages
RUN set -eux && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    apt-get install -y \
        bash-completion \
        coreutils \
        curl \
        git \
        gnupg \
        gosu \
        jq \
        oathtool \
        openssh-client \
        unzip \
        && \
    rm -rf /var/lib/apt/lists/*

# Installation customization environment variables
ENV PYENV_ROOT="/opt/pyenv"
ENV TFENV_ROOT="/opt/tfenv"
ENV POETRY_HOME="/opt/pypoetry"
ENV PATH="${PYENV_ROOT}/versions/${PYTHON_VERSION}/bin:${POETRY_HOME}/bin:${TFENV_ROOT}/bin:${PYENV_ROOT}/bin:${PATH}"

# Copy pyenv and the Python build from the build container
COPY --from=pyenv-builder "${PYENV_ROOT}" "${PYENV_ROOT}"

# Install tools with custom installation steps
RUN set -eux && mkdir -p /tmp/downloads && cd /tmp/downloads && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
    dpkg -i session-manager-plugin.deb && \
    pip install \
        pre-commit \
        boto3 \
        requests \
    && \
    curl -sSL https://install.python-poetry.org | python3 - && \
    git clone --depth=1 https://github.com/tfutils/tfenv.git "${TFENV_ROOT}" && \
    tfenv install "${TERRAFORM_VERSION}" && \
    tfenv use "${TERRAFORM_VERSION}" && \
    curl -sSLo ./terraform-docs.tar.gz "https://terraform-docs.io/dl/${TERRAFORM_DOCS_VERSION}/terraform-docs-${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz" && \
    tar -xzf terraform-docs.tar.gz && \
    chmod +x terraform-docs && \
    mv terraform-docs /usr/local/bin && \
    curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash && \
    rm -rf /tmp/downloads

# Copy aws-okta from the build container
COPY --from=aws-okta-build /build/aws-okta /usr/local/bin/

# Tool configuration environment variables
ENV POETRY_VIRTUALENVS_IN_PROJECT="true"
ENV AWS_DEFAULT_REGION="us-west-2"

# Fox cloud team environment configuration
COPY entrypoint.sh setup-home.sh /opt/std-dev-env/
COPY home /opt/std-dev-env/home

# Image configuration
ENTRYPOINT [ "/opt/std-dev-env/entrypoint.sh" ]
CMD [ "/bin/bash", "--login" ]
