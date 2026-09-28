"""Implementazione di riferimento del codice fiscale (DM 23/12/1976), solo per i test.

Indipendente da codfisc.mc: serve come oracolo in tools/verifica-luoghi.py.
"""
import unicodedata

VOCALI = "AEIOU"
MESI = "ABCDEHLMPRST"
DISPARI = [1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 2, 4, 18, 20, 11, 3, 6, 8, 12, 14, 16, 10, 22, 25, 24, 23]


def lettere(testo):
    testo = unicodedata.normalize("NFKD", testo.replace("ß", "SS"))
    testo = "".join(c for c in testo if not unicodedata.combining(c)).upper()
    return [c for c in testo if "A" <= c <= "Z"]


def tre(testo, nome):
    l = lettere(testo)
    consonanti = [c for c in l if c not in VOCALI]
    vocali = [c for c in l if c in VOCALI]
    if nome and len(consonanti) >= 4:
        return consonanti[0] + consonanti[2] + consonanti[3]
    return "".join((consonanti + vocali + ["X"] * 3)[:3])


def controllo(quindici):
    somma = 0
    for i, c in enumerate(quindici):
        v = int(c) if c.isdigit() else ord(c) - 65
        somma += DISPARI[v] if i % 2 == 0 else v
    return chr(65 + somma % 26)


def codice_fiscale(cognome, nome, sesso, giorno, mese, anno, catastale):
    g = giorno + (40 if sesso.upper() == "F" else 0)
    base = f"{tre(cognome, False)}{tre(nome, True)}{anno % 100:02d}{MESI[mese - 1]}{g:02d}{catastale}"
    return base + controllo(base)
