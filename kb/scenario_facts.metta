; Scenario-specific evidence. Data only: no imports, no queries.
; S1: two independent sensors both report Host17 as compromised (IDs 20, 21).
(= (extraS1)
   ((Sentence ((Inheritance Host17 Compromised) (stv 0.75 0.8)) (20))
    (Sentence ((Inheritance Host17 Compromised) (stv 0.65 0.8)) (21))))
