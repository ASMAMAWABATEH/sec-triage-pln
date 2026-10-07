!(import! &self (library lib_import))
!(git-import! "https://github.com/trueagi-io/PLN.git")
!(import! &self (library PLN lib_pln))
!(import! &self ../kb/security_kb)
!(import! &self ../src/backward)
!(import! &self ../src/engine)

; The same three questions as before, answered both ways
!(Compare (kb) PhishingCompromise CredentialTheft 1)
!(Compare (kb) Host17 PhishingCompromise 1)
!(Compare (kb) Host17 AdminMaintenance 1)
