; Scenario-specific evidence. Data only: no imports, no queries.
; S1: two independent sensors both report Host17 as compromised (IDs 20, 21).
(= (extraS1)
   ((Sentence ((Inheritance Host17 Compromised) (stv 0.75 0.8)) (20))
    (Sentence ((Inheritance Host17 Compromised) (stv 0.65 0.8)) (21))))

; S4: conflicting evidence about Host17 (IDs 30-32). Early = before the threat-intel hit.
(= (extraS4early)
   ((Sentence ((Inheritance Host17 Compromised) (stv 0.1 0.6)) (30))
    (Sentence ((Inheritance Host17 Compromised) (stv 0.7 0.5)) (31))))
(= (extraS4)
   ((Sentence ((Inheritance Host17 Compromised) (stv 0.1 0.6)) (30))
    (Sentence ((Inheritance Host17 Compromised) (stv 0.7 0.5)) (31))
    (Sentence ((Inheritance Host17 Compromised) (stv 0.8 0.9)) (32))))
