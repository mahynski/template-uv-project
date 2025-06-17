#!/bin/bash
# Activate your virtual environment, then call this file. Jupyter is installed in each by default.
export MLFLOW_TRACKING_URI="http://127.0.0.1:1235";
jupyter lab --port 1234 --ip='*' --NotebookApp.token='' --NotebookApp.password='';
