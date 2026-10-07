; ===== Backward chainer v0 (goal-driven) =====
; Imported AFTER lib_pln and the KB. Functions only: no ! lines.
; A proof is (BwProof (stv s c) (evidence ids) (how it was derived)).
; Solving a goal returns a list of proofs; BwBest keeps at most one.

(= (BwConf (stv $s $c)) $c)

; true when no id in $a appears in $b (prevents double-counting evidence)
(= (BwDisjoint $a $b)
   (if (== $a ())
       (== () ())
       (let* (($h (car-atom $a)) ($t (cdr-atom $a)))
         (if (is-member $h $b) (== 1 0) (BwDisjoint $t $b)))))

(= (BwUniq $xs $acc)
   (if (== $xs ())
       $acc
       (let* (($h (car-atom $xs)) ($t (cdr-atom $xs)))
         (BwUniq $t (PushUnique $acc $h)))))

; ---- direct facts "A -> B" in the KB ----
(= (BwDirectOne (Sentence (($Type $X $Y) $tv) $ids) $A $B)
   (if (== $X $A)
       (if (== $Y $B) ((BwProof $tv $ids (Fact $A $B))) ())
       ()))

(= (BwDirect $xs $A $B)
   (if (== $xs ())
       ()
       (let* (($h (car-atom $xs)) ($t (cdr-atom $xs)))
         (append (BwDirectOne $h $A $B) (BwDirect $t $A $B)))))

; ---- all targets T such that the KB has A -> T ----
(= (BwTargetsOne (Sentence (($Type $X $Y) $tv) $ids) $A)
   (if (== $X $A) ($Y) ()))

(= (BwTargets $xs $A)
   (if (== $xs ())
       ()
       (let* (($h (car-atom $xs)) ($t (cdr-atom $xs)))
         (append (BwTargetsOne $h $A) (BwTargets $t $A)))))

; ---- revision: merge several proofs of the same statement ----
(= (BwRevisePair (BwProof $tv1 $ids1 $r1) (BwProof $tv2 $ids2 $r2))
   (if (BwDisjoint $ids1 $ids2)
       (BwProof (Truth_Revision $tv1 $tv2) (ConcatUnique $ids1 $ids2) (Revision $r1 $r2))
       (if (> (BwConf $tv1) (BwConf $tv2))
           (BwProof $tv1 $ids1 $r1)
           (BwProof $tv2 $ids2 $r2))))

(= (BwMergeInto $acc $ps)
   (if (== $ps ())
       ($acc)
       (let* (($h (car-atom $ps)) ($t (cdr-atom $ps)))
         (BwMergeInto (BwRevisePair $acc $h) $t))))

(= (BwMergeAll $ps)
   (if (== $ps ())
       ()
       (BwMergeInto (car-atom $ps) (cdr-atom $ps))))

; ---- keep the single most confident proof (confidence 0 means no information) ----
(= (BwBetter $acc (BwProof $tv $ids $r))
   (if (> (BwConf $tv) 0)
       (if (== $acc ())
           ((BwProof $tv $ids $r))
           (if (> (BwConf $tv) (BwConfOfList $acc))
               ((BwProof $tv $ids $r))
               $acc))
       $acc))

(= (BwConfOfList ((BwProof $tv $ids $r))) (BwConf $tv))

(= (BwBestFrom $ps $acc)
   (if (== $ps ())
       $acc
       (let* (($h (car-atom $ps)) ($t (cdr-atom $ps)))
         (BwBestFrom $t (BwBetter $acc $h)))))

(= (BwBest $ps) (BwBestFrom $ps ()))

; ---- deduction: goal A->B through a middle term M ----
(= (BwDedFrom $A $M $B (BwProof $tv1 $ids1 $r1) (BwProof $tv2 $ids2 $r2))
   (if (BwDisjoint $ids1 $ids2)
       ((BwProof (Truth_Deduction (STV $A) (STV $M) (STV $B) $tv1 $tv2)
                 (ConcatUnique $ids1 $ids2)
                 (Deduction $r1 $r2)))
       ()))

(= (BwCombineDed $A $M $B $p1 $p2)
   (if (== $p1 ())
       ()
       (if (== $p2 ())
           ()
           (BwDedFrom $A $M $B (car-atom $p1) (car-atom $p2)))))

(= (BwDeduceVia $xs $A $M $B $d)
   (if (== $M $B)
       ()
       (if (== $M $A)
           ()
           (BwCombineDed $A $M $B
              (BwBest (BwSolve $xs $A $M (- $d 1)))
              (BwBest (BwSolve $xs $M $B (- $d 1)))))))

(= (BwViaDeduction $xs $A $B $d $Ms)
   (if (== $Ms ())
       ()
       (let* (($M (car-atom $Ms)) ($rest (cdr-atom $Ms)))
         (append (BwDeduceVia $xs $A $M $B $d) (BwViaDeduction $xs $A $B $d $rest)))))

; ---- abduction: goal A->B from A->C and B->C (same argument order as the patched library) ----
(= (BwAbdFrom $A $C $B (BwProof $tv1 $ids1 $r1) (BwProof $tv2 $ids2 $r2))
   (if (BwDisjoint $ids1 $ids2)
       ((BwProof (Truth_Abduction (STV $A) (STV $C) (STV $B) $tv1 $tv2)
                 (ConcatUnique $ids1 $ids2)
                 (Abduction $r1 $r2)))
       ()))

(= (BwCombineAbd $A $C $B $p1 $p2)
   (if (== $p1 ())
       ()
       (if (== $p2 ())
           ()
           (BwAbdFrom $A $C $B (car-atom $p1) (car-atom $p2)))))

(= (BwAbduceVia $xs $A $C $B $d)
   (if (== $C $B)
       ()
       (if (== $C $A)
           ()
           (BwCombineAbd $A $C $B
              (BwBest (BwSolve $xs $A $C (- $d 1)))
              (BwBest (BwSolve $xs $B $C (- $d 1)))))))

(= (BwViaAbduction $xs $A $B $d $Cs)
   (if (== $Cs ())
       ()
       (let* (($C (car-atom $Cs)) ($rest (cdr-atom $Cs)))
         (append (BwAbduceVia $xs $A $C $B $d) (BwViaAbduction $xs $A $B $d $rest)))))

; ---- the solver: direct facts, plus derived proofs while depth remains ----
(= (BwSolve $xs $A $B $d)
   (let* (($direct (BwMergeAll (BwDirect $xs $A $B))))
     (if (> $d 0)
         (let* (($Ms (BwUniq (BwTargets $xs $A) ())))
           (append $direct
                   (append (BwViaDeduction $xs $A $B $d $Ms)
                           (BwViaAbduction $xs $A $B $d $Ms))))
         $direct)))

; ---- entry point: best proof of (Inheritance A B), searching up to depth d ----
(= (Backward $xs $A $B $d) (BwBest (BwSolve $xs $A $B $d)))
