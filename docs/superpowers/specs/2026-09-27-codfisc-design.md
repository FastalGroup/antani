# Codfisc — generatore di codice fiscale in Monicelli

Data: 2026-09-27

## Scopo

Seconda utility del repo: dato cognome, nome, sesso, data e luogo di nascita,
calcola il codice fiscale italiano (DM 23/12/1976). Deve essere **reale e
utilizzabile in produzione**: tabella ufficiale completa dei luoghi (comuni
attuali e cessati, stati esteri), validazione rigorosa dell'input, uso sia
interattivo sia batch.

Come `antani`, tutta la logica è scritta a mano in Monicelli e compilata con
`mcc`. Unica eccezione concordata con l'utente: la **tabella dei luoghi** è un
file `.mc` di soli dati, prodotto da uno script di import a partire dalle fonti
ufficiali (vedi «Tabella dei luoghi»).

## Vincoli verificati (oltre a quelli del CLAUDE.md)

- `Necchi` è `i32` e anche i letterali interi sono `i32` (`types.def`,
  `codegen.cpp:635`). L'hash del luogo è quindi a 32 bit.
- Il blocco `Lei ha clacsonato` diventa `main()` senza parametri
  (`codegen.cpp:121`, `:240`): **argv non è accessibile**. L'unico ingresso è
  stdin.
- `mcc` compila ogni file come modulo separato e non ha prototipi: una funzione
  definita in un altro file non è chiamabile. Il programma deve essere **un solo
  sorgente** al momento della compilazione.
- Spike (usa e getta): una funzione con una catena `che cos'è` di 8.200 casi,
  chiavi `i32` casuali anche negative, compila in circa 30 s e produce un
  eseguibile di circa 200 KB con risultati corretti.
- Il programma non sa se stdin è un terminale, non conosce la data corrente e
  termina sempre con codice di uscita 0.
- **`mcc` non compila sorgenti più grandi di 1 MiB.** Il lexer legge a blocchi
  di 1 MiB (`lexer.h`, `Buffer::DEFAULT_CAPACITY`). Un token a cavallo del
  confine va perso perché `getNextToken` azzera `state_.ts`, e anche con i confini
  allineati su token completi il lexer va in assert alla fine del file
  (`Cursor out of bounds`). Riprodotto con un file sintetico minimo. La tabella
  con controllo di lunghezza e di provincia per ogni nome pesa circa 4 MB e non
  compila. Il formato compatto (sotto) pesa circa 654 KB e compila in circa 1 min.
  Il sorgente concatenato deve restare **sotto 1 MiB**, e il Makefile lo verifica.

## Interfaccia

### Modalità riga (batch, «a parametri»)

Una persona per riga su stdin, una riga di output per ogni riga di input:

```
$ ./codfisc <<< "Rossi;Mario;M;15/03/1985;Roma"
RSSMRA85C15H501R
$ ./codfisc < persone.txt > codici.txt
```

Formato: `Cognome;Nome;Sesso;GG/MM/AAAA;Luogo[;PR]`.

- `Sesso`: `M` o `F`, anche minuscoli.
- `Luogo`: comune (attuale o cessato, denominazione italiana o alternativa
  bilingue) oppure stato estero.
- `PR`: sigla di provincia, facoltativa. Serve **solo a distinguere i nomi
  ambigui** (Livo CO/TN): per questi è accettata qualunque sigla il comune abbia
  avuto nel tempo. Per i nomi non ambigui, cioè il 99%, la sigla viene
  controllata solo nel formato ed è poi ignorata (`Roma;MI` dà H501), per il
  limite di 1 MiB. `EE` equivale a nessuna sigla.
- Spazi prima e dopo ogni campo vengono ignorati.
- Un `\r` a fine riga viene ignorato (file Windows).
- L'output è il codice di 16 caratteri seguito da `\n`, oppure `ERRORE: …`.
- A fine input il programma termina senza stampare altro. L'ultima riga può
  mancare di `\n`.

Nessun banner e nessun prompt in questa modalità.

### Modalità guidata (interattiva)

Si attiva quando la **prima riga** dell'input è vuota, cioè l'utente lancia
`./codfisc` e preme Invio. Poiché il programma non può sapere se stdin è un
terminale, prima dell'Invio non stampa nulla: il README lo documenta.

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

- I prompt non vanno a capo.
- Con un campo errato stampa il messaggio d'errore e **ripete la stessa
  domanda**.
- Se il luogo è ambiguo chiede `Provincia: ` e ripete il calcolo del luogo con
  la sigla. Se il risultato è ancora un errore, lo stampa e torna a
  `Luogo di nascita: `.
- Luogo sconosciuto o non valido alla data: stampa l'errore e ripete la domanda
  sul luogo.
- Termina con `Arrivederci.` quando legge `:q` come risposta a qualunque
  domanda, un cognome vuoto o la fine dell'input.

In questa modalità i messaggi d'errore sono gli stessi della modalità riga,
senza il prefisso `ERRORE: ` e con l'iniziale maiuscola (es.
`Data non valida.`).

### Messaggi di errore (modalità riga)

Ogni riga errata produce esattamente una riga. Il resto della riga viene
scartato e l'elaborazione continua. Se ci sono più errori, si segnala il primo
in ordine di campo.

| Caso | Messaggio |
|---|---|
| numero di campi diverso da 5 o 6, riga vuota dopo la prima | `ERRORE: formato riga (Cognome;Nome;Sesso;GG/MM/AAAA;Luogo[;PR])` |
| cognome senza lettere o con caratteri non ammessi | `ERRORE: cognome non valido` |
| nome senza lettere o con caratteri non ammessi | `ERRORE: nome non valido` |
| sesso diverso da `M`/`F` | `ERRORE: sesso non valido` |
| data malformata o inesistente, anno fuori da 1861–2099 | `ERRORE: data non valida` |
| provincia diversa da 2 lettere | `ERRORE: provincia non valida` |
| luogo non trovato; per un nome ambiguo, sigla che non corrisponde a nessun candidato valido alla data | `ERRORE: luogo sconosciuto` |
| più codici possibili alla data e nessuna provincia che li distingua | `ERRORE: luogo ambiguo, indicare la provincia` |
| nessun periodo di validità contiene la data di nascita | `ERRORE: luogo non valido alla data di nascita` |

Caratteri ammessi nei campi di testo: lettere ASCII, lettere accentate UTF-8 a
2 byte con primo byte `C3`, `C4` o `C5` (ridotte alla lettera base, `ß` → `SS`),
spazio, `'`, `-`, `.`. Qualunque altro byte rende il campo non valido.

## Algoritmo

### Normalizzazione

Ogni lettera viene ridotta a un indice 1–26 (A–Z), ignorando maiuscole e accenti.
Spazi, `'`, `-` e `.` vengono saltati. Le vocali sono A, E, I, O, U; tutte le
altre lettere, comprese J, K, W, X e Y, sono consonanti. La stessa
normalizzazione è implementata in Monicelli (input) e nello script di import
(tabella); i test di copertura ne verificano la coerenza.

### Cognome e nome (streaming)

Durante la lettura si conservano solo le prime 4 consonanti (`c1…c4`), le prime
3 vocali (`v1…v3`) e i contatori `nc`, `nv`.

- Cognome: prime 3 consonanti; se non bastano, si aggiungono le vocali in ordine
  e poi `X` (`Fo` → `FOX`, `Ai` → `AIX`).
- Nome: se `nc ≥ 4`, consonanti 1ª, 3ª e 4ª (`Gianfranco` → `GFR`); altrimenti
  come il cognome.

### Data e sesso

- La data viene letta come `GG/MM/AAAA`, con 1 o 2 cifre per giorno e mese e
  4 cifre per l'anno.
- Viene validata sul calendario reale: bisestile se divisibile per 4 e, per i
  secoli, per 400.
- Si ricava l'intero `data = AAAA*10000 + MM*100 + GG`.
- Il codice è composto dalle ultime due cifre dell'anno, dalla lettera del mese
  (`A B C D E H L M P R S T`) e dal giorno a 2 cifre, aumentato di 40 per le
  donne.

### Luogo

Durante la lettura si calcolano:

- `h = h*31 + lettera` in aritmetica `i32` con overflow. È verificato che `mcc`
  emette `mul`/`add` senza `nsw` (`codegen.def`, `CreateBinOp`);
- `prov = l1*26 + l2` (0 se assente, `EE` trattata come assente).

Non c'è controllo di lunghezza, per il limite di 1 MiB. Un nome inesistente
viene scambiato per uno reale con probabilità di circa 11.000/2³², cioè 1 su
400.000.

`luogo(h, data, prov)`, definita in `src/luoghi.mc`, restituisce:

- `> 0`: codice catastale impacchettato come `lettera*1000 + numero`
  (`H501` → `8501`, `Z404` → `26404`);
- `-1`: sconosciuto; `-2`: ambiguo; `-3`: non valido alla data.

### Carattere di controllo

1. I 15 caratteri vengono salvati in `k1…k15`, perché il codice si stampa solo
   dopo aver validato l'intera riga.
2. Per ciascuno si somma il valore della tabella ufficiale delle posizioni
   dispari (1ª, 3ª, …) o pari. Le due tabelle sono funzioni `dispari`/`pari` da
   36 casi (cifre e lettere).
3. Il resto `s − s/26·26` indica la lettera di controllo (0 → A).

Niente omocodia: il codice generato è quello base. Le varianti omocodiche le
assegna l'Agenzia delle Entrate solo in caso di collisione.

## Tabella dei luoghi

### Fonti (in `dati/`, committate, con URL e data di download in `dati/FONTI.md`)

- `ANPR_archivio_comuni.csv`, archivio storico dei comuni ANPR
  (https://www.anagrafenazionale.interno.it/area-tecnica/archivio-storico-dei-comuni/):
  19.364 righe, di cui 7.894 comuni attivi e 11.470 cessati.
- `tabella_2_statiesteri.xlsx`, tabella di decodifica 2 ANPR (stati esteri):
  si usano le righe con `CODAT` valorizzato, **anche quelle con `NASCITA=N`**
  (territori come Bermuda Z400, Aruba Z501).
- `stati-cessati.csv`, curato a mano: stati esteri cessati assenti dalla
  tabella ANPR (Jugoslavia Z118, URSS Z135, Cecoslovacchia Z105, …), con codici
  e periodi verificati sulla consultazione dell'Agenzia delle Entrate
  (https://arcom.agenziaentrate.gov.it/CitizenArCom/). Formato:
  `denominazione;codice;inizio;fine`.

### Import (`tools/importa-luoghi.py`)

1. Scarta le righe con codice `ND`.
2. Normalizza ogni denominazione (`DENOMINAZIONE_IT` e `ALTRADENOMINAZIONE`
   per i comuni, `DENOMINAZIONE` per gli stati). La normalizzazione è: NFKD,
   rimozione dei diacritici, `ß` → `SS`, maiuscolo, solo A–Z.
3. Raggruppa per nome normalizzato. Per ogni nome raggruppa per codice, unendo
   periodi (`DATAISTITUZIONE`–`DATACESSAZIONE`) e sigle di provincia.
4. Si ferma con un errore se due nomi diversi hanno lo stesso hash. Oggi, con
   11.088 chiavi e moltiplicatore 31, le collisioni sono 0.
5. Scrive `src/luoghi.mc`: un'intestazione `bituma` (file generato, fonti,
   non modificare a mano) e la funzione `luogo`, con una catena
   `che cos'è h?` da un caso per nome. In ogni caso:
   - se il nome ha **un solo codice**, il caso sta su una riga
     (`o magari <h>: r come se fosse <codice>`) e restituisce il codice senza
     guardare data né provincia. Regola di tolleranza: `Abano` per un nato nel
     1950 dà A001, lo stesso codice di Abano Terme;
   - se il nome ha **più codici**, genera `che cos'è` annidati che, per ogni
     codice, contano i candidati validi. Un candidato è valido se un suo periodo
     contiene `data` e, se `prov ≠ 0`, se ha avuto quella sigla. Con un solo
     candidato valido restituisce il suo codice. Con più di uno restituisce
     `-2`. Con nessuno restituisce `-3` se nessun periodo contiene la data,
     altrimenti `-1` (è stata indicata una sigla che non corrisponde).

   Dati di oggi: 94 nomi hanno più codici validi nello stesso periodo (Livo CO/TN,
   Castro BG/LE, Peglio, Samone, San Teodoro, più casi storici). Per 28 coppie
   (nome, provincia) il codice cambia nel tempo (Bellagio CO: A744 fino al
   2014-02-03, poi M335).

Lo script si ferma con un errore se `src/luoghi.mc` supera 768 KiB, per
lasciare spazio a `src/codfisc.mc` sotto il limite di 1 MiB. Il Makefile
verifica il limite sul sorgente concatenato prima di invocare `mcc`.

`make luoghi` riscarica le fonti ANPR e rigenera `src/luoghi.mc`. Il file
generato è committato, così la build non richiede Python né rete.

## Struttura del progetto (aggiunte)

```
src/codfisc.mc            logica, Monicelli scritto a mano
src/luoghi.mc             GENERATO: funzione luogo (solo dati)
dati/                     fonti ufficiali + stati-cessati.csv + FONTI.md
tools/importa-luoghi.py   CSV/XLSX → src/luoghi.mc
tools/verifica-luoghi.py  test di copertura della tabella (oracolo Python)
tests/codfisc/NN-*.in/out casi di test di codfisc
```

- Makefile:
  - `codfisc` concatena `src/luoghi.mc src/codfisc.mc` in `.build/codfisc.mc`
    e compila con `mcc`;
  - `luoghi` rigenera la tabella;
  - `test` esegue le suite dei due programmi;
  - `verifica-luoghi` esegue il test di copertura;
  - prima di `mcc` il Makefile verifica che `.build/codfisc.mc` sia sotto
    1.048.576 byte;
  - `/codfisc` va aggiunto a `.gitignore`.
- Le funzioni di I/O (`leggi`, `scrivi`, `scrivi8`, `aCapo`) vengono copiate da
  `antani.mc`, perché `mcc` non permette di condividerle.
- `tests/run.sh [programma] [prefisso]`: senza argomenti si comporta come oggi
  (antani). Con `codfisc` usa `tests/codfisc/`. Un solo argomento numerico resta
  il prefisso di antani.
- CLAUDE.md: aggiungere l'eccezione (`luoghi.mc` è generato ed è l'unico caso),
  i comandi e l'architettura di `codfisc.mc`. README: sezione d'uso.

## Test

TDD con coppie `.in`/`.out`, valori attesi calcolati a mano (passaggi annotati
nel piano) o presi da codici fiscali di esempio pubblicati, mai copiati
dall'output del programma. Casi:

1. codice base (`Rossi;Mario;M;15/03/1985;Roma` → `RSSMRA85C15H501R`)
2. cognomi e nomi corti, solo vocali, ≥ 4 consonanti nel nome
3. accenti, apostrofi, doppi cognomi, `ß`
4. donne (giorno + 40), tutti i mesi, 29/02 bisestile e non
5. comuni omonimi: senza provincia (ambiguo) e con provincia
6. provincia ignorata per un nome non ambiguo (`Roma;MI` → H501), sigla malformata (`Roma;R1`) → errore
7. fusioni legate alla data (Bellagio 2010 → A744, 2020 → M335)
8. denominazione bilingue (`Bozen` = `Bolzano`)
9. stati esteri, stato cessato (Jugoslavia 1970), `EE`
10. tutti i messaggi di errore; riga errata seguita da riga valida
11. CRLF, spazi attorno ai campi, ultima riga senza `\n`
12. modalità guidata: flusso completo, domanda ripetuta dopo un errore,
    provincia chiesta per un luogo ambiguo, `:q`, EOF

**Test di copertura della tabella** (`make verifica-luoghi`):
`tools/verifica-luoghi.py` genera, per ogni nome normalizzato e per ogni suo
periodo di validità, una riga di input con persona fissa, data interna al periodo
e provincia quando serve. Calcola il codice atteso con un'implementazione di
riferimento indipendente in Python, basata sulle sole fonti, e lo confronta con
l'output di `codfisc`. L'implementazione Python è solo un oracolo di test e non
entra mai nel programma.

## Fuori scopo

- Omocodia e calcolo inverso (dal codice ai dati).
- Lettura di argv o codici di uscita diversi da 0 (impossibili in Monicelli
  puro).
- Rilevamento automatico del terminale: la modalità guidata si attiva con una
  prima riga vuota.
- Controllo che la data non sia futura (il programma non conosce la data
  corrente).
