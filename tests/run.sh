#!/bin/sh
# Esegue ogni tests/<programma>/<prefisso>*.in su ./<programma> e confronta lo stdout con il .out atteso.
# Uso: tests/run.sh [ordina|codfisc] [prefisso]. Senza argomenti prova entrambi i programmi.
cd "$(dirname "$0")/.." || exit 1
programmi="${1:-ordina codfisc}"
pass=0
fail=0
for programma in $programmi; do
  for input in tests/"$programma"/${2:-}*.in; do
    [ -e "$input" ] || continue
    expected="${input%.in}.out"
    actual=$(mktemp)
    ./"$programma" < "$input" > "$actual"
    if cmp -s "$expected" "$actual"; then
      pass=$((pass + 1))
    else
      fail=$((fail + 1))
      echo "FALLITO: $input"
      diff "$expected" "$actual" | head -20
    fi
    rm -f "$actual"
  done
done
echo "$pass passati, $fail falliti"
[ "$fail" -eq 0 ]
