FROM ubuntu:18.04 as build
LABEL Name="pyinstaller-linux"
ENV DEBIAN_FRONTEND noninteractive

# Set python version, and pyinstall_version from command line
ARG PYTHON_VERSION=3.7
ARG PYINSTALLER_VERSION=3.5
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV PYINSTALLER_VERSION=${PYINSTALLER_VERSION}

# Env variables for pypi mirror, used in /entrypont.sh
ENV PYPI_URL=https://pypi.python.org/
ENV PYPI_INDEX_URL=https://pypi.python.org/simple

# Obtain necessary dependencies to build python for pyinstaller purposes
RUN apt update \
&& apt install -y python${PYTHON_VERSION}-dev python3-pip

# Save ~100mb space
RUN rm -rf /var/lib/apt/lists/*

RUN python${PYTHON_VERSION} -m pip install --upgrade pip
RUN python${PYTHON_VERSION} -m pip install --upgrade pyinstaller==${PYINSTALLER_VERSION}

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN mkdir /src
WORKDIR /src
VOLUME /src

ENTRYPOINT ["/bin/bash", "/entrypoint.sh" ]