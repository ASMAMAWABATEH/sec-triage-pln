# Security Alert Triage with Probabilistic Logic Networks (PLN)

Author: <your name>. A small PLN reasoning engine in MeTTa (PeTTa runtime) that ranks the
likely causes of noisy security alerts and says how confident it is.

## Problem and why PLN
Security tools raise alerts that are noisy and ambiguous. The same suspicious-PowerShell alert
can come from a phishing compromise or from routine admin work. Sensors disagree, evidence
arrives over time, and an analyst needs to know both what is likely and how much evidence
supports it. PLN fits because every statement carries a strength (probability) and a
confidence (amount of evidence), and its rules combine them: deduction along attack chains,
abduction from alerts to causes, revision to merge sensors.

## What is in this repository
- kb/security_kb.metta: 13 terms with base rates and 16 links, each with an evidence ID.
- src/validate.metta: checks every link against probability bounds before reasoning.
- src/backward.metta: our goal-driven backward chainer (direct facts, deduction, abduction, revision).
- src/engine.metta: runs the library's forward chaining and our backward chaining side by side.
- src/lib_pln_fixed.metta: the PLN library with two defects fixed (docs/lib_pln_fix.diff).
- scenarios/: the five required scenarios. tests/: validator, backward and engine tests.
- docs/: rule_proofs.md (derivations), kb_design.md (meaning of every number),
  engineering_notes.md, scenario_results.txt (saved output), report.md.

## How to run
Requirements: git, python3, and SWI-Prolog (PeTTa asks for 9.3 or newer; the project also ran with
the swi-prolog package from Ubuntu's apt).

    git clone https://github.com/ASMAMAWABATEH/sec-triage-pln
    cd sec-triage-pln
    sh setup.sh                                      # fetches PeTTa and PLN, applies our library fix
    sh deps/PeTTa/run.sh scenarios/s3_competing.metta 2>&1 | grep -a "^(Result"
    sh run_all.sh                                    # everything; writes docs/scenario_results.txt

Forward chaining is slow, so run_all.sh takes several minutes. Output contains many SELECTED
lines from the library; the commands above filter them.

## Results (backward chaining, verified against hand calculations in docs/rule_proofs.md)
| Scenario | Question | Strength | Confidence |
|---|---|---|---|
| S1 supported | Host17 compromised? (two sensors, revised) | 0.70 | 0.889 |
| S2 incomplete | Host42 brute force? | 0.068 | 0.327 |
| S2 incomplete | Host42 admin maintenance? | 0.370 | 0.327 |
| S2 incomplete | Host42 malware? | no proof | - |
| S3 competing | Host17 admin maintenance | 0.578 | 0.435 |
| S3 competing | Host17 malware | 0.355 | 0.288 |
| S3 competing | Host17 phishing | 0.152 | 0.435 |
| S4 conflict | before threat-intel hit | 0.34 | 0.714 |
| S4 conflict | after threat-intel hit | 0.70 | 0.92 |
| S5 chain | Phishing -> Malware (1 hop) | 0.5 | 0.9 |
| S5 chain | -> CredentialTheft (2 hops) | 0.2015 | 0.144 |
| S5 chain | -> LateralMovement (3 hops) | 0.1028 | 0.0116 |
| S5 chain | -> DataExfiltration (4 hops) | 0.0327 | 0.000113 |

## Findings
1. The original library has two defects. Its abduction rule passed the shared term and the target
   term in swapped slots (one query returned a strength of 3.8, which is not a probability), and
   its inversion rule copied the strength instead of applying Bayes' rule. Both are fixed in
   src/lib_pln_fixed.metta; setup.sh applies it. Details: docs/rule_proofs.md section 11.
2. On this knowledge base with default settings, the library's forward chaining returned an
   answer for 8 of 13 questions and matched the backward result exactly for 3. Its search is
   bounded and depends on queue sizes and fact order (docs/engineering_notes.md). Our backward
   chainer starts from the goal and answered every question that has a proof.

## Limitations
- All strengths, confidences and base rates are the author's estimates, not measured data.
- Deduction, induction and abduction assume conditional independence, which real attacks may violate.
- Confidence values are heuristic. A simple (strength, confidence) pair cannot distinguish
  "no evidence" from "evidence evenly split".
- Abduction cannot explain away: two causes of one alert can slightly raise each other.
- Our backward chainer tries middle terms only among a term's direct links, and it merges only
  direct facts by revision, not derived proofs.
- The forward-versus-backward comparison covers 13 questions on one small knowledge base, so it
  is an observation, not a general claim.

## Credits
Built on the PLN library by TrueAGI: https://github.com/trueagi-io/PLN (MIT licence, copy in
docs/PLN_LICENSE.txt), running on PeTTa: https://github.com/trueagi-io/PeTTa.
