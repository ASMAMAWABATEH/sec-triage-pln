#!/bin/sh
set -e
mkdir -p deps repos
[ -d deps/PeTTa ] || git clone --depth 1 https://github.com/trueagi-io/PeTTa deps/PeTTa
[ -d repos/PLN ] || git clone --depth 1 https://github.com/trueagi-io/PLN repos/PLN
# Apply our patched PLN library (abduction argument order, Bayes inversion; see docs/lib_pln_fix.diff)
cp src/lib_pln_fixed.metta repos/PLN/lib_pln.metta
echo "Setup done. Run from the project root: sh deps/PeTTa/run.sh kb/security_kb.metta"
