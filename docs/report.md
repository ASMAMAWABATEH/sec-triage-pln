# Probabilistic reasoning for security alert triage with PLN

## 1. Problem and why probabilistic reasoning
Security alerts are noisy and ambiguous. An alert such as suspicious PowerShell can be a
phishing compromise or routine administration; sensors disagree; evidence arrives over time.
An analyst needs ranked explanations and a measure of how well each is supported. Probabilistic
Logic Networks give every statement a strength (probability) and a confidence (evidence amount),
with rules that combine them. Abduction (alert to cause), deduction (attack stage to later
stage), and revision (merging sources) all appear naturally in this task.

## 2. Knowledge base
13 terms with base rates and 16 links `(Inheritance X Y)` meaning P(Y | X), each with strength,
confidence and an evidence ID (docs/kb_design.md). Terms cover causes (phishing, admin
maintenance, brute force), attack stages (malware, credential theft, lateral movement,
exfiltration), alerts (suspicious PowerShell, failed logins, outbound beacon) and two hosts.
All values are the author's estimates. A validator rejects any link whose strength is impossible
for its two base rates: max(0, (sA+sB-1)/sA) <= sAB <= min(1, sB/sA). All 21 links and scenario
facts pass.

## 3. Method
Rules follow from the laws of conditional probability, Bayes and total probability, plus a
conditional-independence assumption (docs/rule_proofs.md derives deduction, induction,
abduction, inversion and modus ponens). Revision and the confidence formulas are heuristics:
confidence c maps to evidence weight w = c/(1-c); revision pools weights; deduction
confidence is the product of the strengths and confidences of both premises.
Forward chaining is the library's `PLN.Query`. Backward chaining is our own: starting from a goal
A -> B it looks for direct facts, then deduction through a middle term, then abduction through a
shared term, to a depth limit, merging evidence by revision only when evidence IDs are
disjoint, and returns the most confident proof.
Library fix: the shipped abduction rule passed term strengths in the wrong order and inversion
did not apply Bayes' rule. We fixed both (docs/lib_pln_fix.diff). Before the fix one query returned
strength 3.8; after it, all results match hand calculations.

## 4. Scenarios and results (backward chaining)
| Scenario | Result |
|---|---|
| S1 supported | two independent sensors (0.75, 0.65; c = 0.8 each) merge to 0.70, c = 0.889 |
| S2 incomplete | Host42 has one alert: brute force 0.068, admin 0.370, both c = 0.327; malware has no proof |
| S3 competing | Host17: admin 0.578, malware 0.355, phishing 0.152, ranked mainly by base rate |
| S4 conflict | belief in compromise rises from 0.34 (c 0.714) to 0.70 (c 0.92) when a threat-intel hit arrives |
| S5 chain | confidence falls 0.9, 0.144, 0.0116, 0.000113 over four hops, strength 0.5 to 0.033 |

## 5. Observations
Admin maintenance outranks phishing for Host17 because it is ten times more common, even though
phishing explains the alert better; base rates dominate abduction. In S5 each hop multiplies
confidence by roughly a tenth. Comparing the two chainers on the 13 questions with default
settings, the library's forward search answered 8 and matched our result exactly on 3; our backward
chainer answered all 12 provable questions and correctly returned nothing for the unprovable one.
The forward search is bounded and sensitive to queue sizes and fact order (traced in
docs/engineering_notes.md), though we did not establish why every miss occurred.

## 6. Limitations
Estimated, not measured, numbers. Independence assumptions can fail for real attack stages.
Heuristic confidence cannot separate ignorance from evenly split evidence. Abduction cannot
explain away competing causes (Admin raises Phishing slightly, 0.051 against a 0.02 base rate).
Our chainer only tries middle terms among direct links and merges only direct facts. The
forward-versus-backward comparison is limited to one small knowledge base.
