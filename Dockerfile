FROM docker.io/jupyter/base-notebook:latest

# Binder requires NB_USER (set by base image) and UID 1000

USER root

# Install git for the shallow clone
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER ${NB_USER}

# Shallow clone the ambrs repo into the home directory
RUN git clone --depth 1 --branch main-dev \
    https://github.com/AMBRS-project/ambrs.git \
    ${HOME}/ambrs

# Install Python dependencies
RUN pip install --no-cache-dir -r ${HOME}/ambrs/requirements.txt && \
    pip install --no-cache-dir -e ${HOME}/ambrs

# Set the working directory to the cloned repo so notebooks are visible
WORKDIR ${HOME}/ambrs

