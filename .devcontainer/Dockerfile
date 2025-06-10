FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim
# RUN apt update -y

# Create a user with a given User and Group ID
# https://vsupalov.com/docker-shared-permissions/
ARG UID
ARG GID
RUN addgroup --gid $GID user
RUN adduser --disabled-password --gecos '' --uid $UID --gid $GID user

SHELL ["/bin/bash", "--login", "-c"]

USER user
