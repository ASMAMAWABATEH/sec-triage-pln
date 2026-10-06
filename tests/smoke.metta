!(import! &self (library lib_import))
!(git-import! "https://github.com/trueagi-io/PLN.git")
!(import! &self (library PLN lib_pln))

(= (STV A) (stv 0.5 0.9))
(= (STV B) (stv 0.25 0.9))
(= (STV C) (stv 0.25 0.9))

(= (kb)
   ((Sentence ((Inheritance A B) (stv 0.5 0.9)) (1))
    (Sentence ((Inheritance B C) (stv 0.8 0.9)) (2))))

!(PLN.Query (kb) (Inheritance A C))
