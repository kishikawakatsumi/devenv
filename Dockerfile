FROM ubuntu:focal

SHELL ["/bin/bash", "-c"]

ENV R_VERSION 4.0.2
ENV R_REPOS https://packagemanager.rstudio.com/all/__linux__/focal/311
ENV DISPLAY :0
ENV TZ Europe/Germany

ARG DEBIAN_FRONTEND=noninteractive

COPY package_lists /package_lists
COPY install_scripts /install_scripts

# Ubuntu Setup
RUN apt-get -y update &&\
    apt-get -y --no-install-recommends install\
    software-properties-common \
    git \
    locales &&\
    locale-gen en_US.UTF-8 &&\
    export LC_ALL=en_US.UTF-8 &&\
    export LANG=en_US.UTF-8 && \
    # Cleanup apt cache
    rm -rf /var/lib/apt/lists/*

# Install Python
RUN apt-get -y update &&\
    apt-get -y --no-install-recommends install python3-pip && \
    # Cleanup apt cache
    rm -rf /var/lib/apt/lists/*

# Python packages
RUN pip3 install -U --no-cache-dir\
    $(grep -o '^[^#]*' package_lists/python_packages.txt | tr '\n' ' ')

# Install R
RUN chmod +x /install_scripts/install_r.sh &&\
    /install_scripts/install_r.sh

# R packages
RUN install2.r -error --ncpus 16 --repos $R_REPOS \
    $(grep -o '^[^#]*' package_lists/r_packages.txt | tr '\n' ' ')

# Install Latex
RUN chmod +x /install_scripts/install_latex.sh &&\
    /install_scripts/install_latex.sh

# Set Latex Path
ENV PATH="/usr/local/texlive/bin/x86_64-linux:${PATH}"

# Install latex packages
RUN tlmgr install \
    $(grep -o '^[^#]*' package_lists/latex_packages.txt | tr '\n' ' ')