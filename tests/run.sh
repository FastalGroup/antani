#!/bin/sh
# Esegue ogni tests/<prefisso>*.in su ./antani e confronta lo stdout con il .out atteso.
cd "$(dirname "$0")/.." || exit 1
pass=0
fail=0
for input in tests/${1:-}*.in; do
  expected="${input%.in}.out"
  actual=$(mktemp)
  ./antani < "$input" > "$actual"
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
