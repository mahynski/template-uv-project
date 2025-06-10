#!/bin/bash
# Start a Jupyter Notebook server with no password 
export MLFLOW_TRACKING_URI="http://127.0.0.1:1235";
head_path="$(dirname "$(realpath "$0")")/";
$head_path/../.project-env/bin/jupyter lab --port 1234 --ip='*' --NotebookApp.token='' --NotebookApp.password='';
