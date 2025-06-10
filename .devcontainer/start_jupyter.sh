#!/bin/bash
# Start a Jupyter Notebook server with no password so we can easily access it from base env
export MLFLOW_TRACKING_URI="http://127.0.0.1:1235";
jupyter notebook --port 1234 --ip='*' --NotebookApp.token='' --NotebookApp.password='';
# ------------------------------------------------------------------------------------------------------------------- #
# If notebook is installed in project-env instead of base you can use this instead
# source /opt/conda/etc/profile.d/conda.sh; # Start a Jupyter Notebook server with no password so we can easily access it
# conda activate project-env;
# python -m ipykernel install --user --name=project-env; # Can be re-run multiple times
# jupyter notebook --port 1234 --ip='*' --NotebookApp.token='' --NotebookApp.password='';
# ------------------------------------------------------------------------------------------------------------------- #
