#!/bin/bash

# Allow the workdir to be set using an env var.
# Useful for CI pipiles which use docker for their build steps
# and don't allow that much flexibility to mount volumes
WORKDIR=${SRCDIR:-/src}
REQUIREMENTS=${REQUIREMENTS_FILE:-requirements.txt}

# In case the user specified a custom URL for PYPI, then use
# that one, instead of the default one.
if [[ "$PYPI_URL" != "https://pypi.python.org/" ]] || \
   [[ "$PYPI_INDEX_URL" != "https://pypi.python.org/simple" ]]; then
    mkdir -p /root/.pip
    echo "[global]" > /root/.pip/pip.conf
    echo "index = $PYPI_URL" >> /root/.pip/pip.conf
    echo "index-url = $PYPI_INDEX_URL" >> /root/.pip/pip.conf
    echo "trusted-host = $(echo $PYPI_URL | perl -pe 's|^.*?://(.*?)(:.*?)?/.*$|$1|')" >> /root/.pip/pip.conf

    echo "Using custom pip.conf: "
    cat /root/.pip/pip.conf
fi

cd $WORKDIR

if [ -f $REQUIREMENTS  ]; then
    pip install -r $REQUIREMENTS
fi

echo "$@"

if [[ "$@" == "" ]]; then
    pyinstaller --clean -y --dist ./dist/linux --workpath /tmp *.spec
    chown -R --reference=. ./dist/linux
else
    /bin/bash -c "$@"
fi