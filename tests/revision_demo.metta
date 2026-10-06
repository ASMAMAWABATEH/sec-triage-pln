!(import! &self (library lib_import))
!(git-import! "https://github.com/trueagi-io/PLN.git")
!(import! &self (library PLN lib_pln))

(= (STV Host17) (stv 0.05 0.9))
(= (STV Compromised) (stv 0.04 0.9))

(= (kb)
   ((Sentence ((Inheritance Host17 Compromised) (stv 0.2 0.5)) (1))
    (Sentence ((Inheritance Host17 Compromised) (stv 0.8 0.8)) (2))))

!(PLN.Query (kb) (Inheritance Host17 Compromised))