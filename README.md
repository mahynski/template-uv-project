How To Use
---

<img src="logo.png" align="right" width=200 />

1. Use this repo as a template to create a new repo on GitHub. Name the repo with a 4 digit year-of-initiation prefix, e.g., "2022-". Convention is to use hyphens between words and all lower case.
2. Insert description here.
3. Clone your new repo locally to get started. Python environments are managed using [uv](https://docs.astral.sh/uv/) instead of [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html). This makes installations faster, but is a little more manual. In the conda variant, a Jupyter notebook server is created in the base environment while a kernel for each environment is installed so notebooks can access different environments through a central server.  This is not possible at the moment so Jupyter servers have to be spun up inside each environment, if there are multiple.
4. Modify `.devcontainer/project-env.requirements` to include the relevant repositories and dependencies needed.  You can rename `project-env`, if you want but be sure to modify `setup.sh` accordingly.  You can also create other environments easily by creating new `.devcontainer/*.requirements` files (the names of environments are inferred from the name of this file).
5. If you do not want to work in a development container, skip to "Local Installation" to use a python virtual environment on your local machine.
6. Otherwise, a Docker [dev container](https://code.visualstudio.com/docs/devcontainers/containers) template for [VS Code](https://code.visualstudio.com/) is provided in the `.devcontainer/` folder.  This creates your virtual environment(s) automatically. To use:
   * Change the `UID` and `GID` in `.devcontainer/Dockerfile` if needed.
   * Optional: If you want to connect to other containers, e.g., running ollama for code assitance in [Continue](https://docs.continue.dev/), you might need to consider [Docker networking](https://docs.docker.com/engine/network/tutorials/standalone/). You can skip this in which case ollama will bind to your localhost at your chosen port on the default "bridge" network, which is acceptable on personal devices. Moreover, the default `devcontainer.json` file specifies `"--network=host"` in `runArgs` which uses the host networking when the container is running, which sould enable this automatically.
   * Add [additional arguments](https://containers.dev/implementors/json_reference/) as needed, e.g., "runArgs": ["--gpus", "all"] to [access host gpus](https://stackoverflow.com/questions/25185405/using-gpu-from-a-docker-container). This is helpful if you are doing deep learning in the container/project. You may have to install the appropriate drivers first.
7. Install the "Dev Containers" Extension in VS Code. First `git clone` this repo, then [open the folder in the container](https://code.visualstudio.com/docs/devcontainers/containers#_quick-start-open-an-existing-folder-in-a-container) by selecting "Dev Containers: Open Folder in Container" from the Command Palette.
8. Then run `bash .devcontainer/setup.sh` to create the python virtual environment(s).
9. From a terminal in VS Code, launch your desired virtual environment (e.g., `source .project-env/bin/activate`) then (1) navigate to your desired starting point (`data/analysis` is recommended), then (2) run `$ bash /path/to/.devcontainer/start_jupyter.sh` to launch a Jupyter server (forwarded on port 1234 by default) from the head of the repo in the default environment (`project-env`).  You can modify or duplicate as needed for other environments.

Local Installation
---

You can run the setup script outside of a devcontainer to install these environments on your local machine instead.

```code
$ bash .devcontainer/setup.sh
$ source .project-env/bin/activate
```

At the end of a project it is good practice to export the entire environment to a lockfile for posterity, especially if not working in a development container.

```code
$ source .project-env/bin/activate
$ uv pip freeze > requirements.in
$ uv pip compile requirements.in > requirements.txt
```

This environment can be recreated later.

```code
$ uv pip install -r requirements.txt
```

Contributors
---

Update the CITATION.cff file to enable appropriate citations.  

The logo for this repository (logo.png) was generated using Google Gemini 2.0 Flash (Imagen 3) on Feb. 19, 2025 with the prompt "Create a logo of a robotic bird being designed and templated by a robot in a factory."

Versioning
---

* Use the [public-template](https://github.com/mahynski/public-template) to create a fresh repo to release the code and details after a project is finished, tag the release, then use zenodo to capture changes to future changes/releases made to that repo, if a public record is desired. That serves as the primary **public** repo which is shared with external parties.
* In addition, create a "published" branch on this repo to correspond to when the associated results/paper/report was first published or shared. This repo is retained as the primary **private** version where future work can be performed. Subsequent branches, such as "revision-YYYY-MM-DD" can be created later and similarly reflected in the public-template version if revisions are necessary. 

Associated Publications
---

[LINK TO REPORT]()
