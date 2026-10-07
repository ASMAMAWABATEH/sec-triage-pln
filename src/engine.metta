; Entry points. Imported after lib_pln, the KB, and src/backward.
; Forward = the library's forward chainer (PLN.Query).
; Backward = our goal-driven chainer (src/backward.metta).
; collapse turns "no answer" into () instead of a silent failure.
(= (Forward $kb $A $B)
   (collapse (PLN.Query $kb (Inheritance $A $B))))

(= (Compare $kb $A $B $depth)
   (let* (($f (Forward $kb $A $B))
          ($b (Backward $kb $A $B $depth)))
     (Result (goal $A $B) (forward $f) (backward $b))))
