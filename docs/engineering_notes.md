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

## Forward-chaining trace (KB v0.2, default budget, goal Host17 -> AdminMaintenance)
Observed (from the SELECTED trace, 99 steps):
- Base facts ever selected as tasks: IDs 4, 8, 9, 10, 11, 12, 14, 15, 16.
  Never selected: IDs 1, 2, 3, 5, 6, 7, 13 (so facts 2 and 3, needed for this goal, were never combined).
- Steps are spread over many derived statements, most involving the rare term
  DataExfiltration; they are not stuck on one statement.
Read from the code (not verified by a dedicated test):
- Each step combines one selected task with the belief list; both task queue and
  belief buffer are trimmed to their size limits by confidence (LimitSize).
- Low-confidence derivations (such as Phishing -> CredentialTheft, c = 0.144) can be evicted
  from the belief buffer; Q1 reappeared with a larger buffer (300/10/300).
Unexplained: why IDs 1, 2, 3 are skipped from the first step.
Conclusion for the report: forward results depend on budget, queue sizes and KB order,
while backward chaining answered all three goals directly.
