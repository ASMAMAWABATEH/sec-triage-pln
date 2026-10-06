#!/bin/sh
set -e
mkdir -p deps
[ -d deps/PeTTa ] || git clone --depth 1 https://github.com/trueagi-io/PeTTa deps/PeTTa
echo "Setup done. Run: sh deps/PeTTa/run.sh tests/smoke.metta"
