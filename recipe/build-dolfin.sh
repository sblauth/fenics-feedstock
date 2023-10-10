#!/bin/bash
set -eux

unset CMAKE_PREFIX_PATH

cd dolfin

# scrub problematic -fdebug-prefix-map from C[XX]FLAGS
# these are loaded in the clang[++] activate scripts
export CFLAGS=$(echo $CFLAGS | sed -E 's@\-fdebug\-prefix\-map[^ ]*@@g')
export CXXFLAGS=$(echo $CXXFLAGS | sed -E 's@\-fdebug\-prefix\-map[^ ]*@@g')

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "0" ]]; then
  # needed for cross-compile openmpi
  export OPAL_CC="$CC"
  export OPAL_PREFIX="$PREFIX"
fi

# install Python bindings
cd python
$PYTHON -m pip install -v --no-deps .

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "0" ]]; then
  cd test
  $PYTHON -c 'from dolfin import *; info(parameters["form_compiler"], True)'
fi
