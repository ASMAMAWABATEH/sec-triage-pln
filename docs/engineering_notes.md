# Engineering notes (PeTTa pitfalls we hit)

1. Silent failure: a query that finds no answer prints nothing, no error.
   Debug with (collapse ...) around each step; it prints () for a failed step.
2. Declaration order: a file that calls STV needs the forward declaration
   (= (STV $x) (empty)) at the top, the same trick lib_pln.metta uses. Without it,
   lookups of base rates defined in an imported KB failed silently.
3. Imports use paths relative to the importing file, without .metta:
   !(import! &self ../kb/security_kb)
4. Data and function files contain no ! lines, only runnable files do.
5. Library defects (abduction argument order, Bayes inversion) are in
   docs/rule_proofs.md section 11, patched by setup.sh.
