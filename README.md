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

Solo la prima lettera dopo `:` viene controllata: `:quit` equivale a `:q`, `:ordina` a `:o`.
I tab contano come spazi (a inizio/fine riga vengono tagliati, in mezzo diventano uno spazio).

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
