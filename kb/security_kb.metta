; ===== SECURITY ALERT TRIAGE KNOWLEDGE BASE (v0.2) =====
; Data only: no imports, no queries. Imported by scenarios/ and tests/.
; (Inheritance X Y) with strength s means P(Y | X).
; For a host term (Host17), a link strength is the degree to which that alert is observed.
; Every number is a documented estimate, not a measurement.

; ----- Base rates: how common is each thing among all hosts? -----
; causes and states
(= (STV PhishingCompromise) (stv 0.02  0.9))
(= (STV AdminMaintenance)   (stv 0.20  0.9))
(= (STV BruteForce)         (stv 0.01  0.9))
(= (STV MalwareExec)        (stv 0.03  0.9))
(= (STV CredentialTheft)    (stv 0.015 0.9))
(= (STV LateralMovement)    (stv 0.01  0.9))
(= (STV DataExfiltration)   (stv 0.005 0.9))
(= (STV Compromised)        (stv 0.04  0.9))
; observable alerts
(= (STV SuspiciousPS)       (stv 0.10  0.9))
(= (STV FailedLoginBurst)   (stv 0.08  0.9))
(= (STV OutboundBeacon)     (stv 0.03  0.9))
; hosts under investigation
(= (STV Host17)             (stv 0.05  0.9))
(= (STV Host42)             (stv 0.05  0.9))

; ----- Links, each with its own evidence ID -----
(= (kb)
   (; alert evidence: cause -> alert
    (Sentence ((Inheritance PhishingCompromise SuspiciousPS)    (stv 0.8  0.9)) (1))
    (Sentence ((Inheritance AdminMaintenance   SuspiciousPS)    (stv 0.3  0.9)) (2))
    (Sentence ((Inheritance Host17             SuspiciousPS)    (stv 0.95 0.9)) (3))
    ; attack chain
    (Sentence ((Inheritance PhishingCompromise MalwareExec)     (stv 0.5  0.9)) (4))
    (Sentence ((Inheritance MalwareExec        CredentialTheft) (stv 0.4  0.8)) (5))
    (Sentence ((Inheritance CredentialTheft    LateralMovement) (stv 0.5  0.8)) (6))
    (Sentence ((Inheritance LateralMovement    DataExfiltration)(stv 0.3  0.7)) (7))
    ; more alert evidence
    (Sentence ((Inheritance MalwareExec        OutboundBeacon)  (stv 0.7  0.9)) (8))
    (Sentence ((Inheritance Host17             OutboundBeacon)  (stv 0.5  0.9)) (9))
    (Sentence ((Inheritance BruteForce         FailedLoginBurst)(stv 0.9  0.9)) (10))
    (Sentence ((Inheritance AdminMaintenance   FailedLoginBurst)(stv 0.2  0.9)) (11))
    (Sentence ((Inheritance Host42             FailedLoginBurst)(stv 0.6  0.9)) (12))
    (Sentence ((Inheritance BruteForce         CredentialTheft) (stv 0.3  0.8)) (13))
    ; what counts as compromised
    (Sentence ((Inheritance CredentialTheft    Compromised)     (stv 0.9  0.9)) (14))
    (Sentence ((Inheritance MalwareExec        Compromised)     (stv 0.95 0.9)) (15))
    (Sentence ((Inheritance LateralMovement    Compromised)     (stv 0.95 0.9)) (16))))
