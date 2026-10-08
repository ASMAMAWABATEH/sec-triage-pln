!(import! &self (library lib_import))
!(git-import! "https://github.com/trueagi-io/PLN.git")
!(import! &self (library PLN lib_pln))
!(import! &self ../kb/security_kb)

; Q1 with growing budgets: 100/10/100, then 300/10/300, then 300/100/300
!(collapse (PLN.Query (kb) (Inheritance PhishingCompromise CredentialTheft) 100 10 100))
!(collapse (PLN.Query (kb) (Inheritance PhishingCompromise CredentialTheft) 300 10 300))
!(collapse (PLN.Query (kb) (Inheritance PhishingCompromise CredentialTheft) 300 100 300))
; Q3 with the same three budgets
!(collapse (PLN.Query (kb) (Inheritance Host17 AdminMaintenance) 100 10 100))
!(collapse (PLN.Query (kb) (Inheritance Host17 AdminMaintenance) 300 10 300))
!(collapse (PLN.Query (kb) (Inheritance Host17 AdminMaintenance) 300 100 300))
