#!/bin/bash
# Add new .requirements files for each new environment desired
head_path="$(dirname "$(realpath "$0")")/";
for ENV_NAME in project-env; do 
    FILENAME=$head_path/.devcontainer/$ENV_NAME.requirements
    if [ -f $FILENAME ]; then
        uv venv $head_path/.$ENV_NAME --python=3.12
        source $head_path/.$ENV_NAME/bin/activate
        uv pip install -r $FILENAME
        deactivate
    else
        echo $FILENAME "does not exist."
    fi
done
