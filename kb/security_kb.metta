; ===== SECURITY ALERT TRIAGE KNOWLEDGE BASE (v0.1) =====
; Data only: no imports, no queries. Imported by scenarios/ and tests/.
; (Inheritance X Y) with strength s means P(Y | X).
; Every number is a documented estimate, not a measurement.

; ----- Base rates: how common is each thing among all hosts? -----
(= (STV PhishingCompromise) (stv 0.02  0.9))
(= (STV AdminMaintenance)   (stv 0.20  0.9))
(= (STV SuspiciousPS)       (stv 0.10  0.9))
(= (STV MalwareExec)        (stv 0.03  0.9))
(= (STV CredentialTheft)    (stv 0.015 0.9))
(= (STV Host17)             (stv 0.05  0.9))

; ----- Links, each with its own evidence ID -----
(= (kb)
   ((Sentence ((Inheritance PhishingCompromise SuspiciousPS)    (stv 0.8  0.9)) (1))
    (Sentence ((Inheritance AdminMaintenance   SuspiciousPS)    (stv 0.3  0.9)) (2))
    (Sentence ((Inheritance Host17             SuspiciousPS)    (stv 0.95 0.9)) (3))
    (Sentence ((Inheritance PhishingCompromise MalwareExec)     (stv 0.5  0.9)) (4))
    (Sentence ((Inheritance MalwareExec        CredentialTheft) (stv 0.4  0.8)) (5))))
