# Antani

Utility a linea di comando per effettuare l'ordinamento alfabetico di un elenco di nomi.

Il software è stato realizzato in **Monicelli puro**: il
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
esoterico, poco documentato e privo delle strutture che caratterizzano i linguaggi di ultima generazione.

Che gli attuali strumenti di coding agentico siano in grado di generare codice funzionante in linguaggi di programmazione di larga diffusione, di cui esistono milioni di esempi in rete, entrati nei percorsi di addestramento dei LLM, è un fatto noto e scontato.

Ma se decidessimo di utilizzare un linguaggio assolutamente esoterico, praticamente mai utilizzato in progetti reali, dalla sintassi bizzarra e fortemente fuorviante, tanto da far sembrare il codice una vera *supercazzola*, come se la caverebbe un harness come **Claude Code**?

Questo repository contiene il risultato di un siffatto esperimento.

Il vincolo progettuale è stato l'assoluta **purezza**: tutta la logica si trova in [`src/antani.mc`](src/antani.mc)
ed è compilata con il compilatore ufficiale di Monicelli, `mcc`. Nessun wrapper,
generatore di codice o libreria esterna partecipa all'elaborazione. Lettura
dell'input carattere per carattere, decodifica UTF-8, interpretazione dei
comandi, memoria, confronto, ordinamento e stampa sono tutti in Monicelli.

Il lavoro è stato svolto con lo stesso processo tracciabile utilizzato nei progetti commerciali di Fastal. 

I file di progettazione tipici del plugin *superpowers* di Claude Code sono conservati nel repo:

- [`docs/superpowers/specs/2026-09-26-antani-sort-design.md`](docs/superpowers/specs/2026-09-26-antani-sort-design.md):
  la spec di design, con i vincoli del linguaggio verificati sui sorgenti di `mcc`;
- [`docs/superpowers/plans/2026-09-26-antani-sort.md`](docs/superpowers/plans/2026-09-26-antani-sort.md):
  il piano di implementazione in 5 task, sviluppati in TDD e rivisti uno per uno.

## Codfisc: il codice fiscale

La seconda utility del repository calcola il codice fiscale italiano. Anche questa è
scritta in Monicelli ([`src/codfisc.mc`](src/codfisc.mc)); la tabella ufficiale dei
luoghi di nascita, circa 11.000 denominazioni fra comuni attuali, comuni soppressi e
stati esteri, è un file di soli dati ([`src/luoghi.mc`](src/luoghi.mc)) generato dalle
fonti ANPR con `tools/importa-luoghi.py` (vedi [`dati/FONTI.md`](dati/FONTI.md)).

```
$ ./codfisc <<< "Rossi;Mario;M;15/03/1985;Roma"
RSSMRA85C15H501R
$ ./codfisc < persone.txt > codici.txt
```

### Modalità riga

Una persona per riga, nel formato `Cognome;Nome;Sesso;GG/MM/AAAA;Luogo[;PR]`, e una
riga di risposta per ogni riga letta: il codice oppure `ERRORE: <motivo>`.

- `Sesso`: `M` o `F`.
- `Luogo`: comune (anche soppresso, anche con il nome tedesco o sloveno) o stato estero,
  con la denominazione ufficiale (`Stati Uniti d'America`, `Federazione Russa`).
- `PR`: sigla di provincia, facoltativa. Serve solo quando il nome è ambiguo alla data
  di nascita (`Livo;CO` o `Livo;TN`); `EE` indica uno stato estero (`Palau;EE`).
  Per un nome non ambiguo la sigla viene ignorata.
- Il codice del luogo è quello valido alla data di nascita: `Bellagio` dà A744 per chi
  è nato prima della fusione del 2014 e M335 dopo.

### Modalità guidata

Si lancia `./codfisc` e si preme subito **Invio**: il programma saluta e fa le domande
una alla volta, chiedendo la provincia solo quando serve. `:q` esce.

```
$ ./codfisc

Lei ha clacsonato! Calcolo del codice fiscale.
Risponda alle domande; :q per uscire.
Cognome: Rossi
Nome: Mario
Sesso (M/F): M
Data di nascita (GG/MM/AAAA): 15/03/1985
Luogo di nascita: Roma
Codice fiscale: RSSMRA85C15H501R
Cognome: :q
Arrivederci.
```

### Limiti e perché

- **Niente argomenti da riga di comando.** In Monicelli il programma è un `main()`
  senza parametri: l'unico ingresso è stdin. La «modalità a parametri» è quindi una
  riga su stdin (`<<<`, pipe o file).
- **Nessun output prima dell'Invio.** Il programma non può sapere se stdin è un
  terminale: in modalità riga non deve stampare nulla oltre ai codici, quindi aspetta
  la prima riga prima di decidere la modalità.
- **Codice di uscita sempre 0**, anche con errori: gli errori sono nelle righe di output.
- **Omocodia** non gestita: il codice calcolato è quello base.
- **La tabella dei luoghi usa un hash a 32 bit del nome.** Un nome di luogo inesistente
  ha una probabilità di circa 1 su 400.000 di essere scambiato per un luogo reale.
- **Il sorgente deve restare sotto 1 MiB**: oltre, il lexer di `mcc` va in errore.
  Per questo la tabella è compatta e la provincia conta solo per i nomi ambigui.
  Il Makefile controlla il limite.
- L'input deve essere UTF-8. Un byte non valido (anche 0xFF, o un file UTF-16) produce
  un errore sulla sua riga senza far perdere le righe successive; solo `FF FF` viene
  scambiato per la fine dell'input.

### Build e test

```bash
make codfisc              # circa un minuto: la tabella dei luoghi è grande
make test                 # test di antani, di codfisc e degli script Python
make verifica-luoghi      # confronta ogni luogo della tabella con un'implementazione Python
make luoghi               # riscarica le fonti ANPR e rigenera src/luoghi.mc
```

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

Il compilatore `mcc` va costruito da sorgente: non esistono pacchetti
precompilati. In ogni caso servono LLVM 21 (il CMake di Monicelli richiede quella
versione), ragel, cmake, `git`, `make` e un compilatore C chiamato `c99`, che
`mcc` invoca come linker per produrre l'eseguibile.

| Sistema | Procedura | Stato |
|---|---|---|
| macOS x86_64 | [macOS](#macos) | verificata |
| Linux Ubuntu/Debian | [Linux e WSL](#linux-e-wsl-ubuntu) | verificata su Ubuntu 24.04 |
| Windows 10/11 | [Windows con WSL2](#windows-con-wsl2), poi [Linux e WSL](#linux-e-wsl-ubuntu) | verificata (Ubuntu 24.04 è lo stesso ambiente di WSL2) |
| Windows nativo | [Windows nativo](#windows-nativo-sperimentale) | sperimentale, non verificata |

### macOS

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

### Windows con WSL2

Su Windows il modo consigliato è WSL2 con Ubuntu: Ubuntu LTS è la piattaforma di
riferimento del compilatore Monicelli, e il progetto usa strumenti POSIX (`make`,
`sh`, il linker `c99`) che lì funzionano senza modifiche.

1. **Installare WSL2 con Ubuntu.** Da PowerShell aperta come amministratore:

   ```powershell
   wsl --install -d Ubuntu-24.04
   ```

   Riavviare se richiesto, poi aprire "Ubuntu 24.04" dal menu Start e creare
   l'utente Linux.

2. **Lavorare nel filesystem Linux.** Clonare il progetto nella home di WSL
   (`~`), non sotto `/mnt/c/...`: il disco Windows è molto più lento da WSL e può
   perdere i permessi di esecuzione di `tests/run.sh`.

   ```bash
   cd ~
   git clone https://github.com/FastalGroup/antani.git
   cd antani
   ```

3. **Proseguire con i passi di [Linux e WSL](#linux-e-wsl-ubuntu)**, tutti nel
   terminale Ubuntu.

Per modificare il codice da Windows, VS Code con l'estensione "WSL" apre la
cartella direttamente dentro Ubuntu (`code .` dal terminale WSL).

### Linux e WSL (Ubuntu)

Procedura verificata su Ubuntu 24.04 (in un container, che è lo stesso ambiente
di WSL2 Ubuntu).

1. **Pacchetti di base.** `build-essential` fornisce anche `c99`.

   ```bash
   sudo apt-get update
   sudo apt-get install -y build-essential git make cmake ragel wget gnupg \
     lsb-release software-properties-common zlib1g-dev libzstd-dev
   ```

2. **LLVM 21.** Ubuntu 24.04 non lo ha nei repository standard: si usa quello
   ufficiale di LLVM.

   ```bash
   wget https://apt.llvm.org/llvm.sh
   chmod +x llvm.sh
   sudo ./llvm.sh 21
   sudo apt-get install -y llvm-21-dev
   ```

3. **Compilatore Monicelli.** Su Linux non c'è Homebrew, quindi `LLVM_DIR` va
   indicato esplicitamente:

   ```bash
   make mcc LLVM_DIR=/usr/lib/llvm-21/lib/cmake/llvm
   ```

4. **Verifica:**

   ```bash
   ~/mcc/bin/mcc --help
   ```

Da qui in poi valgono le istruzioni di [Compilare e lanciare](#compilare-e-lanciare).

### Windows nativo (sperimentale)

Questa procedura **non è stata verificata**; la base è la nota per Windows del
[README di Monicelli](https://github.com/esseks/monicelli/blob/main/README.md).
`mcc` lancia il linker con fork+exec, che su Windows non esiste: va compilato
senza linker, produce solo un file oggetto e il collegamento con la runtime C si
fa a mano.

1. Installare LLVM 21 con i file di sviluppo CMake, ragel, cmake e un compilatore
   C/C++ (per esempio Visual Studio Build Tools, oppure MSYS2 con i pacchetti
   `mingw-w64-x86_64-*`).
2. Compilare `mcc` disabilitando il linker:

   ```bash
   git clone https://github.com/esseks/monicelli
   cd monicelli
   git checkout 07d389c3bb5cd670f1aa3d543c9a29fa4369243e
   cmake -S . -B build -DMONICELLI_LINKER=OFF -DLLVM_DIR=<llvm-21>/lib/cmake/llvm
   cmake --build build --target install
   ```

3. Compilare `antani` in un file oggetto e collegarlo con la runtime C:

   ```bash
   mcc -c src/antani.mc -o antani.o
   clang antani.o -o antani.exe
   ```

`make`, `make test` e `tests/run.sh` richiedono una shell POSIX (Git Bash o
MSYS2). Se qualcosa non torna, WSL2 è la strada sicura.

### Variabili del Makefile

Variabili del `Makefile` che si possono sovrascrivere, per esempio con
`make mcc LLVM_DIR=/percorso/llvm/lib/cmake/llvm`:

| Variabile | Default | Significato |
|---|---|---|
| `MCC` | `~/mcc/bin/mcc` | compilatore usato da `make` |
| `LLVM_DIR` | `$(brew --prefix llvm@21)/lib/cmake/llvm` | configurazione CMake di LLVM 21 |
| `MONICELLI_SRC` | `.build/monicelli` | dove clonare i sorgenti di `mcc` |
| `MONICELLI_REV` | `07d389c…` | commit di Monicelli da compilare |

Su processori ARM (Apple Silicon, Linux ARM, Windows su ARM) il CMake di
Monicelli va configurato con `-DMONICELLI_ARCH=AArch64`, perché il default è
`x86`: questa variante non è stata verificata.

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
