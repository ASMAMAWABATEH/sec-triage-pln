!(import! &self ../src/validate)

(= (STV TA) (stv 0.5 0.9))
(= (STV TB) (stv 0.25 0.9))
(= (STV TC) (stv 0.9 0.9))
(= (STV TD) (stv 0.8 0.9))

; Expected: BAD (0.9 > upper bound 0.5), OK (0.5 is exactly the upper bound),
;           BAD (0.3 < lower bound 0.7778)
(= (kbTest)
   ((Sentence ((Inheritance TA TB) (stv 0.9 0.9)) (1))
    (Sentence ((Inheritance TA TB) (stv 0.5 0.9)) (2))
    (Sentence ((Inheritance TC TD) (stv 0.3 0.9)) (3))))

!(ValidateAll (kbTest))
