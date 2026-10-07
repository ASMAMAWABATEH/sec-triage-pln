# Rule proofs: where PLN's formulas come from

Notation: P(X) is a probability. sA = P(A) is the strength of term A.
(Inheritance A B) with strength sAB means P(B | A). The symbol ~ means "not".

## 0. Three laws we use

L1, conditional probability: P(B|A) = P(A and B) / P(A), with P(A) > 0.
Equivalently P(A and B) = P(A) * P(B|A).

L2, Bayes' rule: P(A|B) = P(B|A) * P(A) / P(B).
Proof: by L1, P(A and B) = P(B|A)P(A) and also = P(A|B)P(B). Divide by P(B).

L3, law of total probability: for 0 < P(B) < 1,
  P(C|A) = P(C|A,B) * P(B|A) + P(C|A,~B) * P(~B|A).
Proof: C splits into two disjoint parts, (C and B) and (C and ~B). Condition
on A and apply L1 to each part.

Helpers: P(~B|A) = 1 - P(B|A), and P(C and ~B) = P(C) - P(C and B).

## 1. Consistency bounds (why some inputs are impossible)

P(A and B) <= min(P(A), P(B)) and P(A and B) >= max(0, P(A) + P(B) - 1).
Divide by P(A) using L1:

  max(0, (sA + sB - 1) / sA)  <=  sAB  <=  min(1, sB / sA)

These are smallest/largest-intersection-probability in lib_pln.metta.
Example: sA = 0.5, sB = 0.25 gives sAB <= 0.5, so sAB = 0.9 is impossible.

## 2. Deduction: A->B, B->C  gives  A->C

Apply L3 with B. Independence assumption: given B (or given ~B), learning A
adds nothing about C, so P(C|A,B) = P(C|B) = sBC and P(C|A,~B) = P(C|~B).
By L1, P(C and B) = sB * sBC, so
  P(C|~B) = (sC - sB*sBC) / (1 - sB).
Therefore
  sAC = sAB*sBC + (1 - sAB) * (sC - sB*sBC) / (1 - sB).
This is Truth_Deduction.

## 3. Inversion (Bayes): A->B gives B->A

By L2: sBA = sAB * sA / sB.
If this exceeds 1, the inputs were inconsistent. Example: 0.9 * 0.5 / 0.25 = 1.8.

## 4. Induction: B->A, B->C  gives  A->C

Apply L3 with B and the same independence assumption.
By L2, P(B|A) = sBA * sB / sA. So
  sAC = sBC * sBA*sB/sA + (1 - sBA*sB/sA) * (sC - sB*sBC) / (1 - sB).
This is Truth_Induction.

## 5. Abduction: A->B, C->B  gives  A->C

Apply L3 with B and the same independence assumption.
By L2 (note sCB = P(B|C)):
  P(C|B)  = sCB * sC / sB
  P(C|~B) = P(~B|C) * P(C) / P(~B) = (1 - sCB) * sC / (1 - sB)
and P(B|A) = sAB. Therefore
  sAC = sAB*sCB*sC/sB + (1 - sAB)*(1 - sCB)*sC/(1 - sB).
This is Truth_Abduction.

## 6. Modus ponens: A (strength sA), A->B  gives  B

By L3 over A: P(B) = P(B|A)P(A) + P(B|~A)P(~A).
P(B|~A) is unknown, so the library assumes a default of 0.02:
  sB = sA*sAB + 0.02*(1 - sA).
The 0.02 is a modelling choice, not a theorem.

## 7. Revision (not derivable from L1-L3)

Treat each source as w observations (w = c / (1 - c), so the horizon k = 1).
Pooling observations gives the pooled frequency
  f = (w1*f1 + w2*f2) / (w1 + w2),  with  w = w1 + w2.
The library then sets c = max(w/(w+1), c1, c2). This is a heuristic.

## 8. Confidence is a heuristic, not a theorem

Deduction confidence is sAB*sBC*cAB*cBC; induction and abduction use
w2c(s*c*c). Strengths follow from probability laws, but confidence values are
design choices. State this clearly in the report.

## 9. Hand predictions for kb/security_kb.metta (verify with the engine)

Q1 deduction, Phishing -> CredentialTheft:
  strength = 0.5*0.4 + 0.5*(0.015 - 0.03*0.4)/0.97 = 0.2015
  confidence = 0.5*0.4*0.9*0.8 = 0.144
Q2 abduction, Host17 -> Phishing:
  strength = 0.95*0.8*0.02/0.10 + 0.02*0.05*0.2/0.90 = 0.1522
  confidence = w2c(0.95*0.9*0.9) = 0.7695/1.7695 = 0.435
Q3 abduction, Host17 -> AdminMaintenance:
  strength = 0.95*0.3*0.20/0.10 + 0.20*0.05*0.7/0.90 = 0.5778
  confidence = 0.435
Admin work outranks phishing for Host17 because it is far more common (base rate).

## 10. Assumptions to disclose in the report
- Conditional independence in sections 2, 4 and 5 can fail in real attacks.
- The 0.02 default and the confidence formulas are heuristics.
- Base rates are estimates, not measurements.

## 11. Library defects found and fixed (verified by running the engine)

| Query | Original lib_pln.metta | Patched | Hand calculation |
|---|---|---|---|
| Q1 phishing -> credential theft | 0.4091 | 0.2015 | 0.2015 |
| Q2 Host17 -> phishing | 3.801 (not a probability) | 0.1522 | 0.1522 |
| Q3 Host17 -> admin maintenance | 0.1469 | 0.5778 | 0.5778 |

Defect 1: the abduction rule passed the shared term and the target term to
Truth_Abduction in swapped slots, so the formula divided by the wrong base rate.
Defect 2: Truth_inversion kept the original strength instead of applying Bayes'
rule (section 3).
Fix: src/lib_pln_fixed.metta, applied by setup.sh. Exact diff: docs/lib_pln_fix.diff.
The original library is MIT licensed; license copy in docs/PLN_LICENSE.txt.
