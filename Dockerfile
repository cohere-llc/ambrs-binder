FROM quay.io/jupyter/base-notebook:python-3.12

# Binder requires NB_USER (set by base image) and UID 1000

USER root

# Install git and build dependencies for AMBuilder
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cmake \
        gcc \
        g++ \
        gfortran \
        git \
        libblas-dev \
        liblapack-dev \
        make \
        pkg-config \
        zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Build and install PartMC and MAM4 via AMBuilder
RUN git clone --depth 1 https://github.com/AMBRS-project/ambuilder.git /tmp/ambuilder && \
    cmake -S /tmp/ambuilder -B /tmp/ambuilder-build \
        -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=gcc \
        -DCMAKE_Fortran_COMPILER=gfortran \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DENABLE_CAMP=ON && \
    cmake --build /tmp/ambuilder-build && \
    cmake --install /tmp/ambuilder-build && \
    ldconfig && \
    rm -rf /tmp/ambuilder /tmp/ambuilder-build

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

