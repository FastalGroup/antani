bituma codfisc.mc - calcolo del codice fiscale in Monicelli puro.
bituma La funzione luogo(h, data, prov) sta in luoghi.mc (generato), concatenato prima di questo file dal Makefile.
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

bituma Legge un byte da stdin: 0-254, 256 a fine input, oppure 1000+b per un byte 0xFF reale seguito dal byte b.
bituma car parte da -1, come in antani.mc: a EOF resta invariato e si confonde con 0xFF. Per distinguerli si legge
bituma ancora: dopo l'EOF scanf resta a EOF, quindi -1 di nuovo vuol dire fine input (FF FF resta ambiguo);
bituma altrimenti il 0xFF era un byte vero e il byte appena letto va restituito al chiamante insieme a lui.
blinda la supercazzola Necchi leggi o scherziamo?
  voglio car, Mascetti come se fosse -1
  voglio dopo, Mascetti come se fosse -1
  voglio valore, Necchi come se fosse 0
  mi porga car
  valore come se fosse car
  che cos'è valore?
    minore di 0: valore come se fosse valore più 256
  e velocità di esecuzione
  che cos'è valore?
    255:
      mi porga dopo
      valore come se fosse dopo
      che cos'è valore?
        -1: valore come se fosse 256
        o magari minore di 0: valore come se fosse valore più 1256
        o tarapia tapioco: valore come se fosse valore più 1000
      e velocità di esecuzione
  e velocità di esecuzione
  vaffanzum valore!

bituma 'Lei ha clacsonato! Calcolo del codice fiscale.\nRisponda alle domande; :q per uscire.\n'
blinda la supercazzola msgBenvenuto o scherziamo?
  brematurata la supercazzola scrivi8 con 76, 101, 105, 32, 104, 97, 32, 99 o scherziamo?
  brematurata la supercazzola scrivi8 con 108, 97, 99, 115, 111, 110, 97, 116 o scherziamo?
  brematurata la supercazzola scrivi8 con 111, 33, 32, 67, 97, 108, 99, 111 o scherziamo?
  brematurata la supercazzola scrivi8 con 108, 111, 32, 100, 101, 108, 32, 99 o scherziamo?
  brematurata la supercazzola scrivi8 con 111, 100, 105, 99, 101, 32, 102, 105 o scherziamo?
  brematurata la supercazzola scrivi8 con 115, 99, 97, 108, 101, 46, 10, 82 o scherziamo?
  brematurata la supercazzola scrivi8 con 105, 115, 112, 111, 110, 100, 97, 32 o scherziamo?
  brematurata la supercazzola scrivi8 con 97, 108, 108, 101, 32, 100, 111, 109 o scherziamo?
  brematurata la supercazzola scrivi8 con 97, 110, 100, 101, 59, 32, 58, 113 o scherziamo?
  brematurata la supercazzola scrivi8 con 32, 112, 101, 114, 32, 117, 115, 99 o scherziamo?
  brematurata la supercazzola scrivi8 con 105, 114, 101, 46, 10, 0, 0, 0 o scherziamo?

bituma 'Arrivederci.\n'
blinda la supercazzola msgArrivederci o scherziamo?
  brematurata la supercazzola scrivi8 con 65, 114, 114, 105, 118, 101, 100, 101 o scherziamo?
  brematurata la supercazzola scrivi8 con 114, 99, 105, 46, 10, 0, 0, 0 o scherziamo?

bituma 'Codice fiscale: '
blinda la supercazzola msgCodice o scherziamo?
  brematurata la supercazzola scrivi8 con 67, 111, 100, 105, 99, 101, 32, 102 o scherziamo?
  brematurata la supercazzola scrivi8 con 105, 115, 99, 97, 108, 101, 58, 32 o scherziamo?

bituma Prompt della domanda q (1-6) della modalita' guidata.
blinda la supercazzola prompt con q Necchi o scherziamo?
  che cos'è q?
    1:
      bituma 'Cognome: '
      brematurata la supercazzola scrivi8 con 67, 111, 103, 110, 111, 109, 101, 58 o scherziamo?
      brematurata la supercazzola scrivi8 con 32, 0, 0, 0, 0, 0, 0, 0 o scherziamo?
    o magari 2:
      bituma 'Nome: '
      brematurata la supercazzola scrivi8 con 78, 111, 109, 101, 58, 32, 0, 0 o scherziamo?
    o magari 3:
      bituma 'Sesso (M/F): '
      brematurata la supercazzola scrivi8 con 83, 101, 115, 115, 111, 32, 40, 77 o scherziamo?
      brematurata la supercazzola scrivi8 con 47, 70, 41, 58, 32, 0, 0, 0 o scherziamo?
    o magari 4:
      bituma 'Data di nascita (GG/MM/AAAA): '
      brematurata la supercazzola scrivi8 con 68, 97, 116, 97, 32, 100, 105, 32 o scherziamo?
      brematurata la supercazzola scrivi8 con 110, 97, 115, 99, 105, 116, 97, 32 o scherziamo?
      brematurata la supercazzola scrivi8 con 40, 71, 71, 47, 77, 77, 47, 65 o scherziamo?
      brematurata la supercazzola scrivi8 con 65, 65, 65, 41, 58, 32, 0, 0 o scherziamo?
    o magari 5:
      bituma 'Luogo di nascita: '
      brematurata la supercazzola scrivi8 con 76, 117, 111, 103, 111, 32, 100, 105 o scherziamo?
      brematurata la supercazzola scrivi8 con 32, 110, 97, 115, 99, 105, 116, 97 o scherziamo?
      brematurata la supercazzola scrivi8 con 58, 32, 0, 0, 0, 0, 0, 0 o scherziamo?
    o magari 6:
      bituma 'Provincia: '
      brematurata la supercazzola scrivi8 con 80, 114, 111, 118, 105, 110, 99, 105 o scherziamo?
      brematurata la supercazzola scrivi8 con 97, 58, 32, 0, 0, 0, 0, 0 o scherziamo?
  e velocità di esecuzione

bituma Messaggio d'errore n. Modo 0 (riga): 'ERRORE: testo\n'. Modo 1 (guidata): 'Testo.\n' con l'iniziale maiuscola.
blinda la supercazzola errore con n Necchi, modo Necchi o scherziamo?
  voglio maiuscola, Necchi come se fosse 0
  che cos'è modo?
    1: maiuscola come se fosse 32
    o tarapia tapioco:
      bituma 'ERRORE: '
      brematurata la supercazzola scrivi8 con 69, 82, 82, 79, 82, 69, 58, 32 o scherziamo?
  e velocità di esecuzione
  che cos'è n?
    1:
      bituma 'cognome non valido'
      brematurata la supercazzola scrivi8 con 99 meno maiuscola, 111, 103, 110, 111, 109, 101, 32 o scherziamo?
      brematurata la supercazzola scrivi8 con 110, 111, 110, 32, 118, 97, 108, 105 o scherziamo?
      brematurata la supercazzola scrivi8 con 100, 111, 0, 0, 0, 0, 0, 0 o scherziamo?
    o magari 2:
      bituma 'nome non valido'
      brematurata la supercazzola scrivi8 con 110 meno maiuscola, 111, 109, 101, 32, 110, 111, 110 o scherziamo?
      brematurata la supercazzola scrivi8 con 32, 118, 97, 108, 105, 100, 111, 0 o scherziamo?
    o magari 3:
      bituma 'sesso non valido'
      brematurata la supercazzola scrivi8 con 115 meno maiuscola, 101, 115, 115, 111, 32, 110, 111 o scherziamo?
      brematurata la supercazzola scrivi8 con 110, 32, 118, 97, 108, 105, 100, 111 o scherziamo?
    o magari 4:
      bituma 'data non valida'
      brematurata la supercazzola scrivi8 con 100 meno maiuscola, 97, 116, 97, 32, 110, 111, 110 o scherziamo?
      brematurata la supercazzola scrivi8 con 32, 118, 97, 108, 105, 100, 97, 0 o scherziamo?
    o magari 5:
      bituma 'luogo sconosciuto'
      brematurata la supercazzola scrivi8 con 108 meno maiuscola, 117, 111, 103, 111, 32, 115, 99 o scherziamo?
      brematurata la supercazzola scrivi8 con 111, 110, 111, 115, 99, 105, 117, 116 o scherziamo?
      brematurata la supercazzola scrivi8 con 111, 0, 0, 0, 0, 0, 0, 0 o scherziamo?
    o magari 6:
      bituma 'provincia non valida'
      brematurata la supercazzola scrivi8 con 112 meno maiuscola, 114, 111, 118, 105, 110, 99, 105 o scherziamo?
      brematurata la supercazzola scrivi8 con 97, 32, 110, 111, 110, 32, 118, 97 o scherziamo?
      brematurata la supercazzola scrivi8 con 108, 105, 100, 97, 0, 0, 0, 0 o scherziamo?
    o magari 7:
      bituma 'luogo ambiguo, indicare la provincia'
      brematurata la supercazzola scrivi8 con 108 meno maiuscola, 117, 111, 103, 111, 32, 97, 109 o scherziamo?
      brematurata la supercazzola scrivi8 con 98, 105, 103, 117, 111, 44, 32, 105 o scherziamo?
      brematurata la supercazzola scrivi8 con 110, 100, 105, 99, 97, 114, 101, 32 o scherziamo?
      brematurata la supercazzola scrivi8 con 108, 97, 32, 112, 114, 111, 118, 105 o scherziamo?
      brematurata la supercazzola scrivi8 con 110, 99, 105, 97, 0, 0, 0, 0 o scherziamo?
    o magari 8:
      bituma 'luogo non valido alla data di nascita'
      brematurata la supercazzola scrivi8 con 108 meno maiuscola, 117, 111, 103, 111, 32, 110, 111 o scherziamo?
      brematurata la supercazzola scrivi8 con 110, 32, 118, 97, 108, 105, 100, 111 o scherziamo?
      brematurata la supercazzola scrivi8 con 32, 97, 108, 108, 97, 32, 100, 97 o scherziamo?
      brematurata la supercazzola scrivi8 con 116, 97, 32, 100, 105, 32, 110, 97 o scherziamo?
      brematurata la supercazzola scrivi8 con 115, 99, 105, 116, 97, 0, 0, 0 o scherziamo?
    o magari 9:
      bituma 'formato riga (Cognome;Nome;Sesso;GG/MM/AAAA;Luogo[;PR])'
      brematurata la supercazzola scrivi8 con 102 meno maiuscola, 111, 114, 109, 97, 116, 111, 32 o scherziamo?
      brematurata la supercazzola scrivi8 con 114, 105, 103, 97, 32, 40, 67, 111 o scherziamo?
      brematurata la supercazzola scrivi8 con 103, 110, 111, 109, 101, 59, 78, 111 o scherziamo?
      brematurata la supercazzola scrivi8 con 109, 101, 59, 83, 101, 115, 115, 111 o scherziamo?
      brematurata la supercazzola scrivi8 con 59, 71, 71, 47, 77, 77, 47, 65 o scherziamo?
      brematurata la supercazzola scrivi8 con 65, 65, 65, 59, 76, 117, 111, 103 o scherziamo?
      brematurata la supercazzola scrivi8 con 111, 91, 59, 80, 82, 93, 41, 0 o scherziamo?
  e velocità di esecuzione
  che cos'è modo? 1: brematurata la supercazzola scrivi con 46 o scherziamo? e velocità di esecuzione
  brematurata la supercazzola aCapo o scherziamo?

bituma Byte ASCII -> lettera 1-26 (A=1, maiuscole e minuscole), 0 se non e' una lettera ASCII.
blinda la supercazzola Necchi lettera con byte Necchi o scherziamo?
  voglio r, Necchi come se fosse 0
  che cos'è byte?
    minore di 65:
    o magari minore di 91: r come se fosse byte meno 64
    o magari minore di 97:
    o magari minore di 123: r come se fosse byte meno 96
  e velocità di esecuzione
  vaffanzum r!

bituma Lettera accentata UTF-8 a 2 byte -> lettera base 1-26, 27 per la sharp s (vale SS), 97 se non ammessa.
bituma Stessa riduzione di NFKD usata da tools/importa-luoghi.py: le lettere senza scomposizione (AE, O barrata, eth...) non sono ammesse.
blinda la supercazzola Necchi accentata con primo Necchi, sec Necchi o scherziamo?
  voglio r, Necchi come se fosse 97
  che cos'è primo?
    195:
      che cos'è sec?
        minore di 128:
        o magari minore di 134: r come se fosse 1
        o magari 135: r come se fosse 3
        o magari minore di 136:
        o magari minore di 140: r come se fosse 5
        o magari minore di 144: r come se fosse 9
        o magari 145: r come se fosse 14
        o magari minore di 146:
        o magari minore di 151: r come se fosse 15
        o magari minore di 153:
        o magari minore di 157: r come se fosse 21
        o magari 157: r come se fosse 25
        o magari 159: r come se fosse 27
        o magari minore di 160:
        o magari minore di 166: r come se fosse 1
        o magari 167: r come se fosse 3
        o magari minore di 168:
        o magari minore di 172: r come se fosse 5
        o magari minore di 176: r come se fosse 9
        o magari 177: r come se fosse 14
        o magari minore di 178:
        o magari minore di 183: r come se fosse 15
        o magari minore di 185:
        o magari minore di 189: r come se fosse 21
        o magari 189: r come se fosse 25
        o magari 191: r come se fosse 25
      e velocità di esecuzione
    o magari 196:
      che cos'è sec? 134: r come se fosse 3 o magari 135: r come se fosse 3 o magari 140: r come se fosse 3 o magari 141: r come se fosse 3 e velocità di esecuzione
    o magari 197:
      che cos'è sec? 160: r come se fosse 19 o magari 161: r come se fosse 19 o magari 189: r come se fosse 26 o magari 190: r come se fosse 26 e velocità di esecuzione
  e velocità di esecuzione
  vaffanzum r!

bituma Byte di un campo di testo (cognome, nome, luogo) -> lettera 1-26, 27 = SS, 0 = da saltare (' - .),
bituma 97 = non ammesso, 96 = non ammesso e un byte successivo era ';', 98 = ... era '\n', 99 = ... era la fine dell'input.
bituma Spazi e tab li gestisce il blocco principale. 0xC3, 0xC4, 0xC5 aprono una accentata: il secondo byte viene letto qui.
blinda la supercazzola Necchi decodifica con byte Necchi o scherziamo?
  voglio r, Necchi come se fosse 97
  voglio seconda, Necchi come se fosse 0
  che cos'è byte?
    39: r come se fosse 0
    o magari 45: r come se fosse 0
    o magari 46: r come se fosse 0
    o magari minore di 65:
    o magari minore di 91: r come se fosse byte meno 64
    o magari minore di 97:
    o magari minore di 123: r come se fosse byte meno 96
    o magari 194:
bituma C2 A0, spazio non separabile: si salta come uno spazio.
      seconda come se fosse brematurata la supercazzola leggi o scherziamo?
      che cos'è seconda? 160: r come se fosse 0 o magari 10: r come se fosse 98 o magari 256: r come se fosse 99 o magari 59: r come se fosse 96 e velocità di esecuzione
    o magari 226:
bituma E2 80 98 e E2 80 99, apostrofi tipografici: si saltano come l'apostrofo.
      seconda come se fosse brematurata la supercazzola leggi o scherziamo?
      che cos'è seconda?
        10: r come se fosse 98
        o magari 256: r come se fosse 99
        o magari 59: r come se fosse 96
        o magari 128:
          seconda come se fosse brematurata la supercazzola leggi o scherziamo?
          che cos'è seconda? 152: r come se fosse 0 o magari 153: r come se fosse 0 o magari 10: r come se fosse 98 o magari 256: r come se fosse 99 o magari 59: r come se fosse 96 e velocità di esecuzione
      e velocità di esecuzione
    o magari minore di 195:
    o magari minore di 198:
      seconda come se fosse brematurata la supercazzola leggi o scherziamo?
      che cos'è seconda?
        10: r come se fosse 98
        o magari 256: r come se fosse 99
        o magari 59: r come se fosse 96
        o tarapia tapioco: r come se fosse brematurata la supercazzola accentata con byte, seconda o scherziamo?
      e velocità di esecuzione
  e velocità di esecuzione
  vaffanzum r!

bituma Lettera p (1-3) del codice di cognome (nome = 0) o nome (nome = 1), come lettera 1-26 (X = 24).
bituma Nome con almeno 4 consonanti: 1a, 3a e 4a. Altrimenti consonanti, poi vocali, poi X.
blinda la supercazzola Necchi sigla con p Necchi, c1 Necchi, c2 Necchi, c3 Necchi, c4 Necchi, v1 Necchi, v2 Necchi, v3 Necchi, nc Necchi, nv Necchi, nome Necchi o scherziamo?
  voglio r, Necchi come se fosse 24
  voglio idx, Necchi come se fosse p
  voglio salta, Necchi come se fosse 0
  che cos'è nome? 1: che cos'è nc? maggiore di 3: salta come se fosse 1 e velocità di esecuzione e velocità di esecuzione
  che cos'è salta?
    1: che cos'è p? 1: r come se fosse c1 o magari 2: r come se fosse c3 o tarapia tapioco: r come se fosse c4 e velocità di esecuzione
    o tarapia tapioco:
      che cos'è idx?
        minore uguale a nc:
          che cos'è idx? 1: r come se fosse c1 o magari 2: r come se fosse c2 o tarapia tapioco: r come se fosse c3 e velocità di esecuzione
        o tarapia tapioco:
          idx come se fosse idx meno nc
          che cos'è idx? minore uguale a nv: che cos'è idx? 1: r come se fosse v1 o magari 2: r come se fosse v2 o tarapia tapioco: r come se fosse v3 e velocità di esecuzione e velocità di esecuzione
      e velocità di esecuzione
  e velocità di esecuzione
  vaffanzum r!

bituma Giorni del mese m nell'anno a (bisestile: divisibile per 4, ma non per 100 salvo per 400).
blinda la supercazzola Necchi giorniMese con m Necchi, a Necchi o scherziamo?
  voglio r, Necchi come se fosse 31
  voglio bis, Necchi come se fosse 0
  voglio t, Necchi come se fosse 0
  che cos'è m?
    4: r come se fosse 30
    o magari 6: r come se fosse 30
    o magari 9: r come se fosse 30
    o magari 11: r come se fosse 30
    o magari 2:
      r come se fosse 28
      t come se fosse a meno a diviso 4 per 4
      che cos'è t? 0: bis come se fosse 1 e velocità di esecuzione
      t come se fosse a meno a diviso 100 per 100
      che cos'è t? 0: bis come se fosse 0 e velocità di esecuzione
      t come se fosse a meno a diviso 400 per 400
      che cos'è t? 0: bis come se fosse 1 e velocità di esecuzione
      che cos'è bis? 1: r come se fosse 29 e velocità di esecuzione
  e velocità di esecuzione
  vaffanzum r!

bituma Lettera ASCII del mese: A B C D E H L M P R S T.
blinda la supercazzola Necchi lettMese con m Necchi o scherziamo?
  voglio r, Necchi come se fosse 65
  che cos'è m?
    2: r come se fosse 66
    o magari 3: r come se fosse 67
    o magari 4: r come se fosse 68
    o magari 5: r come se fosse 69
    o magari 6: r come se fosse 72
    o magari 7: r come se fosse 76
    o magari 8: r come se fosse 77
    o magari 9: r come se fosse 80
    o magari 10: r come se fosse 82
    o magari 11: r come se fosse 83
    o magari 12: r come se fosse 84
  e velocità di esecuzione
  vaffanzum r!

bituma Valore di un carattere ASCII (cifra o lettera maiuscola) in posizione dispari, per il carattere di controllo.
blinda la supercazzola Necchi dispari con k Necchi o scherziamo?
  voglio t, Necchi come se fosse 0
  voglio r, Necchi come se fosse 0
  che cos'è k? minore di 65: t come se fosse k meno 48 o tarapia tapioco: t come se fosse k meno 65 e velocità di esecuzione
  che cos'è t?
    0: r come se fosse 1
    o magari 1: r come se fosse 0
    o magari 2: r come se fosse 5
    o magari 3: r come se fosse 7
    o magari 4: r come se fosse 9
    o magari 5: r come se fosse 13
    o magari 6: r come se fosse 15
    o magari 7: r come se fosse 17
    o magari 8: r come se fosse 19
    o magari 9: r come se fosse 21
    o magari 10: r come se fosse 2
    o magari 11: r come se fosse 4
    o magari 12: r come se fosse 18
    o magari 13: r come se fosse 20
    o magari 14: r come se fosse 11
    o magari 15: r come se fosse 3
    o magari 16: r come se fosse 6
    o magari 17: r come se fosse 8
    o magari 18: r come se fosse 12
    o magari 19: r come se fosse 14
    o magari 20: r come se fosse 16
    o magari 21: r come se fosse 10
    o magari 22: r come se fosse 22
    o magari 23: r come se fosse 25
    o magari 24: r come se fosse 24
    o magari 25: r come se fosse 23
  e velocità di esecuzione
  vaffanzum r!

bituma Valore in posizione pari: cifre 0-9, lettere A=0 ... Z=25.
blinda la supercazzola Necchi pari con k Necchi o scherziamo?
  voglio r, Necchi come se fosse 0
  che cos'è k? minore di 65: r come se fosse k meno 48 o tarapia tapioco: r come se fosse k meno 65 e velocità di esecuzione
  vaffanzum r!

bituma Stampa i 16 caratteri del codice e va a capo. k1-k6 sono gia' ASCII; cod e' lettera*1000+numero del luogo.
blinda la supercazzola stampaCodice con k1 Necchi, k2 Necchi, k3 Necchi, k4 Necchi, k5 Necchi, k6 Necchi, nA Necchi, nM Necchi, nG Necchi, sx Necchi, cod Necchi o scherziamo?
  voglio k7, Necchi come se fosse 0
  voglio k8, Necchi come se fosse 0
  voglio k9, Necchi come se fosse 0
  voglio k10, Necchi come se fosse 0
  voglio k11, Necchi come se fosse 0
  voglio k12, Necchi come se fosse 0
  voglio k13, Necchi come se fosse 0
  voglio k14, Necchi come se fosse 0
  voglio k15, Necchi come se fosse 0
  voglio k16, Necchi come se fosse 0
  voglio t, Necchi come se fosse 0
  voglio s, Necchi come se fosse 0
  voglio gs, Necchi come se fosse nG
  voglio num, Necchi come se fosse 0
  t come se fosse nA meno nA diviso 100 per 100
  k7 come se fosse 48 più t diviso 10
  k8 come se fosse 48 più t meno t diviso 10 per 10
  k9 come se fosse brematurata la supercazzola lettMese con nM o scherziamo?
  che cos'è sx? 2: gs come se fosse nG più 40 e velocità di esecuzione
  k10 come se fosse 48 più gs diviso 10
  k11 come se fosse 48 più gs meno gs diviso 10 per 10
  k12 come se fosse 64 più cod diviso 1000
  num come se fosse cod meno cod diviso 1000 per 1000
  k13 come se fosse 48 più num diviso 100
  k14 come se fosse 48 più num diviso 10 meno num diviso 100 per 10
  k15 come se fosse 48 più num meno num diviso 10 per 10
  s come se fosse brematurata la supercazzola dispari con k1 o scherziamo?
  s come se fosse s più brematurata la supercazzola pari con k2 o scherziamo?
  s come se fosse s più brematurata la supercazzola dispari con k3 o scherziamo?
  s come se fosse s più brematurata la supercazzola pari con k4 o scherziamo?
  s come se fosse s più brematurata la supercazzola dispari con k5 o scherziamo?
  s come se fosse s più brematurata la supercazzola pari con k6 o scherziamo?
  s come se fosse s più brematurata la supercazzola dispari con k7 o scherziamo?
  s come se fosse s più brematurata la supercazzola pari con k8 o scherziamo?
  s come se fosse s più brematurata la supercazzola dispari con k9 o scherziamo?
  s come se fosse s più brematurata la supercazzola pari con k10 o scherziamo?
  s come se fosse s più brematurata la supercazzola dispari con k11 o scherziamo?
  s come se fosse s più brematurata la supercazzola pari con k12 o scherziamo?
  s come se fosse s più brematurata la supercazzola dispari con k13 o scherziamo?
  s come se fosse s più brematurata la supercazzola pari con k14 o scherziamo?
  s come se fosse s più brematurata la supercazzola dispari con k15 o scherziamo?
  k16 come se fosse 65 più s meno s diviso 26 per 26
  brematurata la supercazzola scrivi8 con k1, k2, k3, k4, k5, k6, k7, k8 o scherziamo?
  brematurata la supercazzola scrivi8 con k9, k10, k11, k12, k13, k14, k15, k16 o scherziamo?
  brematurata la supercazzola aCapo o scherziamo?

Lei ha clacsonato
bituma [SEZIONE: dichiarazioni]
  voglio modo, Necchi come se fosse 0
  voglio continua, Necchi come se fosse 1
  voglio sospeso, Necchi come se fosse -1
  voglio byte, Necchi come se fosse 0
  voglio l, Necchi come se fosse 0
  voglio ripeti, Necchi come se fosse 0
  voglio voc, Necchi come se fosse 0
  voglio t, Necchi come se fosse 0
  voglio fineRiga, Necchi come se fosse 0
  voglio fineInput, Necchi come se fosse 0
  voglio apri, Necchi come se fosse 0
  voglio chiudi, Necchi come se fosse 0
  voglio separa, Necchi come se fosse 0
  voglio campo, Necchi come se fosse 1
  voglio q, Necchi come se fosse 1
  voglio nRiga, Necchi come se fosse 0
  voglio nByte, Necchi come se fosse 0
  voglio primo, Necchi come se fosse 0
  voglio secondo, Necchi come se fosse 0
  voglio cattivo, Necchi come se fosse 0
  voglio lettere, Necchi come se fosse 0
  voglio iniziato, Necchi come se fosse 0
  voglio spazioDopo, Necchi come se fosse 0
  voglio c1, Necchi come se fosse 0 voglio c2, Necchi come se fosse 0 voglio c3, Necchi come se fosse 0 voglio c4, Necchi come se fosse 0
  voglio v1, Necchi come se fosse 0 voglio v2, Necchi come se fosse 0 voglio v3, Necchi come se fosse 0
  voglio nc, Necchi come se fosse 0 voglio nv, Necchi come se fosse 0
  voglio h, Necchi come se fosse 0
  voglio parte, Necchi come se fosse 1
  voglio g, Necchi come se fosse 0 voglio m, Necchi come se fosse 0 voglio a, Necchi come se fosse 0
  voglio cg, Necchi come se fosse 0 voglio cm, Necchi come se fosse 0 voglio ca, Necchi come se fosse 0
  voglio sx, Necchi come se fosse 0 voglio nsx, Necchi come se fosse 0
  voglio p1, Necchi come se fosse 0 voglio p2, Necchi come se fosse 0 voglio np, Necchi come se fosse 0
  voglio k1, Necchi come se fosse 0 voglio k2, Necchi come se fosse 0 voglio k3, Necchi come se fosse 0
  voglio k4, Necchi come se fosse 0 voglio k5, Necchi come se fosse 0 voglio k6, Necchi come se fosse 0
  voglio errCog, Necchi come se fosse 0 voglio errNom, Necchi come se fosse 0 voglio errSes, Necchi come se fosse 0
  voglio errDat, Necchi come se fosse 0 voglio errLuo, Necchi come se fosse 0 voglio errPro, Necchi come se fosse 0
  voglio sesso, Necchi come se fosse 0
  voglio nascG, Necchi come se fosse 0 voglio nascM, Necchi come se fosse 0 voglio nascA, Necchi come se fosse 0
  voglio data, Necchi come se fosse 0
  voglio hL, Necchi come se fosse 0
  voglio prov, Necchi come se fosse 0
  voglio r, Necchi come se fosse 0
  voglio n, Necchi come se fosse 0
  voglio esci, Necchi come se fosse 0
bituma [SEZIONE: modo]
bituma Prima riga vuota (anche \r\n): modalita' guidata. Altrimenti il primo byte resta in sospeso per la modalita' riga.
  byte come se fosse brematurata la supercazzola leggi o scherziamo?
bituma BOM UTF-8 (EF BB BF) in testa ai file salvati da alcuni editor Windows: si salta.
  che cos'è byte? 239: brematurata la supercazzola leggi o scherziamo? brematurata la supercazzola leggi o scherziamo? byte come se fosse brematurata la supercazzola leggi o scherziamo? e velocità di esecuzione
  che cos'è byte? 13: byte come se fosse brematurata la supercazzola leggi o scherziamo? e velocità di esecuzione
  che cos'è byte?
    10: modo come se fosse 1 brematurata la supercazzola msgBenvenuto o scherziamo?
    o tarapia tapioco: sospeso come se fosse byte
  e velocità di esecuzione
  stuzzica
bituma [SEZIONE: inizio riga]
    che cos'è modo?
      1: brematurata la supercazzola prompt con q o scherziamo? campo come se fosse q
      o tarapia tapioco: campo come se fosse 1
    e velocità di esecuzione
    nRiga come se fosse 0
    fineRiga come se fosse 0
    prov come se fosse 0
    errCog come se fosse 0 errNom come se fosse 0 errSes come se fosse 0 errDat come se fosse 0 errLuo come se fosse 0 errPro come se fosse 0
    apri come se fosse 1
    stuzzica
bituma [SEZIONE: apri campo]
      che cos'è apri?
        1:
          cattivo come se fosse 0 lettere come se fosse 0 iniziato come se fosse 0 spazioDopo come se fosse 0
          nByte come se fosse 0 primo come se fosse 0 secondo come se fosse 0
          c1 come se fosse 0 c2 come se fosse 0 c3 come se fosse 0 c4 come se fosse 0
          v1 come se fosse 0 v2 come se fosse 0 v3 come se fosse 0 nc come se fosse 0 nv come se fosse 0
          h come se fosse 0 parte come se fosse 1
          g come se fosse 0 m come se fosse 0 a come se fosse 0 cg come se fosse 0 cm come se fosse 0 ca come se fosse 0
          sx come se fosse 0 nsx come se fosse 0 p1 come se fosse 0 p2 come se fosse 0 np come se fosse 0
          apri come se fosse 0
      e velocità di esecuzione
bituma [SEZIONE: lettura byte]
      che cos'è sospeso?
        minore di 0: byte come se fosse brematurata la supercazzola leggi o scherziamo?
        o tarapia tapioco: byte come se fosse sospeso sospeso come se fosse -1
      e velocità di esecuzione
bituma 0xFF reale seguito da un byte (vedi leggi): si elabora 255, non ammesso, e il byte seguente resta in sospeso.
      che cos'è byte? maggiore di 999: sospeso come se fosse byte meno 1000 byte come se fosse 255 e velocità di esecuzione
      chiudi come se fosse 0
      separa come se fosse 0
      che cos'è byte?
        256: fineRiga come se fosse 1 fineInput come se fosse 1 chiudi come se fosse 1
        o magari 10: fineRiga come se fosse 1 chiudi come se fosse 1
        o magari 13:
        o tarapia tapioco:
          nRiga come se fosse nRiga più 1
          t come se fosse 0
          che cos'è byte? 59: che cos'è modo? 0: t come se fosse 1 e velocità di esecuzione e velocità di esecuzione
          che cos'è t?
            1: chiudi come se fosse 1 separa come se fosse 1
            o tarapia tapioco:
bituma [SEZIONE: elabora byte]
              che cos'è byte? 9: byte come se fosse 32 e velocità di esecuzione
              che cos'è byte?
                32: che cos'è iniziato? 1: spazioDopo come se fosse 1 e velocità di esecuzione
                o tarapia tapioco:
                  nByte come se fosse nByte più 1
                  che cos'è nByte? 1: primo come se fosse byte o magari 2: secondo come se fosse byte e velocità di esecuzione
                  che cos'è spazioDopo? 1: che cos'è campo? 3: cattivo come se fosse 1 o magari 4: cattivo come se fosse 1 o magari 6: cattivo come se fosse 1 e velocità di esecuzione e velocità di esecuzione
                  iniziato come se fosse 1
                  che cos'è campo?
                    3:
                      nsx come se fosse nsx più 1
                      che cos'è byte? 77: sx come se fosse 1 o magari 109: sx come se fosse 1 o magari 70: sx come se fosse 2 o magari 102: sx come se fosse 2 o tarapia tapioco: cattivo come se fosse 1 e velocità di esecuzione
                    o magari 4:
                      che cos'è byte?
                        47:
                          parte come se fosse parte più 1
                          che cos'è parte? maggiore di 3: cattivo come se fosse 1 e velocità di esecuzione
                        o magari minore di 48: cattivo come se fosse 1
                        o magari minore di 58:
                          t come se fosse byte meno 48
                          che cos'è parte?
                            1: g come se fosse g per 10 più t cg come se fosse cg più 1
                            o magari 2: m come se fosse m per 10 più t cm come se fosse cm più 1
                            o magari 3: a come se fosse a per 10 più t ca come se fosse ca più 1
                          e velocità di esecuzione
                        o tarapia tapioco: cattivo come se fosse 1
                      e velocità di esecuzione
                    o magari 6:
                      np come se fosse np più 1
                      l come se fosse brematurata la supercazzola lettera con byte o scherziamo?
                      che cos'è l? 0: cattivo come se fosse 1 e velocità di esecuzione
                      che cos'è np? 1: p1 come se fosse l o magari 2: p2 come se fosse l e velocità di esecuzione
                    o magari minore di 6:
bituma cognome (1), nome (2) e luogo (5): lettere normalizzate, SS vale due volte S.
                      l come se fosse brematurata la supercazzola decodifica con byte o scherziamo?
                      che cos'è l?
                        0:
                        o magari 96:
                          cattivo come se fosse 1
                          che cos'è modo? 0: chiudi come se fosse 1 separa come se fosse 1 e velocità di esecuzione
                        o magari 97: cattivo come se fosse 1
                        o magari 98: cattivo come se fosse 1 fineRiga come se fosse 1 chiudi come se fosse 1
                        o magari 99: cattivo come se fosse 1 fineRiga come se fosse 1 fineInput come se fosse 1 chiudi come se fosse 1
                        o tarapia tapioco:
                          ripeti come se fosse 1
                          che cos'è l? 27: l come se fosse 19 ripeti come se fosse 2 e velocità di esecuzione
                          stuzzica
                            lettere come se fosse lettere più 1
                            che cos'è campo?
                              5: h come se fosse h per 31 più l
                              o tarapia tapioco:
                                voc come se fosse 0
                                che cos'è l? 1: voc come se fosse 1 o magari 5: voc come se fosse 1 o magari 9: voc come se fosse 1 o magari 15: voc come se fosse 1 o magari 21: voc come se fosse 1 e velocità di esecuzione
                                che cos'è voc?
                                  1:
                                    nv come se fosse nv più 1
                                    che cos'è nv? 1: v1 come se fosse l o magari 2: v2 come se fosse l o magari 3: v3 come se fosse l e velocità di esecuzione
                                  o tarapia tapioco:
                                    nc come se fosse nc più 1
                                    che cos'è nc? 1: c1 come se fosse l o magari 2: c2 come se fosse l o magari 3: c3 come se fosse l o magari 4: c4 come se fosse l e velocità di esecuzione
                                e velocità di esecuzione
                            e velocità di esecuzione
                            ripeti come se fosse ripeti meno 1
                          e brematura anche, se ripeti maggiore di 0
                      e velocità di esecuzione
                  e velocità di esecuzione
              e velocità di esecuzione
          e velocità di esecuzione
      e velocità di esecuzione
bituma [SEZIONE: chiudi campo]
      che cos'è chiudi?
        1:
          che cos'è campo?
            1:
              errCog come se fosse cattivo
              che cos'è lettere? 0: errCog come se fosse 1 e velocità di esecuzione
              k1 come se fosse 64 più brematurata la supercazzola sigla con 1, c1, c2, c3, c4, v1, v2, v3, nc, nv, 0 o scherziamo?
              k2 come se fosse 64 più brematurata la supercazzola sigla con 2, c1, c2, c3, c4, v1, v2, v3, nc, nv, 0 o scherziamo?
              k3 come se fosse 64 più brematurata la supercazzola sigla con 3, c1, c2, c3, c4, v1, v2, v3, nc, nv, 0 o scherziamo?
            o magari 2:
              errNom come se fosse cattivo
              che cos'è lettere? 0: errNom come se fosse 1 e velocità di esecuzione
              k4 come se fosse 64 più brematurata la supercazzola sigla con 1, c1, c2, c3, c4, v1, v2, v3, nc, nv, 1 o scherziamo?
              k5 come se fosse 64 più brematurata la supercazzola sigla con 2, c1, c2, c3, c4, v1, v2, v3, nc, nv, 1 o scherziamo?
              k6 come se fosse 64 più brematurata la supercazzola sigla con 3, c1, c2, c3, c4, v1, v2, v3, nc, nv, 1 o scherziamo?
            o magari 3:
              errSes come se fosse cattivo
              che cos'è nsx? 1: o tarapia tapioco: errSes come se fosse 1 e velocità di esecuzione
              sesso come se fosse sx
            o magari 4:
              errDat come se fosse cattivo
              che cos'è parte? 3: o tarapia tapioco: errDat come se fosse 1 e velocità di esecuzione
              che cos'è cg? minore di 1: errDat come se fosse 1 o magari maggiore di 2: errDat come se fosse 1 e velocità di esecuzione
              che cos'è cm? minore di 1: errDat come se fosse 1 o magari maggiore di 2: errDat come se fosse 1 e velocità di esecuzione
              che cos'è ca? 4: o tarapia tapioco: errDat come se fosse 1 e velocità di esecuzione
              che cos'è m? minore di 1: errDat come se fosse 1 o magari maggiore di 12: errDat come se fosse 1 e velocità di esecuzione
              che cos'è a? minore di 1861: errDat come se fosse 1 o magari maggiore di 2099: errDat come se fosse 1 e velocità di esecuzione
              che cos'è errDat?
                0:
                  t come se fosse brematurata la supercazzola giorniMese con m, a o scherziamo?
                  che cos'è g? minore di 1: errDat come se fosse 1 o magari maggiore di t: errDat come se fosse 1 e velocità di esecuzione
              e velocità di esecuzione
              nascG come se fosse g nascM come se fosse m nascA come se fosse a
              data come se fosse a per 10000 più m per 100 più g
            o magari 5:
              errLuo come se fosse cattivo
              che cos'è lettere? 0: errLuo come se fosse 1 e velocità di esecuzione
              hL come se fosse h
            o magari 6:
              errPro come se fosse cattivo
              che cos'è np? 0: o magari 2: o tarapia tapioco: errPro come se fosse 1 e velocità di esecuzione
              che cos'è np? 2: prov come se fosse p1 per 26 più p2 e velocità di esecuzione
          e velocità di esecuzione
      e velocità di esecuzione
      che cos'è separa? 1: campo come se fosse campo più 1 apri come se fosse 1 e velocità di esecuzione
    e brematura anche, se fineRiga minore di 1
bituma [SEZIONE: riga]
    che cos'è modo?
      0:
bituma Una riga vuota a fine input non e' una persona: si esce senza stampare.
        esci come se fosse 0
        che cos'è nRiga? 0: che cos'è fineInput? 1: esci come se fosse 1 e velocità di esecuzione e velocità di esecuzione
        che cos'è esci?
          0:
            n come se fosse 0
            che cos'è campo? minore di 5: n come se fosse 9 o magari maggiore di 6: n come se fosse 9 e velocità di esecuzione
            che cos'è n? 0: che cos'è errCog? 1: n come se fosse 1 e velocità di esecuzione e velocità di esecuzione
            che cos'è n? 0: che cos'è errNom? 1: n come se fosse 2 e velocità di esecuzione e velocità di esecuzione
            che cos'è n? 0: che cos'è errSes? 1: n come se fosse 3 e velocità di esecuzione e velocità di esecuzione
            che cos'è n? 0: che cos'è errDat? 1: n come se fosse 4 e velocità di esecuzione e velocità di esecuzione
            che cos'è n? 0: che cos'è errLuo? 1: n come se fosse 5 e velocità di esecuzione e velocità di esecuzione
            che cos'è n? 0: che cos'è errPro? 1: n come se fosse 6 e velocità di esecuzione e velocità di esecuzione
            che cos'è n?
              0:
                r come se fosse brematurata la supercazzola luogo con hL, data, prov o scherziamo?
                che cos'è r? -1: n come se fosse 5 o magari -2: n come se fosse 7 o magari -3: n come se fosse 8 e velocità di esecuzione
            e velocità di esecuzione
            che cos'è n?
              0: brematurata la supercazzola stampaCodice con k1, k2, k3, k4, k5, k6, nascA, nascM, nascG, sesso, r o scherziamo?
              o tarapia tapioco: brematurata la supercazzola errore con n, 0 o scherziamo?
            e velocità di esecuzione
        e velocità di esecuzione
        che cos'è fineInput? 1: continua come se fosse 0 e velocità di esecuzione
bituma [SEZIONE: guidata]
      o tarapia tapioco:
        esci come se fosse 0
        che cos'è nRiga? 0: che cos'è fineInput? 1: esci come se fosse 2 e velocità di esecuzione e velocità di esecuzione
        che cos'è esci?
          0:
            che cos'è nByte? 2: che cos'è primo? 58: che cos'è secondo? 113: esci come se fosse 1 o magari 81: esci come se fosse 1 e velocità di esecuzione e velocità di esecuzione e velocità di esecuzione
            che cos'è q? 1: che cos'è nByte? 0: esci come se fosse 1 e velocità di esecuzione e velocità di esecuzione
        e velocità di esecuzione
        che cos'è esci?
          2:
            brematurata la supercazzola aCapo o scherziamo?
            brematurata la supercazzola msgArrivederci o scherziamo?
            continua come se fosse 0
          o magari 1:
            brematurata la supercazzola msgArrivederci o scherziamo?
            continua come se fosse 0
          o tarapia tapioco:
            n come se fosse 0
            che cos'è q?
              1: che cos'è errCog? 1: n come se fosse 1 e velocità di esecuzione
              o magari 2: che cos'è errNom? 1: n come se fosse 2 e velocità di esecuzione
              o magari 3: che cos'è errSes? 1: n come se fosse 3 e velocità di esecuzione
              o magari 4: che cos'è errDat? 1: n come se fosse 4 e velocità di esecuzione
              o magari 5: che cos'è errLuo? 1: n come se fosse 5 e velocità di esecuzione
              o magari 6:
                che cos'è errPro? 1: n come se fosse 6 e velocità di esecuzione
                che cos'è np? 0: n come se fosse 6 e velocità di esecuzione
            e velocità di esecuzione
            che cos'è n?
              0:
                che cos'è q?
                  minore di 5: q come se fosse q più 1
                  o tarapia tapioco:
                    che cos'è q? 5: prov come se fosse 0 e velocità di esecuzione
                    r come se fosse brematurata la supercazzola luogo con hL, data, prov o scherziamo?
                    che cos'è r?
                      maggiore di 0:
                        brematurata la supercazzola msgCodice o scherziamo?
                        brematurata la supercazzola stampaCodice con k1, k2, k3, k4, k5, k6, nascA, nascM, nascG, sesso, r o scherziamo?
                        q come se fosse 1
                      o magari -2:
                        che cos'è q?
                          5: q come se fosse 6
                          o tarapia tapioco: brematurata la supercazzola errore con 7, 1 o scherziamo? q come se fosse 5
                        e velocità di esecuzione
                      o magari -1: brematurata la supercazzola errore con 5, 1 o scherziamo? q come se fosse 5
                      o tarapia tapioco: brematurata la supercazzola errore con 8, 1 o scherziamo? q come se fosse 5
                    e velocità di esecuzione
                e velocità di esecuzione
              o tarapia tapioco: brematurata la supercazzola errore con n, 1 o scherziamo?
            e velocità di esecuzione
        e velocità di esecuzione
    e velocità di esecuzione
  e brematura anche, se continua maggiore di 0
