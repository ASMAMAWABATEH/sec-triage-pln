!(import! &self (library lib_import))
!(git-import! "https://github.com/trueagi-io/PLN.git")
!(import! &self (library PLN lib_pln))

; ===== SECURITY ALERT TRIAGE KNOWLEDGE BASE (v0.1) =====
; (Inheritance X Y) with strength s means P(Y | X).
; Every number is a documented estimate, not a measurement.

; ----- Base rates: how common is each thing among all hosts? -----
(= (STV PhishingCompromise) (stv 0.02  0.9))   ; hosts hit by a phishing-driven compromise
(= (STV AdminMaintenance)   (stv 0.20  0.9))   ; hosts under routine admin work
(= (STV SuspiciousPS)       (stv 0.10  0.9))   ; hosts raising a suspicious-PowerShell alert
(= (STV MalwareExec)        (stv 0.03  0.9))   ; hosts where malware has executed
(= (STV CredentialTheft)    (stv 0.015 0.9))   ; hosts where credentials were stolen
(= (STV Host17)             (stv 0.05  0.9))   ; the host we are investigating

; ----- Links, each with its own evidence ID -----
(= (kb)
   ((Sentence ((Inheritance PhishingCompromise SuspiciousPS)    (stv 0.8  0.9)) (1))
    (Sentence ((Inheritance AdminMaintenance   SuspiciousPS)    (stv 0.3  0.9)) (2))
    (Sentence ((Inheritance Host17             SuspiciousPS)    (stv 0.95 0.9)) (3))
    (Sentence ((Inheritance PhishingCompromise MalwareExec)     (stv 0.5  0.9)) (4))
    (Sentence ((Inheritance MalwareExec        CredentialTheft) (stv 0.4  0.8)) (5))))

; ----- Queries -----
; Q1 deduction: phishing -> malware -> credential theft
!(PLN.Query (kb) (Inheritance PhishingCompromise CredentialTheft))
; Q2 abduction: Host17 shows the alert; is phishing the cause?
!(PLN.Query (kb) (Inheritance Host17 PhishingCompromise))
; Q3 abduction: or is it admin maintenance?
!(PLN.Query (kb) (Inheritance Host17 AdminMaintenance))
