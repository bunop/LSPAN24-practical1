
# VERSION 0.1.0
# DOCKER-VERSION  27.0.3
# AUTHOR:         Paolo Cozzi <paolo.cozzi@ibba.cnr.it>
# DESCRIPTION:    A docker images with mamba and apptainer based on gitpod/workspace-base
# TO_BUILD:       docker build --rm -t bunop/lspan24practical1 .
# TO_RUN:         docker run --rm -ti bunop/lspan24practical1 bash
# TO_TAG:         docker tag bunop/lspan24practical1:latest bunop/lspan24practical1:0.1.0
#

FROM gitpod/workspace-base:2024-07-10-08-22-03

LABEL maintainer="paolo.cozzi@ibba.cnr.it"

# set user for installing stuff
USER root

# Install stuff
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cargo \
        wget \
        curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# Taken from: https://github.com/nextflow-io/training/blob/master/.github/gitpod.Dockerfile
# Install Apptainer (Singularity)
RUN add-apt-repository -y ppa:apptainer/ppa && \
    apt-get update --quiet && \
    apt install -y apptainer && \
    apt-get clean && rm -rf /var/lib/apt/lists/

# set environment variables
ENV CONDA_DIR="/opt/conda"

# Install Conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p ${CONDA_DIR} && \
    rm Miniconda3-latest-Linux-x86_64.sh

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

# update base channel
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda update --quiet --yes --all && \
    conda install --quiet --yes --name base \
        mamba && \
    conda clean --all --force-pkgs-dirs --yes

# ovverride bashrc
COPY .bashrc /home/gitpod/.bashrc

# Fix user permissions
RUN mkdir -p /home/gitpod/.conda && \
    chown -R gitpod:gitpod /home/gitpod/

# Change user to gitpod
USER gitpod
