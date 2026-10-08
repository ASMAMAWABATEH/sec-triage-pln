#!/bin/sh
# Runs validators, backward tests and the five scenarios; saves clean output to docs/scenario_results.txt
OUT=docs/scenario_results.txt
: > $OUT
for f in tests/validate_test.metta tests/validate_security_kb.metta tests/validate_scenarios.metta \
         tests/backward_test.metta scenarios/s1_supported.metta scenarios/s2_incomplete.metta \
         scenarios/s3_competing.metta scenarios/s4_conflict.metta scenarios/s5_chain.metta; do
  echo "== $f" >> $OUT
  sh deps/PeTTa/run.sh $f 2>&1 | grep -aE '^\(Result|^\(\(OK|^\(\(BAD|^\(\(BwProof|^\(\)$|^[0-9]+$' >> $OUT
done
echo "saved to $OUT"
