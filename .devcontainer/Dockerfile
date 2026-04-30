FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Need git and build-essential (provides gcc compiler) for pre-commit
RUN apt update -y \
 && apt install git -y \
 && apt install build-essential -y \
 && apt install curl unzip -y

# Also add timezone support
RUN apt install tzdata -y \
 && ln -sf /usr/share/zoneinfo/$(cat /etc/timezone) /etc/localtime \
 && echo $(cat /etc/timezone) > /etc/timezone

ENV TZ=America/New_York

# Create a user with a given User and Group ID
# https://vsupalov.com/docker-shared-permissions/
ARG UID
ARG GID
RUN addgroup --gid $GID user
RUN adduser --disabled-password --gecos '' --uid $UID --gid $GID user

SHELL ["/bin/bash", "--login", "-c"]

USER user

# Needed for cstack if not planning to use this, you can ignore
# -------------------------------------------------------------
# Install Bun as the user
RUN curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH
ENV BUN_INSTALL="/home/user/.bun"
ENV PATH="$BUN_INSTALL/bin:$PATH"
# -------------------------------------------------------------
