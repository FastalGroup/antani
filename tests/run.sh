#!/bin/sh
# Esegue ogni tests/<dir>/<prefisso>*.in sul programma e confronta lo stdout con il .out atteso.
# Uso: tests/run.sh [codfisc] [prefisso]. Senza "codfisc" prova ./antani sui test in tests/.
cd "$(dirname "$0")/.." || exit 1
programma=./antani
cartella=tests
if [ "${1:-}" = codfisc ]; then
  programma=./codfisc
  cartella=tests/codfisc
  shift
fi
pass=0
fail=0
for input in "$cartella"/${1:-}*.in; do
  [ -e "$input" ] || continue
  expected="${input%.in}.out"
  actual=$(mktemp)
  "$programma" < "$input" > "$actual"
  if cmp -s "$expected" "$actual"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    echo "FALLITO: $input"
    diff "$expected" "$actual" | head -20
  fi
  rm -f "$actual"
done
echo "$pass passati, $fail falliti"
[ "$fail" -eq 0 ]
