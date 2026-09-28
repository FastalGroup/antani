# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Progetto

`antani` è una CLI che ordina alfabeticamente fino a 16 nomi, scritta **interamente
in Monicelli** (https://github.com/esseks/monicelli), il linguaggio esoterico
basato sulla supercazzola di *Amici miei*. Lo scopo è dimostrare che un agente
può costruire un programma reale in **Monicelli puro**. Tutta la logica sta in
`src/antani.mc`: niente generatori di codice, wrapper o librerie, e niente patch
al compilatore. Una funzionalità che non si può esprimere in Monicelli va
discussa con l'utente, non aggirata.

Il repo contiene anche `codfisc`, un generatore di codice fiscale: la logica è in
`src/codfisc.mc`, scritta a mano. **Unica eccezione alla regola sui generatori:**
`src/luoghi.mc` contiene solo la funzione `luogo` (la tabella dei luoghi di nascita)
ed è generato da `tools/importa-luoghi.py` a partire dalle fonti ANPR in `dati/`.
Non va modificato a mano: si modifica lo script e si rigenera. Spec e piano:
`docs/superpowers/specs/2026-09-27-codfisc-design.md`,
`docs/superpowers/plans/2026-09-27-codfisc.md`.

Spec e piano originali: `docs/superpowers/specs/2026-09-26-antani-sort-design.md`,
`docs/superpowers/plans/2026-09-26-antani-sort.md`. Il README documenta setup
(macOS, Linux/WSL, Windows) e uso.

## Comandi

```bash
make mcc                  # clona Monicelli (commit fissato in MONICELLI_REV) e installa mcc in ~/mcc
                          # su Linux/WSL: make mcc LLVM_DIR=/usr/lib/llvm-21/lib/cmake/llvm
make                      # ~/mcc/bin/mcc src/antani.mc -o antani
make test                 # tests/run.sh su antani e codfisc, più i test Python
tests/run.sh 12           # solo i test il cui nome inizia per "12"
printf 'b\na\n:o\n:q\n' | ./antani
make codfisc              # concatena src/luoghi.mc + src/codfisc.mc in .build/ e compila (~1 min)
tests/run.sh codfisc 05   # test di codfisc (tests/codfisc/), eventualmente per prefisso
make verifica-luoghi      # ogni luogo della tabella contro l'oracolo Python
make luoghi               # riscarica le fonti ANPR e rigenera src/luoghi.mc
python3 -m unittest discover -s tools

~/mcc/bin/mcc -p src/antani.mc   # AST come pseudocodice (utile per capire come è stato parsato)
~/mcc/bin/mcc -s src/antani.mc   # IR LLVM
~/mcc/bin/mcc -t src/antani.mc   # token del lexer
```

Non esiste un linter. Per esperimenti di sintassi conviene compilare un piccolo
`.mc` in `/tmp`. La verità sulla sintassi e sulla semantica sono i sorgenti del
compilatore in `.build/monicelli/src/` (`lexer.rl`, `parser.cpp`, `codegen.cpp`),
presenti dopo `make mcc`; la documentazione ufficiale è incompleta.

## Regole di Monicelli (verificate su `mcc`: violarle produce bug silenziosi)

1. **Mai `voglio` dentro un `stuzzica`.** Ogni dichiarazione è un `alloca` nel
   punto corrente, quindi dentro un ciclo lo stack cresce a ogni giro. Tutte le
   dichiarazioni vanno in testa alla funzione.
2. **Flag solo come `Necchi` 0/1, mai `Melandri`.** Le conversioni intere
   estendono il segno: un i1 vero confrontato con `1` diventa `-1`.
3. **Un solo `vaffanzum`, come ultima istruzione della funzione.** Un ritorno
   dentro un ramo genera IR con terminatori doppi. Si usa una variabile
   risultato.
4. **Niente parentesi.** `più`/`meno` legano più dello shift, `per`/`diviso` più
   di `più`/`meno`: `21 meno pos per 7` vale `21 - pos*7`. Nei casi dubbi si usano
   variabili d'appoggio.
5. **`che cos'è` accetta solo una variabile come soggetto.** Un caso è una
   semi-espressione (`0:`, `minore di 40:`), vince il primo che corrisponde, e un
   corpo vuoto è lecito.
6. **Tutti i cicli sono do-while** (`stuzzica … e brematura anche, se cond`): se
   il corpo non deve eseguire mai, va protetto con un `che cos'è`.
7. **Identificatori:** solo lettere e cifre, niente `_`. Non usare come nomi, né
   come loro prefisso se il lexer li spezza, `per con meno più diviso conte
   voglio o e i il lo la le gli un una dei delle`. Mai un identificatore che
   inizi per `bituma`: il lexer lo tratta come commento fino a fine riga.
8. **`bituma` commenta fino a fine riga**: niente codice dopo, sulla stessa riga.
9. **Mancano AND, OR, modulo e stringhe letterali.** Le condizioni composte si
   fanno con `che cos'è` annidati; i bit si estraggono con shift e sottrazione
   (vedi `prendi`).
10. **I/O:** `mi porga` su `Mascetti` è `scanf("%c")`; `a posterdati` su
    `Mascetti` stampa un byte senza newline, su `Necchi` stampa `%d\n`. Per
    questo i numeri si stampano cifra per cifra come caratteri. I byte ≥ 128
    arrivano negativi.
11. **Sorgenti sotto 1 MiB.** Il lexer di `mcc` legge a blocchi da 1 MiB e va in
    assert (`Cursor out of bounds`) su file più grandi. Il Makefile controlla
    `.build/codfisc.mc`; per questo `luoghi.mc` è compatto (una riga per nome).

## Architettura di `src/antani.mc`

Un solo file: prima le funzioni, poi il blocco principale `Lei ha clacsonato`.
Le funzioni non vedono le variabili del chiamante, quindi tutto lo stato vive
nel blocco principale.

**Funzioni (pure o solo I/O):**
- `scrivi` / `scrivi8` / `aCapo` e `msg*`: senza stringhe, ogni messaggio è una
  sequenza di `scrivi8` con i codici ASCII (anche i byte UTF-8), preceduta da un
  commento `bituma '<testo>'`. Cambiare un testo significa ricalcolare i codici
  e aggiornare i `.out` dei test.
- `leggi`: restituisce 0–255, oppure 256 a fine input. La sentinella è `0xFF`
  (`car` inizializzato a -1), perché il valore di ritorno di `scanf` non è
  accessibile; quindi un byte 0xFF reale viene letto come EOF.
- `decodifica`: byte → codice carattere. Restituisce 0 per un carattere non
  ammesso, 98 se non è ammesso e la riga è finita, 99 se non è ammesso e l'input
  è finito. Legge il secondo byte delle accentate `0xC3 xx`.
- `scriviCodice`: codice → byte, ricodificando in UTF-8.
- `metti` / `prendi` / `carattere`: impacchettamento. Un nome è formato da 5
  `Necchi` (`w1…w5`) con 4 caratteri da 7 bit ciascuno; il carattere in
  posizione `pos` (0–3) sta a `21 - 7*pos` bit, quindi il primo occupa i bit
  alti.
- `rango` e `precede`: collazione e confronto stretto (1 se X < Y). A parità
  restituisce 0, e da questo dipende la stabilità del sort.

**Codici carattere:** 0 fine, 1 spazio, 2 `'`, 3 `-`, 10–35 `A`–`Z`, 40–65 `a`–`z`,
70–75 `à è é ì ò ù`, 80–85 `À È É Ì Ò Ù`. `rango` riduce ogni lettera a 10 + indice
(a=10 … z=35), ignorando maiuscole e accenti.

**Blocco principale:** un ciclo per riga, diviso in sezioni marcate
`bituma [SEZIONE: <nome>]`, in quest'ordine:
- `dichiarazioni`: gli slot `s<k>w<1..5>` (k = 0–15), `n`, `idx`, i registri
  `a1…a5`/`b1…b5` e i flag.
- `lettura riga`: legge byte per byte e costruisce il nome nel registro A. Gli
  spazi non vengono scritti subito: si contano in `spazi` e si emettono solo
  prima di un carattere valido, così spazi iniziali e finali spariscono da soli.
  Imposta `comando`, `lettera`, `invalido`, `troncato`, `fineRiga`, `fineInput`.
- `azione`: esegue il comando o salva il nome; imposta `daOrdinare` e
  `daStampare`.
- `fine input`: a EOF stampa `\n` e, se la lista non è vuota, chiede ordinamento
  e stampa.
- `ordinamento`: bubble sort che scambia solo se `precede(B, A)`.
- `stampa`: stampa la lista numerata.

**Memoria indirizzabile:** Monicelli non ha array. L'accesso allo slot `idx` è
una catena `che cos'è idx? 0: … o magari 15: …` che copia le 5 parole da e verso
un registro. Ne esistono **6 copie**: salva A in `azione`; carica A, carica B,
salva B e salva A in `ordinamento`; carica A in `stampa`. Cambiare la capacità
(16) o il formato di uno slot significa aggiornare:
- le dichiarazioni;
- tutte e 6 le catene;
- il `che cos'è n? minore di 16:` in `azione`. Gli altri `minore di 16` del file
  riguardano la posizione del carattere nel nome, non la capacità;
- `stampaIndice`, che stampa solo numeri da 1 a 19;
- il messaggio di benvenuto e il test `09-piena`.

## Architettura di `src/codfisc.mc`

`luogo(h, data, prov)` viene da `src/luoghi.mc` (concatenato prima). Codifiche
condivise con `tools/importa-luoghi.py`: lettera A=1…Z=26, hash `h*31+lettera` in i32,
provincia `l1*26+l2` (0 assente, `EE`=135 stato estero), codice catastale
`lettera*1000+numero`. `luogo` restituisce -1 sconosciuto, -2 ambiguo, -3 non valido
alla data.

Funzioni: I/O come antani (`scrivi`, `scrivi8`, `aCapo`, `leggi`); messaggi
(`msgBenvenuto`, `msgArrivederci`, `msgCodice`, `prompt(q)`, `errore(n, modo)`, dove
`modo` 1 rende maiuscola l'iniziale e aggiunge il punto); `lettera`, `accentata`,
`decodifica` (byte → lettera 1–26, 27 = SS, 0 da saltare, 96–99 non ammesso con
`;`, `\n` o EOF come secondo byte); `sigla` (le 3 lettere di cognome/nome);
`giorniMese`, `lettMese`, `dispari`, `pari`, `stampaCodice`.

Blocco principale, sezioni `bituma [SEZIONE: …]`:
- `modo`: salta il BOM; prima riga vuota → modalità guidata (`modo` 1), altrimenti
  il primo byte resta in `sospeso`;
- `inizio riga` / `apri campo` / `lettura byte` / `elabora byte` / `chiudi campo`:
  un campo alla volta (`campo` 1–6; in modalità guidata `campo` = domanda `q`), in
  streaming: prime 4 consonanti e 3 vocali, hash del luogo, cifre della data, sigla.
  `chiudi campo` salva i risultati (`k1…k6`, `data`, `hL`, `prov`, `err*`);
- `riga`: primo errore in ordine di campo, poi `luogo`, poi `stampaCodice`;
- `guidata`: `:q`, cognome vuoto o EOF escono; un errore ripete la domanda; `-2`
  sul luogo chiede la provincia (`q` = 6).

## Test

Ogni caso è una coppia `tests/NN-nome.in` / `tests/NN-nome.out`, confrontata
byte per byte da `tests/run.sh`. Convenzioni:

- Ogni `.out` inizia con `tests/intestazione.txt`, le due righe di benvenuto.
- Il prompt `> ` viene stampato prima di **ogni** riga letta, anche in pipe, e
  non va a capo. L'output di una riga compare quindi subito dopo il suo prompt
  (vedi `tests/07-invalido.out`).
- I file si creano con `printf`, compresi UTF-8, `\r`, `\0` e byte grezzi come
  `\303`. Per esempio:
  `{ cat tests/intestazione.txt; printf '> Arrivederci.\n'; } > tests/NN-x.out`
- L'output atteso si ricava ragionando sul comportamento specificato, mai
  copiando l'output del programma.
- Si procede in TDD: prima il test che fallisce, poi il codice.

I test di codfisc sono in `tests/codfisc/` (`tests/run.sh codfisc`). I valori attesi
si ricavano dall'oracolo `tools/oracolo.py`, verificato su codici pubblicati, e dai
codici catastali delle fonti. La modalità guidata si attiva con una prima riga vuota.
