; Forward declaration: makes STV known as a function when this file is compiled
; (same trick as lib_pln.metta). The real definitions come from the KB file.
(= (STV $x) (empty))

; Knowledge-base validator. Functions only; needs no library import.
; Bounds derived in docs/rule_proofs.md, section 1:
;   max(0, (sA+sB-1)/sA) <= sAB <= min(1, sB/sA)

(= (StrengthOf (stv $s $c)) $s)

(= (LowerBound $sA $sB) (max 0 (/ (- (+ $sA $sB) 1) $sA)))
(= (UpperBound $sA $sB) (min 1 (/ $sB $sA)))

; Result is (OK ...) or (BAD ...), with the allowed range shown.
(= (CheckLink $type $A $B $s $ids)
   (let* (($sA (StrengthOf (STV $A)))
          ($sB (StrengthOf (STV $B))))
     (if (> $sA 0)
         (let* (($lo (LowerBound $sA $sB))
                ($hi (UpperBound $sA $sB)))
           (if (and (<= $lo (+ $s 0.000000001))
                    (<= $s (+ $hi 0.000000001)))
               (OK  $type $A $B $s (range $lo $hi) $ids)
               (BAD $type $A $B $s (range $lo $hi) $ids)))
         (BAD $type $A $B $s (zero-base-rate $A) $ids))))

(= (ValidateOne (Sentence ((Inheritance $A $B) (stv $s $c)) $ids))
   (CheckLink Inheritance $A $B $s $ids))
(= (ValidateOne (Sentence ((Implication $A $B) (stv $s $c)) $ids))
   (CheckLink Implication $A $B $s $ids))

(= (ValidateAll $xs)
   (if (== $xs ())
       ()
       (let* (($head (car-atom $xs))
              ($tail (cdr-atom $xs))
              ($r    (ValidateOne $head)))
         (append ($r) (ValidateAll $tail)))))

(= (CountItems $xs)
   (if (== $xs ()) 0 (+ 1 (CountItems (cdr-atom $xs)))))
