!(import! &self (library lib_import))
!(git-import! "https://github.com/trueagi-io/PLN.git")
!(import! &self (library PLN lib_pln))
!(import! &self ../kb/security_kb)

; Q1 deduction: phishing -> malware -> credential theft
!(PLN.Query (kb) (Inheritance PhishingCompromise CredentialTheft))
; Q2 abduction: Host17 shows the alert; is phishing the cause?
!(PLN.Query (kb) (Inheritance Host17 PhishingCompromise))
; Q3 abduction: or is it admin maintenance?
!(PLN.Query (kb) (Inheritance Host17 AdminMaintenance))
