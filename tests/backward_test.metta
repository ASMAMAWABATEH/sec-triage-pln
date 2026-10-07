!(import! &self (library lib_import))
!(git-import! "https://github.com/trueagi-io/PLN.git")
!(import! &self (library PLN lib_pln))
!(import! &self ../kb/security_kb)
!(import! &self ../src/backward)

; B1 deduction: expect strength 0.2015, confidence 0.144, evidence 4 and 5
!(Backward (kb) PhishingCompromise CredentialTheft 1)
; B2 abduction: expect 0.1522, 0.4349, evidence 1 and 3
!(Backward (kb) Host17 PhishingCompromise 1)
; B3 abduction: expect 0.5778, 0.4349, evidence 2 and 3
!(Backward (kb) Host17 AdminMaintenance 1)
; B4 direct fact: expect (stv 0.95 0.9), evidence 3
!(Backward (kb) Host17 SuspiciousPS 0)
; B5 abduction through a shared effect is a legitimate proof: expect 0.0511, 0.1955
!(Backward (kb) AdminMaintenance PhishingCompromise 1)
; B6 no proof exists (CredentialTheft has no outgoing links): expect ()
!(Backward (kb) CredentialTheft Host17 1)
; B7 depth 0 allows only direct facts, so the deduction is not attempted: expect ()
!(Backward (kb) PhishingCompromise CredentialTheft 0)
