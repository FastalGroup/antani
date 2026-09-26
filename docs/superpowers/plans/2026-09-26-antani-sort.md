# Antani — ordinamento di nomi in Monicelli puro: piano di implementazione

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Un eseguibile CLI `antani`, scritto interamente in Monicelli e compilato con `mcc`, che raccoglie fino a 16 nomi e li ordina alfabeticamente.

**Architecture:** Un unico sorgente `src/antani.mc`. Le funzioni pure (I/O di caratteri, impacchettamento, decodifica UTF-8, collazione, confronto) stanno in testa al file; il blocco principale `Lei ha clacsonato` contiene le 80 variabili-registro dei 16 slot e un ciclo "leggi riga → decidi azione → ordina → stampa". L'accesso indicizzato agli slot avviene con catene `che cos'è idx? 0: … o magari 15: …`. I test sono coppie `tests/*.in`/`tests/*.out` confrontate da `tests/run.sh`.

**Tech Stack:** Monicelli (compilatore `mcc` da https://github.com/esseks/monicelli), LLVM 21 (`llvm@21` Homebrew), ragel, cmake, POSIX sh, make. macOS x86_64.

**Spec:** `docs/superpowers/specs/2026-09-26-antani-sort-design.md`

## Global Constraints

- Tutta la logica è in `src/antani.mc`, Monicelli puro. Nessun generatore di codice, wrapper o libreria nel repo.
- Capacità: 16 nomi; lunghezza massima: 20 caratteri (le accentate contano 1).
- Codici carattere (7 bit): 0 fine, 1 spazio, 2 `'`, 3 `-`, 10–35 `A`–`Z`, 40–65 `a`–`z`, 70–75 `à è é ì ò ù`, 80–85 `À È É Ì Ò Ù`.
- Un nome = 5 Necchi, 4 caratteri per Necchi, primo carattere nei bit alti (shift `21 - 7*pos`).
- Collazione: fine 0, spazio 1, `'` 2, `-` 3, lettera → 10 + indice (a=10 … z=35), ignorando maiuscole e accenti; ordinamento stabile.
- Comandi: `:o` ordina e stampa, `:l` elenca, `:c` cancella, `:q` esce (maiuscole accettate); il primo carattere non-spazio della riga deve essere `:`.
- Il prompt `> ` è sempre stampato prima di leggere una riga. A EOF: stampa `\n`, poi se la lista non è vuota la ordina e la stampa.
- Testi esatti dei messaggi:
  - `Lei ha clacsonato! Inserisca i nomi, uno per riga (massimo 16).`
  - `Comandi: :o ordina  :l elenca  :c cancella  :q esci`
  - `Arrivederci.` · `Lista piena: nome scartato.` · `Nome troncato a 20 caratteri.`
  - `Carattere non ammesso: nome scartato.` · `Lista vuota.` · `Lista cancellata.` · `Comando sconosciuto.`
- Righe di elenco: `N. nome` (es. `1. anna`), una per riga.

### Regole di Monicelli verificate sui sorgenti di `mcc` (valgono per ogni task)

1. **Mai dichiarare variabili (`voglio`) dentro un ciclo `stuzzica`**: ogni `voglio` è un `alloca` nel punto corrente, dentro un ciclo lo stack cresce a ogni iterazione. Tutte le dichiarazioni vanno in testa alla funzione.
2. **Flag solo come Necchi 0/1, mai Melandri**: le conversioni intere usano estensione con segno, `vero` (i1) confrontato con `1` diventa `-1 ≠ 1`.
3. **Un solo `vaffanzum`, ultima istruzione della funzione** (un ritorno dentro un ramo genera IR con terminatori doppi).
4. **Niente parentesi e precedenze insidiose**: `più`/`meno` (15) legano più dello shift (10); `per` (20) più di `meno`. Usare variabili d'appoggio: `21 meno pos per 7` = `21 - pos*7`.
5. **`che cos'è` accetta solo una variabile** come soggetto; i casi sono valutati in ordine, vince il primo. Un caso con corpo vuoto è lecito.
6. **Tutti i cicli sono do-while** (`stuzzica … e brematura anche, se cond`): proteggere con un `che cos'è` quando il corpo non deve eseguire neanche una volta.
7. **Parole riservate da non usare come identificatori** (né come prefisso di `bituma`): `per con meno più diviso conte voglio o e i il lo la le gli un una dei delle`, e nessun identificatore che inizi con `bituma`. Gli identificatori sono solo lettere e cifre (niente `_`).
8. `bituma` commenta fino a fine riga: mai codice dopo un commento sulla stessa riga.
9. `mi porga` su Mascetti = `scanf("%c")`: a EOF la variabile resta invariata (per questo la si azzera prima). Byte ≥ 128 arrivano negativi: si aggiunge 256.
10. `a posterdati` su Mascetti stampa il byte senza newline; su Necchi stampa `%d\n` (quindi le cifre si stampano come caratteri).

## Review Focus

1. Ultima riga senza `\n` finale (tipico di `printf 'a\nb' | ./antani`): il nome va comunque aggiunto e poi ordinato. → test `15-eof-ordina` (Task 4).
2. File con fine riga Windows (`\r\n`): il `\r` va ignorato, non diventare "carattere non ammesso". → test `04-spazi` (Task 2).
3. Nome lungo esattamente 20 caratteri seguito da spazi: non è troncato. → test `06-troncamento` (Task 3).
4. `:` dentro un nome (`Ma:rio`) è carattere non ammesso; `:` dopo spazi iniziali è un comando. → test `07-invalido` (Task 3) e `02-comando-sconosciuto` (Task 1).
5. Sequenza UTF-8 spezzata da un a-capo (`0xC3` seguito da `\n`): nome scartato, ma la riga successiva va letta normalmente. → test `08-utf8-spezzato` (Task 3).

---

### Task 1: Toolchain, harness di test e scheletro del programma

**Files:**
- Create: `Makefile`, `.gitignore`, `tests/run.sh`, `tests/intestazione.txt`
- Create: `tests/00-uscita.in/.out`, `tests/01-eof-vuoto.in/.out`, `tests/02-comando-sconosciuto.in/.out`
- Create: `src/antani.mc`

**Interfaces:**
- Consumes: nulla.
- Produces (funzioni Monicelli usate da tutti i task successivi):
  - `scrivi con codice Necchi` — stampa il byte `codice`.
  - `scrivi8 con c1 … c8 Necchi` — stampa fino a 8 byte, saltando gli 0.
  - `aCapo` — stampa `\n`.
  - `Necchi leggi` — legge un byte da stdin, restituisce 0–255, oppure 256 a EOF.
  - `msgBenvenuto`, `msgPrompt`, `msgArrivederci`, `msgSconosciuto`.
  - Blocco principale diviso in sezioni marcate da righe `bituma [SEZIONE: <nome>]`: `dichiarazioni`, `lettura riga`, `azione`, `fine input`. I task successivi sostituiscono intere sezioni: una sezione va dalla sua riga marcatore (esclusa) fino alla riga marcatore successiva (esclusa) o fino alla riga `  e brematura anche, se continua maggiore di 0`.
  - `make` → `./antani`; `make test` → esegue `tests/run.sh`; `tests/run.sh 03` esegue solo i test il cui nome inizia per `03`.

- [ ] **Step 1: Installare le dipendenze e compilare `mcc`**

```bash
brew install llvm@21 ragel cmake
```

Creare `Makefile`:

```make
MCC ?= $(HOME)/mcc/bin/mcc
LLVM_DIR ?= $(shell brew --prefix llvm@21)/lib/cmake/llvm
MONICELLI_SRC ?= .build/monicelli

antani: src/antani.mc
	$(MCC) src/antani.mc -o antani

test: antani
	./tests/run.sh

mcc:
	test -d $(MONICELLI_SRC) || git clone --depth 1 https://github.com/esseks/monicelli $(MONICELLI_SRC)
	cmake -S $(MONICELLI_SRC) -B $(MONICELLI_SRC)/build -DCMAKE_INSTALL_PREFIX=$(HOME)/mcc -DLLVM_DIR=$(LLVM_DIR)
	cmake --build $(MONICELLI_SRC)/build --target install

clean:
	rm -f antani

.PHONY: test mcc clean
```

Creare `.gitignore`:

```
/antani
/.build/
```

Run: `make mcc`
Expected: termina con righe `-- Installing: …/mcc/bin/mcc`. Se cmake non trova LLVM, verificare `ls $(brew --prefix llvm@21)/lib/cmake/llvm/LLVMConfig.cmake`.

- [ ] **Step 2: Smoke test del compilatore**

```bash
~/mcc/bin/mcc .build/monicelli/examples/hello-world.mc -o /tmp/hello && /tmp/hello; echo " exit=$?"
```

Expected: stampa un saluto (`Hello, world!` con qualche variazione) e `exit=0`. Se il link fallisce, verificare che `c99` sia nel PATH (`which c99`).

- [ ] **Step 3: Harness di test**

Creare `tests/run.sh` (poi `chmod +x tests/run.sh`):

```sh
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
```

Creare `tests/intestazione.txt` (le due righe di benvenuto, riusate da tutti i `.out`):

```bash
printf 'Lei ha clacsonato! Inserisca i nomi, uno per riga (massimo 16).\nComandi: :o ordina  :l elenca  :c cancella  :q esci\n' > tests/intestazione.txt
```

- [ ] **Step 4: Scrivere i test che falliscono**

```bash
printf ':q\n' > tests/00-uscita.in
{ cat tests/intestazione.txt; printf '> Arrivederci.\n'; } > tests/00-uscita.out

printf '' > tests/01-eof-vuoto.in
{ cat tests/intestazione.txt; printf '> \n'; } > tests/01-eof-vuoto.out

printf ':x\nMario\n:\n   :Q\n' > tests/02-comando-sconosciuto.in
{ cat tests/intestazione.txt; printf '> Comando sconosciuto.\n> > Comando sconosciuto.\n> Arrivederci.\n'; } > tests/02-comando-sconosciuto.out
```

Nota: in questo task le righe-nome (`Mario`) sono lette e ignorate.

- [ ] **Step 5: Verificare che falliscano**

Run: `make test`
Expected: FAIL — `make` si ferma perché `src/antani.mc` non esiste.

- [ ] **Step 6: Scrivere lo scheletro `src/antani.mc`**

```
bituma antani.mc - ordinamento alfabetico di nomi in Monicelli puro.
bituma Regole: variabili in testa alle funzioni e mai nei cicli; flag come Necchi 0/1;
bituma un solo vaffanzum in fondo; niente parentesi, lo shift lega meno di piu' e meno.

bituma Stampa un byte.
blinda la supercazzola scrivi con codice Necchi o scherziamo?
  voglio car, Mascetti come se fosse codice
  car a posterdati

bituma Stampa fino a 8 byte, saltando gli zeri: i messaggi sono sequenze di scrivi8.
blinda la supercazzola scrivi8 con c1 Necchi, c2 Necchi, c3 Necchi, c4 Necchi, c5 Necchi, c6 Necchi, c7 Necchi, c8 Necchi o scherziamo?
  che cos'è c1? maggiore di 0: brematurata la supercazzola scrivi con c1 o scherziamo? e velocità di esecuzione
  che cos'è c2? maggiore di 0: brematurata la supercazzola scrivi con c2 o scherziamo? e velocità di esecuzione
  che cos'è c3? maggiore di 0: brematurata la supercazzola scrivi con c3 o scherziamo? e velocità di esecuzione
  che cos'è c4? maggiore di 0: brematurata la supercazzola scrivi con c4 o scherziamo? e velocità di esecuzione
  che cos'è c5? maggiore di 0: brematurata la supercazzola scrivi con c5 o scherziamo? e velocità di esecuzione
  che cos'è c6? maggiore di 0: brematurata la supercazzola scrivi con c6 o scherziamo? e velocità di esecuzione
  che cos'è c7? maggiore di 0: brematurata la supercazzola scrivi con c7 o scherziamo? e velocità di esecuzione
  che cos'è c8? maggiore di 0: brematurata la supercazzola scrivi con c8 o scherziamo? e velocità di esecuzione

blinda la supercazzola aCapo o scherziamo?
  brematurata la supercazzola scrivi con 10 o scherziamo?

bituma Legge un byte da stdin: 0-255, oppure 256 a fine input.
blinda la supercazzola Necchi leggi o scherziamo?
  voglio car, Mascetti come se fosse 0
  voglio valore, Necchi come se fosse 0
  mi porga car
  valore come se fosse car
  che cos'è valore?
    minore di 0: valore come se fosse valore più 256
    o magari 0: valore come se fosse 256
  e velocità di esecuzione
  vaffanzum valore!

bituma 'Lei ha clacsonato! Inserisca i nomi, uno per riga (massimo 16).\nComandi: :o ordina  :l elenca  :c cancella  :q esci\n'
blinda la supercazzola msgBenvenuto o scherziamo?
  brematurata la supercazzola scrivi8 con 76, 101, 105, 32, 104, 97, 32, 99 o scherziamo?
  brematurata la supercazzola scrivi8 con 108, 97, 99, 115, 111, 110, 97, 116 o scherziamo?
  brematurata la supercazzola scrivi8 con 111, 33, 32, 73, 110, 115, 101, 114 o scherziamo?
  brematurata la supercazzola scrivi8 con 105, 115, 99, 97, 32, 105, 32, 110 o scherziamo?
  brematurata la supercazzola scrivi8 con 111, 109, 105, 44, 32, 117, 110, 111 o scherziamo?
  brematurata la supercazzola scrivi8 con 32, 112, 101, 114, 32, 114, 105, 103 o scherziamo?
  brematurata la supercazzola scrivi8 con 97, 32, 40, 109, 97, 115, 115, 105 o scherziamo?
  brematurata la supercazzola scrivi8 con 109, 111, 32, 49, 54, 41, 46, 10 o scherziamo?
  brematurata la supercazzola scrivi8 con 67, 111, 109, 97, 110, 100, 105, 58 o scherziamo?
  brematurata la supercazzola scrivi8 con 32, 58, 111, 32, 111, 114, 100, 105 o scherziamo?
  brematurata la supercazzola scrivi8 con 110, 97, 32, 32, 58, 108, 32, 101 o scherziamo?
  brematurata la supercazzola scrivi8 con 108, 101, 110, 99, 97, 32, 32, 58 o scherziamo?
  brematurata la supercazzola scrivi8 con 99, 32, 99, 97, 110, 99, 101, 108 o scherziamo?
  brematurata la supercazzola scrivi8 con 108, 97, 32, 32, 58, 113, 32, 101 o scherziamo?
  brematurata la supercazzola scrivi8 con 115, 99, 105, 10, 0, 0, 0, 0 o scherziamo?

bituma '> '
blinda la supercazzola msgPrompt o scherziamo?
  brematurata la supercazzola scrivi8 con 62, 32, 0, 0, 0, 0, 0, 0 o scherziamo?

bituma 'Arrivederci.\n'
blinda la supercazzola msgArrivederci o scherziamo?
  brematurata la supercazzola scrivi8 con 65, 114, 114, 105, 118, 101, 100, 101 o scherziamo?
  brematurata la supercazzola scrivi8 con 114, 99, 105, 46, 10, 0, 0, 0 o scherziamo?

bituma 'Comando sconosciuto.\n'
blinda la supercazzola msgSconosciuto o scherziamo?
  brematurata la supercazzola scrivi8 con 67, 111, 109, 97, 110, 100, 111, 32 o scherziamo?
  brematurata la supercazzola scrivi8 con 115, 99, 111, 110, 111, 115, 99, 105 o scherziamo?
  brematurata la supercazzola scrivi8 con 117, 116, 111, 46, 10, 0, 0, 0 o scherziamo?

Lei ha clacsonato
bituma [SEZIONE: dichiarazioni]
  voglio byte, Necchi come se fosse 0
  voglio len, Necchi come se fosse 0
  voglio comando, Necchi come se fosse 0
  voglio lettera, Necchi come se fosse 0
  voglio fineRiga, Necchi come se fosse 0
  voglio fineInput, Necchi come se fosse 0
  voglio continua, Necchi come se fosse 1
  brematurata la supercazzola msgBenvenuto o scherziamo?
  stuzzica
    brematurata la supercazzola msgPrompt o scherziamo?
bituma [SEZIONE: lettura riga]
    len come se fosse 0
    comando come se fosse 0
    lettera come se fosse 0
    fineRiga come se fosse 0
    stuzzica
      byte come se fosse brematurata la supercazzola leggi o scherziamo?
      che cos'è byte?
        256: fineRiga come se fosse 1 fineInput come se fosse 1
        o magari 10: fineRiga come se fosse 1
        o magari 13:
        o tarapia tapioco:
          che cos'è comando?
            1: che cos'è lettera? 0: lettera come se fosse byte e velocità di esecuzione
            o tarapia tapioco:
              che cos'è byte?
                32:
                o magari 58: che cos'è len? 0: comando come se fosse 1 e velocità di esecuzione
                o tarapia tapioco: len come se fosse len più 1
              e velocità di esecuzione
          e velocità di esecuzione
      e velocità di esecuzione
    e brematura anche, se fineRiga minore di 1
bituma [SEZIONE: azione]
    che cos'è comando?
      1:
        che cos'è lettera?
          113: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o magari 81: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o tarapia tapioco: brematurata la supercazzola msgSconosciuto o scherziamo?
        e velocità di esecuzione
    e velocità di esecuzione
bituma [SEZIONE: fine input]
    che cos'è fineInput?
      1:
        che cos'è continua? 1: brematurata la supercazzola aCapo o scherziamo? e velocità di esecuzione
        continua come se fosse 0
    e velocità di esecuzione
  e brematura anche, se continua maggiore di 0
```

- [ ] **Step 7: Verificare che passino**

Run: `make && make test`
Expected: `3 passati, 0 falliti`. Se `mcc` segnala errori di sintassi, confrontare la riga indicata con le regole 5–8 in "Regole di Monicelli".

- [ ] **Step 8: Commit**

```bash
git add Makefile .gitignore tests src
git commit -m "Scheletro di antani: toolchain mcc, harness di test, comandi :q e EOF"
```

---

### Task 2: Nomi — impacchettamento, registri, elenco `:l`

**Files:**
- Modify: `src/antani.mc` (nuove funzioni prima di `Lei ha clacsonato`; sezioni `dichiarazioni`, `lettura riga`, `azione`; nuova sezione `stampa` dopo `fine input`)
- Test: `tests/03-elenco.in/.out`, `tests/04-spazi.in/.out`, `tests/05-lista-vuota.in/.out`

**Interfaces:**
- Consumes: `scrivi`, `scrivi8`, `aCapo`, `leggi`, `msg*` del Task 1.
- Produces:
  - `Necchi metti con parola Necchi, pos Necchi, codice Necchi` — `parola` con `codice` inserito nella posizione `pos` (0–3).
  - `Necchi prendi con parola Necchi, pos Necchi` — codice in posizione `pos` (0–3).
  - `Necchi carattere con w1 … w5 Necchi, p Necchi` — codice in posizione `p` (0–19) del nome.
  - `Necchi decodifica con byte Necchi` — codice 1–85, oppure 0 (non ammesso), 98 (non ammesso, riga finita), 99 (non ammesso, input finito). In questo task solo ASCII.
  - `scriviCodice con codice Necchi` — stampa il carattere (in questo task solo ASCII).
  - `stampaIndice con num Necchi` — stampa `num. `.
  - `stampaNome con w1 … w5 Necchi`.
  - `msgVuota`.
  - Variabili del blocco principale: slot `s<k>w<1..5>` (k 0–15), `n` (numero di nomi), `idx` (indice per il dispatch), registri `a1…a5`, `b1…b5`, flag `daOrdinare`, `daStampare`, `invalido`, `troncato`.

- [ ] **Step 1: Scrivere i test che falliscono**

```bash
printf 'Mario\nanna\nLuca\n:l\n:q\n' > tests/03-elenco.in
{ cat tests/intestazione.txt; printf '> > > > 1. Mario\n2. anna\n3. Luca\n> Arrivederci.\n'; } > tests/03-elenco.out

printf '  Mario  \n\n   \r\nDe Sica\r\nD'"'"'Amico\nAnna-Maria\nVan  Basten\n:l\n:q\n' > tests/04-spazi.in
{ cat tests/intestazione.txt; printf '> > > > > > > > 1. Mario\n2. De Sica\n3. D'"'"'Amico\n4. Anna-Maria\n5. Van  Basten\n> Arrivederci.\n'; } > tests/04-spazi.out

printf ':l\n:L\n:q\n' > tests/05-lista-vuota.in
{ cat tests/intestazione.txt; printf '> Lista vuota.\n> Lista vuota.\n> Arrivederci.\n'; } > tests/05-lista-vuota.out
```

- [ ] **Step 2: Verificare che falliscano**

Run: `make && tests/run.sh 0`
Expected: `03`, `04`, `05` FALLITO (`:l` è ancora "Comando sconosciuto"); `00`–`02` passano.

- [ ] **Step 3: Aggiungere le funzioni**

Inserire subito prima della riga `Lei ha clacsonato`:

```
bituma Inserisce codice (7 bit) nella posizione pos (0-3) di una parola: il carattere 0 sta nei bit alti.
blinda la supercazzola Necchi metti con parola Necchi, pos Necchi, codice Necchi o scherziamo?
  voglio spostamento, Necchi come se fosse 21 meno pos per 7
  voglio pezzo, Necchi come se fosse codice con scappellamento a sinistra per spostamento
  vaffanzum parola più pezzo!

bituma Estrae il codice in posizione pos (0-3): niente AND, si sottrae la parte alta.
blinda la supercazzola Necchi prendi con parola Necchi, pos Necchi o scherziamo?
  voglio spostamento, Necchi come se fosse 21 meno pos per 7
  voglio alto, Necchi come se fosse parola con scappellamento a destra per spostamento
  voglio sopra, Necchi come se fosse alto con scappellamento a destra per 7
  sopra come se fosse sopra con scappellamento a sinistra per 7
  vaffanzum alto meno sopra!

bituma Codice in posizione p (0-19) di un nome impacchettato in cinque parole.
blinda la supercazzola Necchi carattere con w1 Necchi, w2 Necchi, w3 Necchi, w4 Necchi, w5 Necchi, p Necchi o scherziamo?
  voglio risultato, Necchi come se fosse 0
  che cos'è p?
    minore di 4: risultato come se fosse brematurata la supercazzola prendi con w1, p o scherziamo?
    o magari minore di 8: risultato come se fosse brematurata la supercazzola prendi con w2, p meno 4 o scherziamo?
    o magari minore di 12: risultato come se fosse brematurata la supercazzola prendi con w3, p meno 8 o scherziamo?
    o magari minore di 16: risultato come se fosse brematurata la supercazzola prendi con w4, p meno 12 o scherziamo?
    o tarapia tapioco: risultato come se fosse brematurata la supercazzola prendi con w5, p meno 16 o scherziamo?
  e velocità di esecuzione
  vaffanzum risultato!

bituma Byte di input -> codice. 0 = non ammesso. Spazio e due punti li gestisce il blocco principale.
blinda la supercazzola Necchi decodifica con byte Necchi o scherziamo?
  voglio codice, Necchi come se fosse 0
  che cos'è byte?
    39: codice come se fosse 2
    o magari 45: codice come se fosse 3
    o magari minore di 65: codice come se fosse 0
    o magari minore di 91: codice come se fosse byte meno 55
    o magari minore di 97: codice come se fosse 0
    o magari minore di 123: codice come se fosse byte meno 57
  e velocità di esecuzione
  vaffanzum codice!

bituma Codice -> byte stampati.
blinda la supercazzola scriviCodice con codice Necchi o scherziamo?
  che cos'è codice?
    1: brematurata la supercazzola scrivi con 32 o scherziamo?
    o magari 2: brematurata la supercazzola scrivi con 39 o scherziamo?
    o magari 3: brematurata la supercazzola scrivi con 45 o scherziamo?
    o magari minore di 40: brematurata la supercazzola scrivi con codice più 55 o scherziamo?
    o magari minore di 70: brematurata la supercazzola scrivi con codice più 57 o scherziamo?
  e velocità di esecuzione

bituma Stampa "num. " (num da 1 a 16) cifra per cifra.
blinda la supercazzola stampaIndice con num Necchi o scherziamo?
  che cos'è num?
    maggiore di 9:
      brematurata la supercazzola scrivi con 49 o scherziamo?
      brematurata la supercazzola scrivi con num meno 10 più 48 o scherziamo?
    o tarapia tapioco:
      brematurata la supercazzola scrivi con num più 48 o scherziamo?
  e velocità di esecuzione
  brematurata la supercazzola scrivi con 46 o scherziamo?
  brematurata la supercazzola scrivi con 32 o scherziamo?

blinda la supercazzola stampaNome con w1 Necchi, w2 Necchi, w3 Necchi, w4 Necchi, w5 Necchi o scherziamo?
  voglio p, Necchi come se fosse 0
  voglio codice, Necchi come se fosse 0
  stuzzica
    codice come se fosse brematurata la supercazzola carattere con w1, w2, w3, w4, w5, p o scherziamo?
    che cos'è codice? maggiore di 0: brematurata la supercazzola scriviCodice con codice o scherziamo? e velocità di esecuzione
    p come se fosse p più 1
  e brematura anche, se p minore di 20

bituma 'Lista vuota.\n'
blinda la supercazzola msgVuota o scherziamo?
  brematurata la supercazzola scrivi8 con 76, 105, 115, 116, 97, 32, 118, 117 o scherziamo?
  brematurata la supercazzola scrivi8 con 111, 116, 97, 46, 10, 0, 0, 0 o scherziamo?

```

- [ ] **Step 4: Sostituire la sezione `dichiarazioni`**

Contenuto completo della sezione (dalla riga dopo `bituma [SEZIONE: dichiarazioni]` fino a `bituma [SEZIONE: lettura riga]` esclusa):

```
bituma I 16 slot: slot k = parole s<k>w1..s<k>w5.
  voglio s0w1, Necchi come se fosse 0 voglio s0w2, Necchi come se fosse 0 voglio s0w3, Necchi come se fosse 0 voglio s0w4, Necchi come se fosse 0 voglio s0w5, Necchi come se fosse 0
  voglio s1w1, Necchi come se fosse 0 voglio s1w2, Necchi come se fosse 0 voglio s1w3, Necchi come se fosse 0 voglio s1w4, Necchi come se fosse 0 voglio s1w5, Necchi come se fosse 0
  voglio s2w1, Necchi come se fosse 0 voglio s2w2, Necchi come se fosse 0 voglio s2w3, Necchi come se fosse 0 voglio s2w4, Necchi come se fosse 0 voglio s2w5, Necchi come se fosse 0
  voglio s3w1, Necchi come se fosse 0 voglio s3w2, Necchi come se fosse 0 voglio s3w3, Necchi come se fosse 0 voglio s3w4, Necchi come se fosse 0 voglio s3w5, Necchi come se fosse 0
  voglio s4w1, Necchi come se fosse 0 voglio s4w2, Necchi come se fosse 0 voglio s4w3, Necchi come se fosse 0 voglio s4w4, Necchi come se fosse 0 voglio s4w5, Necchi come se fosse 0
  voglio s5w1, Necchi come se fosse 0 voglio s5w2, Necchi come se fosse 0 voglio s5w3, Necchi come se fosse 0 voglio s5w4, Necchi come se fosse 0 voglio s5w5, Necchi come se fosse 0
  voglio s6w1, Necchi come se fosse 0 voglio s6w2, Necchi come se fosse 0 voglio s6w3, Necchi come se fosse 0 voglio s6w4, Necchi come se fosse 0 voglio s6w5, Necchi come se fosse 0
  voglio s7w1, Necchi come se fosse 0 voglio s7w2, Necchi come se fosse 0 voglio s7w3, Necchi come se fosse 0 voglio s7w4, Necchi come se fosse 0 voglio s7w5, Necchi come se fosse 0
  voglio s8w1, Necchi come se fosse 0 voglio s8w2, Necchi come se fosse 0 voglio s8w3, Necchi come se fosse 0 voglio s8w4, Necchi come se fosse 0 voglio s8w5, Necchi come se fosse 0
  voglio s9w1, Necchi come se fosse 0 voglio s9w2, Necchi come se fosse 0 voglio s9w3, Necchi come se fosse 0 voglio s9w4, Necchi come se fosse 0 voglio s9w5, Necchi come se fosse 0
  voglio s10w1, Necchi come se fosse 0 voglio s10w2, Necchi come se fosse 0 voglio s10w3, Necchi come se fosse 0 voglio s10w4, Necchi come se fosse 0 voglio s10w5, Necchi come se fosse 0
  voglio s11w1, Necchi come se fosse 0 voglio s11w2, Necchi come se fosse 0 voglio s11w3, Necchi come se fosse 0 voglio s11w4, Necchi come se fosse 0 voglio s11w5, Necchi come se fosse 0
  voglio s12w1, Necchi come se fosse 0 voglio s12w2, Necchi come se fosse 0 voglio s12w3, Necchi come se fosse 0 voglio s12w4, Necchi come se fosse 0 voglio s12w5, Necchi come se fosse 0
  voglio s13w1, Necchi come se fosse 0 voglio s13w2, Necchi come se fosse 0 voglio s13w3, Necchi come se fosse 0 voglio s13w4, Necchi come se fosse 0 voglio s13w5, Necchi come se fosse 0
  voglio s14w1, Necchi come se fosse 0 voglio s14w2, Necchi come se fosse 0 voglio s14w3, Necchi come se fosse 0 voglio s14w4, Necchi come se fosse 0 voglio s14w5, Necchi come se fosse 0
  voglio s15w1, Necchi come se fosse 0 voglio s15w2, Necchi come se fosse 0 voglio s15w3, Necchi come se fosse 0 voglio s15w4, Necchi come se fosse 0 voglio s15w5, Necchi come se fosse 0
  voglio n, Necchi come se fosse 0
  voglio idx, Necchi come se fosse 0
  voglio a1, Necchi come se fosse 0 voglio a2, Necchi come se fosse 0 voglio a3, Necchi come se fosse 0 voglio a4, Necchi come se fosse 0 voglio a5, Necchi come se fosse 0
  voglio b1, Necchi come se fosse 0 voglio b2, Necchi come se fosse 0 voglio b3, Necchi come se fosse 0 voglio b4, Necchi come se fosse 0 voglio b5, Necchi come se fosse 0
  voglio byte, Necchi come se fosse 0
  voglio codice, Necchi come se fosse 0
  voglio daEmettere, Necchi come se fosse 0
  voglio pos, Necchi come se fosse 0
  voglio len, Necchi come se fosse 0
  voglio spazi, Necchi come se fosse 0
  voglio comando, Necchi come se fosse 0
  voglio lettera, Necchi come se fosse 0
  voglio invalido, Necchi come se fosse 0
  voglio troncato, Necchi come se fosse 0
  voglio fineRiga, Necchi come se fosse 0
  voglio fineInput, Necchi come se fosse 0
  voglio continua, Necchi come se fosse 1
  voglio daOrdinare, Necchi come se fosse 0
  voglio daStampare, Necchi come se fosse 0
  voglio j, Necchi come se fosse 0
  voglio limite, Necchi come se fosse 0
  voglio scambiato, Necchi come se fosse 0
  voglio prima, Necchi come se fosse 0
  brematurata la supercazzola msgBenvenuto o scherziamo?
  stuzzica
    brematurata la supercazzola msgPrompt o scherziamo?
```

(`limite`, `scambiato`, `prima`, `b1…b5` servono dal Task 4; dichiararli ora evita di toccare di nuovo la sezione.)

- [ ] **Step 5: Sostituire la sezione `lettura riga`**

Gli spazi non vengono scritti subito: si contano in `spazi` e si emettono solo quando arriva un carattere valido. Così spazi iniziali e finali spariscono da soli.

```
    len come se fosse 0
    spazi come se fosse 0
    comando come se fosse 0
    lettera come se fosse 0
    invalido come se fosse 0
    troncato come se fosse 0
    fineRiga come se fosse 0
    daOrdinare come se fosse 0
    daStampare come se fosse 0
    a1 come se fosse 0 a2 come se fosse 0 a3 come se fosse 0 a4 come se fosse 0 a5 come se fosse 0
    stuzzica
      byte come se fosse brematurata la supercazzola leggi o scherziamo?
      che cos'è byte?
        256: fineRiga come se fosse 1 fineInput come se fosse 1
        o magari 10: fineRiga come se fosse 1
        o magari 13:
        o tarapia tapioco:
          che cos'è comando?
            1: che cos'è lettera? 0: lettera come se fosse byte e velocità di esecuzione
            o tarapia tapioco:
              che cos'è byte?
                32: che cos'è len? maggiore di 0: spazi come se fosse spazi più 1 e velocità di esecuzione
                o magari 58:
                  che cos'è len? 0: comando come se fosse 1 o tarapia tapioco: invalido come se fosse 1 e velocità di esecuzione
                o tarapia tapioco:
                  codice come se fosse brematurata la supercazzola decodifica con byte o scherziamo?
                  che cos'è codice?
                    0: invalido come se fosse 1
                    o magari 98: invalido come se fosse 1 fineRiga come se fosse 1
                    o magari 99: invalido come se fosse 1 fineRiga come se fosse 1 fineInput come se fosse 1
                    o tarapia tapioco:
bituma prima gli spazi in attesa (spazi volte il codice 1), poi il carattere; oltre 20 si tronca
                      stuzzica
                        che cos'è spazi? maggiore di 0: daEmettere come se fosse 1 o tarapia tapioco: daEmettere come se fosse codice e velocità di esecuzione
                        che cos'è len?
                          minore di 20:
                            pos come se fosse len
                            che cos'è pos?
                              minore di 4: a1 come se fosse brematurata la supercazzola metti con a1, pos, daEmettere o scherziamo?
                              o magari minore di 8: a2 come se fosse brematurata la supercazzola metti con a2, pos meno 4, daEmettere o scherziamo?
                              o magari minore di 12: a3 come se fosse brematurata la supercazzola metti con a3, pos meno 8, daEmettere o scherziamo?
                              o magari minore di 16: a4 come se fosse brematurata la supercazzola metti con a4, pos meno 12, daEmettere o scherziamo?
                              o tarapia tapioco: a5 come se fosse brematurata la supercazzola metti con a5, pos meno 16, daEmettere o scherziamo?
                            e velocità di esecuzione
                            len come se fosse len più 1
                          o tarapia tapioco: troncato come se fosse 1
                        e velocità di esecuzione
                        spazi come se fosse spazi meno 1
                      e brematura anche, se spazi maggiore uguale a 0
                      spazi come se fosse 0
                  e velocità di esecuzione
              e velocità di esecuzione
          e velocità di esecuzione
      e velocità di esecuzione
    e brematura anche, se fineRiga minore di 1
```

- [ ] **Step 6: Sostituire la sezione `azione`**

```
    che cos'è comando?
      1:
        che cos'è lettera?
          108: daStampare come se fosse 1
          o magari 76: daStampare come se fosse 1
          o magari 113: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o magari 81: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o tarapia tapioco: brematurata la supercazzola msgSconosciuto o scherziamo?
        e velocità di esecuzione
      o tarapia tapioco:
        che cos'è len?
          maggiore di 0:
            che cos'è n?
              minore di 16:
                idx come se fosse n
                che cos'è idx?
                  0: s0w1 come se fosse a1 s0w2 come se fosse a2 s0w3 come se fosse a3 s0w4 come se fosse a4 s0w5 come se fosse a5
                  o magari 1: s1w1 come se fosse a1 s1w2 come se fosse a2 s1w3 come se fosse a3 s1w4 come se fosse a4 s1w5 come se fosse a5
                  o magari 2: s2w1 come se fosse a1 s2w2 come se fosse a2 s2w3 come se fosse a3 s2w4 come se fosse a4 s2w5 come se fosse a5
                  o magari 3: s3w1 come se fosse a1 s3w2 come se fosse a2 s3w3 come se fosse a3 s3w4 come se fosse a4 s3w5 come se fosse a5
                  o magari 4: s4w1 come se fosse a1 s4w2 come se fosse a2 s4w3 come se fosse a3 s4w4 come se fosse a4 s4w5 come se fosse a5
                  o magari 5: s5w1 come se fosse a1 s5w2 come se fosse a2 s5w3 come se fosse a3 s5w4 come se fosse a4 s5w5 come se fosse a5
                  o magari 6: s6w1 come se fosse a1 s6w2 come se fosse a2 s6w3 come se fosse a3 s6w4 come se fosse a4 s6w5 come se fosse a5
                  o magari 7: s7w1 come se fosse a1 s7w2 come se fosse a2 s7w3 come se fosse a3 s7w4 come se fosse a4 s7w5 come se fosse a5
                  o magari 8: s8w1 come se fosse a1 s8w2 come se fosse a2 s8w3 come se fosse a3 s8w4 come se fosse a4 s8w5 come se fosse a5
                  o magari 9: s9w1 come se fosse a1 s9w2 come se fosse a2 s9w3 come se fosse a3 s9w4 come se fosse a4 s9w5 come se fosse a5
                  o magari 10: s10w1 come se fosse a1 s10w2 come se fosse a2 s10w3 come se fosse a3 s10w4 come se fosse a4 s10w5 come se fosse a5
                  o magari 11: s11w1 come se fosse a1 s11w2 come se fosse a2 s11w3 come se fosse a3 s11w4 come se fosse a4 s11w5 come se fosse a5
                  o magari 12: s12w1 come se fosse a1 s12w2 come se fosse a2 s12w3 come se fosse a3 s12w4 come se fosse a4 s12w5 come se fosse a5
                  o magari 13: s13w1 come se fosse a1 s13w2 come se fosse a2 s13w3 come se fosse a3 s13w4 come se fosse a4 s13w5 come se fosse a5
                  o magari 14: s14w1 come se fosse a1 s14w2 come se fosse a2 s14w3 come se fosse a3 s14w4 come se fosse a4 s14w5 come se fosse a5
                  o magari 15: s15w1 come se fosse a1 s15w2 come se fosse a2 s15w3 come se fosse a3 s15w4 come se fosse a4 s15w5 come se fosse a5
                e velocità di esecuzione
                n come se fosse n più 1
            e velocità di esecuzione
        e velocità di esecuzione
    e velocità di esecuzione
```

- [ ] **Step 7: Aggiungere la sezione `stampa`**

Subito prima della riga `  e brematura anche, se continua maggiore di 0` (in fondo al file):

```
bituma [SEZIONE: stampa]
    che cos'è daStampare?
      1:
        che cos'è n?
          0: brematurata la supercazzola msgVuota o scherziamo?
          o tarapia tapioco:
            j come se fosse 0
            stuzzica
              idx come se fosse j
              che cos'è idx?
                0: a1 come se fosse s0w1 a2 come se fosse s0w2 a3 come se fosse s0w3 a4 come se fosse s0w4 a5 come se fosse s0w5
                o magari 1: a1 come se fosse s1w1 a2 come se fosse s1w2 a3 come se fosse s1w3 a4 come se fosse s1w4 a5 come se fosse s1w5
                o magari 2: a1 come se fosse s2w1 a2 come se fosse s2w2 a3 come se fosse s2w3 a4 come se fosse s2w4 a5 come se fosse s2w5
                o magari 3: a1 come se fosse s3w1 a2 come se fosse s3w2 a3 come se fosse s3w3 a4 come se fosse s3w4 a5 come se fosse s3w5
                o magari 4: a1 come se fosse s4w1 a2 come se fosse s4w2 a3 come se fosse s4w3 a4 come se fosse s4w4 a5 come se fosse s4w5
                o magari 5: a1 come se fosse s5w1 a2 come se fosse s5w2 a3 come se fosse s5w3 a4 come se fosse s5w4 a5 come se fosse s5w5
                o magari 6: a1 come se fosse s6w1 a2 come se fosse s6w2 a3 come se fosse s6w3 a4 come se fosse s6w4 a5 come se fosse s6w5
                o magari 7: a1 come se fosse s7w1 a2 come se fosse s7w2 a3 come se fosse s7w3 a4 come se fosse s7w4 a5 come se fosse s7w5
                o magari 8: a1 come se fosse s8w1 a2 come se fosse s8w2 a3 come se fosse s8w3 a4 come se fosse s8w4 a5 come se fosse s8w5
                o magari 9: a1 come se fosse s9w1 a2 come se fosse s9w2 a3 come se fosse s9w3 a4 come se fosse s9w4 a5 come se fosse s9w5
                o magari 10: a1 come se fosse s10w1 a2 come se fosse s10w2 a3 come se fosse s10w3 a4 come se fosse s10w4 a5 come se fosse s10w5
                o magari 11: a1 come se fosse s11w1 a2 come se fosse s11w2 a3 come se fosse s11w3 a4 come se fosse s11w4 a5 come se fosse s11w5
                o magari 12: a1 come se fosse s12w1 a2 come se fosse s12w2 a3 come se fosse s12w3 a4 come se fosse s12w4 a5 come se fosse s12w5
                o magari 13: a1 come se fosse s13w1 a2 come se fosse s13w2 a3 come se fosse s13w3 a4 come se fosse s13w4 a5 come se fosse s13w5
                o magari 14: a1 come se fosse s14w1 a2 come se fosse s14w2 a3 come se fosse s14w3 a4 come se fosse s14w4 a5 come se fosse s14w5
                o magari 15: a1 come se fosse s15w1 a2 come se fosse s15w2 a3 come se fosse s15w3 a4 come se fosse s15w4 a5 come se fosse s15w5
              e velocità di esecuzione
              brematurata la supercazzola stampaIndice con j più 1 o scherziamo?
              brematurata la supercazzola stampaNome con a1, a2, a3, a4, a5 o scherziamo?
              brematurata la supercazzola aCapo o scherziamo?
              j come se fosse j più 1
            e brematura anche, se j minore di n
        e velocità di esecuzione
    e velocità di esecuzione
```

- [ ] **Step 8: Verificare che passino**

Run: `make && make test`
Expected: `6 passati, 0 falliti`.

- [ ] **Step 9: Commit**

```bash
git add src/antani.mc tests
git commit -m "Nomi impacchettati in registri, comando :l, rimozione spazi"
```

---

### Task 3: Validazione — troncamento, caratteri non ammessi, lista piena, accentate UTF-8

**Files:**
- Modify: `src/antani.mc` (funzioni `decodifica` e `scriviCodice` sostituite; nuovi messaggi; sezione `azione`)
- Test: `tests/06-troncamento`, `tests/07-invalido`, `tests/08-utf8-spezzato`, `tests/09-piena`, `tests/10-accentate` (`.in`/`.out`)

**Interfaces:**
- Consumes: funzioni e variabili del Task 2 (`decodifica` restituisce già 98/99 nel contratto; qui si implementa).
- Produces: `decodifica` e `scriviCodice` complete (codici 70–75, 80–85); `msgPiena`, `msgTroncato`, `msgInvalido`.

- [ ] **Step 1: Scrivere i test che falliscono**

```bash
printf 'Abcdefghijklmnopqrstuvwxyz\nAbcdefghijklmnopqrst   \n:l\n:q\n' > tests/06-troncamento.in
{ cat tests/intestazione.txt; printf '> Nome troncato a 20 caratteri.\n> > 1. Abcdefghijklmnopqrst\n2. Abcdefghijklmnopqrst\n> Arrivederci.\n'; } > tests/06-troncamento.out

printf 'R2D2\nMa:rio\nLuca\n:l\n:q\n' > tests/07-invalido.in
{ cat tests/intestazione.txt; printf '> Carattere non ammesso: nome scartato.\n> Carattere non ammesso: nome scartato.\n> > 1. Luca\n> Arrivederci.\n'; } > tests/07-invalido.out

printf 'Nicol\303\nLuca\n:l\n:q\n' > tests/08-utf8-spezzato.in
{ cat tests/intestazione.txt; printf '> Carattere non ammesso: nome scartato.\n> > 1. Luca\n> Arrivederci.\n'; } > tests/08-utf8-spezzato.out

printf 'A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\n:l\n:q\n' > tests/09-piena.in
{ cat tests/intestazione.txt
  printf '> > > > > > > > > > > > > > > > > Lista piena: nome scartato.\n> '
  printf '1. A\n2. B\n3. C\n4. D\n5. E\n6. F\n7. G\n8. H\n9. I\n10. J\n11. K\n12. L\n13. M\n14. N\n15. O\n16. P\n'
  printf '> Arrivederci.\n'; } > tests/09-piena.out

printf 'Niccolò\nàèéìòù\nÀÈÉÌÒÙ\nPerù\n:l\n:q\n' > tests/10-accentate.in
{ cat tests/intestazione.txt; printf '> > > > > 1. Niccolò\n2. àèéìòù\n3. ÀÈÉÌÒÙ\n4. Perù\n> Arrivederci.\n'; } > tests/10-accentate.out
```

(Il file sorgente di questo piano e il terminale sono UTF-8: `printf` scrive le accentate come sequenze `C3 xx`. Verificare con `od -c tests/10-accentate.in | head -2`.)

- [ ] **Step 2: Verificare che falliscano**

Run: `make && make test`
Expected: FALLITO su `06` (manca il messaggio), `07`, `08`, `09`, `10`; gli altri passano.

- [ ] **Step 3: Sostituire `decodifica` e `scriviCodice` e aggiungere i messaggi**

Sostituire l'intera funzione `decodifica` (dalla riga-commento che la precede fino alla sua riga `vaffanzum codice!` inclusa) con:

```
bituma Byte di input -> codice. 0 = non ammesso; 98 = non ammesso e riga finita; 99 = non ammesso e input finito.
bituma Spazio e due punti li gestisce il blocco principale. 195 (0xC3) apre una accentata UTF-8.
blinda la supercazzola Necchi decodifica con byte Necchi o scherziamo?
  voglio codice, Necchi come se fosse 0
  voglio seconda, Necchi come se fosse 0
  che cos'è byte?
    39: codice come se fosse 2
    o magari 45: codice come se fosse 3
    o magari minore di 65: codice come se fosse 0
    o magari minore di 91: codice come se fosse byte meno 55
    o magari minore di 97: codice come se fosse 0
    o magari minore di 123: codice come se fosse byte meno 57
    o magari 195:
      seconda come se fosse brematurata la supercazzola leggi o scherziamo?
      che cos'è seconda?
        160: codice come se fosse 70
        o magari 168: codice come se fosse 71
        o magari 169: codice come se fosse 72
        o magari 172: codice come se fosse 73
        o magari 178: codice come se fosse 74
        o magari 185: codice come se fosse 75
        o magari 128: codice come se fosse 80
        o magari 136: codice come se fosse 81
        o magari 137: codice come se fosse 82
        o magari 140: codice come se fosse 83
        o magari 146: codice come se fosse 84
        o magari 153: codice come se fosse 85
        o magari 10: codice come se fosse 98
        o magari 256: codice come se fosse 99
      e velocità di esecuzione
  e velocità di esecuzione
  vaffanzum codice!
```

Sostituire l'intera funzione `scriviCodice` con:

```
bituma Codice -> byte stampati (le accentate come coppia UTF-8 195, xx).
blinda la supercazzola scriviCodice con codice Necchi o scherziamo?
  voglio seconda, Necchi come se fosse 0
  che cos'è codice?
    1: brematurata la supercazzola scrivi con 32 o scherziamo?
    o magari 2: brematurata la supercazzola scrivi con 39 o scherziamo?
    o magari 3: brematurata la supercazzola scrivi con 45 o scherziamo?
    o magari minore di 40: brematurata la supercazzola scrivi con codice più 55 o scherziamo?
    o magari minore di 70: brematurata la supercazzola scrivi con codice più 57 o scherziamo?
    o tarapia tapioco:
      che cos'è codice?
        70: seconda come se fosse 160
        o magari 71: seconda come se fosse 168
        o magari 72: seconda come se fosse 169
        o magari 73: seconda come se fosse 172
        o magari 74: seconda come se fosse 178
        o magari 75: seconda come se fosse 185
        o magari 80: seconda come se fosse 128
        o magari 81: seconda come se fosse 136
        o magari 82: seconda come se fosse 137
        o magari 83: seconda come se fosse 140
        o magari 84: seconda come se fosse 146
        o magari 85: seconda come se fosse 153
      e velocità di esecuzione
      brematurata la supercazzola scrivi con 195 o scherziamo?
      brematurata la supercazzola scrivi con seconda o scherziamo?
  e velocità di esecuzione
```

Aggiungere, subito prima di `Lei ha clacsonato`:

```
bituma 'Lista piena: nome scartato.\n'
blinda la supercazzola msgPiena o scherziamo?
  brematurata la supercazzola scrivi8 con 76, 105, 115, 116, 97, 32, 112, 105 o scherziamo?
  brematurata la supercazzola scrivi8 con 101, 110, 97, 58, 32, 110, 111, 109 o scherziamo?
  brematurata la supercazzola scrivi8 con 101, 32, 115, 99, 97, 114, 116, 97 o scherziamo?
  brematurata la supercazzola scrivi8 con 116, 111, 46, 10, 0, 0, 0, 0 o scherziamo?

bituma 'Nome troncato a 20 caratteri.\n'
blinda la supercazzola msgTroncato o scherziamo?
  brematurata la supercazzola scrivi8 con 78, 111, 109, 101, 32, 116, 114, 111 o scherziamo?
  brematurata la supercazzola scrivi8 con 110, 99, 97, 116, 111, 32, 97, 32 o scherziamo?
  brematurata la supercazzola scrivi8 con 50, 48, 32, 99, 97, 114, 97, 116 o scherziamo?
  brematurata la supercazzola scrivi8 con 116, 101, 114, 105, 46, 10, 0, 0 o scherziamo?

bituma 'Carattere non ammesso: nome scartato.\n'
blinda la supercazzola msgInvalido o scherziamo?
  brematurata la supercazzola scrivi8 con 67, 97, 114, 97, 116, 116, 101, 114 o scherziamo?
  brematurata la supercazzola scrivi8 con 101, 32, 110, 111, 110, 32, 97, 109 o scherziamo?
  brematurata la supercazzola scrivi8 con 109, 101, 115, 115, 111, 58, 32, 110 o scherziamo?
  brematurata la supercazzola scrivi8 con 111, 109, 101, 32, 115, 99, 97, 114 o scherziamo?
  brematurata la supercazzola scrivi8 con 116, 97, 116, 111, 46, 10, 0, 0 o scherziamo?

```

- [ ] **Step 4: Sostituire la sezione `azione`**

```
    che cos'è comando?
      1:
        che cos'è lettera?
          108: daStampare come se fosse 1
          o magari 76: daStampare come se fosse 1
          o magari 113: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o magari 81: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o tarapia tapioco: brematurata la supercazzola msgSconosciuto o scherziamo?
        e velocità di esecuzione
      o tarapia tapioco:
        che cos'è invalido?
          1: brematurata la supercazzola msgInvalido o scherziamo?
          o tarapia tapioco:
            che cos'è len?
              maggiore di 0:
                che cos'è n?
                  minore di 16:
                    idx come se fosse n
                    che cos'è idx?
                      0: s0w1 come se fosse a1 s0w2 come se fosse a2 s0w3 come se fosse a3 s0w4 come se fosse a4 s0w5 come se fosse a5
                      o magari 1: s1w1 come se fosse a1 s1w2 come se fosse a2 s1w3 come se fosse a3 s1w4 come se fosse a4 s1w5 come se fosse a5
                      o magari 2: s2w1 come se fosse a1 s2w2 come se fosse a2 s2w3 come se fosse a3 s2w4 come se fosse a4 s2w5 come se fosse a5
                      o magari 3: s3w1 come se fosse a1 s3w2 come se fosse a2 s3w3 come se fosse a3 s3w4 come se fosse a4 s3w5 come se fosse a5
                      o magari 4: s4w1 come se fosse a1 s4w2 come se fosse a2 s4w3 come se fosse a3 s4w4 come se fosse a4 s4w5 come se fosse a5
                      o magari 5: s5w1 come se fosse a1 s5w2 come se fosse a2 s5w3 come se fosse a3 s5w4 come se fosse a4 s5w5 come se fosse a5
                      o magari 6: s6w1 come se fosse a1 s6w2 come se fosse a2 s6w3 come se fosse a3 s6w4 come se fosse a4 s6w5 come se fosse a5
                      o magari 7: s7w1 come se fosse a1 s7w2 come se fosse a2 s7w3 come se fosse a3 s7w4 come se fosse a4 s7w5 come se fosse a5
                      o magari 8: s8w1 come se fosse a1 s8w2 come se fosse a2 s8w3 come se fosse a3 s8w4 come se fosse a4 s8w5 come se fosse a5
                      o magari 9: s9w1 come se fosse a1 s9w2 come se fosse a2 s9w3 come se fosse a3 s9w4 come se fosse a4 s9w5 come se fosse a5
                      o magari 10: s10w1 come se fosse a1 s10w2 come se fosse a2 s10w3 come se fosse a3 s10w4 come se fosse a4 s10w5 come se fosse a5
                      o magari 11: s11w1 come se fosse a1 s11w2 come se fosse a2 s11w3 come se fosse a3 s11w4 come se fosse a4 s11w5 come se fosse a5
                      o magari 12: s12w1 come se fosse a1 s12w2 come se fosse a2 s12w3 come se fosse a3 s12w4 come se fosse a4 s12w5 come se fosse a5
                      o magari 13: s13w1 come se fosse a1 s13w2 come se fosse a2 s13w3 come se fosse a3 s13w4 come se fosse a4 s13w5 come se fosse a5
                      o magari 14: s14w1 come se fosse a1 s14w2 come se fosse a2 s14w3 come se fosse a3 s14w4 come se fosse a4 s14w5 come se fosse a5
                      o magari 15: s15w1 come se fosse a1 s15w2 come se fosse a2 s15w3 come se fosse a3 s15w4 come se fosse a4 s15w5 come se fosse a5
                    e velocità di esecuzione
                    n come se fosse n più 1
                    che cos'è troncato? 1: brematurata la supercazzola msgTroncato o scherziamo? e velocità di esecuzione
                  o tarapia tapioco: brematurata la supercazzola msgPiena o scherziamo?
                e velocità di esecuzione
            e velocità di esecuzione
        e velocità di esecuzione
    e velocità di esecuzione
```

- [ ] **Step 5: Verificare che passino**

Run: `make && make test`
Expected: `11 passati, 0 falliti`.

- [ ] **Step 6: Commit**

```bash
git add src/antani.mc tests
git commit -m "Validazione: troncamento, caratteri non ammessi, lista piena, accentate UTF-8"
```

---

### Task 4: Ordinamento — collazione, bubble sort, `:o` ed EOF

**Files:**
- Modify: `src/antani.mc` (funzioni `rango`, `precede`; sezioni `azione`, `fine input`; nuova sezione `ordinamento` tra `fine input` e `stampa`)
- Test: `tests/11-ordina-base`, `tests/12-collazione`, `tests/13-stabilita`, `tests/14-peggiore`, `tests/15-eof-ordina` (`.in`/`.out`)

**Interfaces:**
- Consumes: `carattere`, registri `a*`/`b*`, slot, `idx`, `n`, `j`, `limite`, `scambiato`, `prima`, `daOrdinare`, `daStampare`.
- Produces:
  - `Necchi rango con codice Necchi` — chiave di collazione.
  - `Necchi precede con x1 … x5 Necchi, y1 … y5 Necchi` — 1 se X < Y strettamente, altrimenti 0.

- [ ] **Step 1: Scrivere i test che falliscono**

```bash
printf 'Mario\nanna\nLuca\n:o\n:l\n:q\n' > tests/11-ordina-base.in
{ cat tests/intestazione.txt; printf '> > > > 1. anna\n2. Luca\n3. Mario\n> 1. anna\n2. Luca\n3. Mario\n> Arrivederci.\n'; } > tests/11-ordina-base.out

printf 'zeta\nZorro\nÈlia\nelena\nEmma\nOrlando\nòscar\nDe Sica\nDe Santis\nD'"'"'Amico\nDeAndre\n:O\n:q\n' > tests/12-collazione.in
{ cat tests/intestazione.txt
  printf '> > > > > > > > > > > > '
  printf '1. D'"'"'Amico\n2. De Santis\n3. De Sica\n4. DeAndre\n5. elena\n6. Èlia\n7. Emma\n8. Orlando\n9. òscar\n10. zeta\n11. Zorro\n'
  printf '> Arrivederci.\n'; } > tests/12-collazione.out

printf 'Bea\nAnna\nann\nanna\nANNA\nànna\n:o\n:q\n' > tests/13-stabilita.in
{ cat tests/intestazione.txt; printf '> > > > > > > 1. ann\n2. Anna\n3. anna\n4. ANNA\n5. ànna\n6. Bea\n> Arrivederci.\n'; } > tests/13-stabilita.out

: > tests/14-peggiore.in
for c in p o n m l k j i h g f e d c b a; do printf 'Aaaaaaaaaaaaaaaaa%s\n' "$c" >> tests/14-peggiore.in; done
printf ':o\n:q\n' >> tests/14-peggiore.in
{ cat tests/intestazione.txt
  printf '> > > > > > > > > > > > > > > > > '
  k=1; for c in a b c d e f g h i j k l m n o p; do printf '%d. Aaaaaaaaaaaaaaaaa%s\n' "$k" "$c"; k=$((k + 1)); done
  printf '> Arrivederci.\n'; } > tests/14-peggiore.out

printf 'Mario\nanna\nLuca' > tests/15-eof-ordina.in
{ cat tests/intestazione.txt; printf '> > > \n1. anna\n2. Luca\n3. Mario\n'; } > tests/15-eof-ordina.out
```

Perché questi attesi: `'` (rango 2) e spazio (1) precedono ogni lettera (≥10), quindi `D'Amico` < `De Santis` < `De Sica` < `DeAndre`; `È`/`ò` valgono `e`/`o`; `ann` è prefisso di `anna` e viene prima; `Anna anna ANNA ànna` hanno chiave uguale e restano nell'ordine d'inserimento. `14` differisce solo al 18° carattere (parola 5) ed è in ordine inverso: 15 passate di bubble sort.

- [ ] **Step 2: Verificare che falliscano**

Run: `make && make test`
Expected: FALLITO su `11`–`15` (`:o` è "Comando sconosciuto", EOF non ordina).

- [ ] **Step 3: Aggiungere `rango` e `precede`**

Subito prima di `Lei ha clacsonato`:

```
bituma Chiave di collazione: maiuscole, minuscole e accentate valgono la lettera base (a=10 ... z=35).
blinda la supercazzola Necchi rango con codice Necchi o scherziamo?
  voglio r, Necchi come se fosse codice
  che cos'è codice?
    minore di 40:
    o magari minore di 70: r come se fosse codice meno 30
    o magari 70: r come se fosse 10
    o magari 80: r come se fosse 10
    o magari 71: r come se fosse 14
    o magari 72: r come se fosse 14
    o magari 81: r come se fosse 14
    o magari 82: r come se fosse 14
    o magari 73: r come se fosse 18
    o magari 83: r come se fosse 18
    o magari 74: r come se fosse 24
    o magari 84: r come se fosse 24
    o magari 75: r come se fosse 30
    o magari 85: r come se fosse 30
  e velocità di esecuzione
  vaffanzum r!

bituma 1 se il nome X viene strettamente prima del nome Y, altrimenti 0 (a parita' resta 0: ordinamento stabile).
blinda la supercazzola Necchi precede con x1 Necchi, x2 Necchi, x3 Necchi, x4 Necchi, x5 Necchi, y1 Necchi, y2 Necchi, y3 Necchi, y4 Necchi, y5 Necchi o scherziamo?
  voglio p, Necchi come se fosse 0
  voglio esito, Necchi come se fosse 0
  voglio deciso, Necchi come se fosse 0
  voglio rx, Necchi come se fosse 0
  voglio ry, Necchi come se fosse 0
  stuzzica
    rx come se fosse brematurata la supercazzola carattere con x1, x2, x3, x4, x5, p o scherziamo?
    rx come se fosse brematurata la supercazzola rango con rx o scherziamo?
    ry come se fosse brematurata la supercazzola carattere con y1, y2, y3, y4, y5, p o scherziamo?
    ry come se fosse brematurata la supercazzola rango con ry o scherziamo?
    che cos'è rx?
      minore di ry: esito come se fosse 1 deciso come se fosse 1
      o magari maggiore di ry: deciso come se fosse 1
      o magari 0: deciso come se fosse 1
    e velocità di esecuzione
    p come se fosse p più 1
    che cos'è p? 20: deciso come se fosse 1 e velocità di esecuzione
  e brematura anche, se deciso minore di 1
  vaffanzum esito!
```

- [ ] **Step 4: Sostituire la sezione `azione`**

```
    che cos'è comando?
      1:
        che cos'è lettera?
          111: daOrdinare come se fosse 1 daStampare come se fosse 1
          o magari 79: daOrdinare come se fosse 1 daStampare come se fosse 1
          o magari 108: daStampare come se fosse 1
          o magari 76: daStampare come se fosse 1
          o magari 113: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o magari 81: brematurata la supercazzola msgArrivederci o scherziamo? continua come se fosse 0
          o tarapia tapioco: brematurata la supercazzola msgSconosciuto o scherziamo?
        e velocità di esecuzione
      o tarapia tapioco:
        che cos'è invalido?
          1: brematurata la supercazzola msgInvalido o scherziamo?
          o tarapia tapioco:
            che cos'è len?
              maggiore di 0:
                che cos'è n?
                  minore di 16:
                    idx come se fosse n
                    che cos'è idx?
                      0: s0w1 come se fosse a1 s0w2 come se fosse a2 s0w3 come se fosse a3 s0w4 come se fosse a4 s0w5 come se fosse a5
                      o magari 1: s1w1 come se fosse a1 s1w2 come se fosse a2 s1w3 come se fosse a3 s1w4 come se fosse a4 s1w5 come se fosse a5
                      o magari 2: s2w1 come se fosse a1 s2w2 come se fosse a2 s2w3 come se fosse a3 s2w4 come se fosse a4 s2w5 come se fosse a5
                      o magari 3: s3w1 come se fosse a1 s3w2 come se fosse a2 s3w3 come se fosse a3 s3w4 come se fosse a4 s3w5 come se fosse a5
                      o magari 4: s4w1 come se fosse a1 s4w2 come se fosse a2 s4w3 come se fosse a3 s4w4 come se fosse a4 s4w5 come se fosse a5
                      o magari 5: s5w1 come se fosse a1 s5w2 come se fosse a2 s5w3 come se fosse a3 s5w4 come se fosse a4 s5w5 come se fosse a5
                      o magari 6: s6w1 come se fosse a1 s6w2 come se fosse a2 s6w3 come se fosse a3 s6w4 come se fosse a4 s6w5 come se fosse a5
                      o magari 7: s7w1 come se fosse a1 s7w2 come se fosse a2 s7w3 come se fosse a3 s7w4 come se fosse a4 s7w5 come se fosse a5
                      o magari 8: s8w1 come se fosse a1 s8w2 come se fosse a2 s8w3 come se fosse a3 s8w4 come se fosse a4 s8w5 come se fosse a5
                      o magari 9: s9w1 come se fosse a1 s9w2 come se fosse a2 s9w3 come se fosse a3 s9w4 come se fosse a4 s9w5 come se fosse a5
                      o magari 10: s10w1 come se fosse a1 s10w2 come se fosse a2 s10w3 come se fosse a3 s10w4 come se fosse a4 s10w5 come se fosse a5
                      o magari 11: s11w1 come se fosse a1 s11w2 come se fosse a2 s11w3 come se fosse a3 s11w4 come se fosse a4 s11w5 come se fosse a5
                      o magari 12: s12w1 come se fosse a1 s12w2 come se fosse a2 s12w3 come se fosse a3 s12w4 come se fosse a4 s12w5 come se fosse a5
                      o magari 13: s13w1 come se fosse a1 s13w2 come se fosse a2 s13w3 come se fosse a3 s13w4 come se fosse a4 s13w5 come se fosse a5
                      o magari 14: s14w1 come se fosse a1 s14w2 come se fosse a2 s14w3 come se fosse a3 s14w4 come se fosse a4 s14w5 come se fosse a5
                      o magari 15: s15w1 come se fosse a1 s15w2 come se fosse a2 s15w3 come se fosse a3 s15w4 come se fosse a4 s15w5 come se fosse a5
                    e velocità di esecuzione
                    n come se fosse n più 1
                    che cos'è troncato? 1: brematurata la supercazzola msgTroncato o scherziamo? e velocità di esecuzione
                  o tarapia tapioco: brematurata la supercazzola msgPiena o scherziamo?
                e velocità di esecuzione
            e velocità di esecuzione
        e velocità di esecuzione
    e velocità di esecuzione
```

- [ ] **Step 5: Sostituire la sezione `fine input` e aggiungere la sezione `ordinamento`**

Sostituire tutto da `bituma [SEZIONE: fine input]` (incluso) fino a `bituma [SEZIONE: stampa]` (escluso) con:

```
bituma [SEZIONE: fine input]
    che cos'è fineInput?
      1:
        che cos'è continua?
          1:
            brematurata la supercazzola aCapo o scherziamo?
            che cos'è n? maggiore di 0: daOrdinare come se fosse 1 daStampare come se fosse 1 e velocità di esecuzione
        e velocità di esecuzione
        continua come se fosse 0
    e velocità di esecuzione
bituma [SEZIONE: ordinamento]
bituma Bubble sort stabile: si scambia solo se il successivo precede strettamente il corrente.
    che cos'è daOrdinare?
      1:
        che cos'è n?
          maggiore di 1:
            limite come se fosse n meno 1
            stuzzica
              scambiato come se fosse 0
              j come se fosse 0
              stuzzica
                idx come se fosse j
                che cos'è idx?
                  0: a1 come se fosse s0w1 a2 come se fosse s0w2 a3 come se fosse s0w3 a4 come se fosse s0w4 a5 come se fosse s0w5
                  o magari 1: a1 come se fosse s1w1 a2 come se fosse s1w2 a3 come se fosse s1w3 a4 come se fosse s1w4 a5 come se fosse s1w5
                  o magari 2: a1 come se fosse s2w1 a2 come se fosse s2w2 a3 come se fosse s2w3 a4 come se fosse s2w4 a5 come se fosse s2w5
                  o magari 3: a1 come se fosse s3w1 a2 come se fosse s3w2 a3 come se fosse s3w3 a4 come se fosse s3w4 a5 come se fosse s3w5
                  o magari 4: a1 come se fosse s4w1 a2 come se fosse s4w2 a3 come se fosse s4w3 a4 come se fosse s4w4 a5 come se fosse s4w5
                  o magari 5: a1 come se fosse s5w1 a2 come se fosse s5w2 a3 come se fosse s5w3 a4 come se fosse s5w4 a5 come se fosse s5w5
                  o magari 6: a1 come se fosse s6w1 a2 come se fosse s6w2 a3 come se fosse s6w3 a4 come se fosse s6w4 a5 come se fosse s6w5
                  o magari 7: a1 come se fosse s7w1 a2 come se fosse s7w2 a3 come se fosse s7w3 a4 come se fosse s7w4 a5 come se fosse s7w5
                  o magari 8: a1 come se fosse s8w1 a2 come se fosse s8w2 a3 come se fosse s8w3 a4 come se fosse s8w4 a5 come se fosse s8w5
                  o magari 9: a1 come se fosse s9w1 a2 come se fosse s9w2 a3 come se fosse s9w3 a4 come se fosse s9w4 a5 come se fosse s9w5
                  o magari 10: a1 come se fosse s10w1 a2 come se fosse s10w2 a3 come se fosse s10w3 a4 come se fosse s10w4 a5 come se fosse s10w5
                  o magari 11: a1 come se fosse s11w1 a2 come se fosse s11w2 a3 come se fosse s11w3 a4 come se fosse s11w4 a5 come se fosse s11w5
                  o magari 12: a1 come se fosse s12w1 a2 come se fosse s12w2 a3 come se fosse s12w3 a4 come se fosse s12w4 a5 come se fosse s12w5
                  o magari 13: a1 come se fosse s13w1 a2 come se fosse s13w2 a3 come se fosse s13w3 a4 come se fosse s13w4 a5 come se fosse s13w5
                  o magari 14: a1 come se fosse s14w1 a2 come se fosse s14w2 a3 come se fosse s14w3 a4 come se fosse s14w4 a5 come se fosse s14w5
                  o magari 15: a1 come se fosse s15w1 a2 come se fosse s15w2 a3 come se fosse s15w3 a4 come se fosse s15w4 a5 come se fosse s15w5
                e velocità di esecuzione
                idx come se fosse j più 1
                che cos'è idx?
                  0: b1 come se fosse s0w1 b2 come se fosse s0w2 b3 come se fosse s0w3 b4 come se fosse s0w4 b5 come se fosse s0w5
                  o magari 1: b1 come se fosse s1w1 b2 come se fosse s1w2 b3 come se fosse s1w3 b4 come se fosse s1w4 b5 come se fosse s1w5
                  o magari 2: b1 come se fosse s2w1 b2 come se fosse s2w2 b3 come se fosse s2w3 b4 come se fosse s2w4 b5 come se fosse s2w5
                  o magari 3: b1 come se fosse s3w1 b2 come se fosse s3w2 b3 come se fosse s3w3 b4 come se fosse s3w4 b5 come se fosse s3w5
                  o magari 4: b1 come se fosse s4w1 b2 come se fosse s4w2 b3 come se fosse s4w3 b4 come se fosse s4w4 b5 come se fosse s4w5
                  o magari 5: b1 come se fosse s5w1 b2 come se fosse s5w2 b3 come se fosse s5w3 b4 come se fosse s5w4 b5 come se fosse s5w5
                  o magari 6: b1 come se fosse s6w1 b2 come se fosse s6w2 b3 come se fosse s6w3 b4 come se fosse s6w4 b5 come se fosse s6w5
                  o magari 7: b1 come se fosse s7w1 b2 come se fosse s7w2 b3 come se fosse s7w3 b4 come se fosse s7w4 b5 come se fosse s7w5
                  o magari 8: b1 come se fosse s8w1 b2 come se fosse s8w2 b3 come se fosse s8w3 b4 come se fosse s8w4 b5 come se fosse s8w5
                  o magari 9: b1 come se fosse s9w1 b2 come se fosse s9w2 b3 come se fosse s9w3 b4 come se fosse s9w4 b5 come se fosse s9w5
                  o magari 10: b1 come se fosse s10w1 b2 come se fosse s10w2 b3 come se fosse s10w3 b4 come se fosse s10w4 b5 come se fosse s10w5
                  o magari 11: b1 come se fosse s11w1 b2 come se fosse s11w2 b3 come se fosse s11w3 b4 come se fosse s11w4 b5 come se fosse s11w5
                  o magari 12: b1 come se fosse s12w1 b2 come se fosse s12w2 b3 come se fosse s12w3 b4 come se fosse s12w4 b5 come se fosse s12w5
                  o magari 13: b1 come se fosse s13w1 b2 come se fosse s13w2 b3 come se fosse s13w3 b4 come se fosse s13w4 b5 come se fosse s13w5
                  o magari 14: b1 come se fosse s14w1 b2 come se fosse s14w2 b3 come se fosse s14w3 b4 come se fosse s14w4 b5 come se fosse s14w5
                  o magari 15: b1 come se fosse s15w1 b2 come se fosse s15w2 b3 come se fosse s15w3 b4 come se fosse s15w4 b5 come se fosse s15w5
                e velocità di esecuzione
                prima come se fosse brematurata la supercazzola precede con b1, b2, b3, b4, b5, a1, a2, a3, a4, a5 o scherziamo?
                che cos'è prima?
                  1:
                    idx come se fosse j
                    che cos'è idx?
                      0: s0w1 come se fosse b1 s0w2 come se fosse b2 s0w3 come se fosse b3 s0w4 come se fosse b4 s0w5 come se fosse b5
                      o magari 1: s1w1 come se fosse b1 s1w2 come se fosse b2 s1w3 come se fosse b3 s1w4 come se fosse b4 s1w5 come se fosse b5
                      o magari 2: s2w1 come se fosse b1 s2w2 come se fosse b2 s2w3 come se fosse b3 s2w4 come se fosse b4 s2w5 come se fosse b5
                      o magari 3: s3w1 come se fosse b1 s3w2 come se fosse b2 s3w3 come se fosse b3 s3w4 come se fosse b4 s3w5 come se fosse b5
                      o magari 4: s4w1 come se fosse b1 s4w2 come se fosse b2 s4w3 come se fosse b3 s4w4 come se fosse b4 s4w5 come se fosse b5
                      o magari 5: s5w1 come se fosse b1 s5w2 come se fosse b2 s5w3 come se fosse b3 s5w4 come se fosse b4 s5w5 come se fosse b5
                      o magari 6: s6w1 come se fosse b1 s6w2 come se fosse b2 s6w3 come se fosse b3 s6w4 come se fosse b4 s6w5 come se fosse b5
                      o magari 7: s7w1 come se fosse b1 s7w2 come se fosse b2 s7w3 come se fosse b3 s7w4 come se fosse b4 s7w5 come se fosse b5
                      o magari 8: s8w1 come se fosse b1 s8w2 come se fosse b2 s8w3 come se fosse b3 s8w4 come se fosse b4 s8w5 come se fosse b5
                      o magari 9: s9w1 come se fosse b1 s9w2 come se fosse b2 s9w3 come se fosse b3 s9w4 come se fosse b4 s9w5 come se fosse b5
                      o magari 10: s10w1 come se fosse b1 s10w2 come se fosse b2 s10w3 come se fosse b3 s10w4 come se fosse b4 s10w5 come se fosse b5
                      o magari 11: s11w1 come se fosse b1 s11w2 come se fosse b2 s11w3 come se fosse b3 s11w4 come se fosse b4 s11w5 come se fosse b5
                      o magari 12: s12w1 come se fosse b1 s12w2 come se fosse b2 s12w3 come se fosse b3 s12w4 come se fosse b4 s12w5 come se fosse b5
                      o magari 13: s13w1 come se fosse b1 s13w2 come se fosse b2 s13w3 come se fosse b3 s13w4 come se fosse b4 s13w5 come se fosse b5
                      o magari 14: s14w1 come se fosse b1 s14w2 come se fosse b2 s14w3 come se fosse b3 s14w4 come se fosse b4 s14w5 come se fosse b5
                      o magari 15: s15w1 come se fosse b1 s15w2 come se fosse b2 s15w3 come se fosse b3 s15w4 come se fosse b4 s15w5 come se fosse b5
                    e velocità di esecuzione
                    idx come se fosse j più 1
                    che cos'è idx?
                      0: s0w1 come se fosse a1 s0w2 come se fosse a2 s0w3 come se fosse a3 s0w4 come se fosse a4 s0w5 come se fosse a5
                      o magari 1: s1w1 come se fosse a1 s1w2 come se fosse a2 s1w3 come se fosse a3 s1w4 come se fosse a4 s1w5 come se fosse a5
                      o magari 2: s2w1 come se fosse a1 s2w2 come se fosse a2 s2w3 come se fosse a3 s2w4 come se fosse a4 s2w5 come se fosse a5
                      o magari 3: s3w1 come se fosse a1 s3w2 come se fosse a2 s3w3 come se fosse a3 s3w4 come se fosse a4 s3w5 come se fosse a5
                      o magari 4: s4w1 come se fosse a1 s4w2 come se fosse a2 s4w3 come se fosse a3 s4w4 come se fosse a4 s4w5 come se fosse a5
                      o magari 5: s5w1 come se fosse a1 s5w2 come se fosse a2 s5w3 come se fosse a3 s5w4 come se fosse a4 s5w5 come se fosse a5
                      o magari 6: s6w1 come se fosse a1 s6w2 come se fosse a2 s6w3 come se fosse a3 s6w4 come se fosse a4 s6w5 come se fosse a5
                      o magari 7: s7w1 come se fosse a1 s7w2 come se fosse a2 s7w3 come se fosse a3 s7w4 come se fosse a4 s7w5 come se fosse a5
                      o magari 8: s8w1 come se fosse a1 s8w2 come se fosse a2 s8w3 come se fosse a3 s8w4 come se fosse a4 s8w5 come se fosse a5
                      o magari 9: s9w1 come se fosse a1 s9w2 come se fosse a2 s9w3 come se fosse a3 s9w4 come se fosse a4 s9w5 come se fosse a5
                      o magari 10: s10w1 come se fosse a1 s10w2 come se fosse a2 s10w3 come se fosse a3 s10w4 come se fosse a4 s10w5 come se fosse a5
                      o magari 11: s11w1 come se fosse a1 s11w2 come se fosse a2 s11w3 come se fosse a3 s11w4 come se fosse a4 s11w5 come se fosse a5
                      o magari 12: s12w1 come se fosse a1 s12w2 come se fosse a2 s12w3 come se fosse a3 s12w4 come se fosse a4 s12w5 come se fosse a5
                      o magari 13: s13w1 come se fosse a1 s13w2 come se fosse a2 s13w3 come se fosse a3 s13w4 come se fosse a4 s13w5 come se fosse a5
                      o magari 14: s14w1 come se fosse a1 s14w2 come se fosse a2 s14w3 come se fosse a3 s14w4 come se fosse a4 s14w5 come se fosse a5
                      o magari 15: s15w1 come se fosse a1 s15w2 come se fosse a2 s15w3 come se fosse a3 s15w4 come se fosse a4 s15w5 come se fosse a5
                    e velocità di esecuzione
                    scambiato come se fosse 1
                e velocità di esecuzione
                j come se fosse j più 1
              e brematura anche, se j minore di limite
            e brematura anche, se scambiato maggiore di 0
        e velocità di esecuzione
    e velocità di esecuzione
```

- [ ] **Step 6: Verificare che passino**

Run: `make && make test`
Expected: `16 passati, 0 falliti`.

- [ ] **Step 7: Commit**

```bash
git add src/antani.mc tests
git commit -m "Ordinamento: collazione case/accent-insensitive, bubble sort stabile, :o ed EOF"
```

---

### Task 5: Comando `:c` e README

**Files:**
- Modify: `src/antani.mc` (sezione `azione`, nuovo messaggio)
- Create: `README.md`
- Test: `tests/16-cancella.in/.out`

**Interfaces:**
- Consumes: tutto quanto sopra.
- Produces: `msgCancellata`; programma completo.

- [ ] **Step 1: Scrivere il test che fallisce**

```bash
printf ':o\nMario\n:C\n:l\nanna\n:c\nBea\nanna\n:o\n:q\n' > tests/16-cancella.in
{ cat tests/intestazione.txt; printf '> Lista vuota.\n> > Lista cancellata.\n> Lista vuota.\n> > Lista cancellata.\n> > > 1. anna\n2. Bea\n> Arrivederci.\n'; } > tests/16-cancella.out
```

- [ ] **Step 2: Verificare che fallisca**

Run: `make && tests/run.sh 16`
Expected: FALLITO (`:C` è "Comando sconosciuto").

- [ ] **Step 3: Implementare**

Aggiungere subito prima di `Lei ha clacsonato`:

```
bituma 'Lista cancellata.\n'
blinda la supercazzola msgCancellata o scherziamo?
  brematurata la supercazzola scrivi8 con 76, 105, 115, 116, 97, 32, 99, 97 o scherziamo?
  brematurata la supercazzola scrivi8 con 110, 99, 101, 108, 108, 97, 116, 97 o scherziamo?
  brematurata la supercazzola scrivi8 con 46, 10, 0, 0, 0, 0, 0, 0 o scherziamo?

```

Nella sezione `azione`, sostituire le due righe:

```
          o magari 108: daStampare come se fosse 1
          o magari 76: daStampare come se fosse 1
```

con:

```
          o magari 108: daStampare come se fosse 1
          o magari 76: daStampare come se fosse 1
          o magari 99: n come se fosse 0 brematurata la supercazzola msgCancellata o scherziamo?
          o magari 67: n come se fosse 0 brematurata la supercazzola msgCancellata o scherziamo?
```

(Svuotare è `n = 0`: gli slot vecchi vengono sovrascritti per intero, 5 parole, al prossimo inserimento.)

- [ ] **Step 4: Verificare che passino tutti**

Run: `make && make test`
Expected: `17 passati, 0 falliti`.

- [ ] **Step 5: Scrivere `README.md`**

```markdown
# antani

Ordinamento alfabetico di una lista di nomi, scritto in **Monicelli puro**
(https://github.com/esseks/monicelli), il linguaggio esoterico ispirato ad
*Amici miei*. Tutta la logica — lettura carattere per carattere, decodifica
UTF-8, comandi, memoria, confronto, ordinamento, stampa — è in `src/antani.mc`.

## Uso

    $ ./antani
    Lei ha clacsonato! Inserisca i nomi, uno per riga (massimo 16).
    Comandi: :o ordina  :l elenca  :c cancella  :q esci
    > Mario
    > anna
    > :o
    1. anna
    2. Mario
    > :q
    Arrivederci.

Da file: `./antani < nomi.txt` — a fine input la lista viene ordinata e stampata.

## Build

    brew install llvm@21 ragel cmake
    make mcc     # clona e compila il compilatore Monicelli in ~/mcc
    make         # compila src/antani.mc -> ./antani
    make test    # esegue i test in tests/

## Limiti e perché

Monicelli non ha array, stringhe né memoria indicizzabile: i puntatori (`conte`)
sono dichiarabili ma il compilatore non permette di dereferenziarli né di fare
aritmetica. La lista vive quindi in 80 variabili Necchi (16 nomi × 5 parole da
4 caratteri a 7 bit), indirizzate con catene `che cos'è idx? 0: … o magari 15: …`.

- Massimo 16 nomi, 20 caratteri ciascuno (oltre si tronca con avviso).
- Caratteri ammessi: lettere, spazio, `'`, `-`, `à è é ì ò ù À È É Ì Ò Ù`.
- Ordine alfabetico che ignora maiuscole e accenti; stabile a parità.
```

- [ ] **Step 6: Commit**

```bash
git add src/antani.mc tests README.md
git commit -m "Comando :c e README"
```
