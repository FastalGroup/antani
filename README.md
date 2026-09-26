# antani

Ordinamento alfabetico di una lista di nomi, scritto in **Monicelli puro**: il
linguaggio di programmazione esoterico che traduce in codice la *supercazzola*
del film *Amici miei*.

```
$ ./antani
Lei ha clacsonato! Inserisca i nomi, uno per riga (massimo 16).
Comandi: :o ordina  :l elenca  :c cancella  :q esci
> Mario
> anna
> Niccolò
> De Sica
> :o
1. anna
2. De Sica
3. Mario
4. Niccolò
> :q
Arrivederci.
```

## Scopo del progetto

`antani` è un esperimento: dimostrare che un harness di coding agentico come
[Claude Code](https://claude.com/claude-code) è in grado di progettare,
scrivere, testare e rivedere un programma reale e non banale in un linguaggio
esoterico, poco documentato e privo delle strutture che di solito si danno per
scontate.

Il vincolo è la **purezza**: tutta la logica sta in [`src/antani.mc`](src/antani.mc)
ed è compilata con il compilatore ufficiale di Monicelli, `mcc`. Nessun wrapper,
generatore di codice o libreria esterna partecipa all'elaborazione. Lettura
dell'input carattere per carattere, decodifica UTF-8, interpretazione dei
comandi, memoria, confronto, ordinamento e stampa sono tutti in Monicelli.

Il lavoro è stato svolto con un processo tracciabile, conservato nel repo:

- [`docs/superpowers/specs/2026-09-26-antani-sort-design.md`](docs/superpowers/specs/2026-09-26-antani-sort-design.md):
  la spec di design, con i vincoli del linguaggio verificati sui sorgenti di `mcc`;
- [`docs/superpowers/plans/2026-09-26-antani-sort.md`](docs/superpowers/plans/2026-09-26-antani-sort.md):
  il piano di implementazione in 5 task, sviluppati in TDD e rivisti uno per uno.

## Il linguaggio Monicelli

[Monicelli](https://github.com/esseks/monicelli) è un linguaggio esoterico
compilato, basato su LLVM, la cui sintassi riprende le battute del film
[*Amici miei*](https://it.wikipedia.org/wiki/Amici_miei) (1975) di
[Mario Monicelli](https://it.wikipedia.org/wiki/Mario_Monicelli), in particolare
la celebre [supercazzola](https://it.wikipedia.org/wiki/Supercazzola) del
Conte Mascetti. I tipi portano i nomi dei protagonisti:

| Tipo Monicelli | Equivalente C | Uso in antani |
|---|---|---|
| `Necchi` | intero (32 bit nel compilatore attuale) | tutto: codici, parole impacchettate, flag, indici |
| `Mascetti` | `char` | I/O di un byte |
| `Perozzi` | `float` | — |
| `Melandri` | `bool` | — (vedi "Insidie") |
| `Sassaroli` | `double` | — |

Un assaggio della sintassi, preso da `antani`:

| Costrutto | Monicelli | Equivalente |
|---|---|---|
| inizio programma | `Lei ha clacsonato` | `int main()` |
| dichiarazione | `voglio n, Necchi come se fosse 0` | `int n = 0;` |
| assegnamento | `n come se fosse n più 1` | `n = n + 1;` |
| lettura / stampa | `mi porga car` / `car a posterdati` | `scanf` / `printf` |
| switch | `che cos'è idx? 0: … o magari 1: … o tarapia tapioco: … e velocità di esecuzione` | `switch`/`if` con `default` |
| ciclo | `stuzzica … e brematura anche, se j minore di n` | `do { … } while (j < n);` |
| funzione | `blinda la supercazzola Necchi rango con codice Necchi o scherziamo?` | `int rango(int codice)` |
| chiamata | `brematurata la supercazzola rango con rx o scherziamo?` | `rango(rx)` |
| ritorno | `vaffanzum r!` | `return r;` |
| shift | `codice con scappellamento a sinistra per 7` | `codice << 7` |
| commento | `bituma …` | `// …` |

### Riferimenti su Monicelli

- Repository ufficiale e compilatore `mcc`: <https://github.com/esseks/monicelli>
- Specifica del linguaggio (README del progetto): <https://github.com/esseks/monicelli/blob/main/README.md>
- Proposta originale della specifica (storica): <https://github.com/esseks/monicelli/blob/main/Specification.txt>
- Programmi di esempio (fattoriale, Fibonacci, numeri primi, Mandelbrot…): <https://github.com/esseks/monicelli/tree/main/examples>
- Scheda sull'Esolang wiki: <https://esolangs.org/wiki/Monicelli>
- I linguaggi esoterici in generale: <https://en.wikipedia.org/wiki/Esoteric_programming_language>
- Le fonti d'ispirazione: [*Amici miei*](https://it.wikipedia.org/wiki/Amici_miei),
  [la supercazzola](https://it.wikipedia.org/wiki/Supercazzola),
  [Mario Monicelli](https://it.wikipedia.org/wiki/Mario_Monicelli)
- Le dipendenze del compilatore: [LLVM](https://llvm.org), [Ragel](https://www.colm.net/open-source/ragel/)

`antani` è compilato con `mcc` al commit
[`07d389c`](https://github.com/esseks/monicelli/commit/07d389c3bb5cd670f1aa3d543c9a29fa4369243e)
(novembre 2025), fissato nel `Makefile`.

## Setup dell'ambiente di sviluppo

Testato su **macOS x86_64** con Homebrew. Il compilatore `mcc` va costruito da
sorgente: non esistono pacchetti precompilati.

1. **Strumenti da riga di comando di Xcode.** Forniscono `git`, `make` e `c99`,
   il linker che `mcc` invoca per produrre l'eseguibile:

   ```bash
   xcode-select --install
   ```

2. **Dipendenze del compilatore.** Serve LLVM 21: il CMake di Monicelli richiede
   quella versione.

   ```bash
   brew install llvm@21 ragel cmake
   ```

   `llvm@21` è *keg-only*: non serve aggiungerlo al `PATH`, perché il `Makefile`
   lo trova con `brew --prefix llvm@21`.

3. **Compilatore Monicelli.** Clona il repo in `.build/monicelli`, si porta al
   commit fissato, compila e installa `mcc` in `~/mcc`:

   ```bash
   make mcc
   ```

4. **Verifica:**

   ```bash
   ~/mcc/bin/mcc --help
   ```

Variabili del `Makefile` che si possono sovrascrivere, per esempio con
`make mcc LLVM_DIR=/percorso/llvm/lib/cmake/llvm`:

| Variabile | Default | Significato |
|---|---|---|
| `MCC` | `~/mcc/bin/mcc` | compilatore usato da `make` |
| `LLVM_DIR` | `$(brew --prefix llvm@21)/lib/cmake/llvm` | configurazione CMake di LLVM 21 |
| `MONICELLI_SRC` | `.build/monicelli` | dove clonare i sorgenti di `mcc` |
| `MONICELLI_REV` | `07d389c…` | commit di Monicelli da compilare |

Su altre piattaforme il procedimento è lo stesso (LLVM 21, ragel, cmake, un
compilatore C chiamato `c99` nel `PATH`), ma non è stato provato. Su Apple
Silicon o Linux ARM il CMake di Monicelli va configurato con
`-DMONICELLI_ARCH=AArch64`, perché il default è `x86`.

## Compilare e lanciare

```bash
make            # compila src/antani.mc in ./antani
./antani        # modalità interattiva
make test       # esegue i 21 casi di test in tests/
make clean      # rimuove l'eseguibile
```

### Uso

Si scrive un nome per riga. Una riga che inizia con `:` è un comando:

| Comando | Effetto |
|---|---|
| `:o` | ordina la lista e la stampa numerata |
| `:l` | stampa la lista nell'ordine attuale |
| `:c` | svuota la lista |
| `:q` | esce |

- Conta solo la prima lettera dopo `:` (`:quit` equivale a `:q`); le maiuscole
  sono accettate.
- A fine input (**Ctrl-D** nel terminale, o fine del file) la lista viene
  ordinata e stampata.
- Da file: `./antani < nomi.txt`.
- Il prompt `> ` viene stampato anche quando l'input arriva da una pipe:
  Monicelli non può sapere se sta leggendo da un terminale.

### Test

Ogni caso è una coppia `tests/NN-nome.in` / `tests/NN-nome.out`: `tests/run.sh`
passa l'input al programma e confronta lo stdout con quello atteso.

```bash
tests/run.sh      # tutti i test
tests/run.sh 12   # solo quelli il cui nome inizia per "12"
```

### Debug con `mcc`

```bash
~/mcc/bin/mcc -p src/antani.mc   # stampa l'AST come pseudocodice
~/mcc/bin/mcc -s src/antani.mc   # stampa l'IR LLVM generato
~/mcc/bin/mcc -t src/antani.mc   # traccia i token letti dal lexer
```

## Come funziona

Monicelli non ha array, stringhe né memoria indicizzabile. I puntatori (`conte`)
si possono dichiarare, ma il compilatore non permette di dereferenziarli né di
fare aritmetica. Il programma quindi si costruisce tutto da sé:

- **Codici carattere a 7 bit:** 0 fine, 1 spazio, 2 `'`, 3 `-`, 10–35 `A`–`Z`,
  40–65 `a`–`z`, 70–75 `à è é ì ò ù`, 80–85 `À È É Ì Ò Ù`. Le accentate
  arrivano in UTF-8 come coppia di byte `0xC3 xx`.
- **Nomi impacchettati:** un nome sta in 5 Necchi da 4 caratteri ciascuno, a
  colpi di `con scappellamento a sinistra per 7`.
- **Registri indirizzabili:** i 16 slot sono 80 variabili nel blocco
  principale. L'accesso "per indice" è una catena
  `che cos'è idx? 0: … o magari 15: …` che copia lo slot in due registri
  temporanei.
- **Collazione:** la funzione `rango` riduce maiuscole, minuscole e accentate
  alla lettera base; `precede` confronta due nomi carattere per carattere.
- **Ordinamento:** bubble sort stabile, che scambia due nomi solo se il secondo
  viene strettamente prima.
- **Messaggi:** senza stringhe letterali, ogni testo è una sequenza di codici
  ASCII stampati otto alla volta da `scrivi8`.

### Insidie del compilatore (verificate sui sorgenti di `mcc`)

- Ogni `voglio` alloca spazio sullo stack nel punto in cui compare: dentro un
  ciclo lo stack cresce a ogni giro. Tutte le dichiarazioni stanno in testa alle
  funzioni.
- Le conversioni intere estendono il segno: un `Melandri` vero confrontato con
  `1` vale `-1`. Per questo i flag sono `Necchi` 0/1.
- Non ci sono parentesi, e lo shift lega meno di `più` e `meno`: servono
  variabili d'appoggio.
- Tutti i cicli sono do-while; `che cos'è` accetta come soggetto solo una
  variabile.
- Non c'è un operatore AND sui bit: per estrarre un carattere si sottrae la
  parte alta, ottenuta con due shift.

## Limiti

- Massimo **16 nomi** da **20 caratteri** ciascuno; oltre, il nome viene
  troncato con un avviso.
- Caratteri ammessi: lettere, spazio, `'`, `-`, `à è é ì ò ù À È É Ì Ò Ù`. Ogni
  altro carattere scarta il nome con un avviso. I tab contano come spazi.
- L'ordine ignora maiuscole e accenti; a parità di chiave resta l'ordine
  d'inserimento.
- Un byte `0xFF` nell'input viene letto come fine input. Monicelli non espone
  il valore di ritorno di `scanf`, quindi un valore di byte va sacrificato come
  sentinella; `0xFF` non compare mai in un testo UTF-8 valido.
- La lista non può essere illimitata: senza memoria indicizzabile, l'unica
  alternativa sarebbe modificare il compilatore, e non sarebbe più Monicelli
  puro.
