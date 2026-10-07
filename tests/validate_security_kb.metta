!(import! &self ../src/validate)
!(import! &self ../kb/security_kb)

!(ValidateAll (kb))
; Both counts must be equal; a smaller second number means a link's term has no base rate.
!(CountItems (kb))
!(CountItems (ValidateAll (kb)))
