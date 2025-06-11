#!/bin/bash
# Add new .requirements files for each new environment desired
head_path="$(dirname "$(realpath "$0")")/";
for FILENAME in $(ls $head_path/*.requirements); do
    ENV_NAME=$(basename "$FILENAME" .requirements)
    uv venv $head_path/../.$ENV_NAME --python=3.12
    source $head_path/../.$ENV_NAME/bin/activate
    uv pip install pre-commit mlflow jupyterlab # Always install these
    uv pip install -r $FILENAME
    pre-commit install
    deactivate
done
