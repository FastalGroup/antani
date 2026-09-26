# Antani — ordinamento alfabetico di nomi in Monicelli puro

Data: 2026-09-26

## Scopo

Dimostrare che un harness come Claude Code è capace di realizzare un programma
reale e non banale in **Monicelli puro**: un eseguibile CLI che raccoglie una
lista di nomi e la ordina alfabeticamente. Tutta la logica (parsing dell'input,
comandi, memorizzazione, confronto, ordinamento, stampa) è scritta in Monicelli e
compilata con il compilatore ufficiale `mcc`. Nessun wrapper, generatore di
codice o libreria esterna partecipa all'elaborazione.

## Vincoli del linguaggio (verificati sui sorgenti di `mcc`, commit 2025-11-23)

- Tipi: Necchi = `i32`, Mascetti = `i8`, Perozzi = `float`, Melandri = `i1`,
  Sassaroli = `double`.
- Nessun array, nessuna stringa letterale, nessuna memoria indicizzabile.
- I puntatori (`conte`) sono dichiarabili ma non utilizzabili: niente
  dereferenziazione, niente indirizzo, aritmetica vietata
  (`codegen.cpp:576`), cast vietati.
- I/O: `mi porga` su Mascetti usa `scanf("%c")`; `a posterdati` su Mascetti
  usa `printf("%c")` (senza newline), su Necchi `printf("%d\n")`.
- Operatori: `più meno per diviso`, confronti, shift (`con scappellamento a
  sinistra|destra per N`). Nessun modulo né operatore logico (si usano
  divisioni e `che cos'è` annidati).
- Controllo: `che cos'è … o magari … o tarapia tapioco … e velocità di
  esecuzione`, ciclo `stuzzica … e brematura anche, se …`, funzioni con
  parametri e ricorsione (`blinda la supercazzola`).

Conseguenza: la lista ha lunghezza variabile ma **capacità massima fissa**,
realizzata come insieme finito di variabili ("registri") indirizzate tramite
funzioni di dispatch.

## Interfaccia CLI

```
$ ./antani
Lei ha clacsonato! Inserisca i nomi, uno per riga (massimo 16).
Comandi: :o ordina  :l elenca  :c cancella  :q esci
> Mario
> anna
> Niccolò
> :o
1. anna
2. Mario
3. Niccolò
> :q
```

- Ogni riga non vuota che non inizia con `:` aggiunge un nome.
- Spazi iniziali e finali vengono rimossi; le righe vuote (o di soli spazi)
  sono ignorate.
- Comandi (riga che inizia con `:`, seguito da una lettera):
  - `:o` — ordina la lista in-place e la stampa numerata;
  - `:l` — stampa la lista numerata nell'ordine corrente;
  - `:c` — svuota la lista;
  - `:q` — esce;
  - qualsiasi altro — messaggio "comando sconosciuto".
- A fine input (EOF, es. `cat nomi.txt | ./antani`): se la lista non è vuota
  viene ordinata e stampata, poi il programma termina.
- Il prompt `> ` viene sempre stampato (Monicelli non può sapere se stdin è un
  terminale); i test ne tengono conto.

### Messaggi di errore

- Lista piena: il nome viene scartato con avviso.
- Nome più lungo di 20 caratteri: troncato a 20 con avviso.
- Carattere non ammesso: il nome viene scartato con avviso (il resto della
  riga viene consumato).
- `:o` o `:l` a lista vuota: messaggio "lista vuota".

I testi esatti vengono fissati nei file di test attesi.

## Rappresentazione dei dati

### Alfabeto e codici di carattere (7 bit, 0 = fine nome)

| Codice | Carattere | Input |
|--------|-----------|-------|
| 0 | fine / slot vuoto | — |
| 1 | spazio | 32 |
| 2 | apostrofo `'` | 39 |
| 3 | trattino `-` | 45 |
| 10–35 | `A`–`Z` | 65–90 |
| 40–65 | `a`–`z` | 97–122 |
| 70–75 | `à è é ì ò ù` | UTF-8 `C3 A0/A8/A9/AC/B2/B9` |
| 80–85 | `À È É Ì Ò Ù` | UTF-8 `C3 80/88/89/8C/92/99` |

Ogni altro byte o sequenza è "carattere non ammesso". I byte letti da
`scanf("%c")` in un Mascetti sono con segno: vengono normalizzati in 0–255
prima della decodifica.

### Impacchettamento

- Un nome = 5 Necchi (`w1…w5`), 4 caratteri per Necchi, 7 bit per carattere
  (28 bit, sempre positivi). Il primo carattere occupa i bit più alti, così i
  caratteri restano in ordine di lettura.
- Capacità: **16 slot** × 5 parole = 80 variabili, più il contatore `n`.

### Registri indirizzabili

Monicelli non può indicizzare variabili, e le funzioni non vedono le variabili
del chiamante. Le 80 variabili vivono nel blocco principale; lettura e
scrittura dello slot `i` sono implementate con catene
`che cos'è i? 0: … o magari 1: … o magari 15: …` che copiano da/verso due
registri temporanei `A` (`a1…a5`) e `B` (`b1…b5`).

## Confronto (collazione)

Funzione pura `rango(codice)` → chiave di ordinamento:

- 0 (fine) → 0; spazio → 1; apostrofo → 2; trattino → 3;
- lettere → 10 + indice della lettera (a/A/à/À → 10, …, z/Z → 35),
  ignorando maiuscole/minuscole e accenti.

Funzione `precede(a1…a5, b1…b5)` (Melandri): confronta carattere per carattere
i ranghi; restituisce vero se A < B strettamente. Nomi con chiave uguale
mantengono l'ordine di inserimento.

## Ordinamento

Bubble sort stabile sugli slot `0…n-1`: per ogni coppia adiacente carica
`A = slot[j]`, `B = slot[j+1]`; se `precede(B, A)` scrive `slot[j] = B`,
`slot[j+1] = A`. Termina quando un passaggio non effettua scambi.

## Output

- Nome: spacchettamento delle 5 parole e stampa dei caratteri, con
  ricodifica UTF-8 per le accentate.
- Numerazione `1.`…`16.` stampata come caratteri (le cifre come Necchi
  stamperebbero un newline).
- Messaggi: Monicelli non ha stringhe letterali; i testi sono stampati da
  funzioni che emettono i codici ASCII (eventualmente impacchettati a 4
  caratteri per Necchi per ridurre il codice).

## Struttura del progetto

```
antani/
  src/antani.mc      programma completo, Monicelli scritto a mano
  Makefile           build (mcc) e test
  tests/NN-nome.in   input del caso di test
  tests/NN-nome.out  stdout atteso
  tests/run.sh       esegue ogni .in e confronta con .out (diff)
  README.md          uso, limiti, motivazioni tecniche
```

## Toolchain

- Dipendenze Homebrew: `llvm@21` (21.1.8, keg-only), `ragel`, `cmake`.
- `mcc` compilato da https://github.com/esseks/monicelli con
  `-DLLVM_DIR=$(brew --prefix llvm@21)/lib/cmake/llvm` e installato in
  `~/mcc`. Il Makefile usa `MCC ?= $(HOME)/mcc/bin/mcc`.

## Test

TDD guidato da file: ogni funzionalità nasce con un caso `tests/*.in/.out`
che fallisce, poi viene implementata. Casi minimi:

1. ordinamento base
2. maiuscole/minuscole miste
3. accentate (UTF-8) ordinate come la lettera base
4. spazi, apostrofi, trattini (`De Sica`, `D'Amico`, `Anna-Maria`)
5. spazi iniziali/finali e righe vuote
6. troncamento oltre 20 caratteri
7. lista piena (17° nome scartato)
8. carattere non ammesso
9. comandi `:l`, `:c`, `:q`, comando sconosciuto, lista vuota
10. EOF con ordinamento automatico
11. stabilità a chiavi uguali (`anna`, `Anna`)
12. esattamente 16 nomi in ordine inverso (caso peggiore del bubble sort)

## Fuori scopo

- Liste illimitate (impossibili senza memoria indicizzabile; richiederebbero
  di modificare il compilatore, violando il vincolo di Monicelli puro).
- Caratteri Unicode diversi dalle accentate italiane elencate.
- Interfaccia web.
