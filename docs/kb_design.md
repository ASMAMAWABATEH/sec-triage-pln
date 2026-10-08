# Knowledge base design (KB v0.2)

## 1. What the numbers mean
- Every fact is `(Inheritance X Y) (stv s c)` with evidence ID(s).
- **Strength s** is P(Y | X): the chance of Y given X. For a host term such as Host17,
  s is the degree to which that alert is observed on that host.
- **Confidence c** is how much evidence stands behind s. The library converts it to an
  evidence weight w = c / (1 - c) (horizon k = 1), so c = 0.9 means about 9 observations' worth.
- **Base rate** `(STV Term)` is P(Term) among all hosts. Abduction and deduction need it.
- **Evidence IDs** are unique per source. Revision merges two beliefs only when their IDs
  are disjoint, so one report is never counted twice.
- **All values are the author's estimates for illustration, not measurements from real data.**
  The project demonstrates the reasoning, not a calibrated detector.

## 2. Terms and base rates (all with confidence 0.9)
| Term | Role | Base rate | Meaning |
|---|---|---|---|
| PhishingCompromise | cause | 0.02 | host compromised through a phishing email |
| AdminMaintenance | cause | 0.20 | host under routine administrator work |
| BruteForce | cause | 0.01 | host under a password-guessing attack |
| MalwareExec | cause/state | 0.03 | malware has executed on the host |
| CredentialTheft | state | 0.015 | credentials stolen from the host |
| LateralMovement | state | 0.01 | attacker moving from this host to others |
| DataExfiltration | state | 0.005 | data being sent out |
| Compromised | state | 0.04 | host is compromised, by any route |
| SuspiciousPS | alert | 0.10 | suspicious-PowerShell alert raised |
| FailedLoginBurst | alert | 0.08 | burst of failed logins raised |
| OutboundBeacon | alert | 0.03 | periodic outbound connection typical of command-and-control |
| Host17, Host42 | hosts | 0.05 each | the two hosts under investigation |

## 3. Links
"Max s" is the largest strength the consistency check allows for that link (src/validate.metta,
docs/rule_proofs.md section 1). The lower bound is 0 for every link.

| ID | Link | s | c | Max s | Rationale |
|---|---|---|---|---|---|
| 1 | Phishing -> SuspiciousPS | 0.8 | 0.9 | 1 | most phishing payloads run PowerShell |
| 2 | AdminMaintenance -> SuspiciousPS | 0.3 | 0.9 | 0.5 | admin scripts often trigger the same rule |
| 3 | Host17 -> SuspiciousPS | 0.95 | 0.9 | 1 | the alert was observed on Host17 |
| 4 | Phishing -> MalwareExec | 0.5 | 0.9 | 1 | about half of phishing compromises drop malware |
| 5 | MalwareExec -> CredentialTheft | 0.4 | 0.8 | 0.5 | malware often, but not always, steals credentials |
| 6 | CredentialTheft -> LateralMovement | 0.5 | 0.8 | 0.667 | stolen credentials are often reused to move on |
| 7 | LateralMovement -> DataExfiltration | 0.3 | 0.7 | 0.5 | exfiltration follows only some intrusions |
| 8 | MalwareExec -> OutboundBeacon | 0.7 | 0.9 | 1 | most malware calls home |
| 9 | Host17 -> OutboundBeacon | 0.5 | 0.9 | 0.6 | beaconing was observed on Host17, with moderate strength |
| 10 | BruteForce -> FailedLoginBurst | 0.9 | 0.9 | 1 | guessing passwords causes failed logins |
| 11 | AdminMaintenance -> FailedLoginBurst | 0.2 | 0.9 | 0.4 | admins sometimes mistype passwords |
| 12 | Host42 -> FailedLoginBurst | 0.6 | 0.9 | 1 | the alert was observed on Host42 |
| 13 | BruteForce -> CredentialTheft | 0.3 | 0.8 | 1 | some guessing attacks succeed |
| 14 | CredentialTheft -> Compromised | 0.9 | 0.9 | 1 | stolen credentials mean compromise |
| 15 | MalwareExec -> Compromised | 0.95 | 0.9 | 1 | executed malware means compromise |
| 16 | LateralMovement -> Compromised | 0.95 | 0.9 | 1 | movement implies a compromised source host |

## 4. Scenario evidence (kb/scenario_facts.metta)
| ID | Statement | s | c | Source | Used in |
|---|---|---|---|---|---|
| 20 | Host17 -> Compromised | 0.75 | 0.8 | sensor A | S1 |
| 21 | Host17 -> Compromised | 0.65 | 0.8 | sensor B | S1 |
| 30 | Host17 -> Compromised | 0.1 | 0.6 | endpoint agent says probably clean | S4 |
| 31 | Host17 -> Compromised | 0.7 | 0.5 | noisy IDS says compromised | S4 |
| 32 | Host17 -> Compromised | 0.8 | 0.9 | threat-intel hit, arrives later | S4 |

All five fit under the 0.8 ceiling for Host17 -> Compromised (0.04 / 0.05).

## 5. Known limits of this design
- The validator checks each link against its two base rates only. It does not check that
  all base rates are jointly consistent.
- Deduction, induction and abduction assume conditional independence, which real attack
  stages may violate.
- Confidence values are heuristic, not derived from counts.
- Abduction cannot "explain away": two causes of one alert can slightly raise each other
  (see the Admin -> Phishing result, 0.051 against a 0.02 base rate).
