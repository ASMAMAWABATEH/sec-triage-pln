import pathlib, re

src = pathlib.Path("repos/PLN/lib_pln.metta").read_text()

def patch(pattern, repl, expected):
    global src
    src, n = re.subn(pattern, lambda m: repl, src, flags=re.S)
    assert n == expected, f"{pattern!r}: expected {expected} match(es), got {n}"

# Fix 1: abduction passed the shared term and the target term in swapped slots
patch(r"\(Truth_Abduction \(STV \$A\)\s+\(STV \$B\)\s+\(STV \$C\) \$T1 \$T2\)",
      "(Truth_Abduction (STV $A) (STV $C) (STV $B) $T1 $T2)", 1)

# Fix 2a: the inversion rules (Inheritance and Implication) also need (STV $A)
patch(r"\(Truth_inversion \(STV \$B\) \$Truth\)",
      "(Truth_inversion (STV $A) (STV $B) $Truth)", 2)

# Fix 2b: the inversion function applies Bayes' rule
new_def = """(= (Truth_inversion (stv $As $Ac) (stv $Bs $Bc) (stv $ABs $ABc))
   ; PATCH: Bayes inversion, sBA = sAB * sA / sB (docs/rule_proofs.md, section 3).
   ; Inconsistent inputs give (stv 1 0), meaning no information, like Truth_Deduction.
   (if (conditional-probability-consistency $As $Bs $ABs)
       (stv (/safe (* $ABs $As) $Bs) (* $Bc (* $ABc 0.6)))
       (stv 1 0)))"""
patch(r"\(= \(Truth_inversion \(stv \$Bs \$Bc\) \(stv \$ABs \$ABc\)\).*?\(\* \$Bc \(\* \$ABc 0\.6\)\)\)\)", new_def, 1)

header = (";; PATCHED COPY of trueagi-io/PLN lib_pln.metta (MIT licensed).\n"
          ";; Changes: abduction argument order; Bayes inversion. See docs/lib_pln_fix.diff\n")
pathlib.Path("src/lib_pln_fixed.metta").write_text(header + src)
pathlib.Path("repos/PLNfix").mkdir(parents=True, exist_ok=True)
pathlib.Path("repos/PLNfix/lib_pln.metta").write_text(header + src)
print("patched OK")
