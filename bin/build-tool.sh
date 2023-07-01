#!/bin/bash
TPC_SCRIPT_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TPC_WORKING_DIR=$(realpath $TPC_SCRIPT_PATH/..)
echo Working dir: $TPC_WORKING_DIR
cd $TPC_WORKING_DIR/tools && make -f Makefile.suite CC=gcc-9 OS=LINUX && make -f Makefile.suite OS=LINUX