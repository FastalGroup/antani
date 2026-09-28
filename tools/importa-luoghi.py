#!/usr/bin/env python3
"""Genera src/luoghi.mc (solo dati) dalle fonti ufficiali in dati/.

Uso: python3 tools/importa-luoghi.py [radice-del-repo]
Solo libreria standard. Il file generato contiene la sola funzione Monicelli
`luogo(h, data, prov)`; tutta la logica del codice fiscale resta scritta a mano
in src/codfisc.mc.

mcc non compila sorgenti oltre 1 MiB (bug del buffer del lexer): per questo i
nomi con un solo codice stanno su una riga, senza controllo di lunghezza ne' di
provincia, e il file non deve superare LIMITE byte.
"""
import csv
import re
import sys
import unicodedata
import xml.etree.ElementTree as ET
import zipfile
from collections import defaultdict
from pathlib import Path

MOLTIPLICATORE = 31
INIZIO_SEMPRE = 18610317
FINE_MAI = 99991231
LIMITE = 768 * 1024
ESTERO = "EE"
NS = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"


def normalizza(testo):
    """Maiuscolo, senza diacritici, ß -> SS, solo A-Z (come codfisc.mc)."""
    testo = testo.replace("ß", "SS").replace("ẞ", "SS")
    testo = unicodedata.normalize("NFKD", testo)
    testo = "".join(c for c in testo if not unicodedata.combining(c)).upper()
    return re.sub("[^A-Z]", "", testo)


def hash32(nome):
    """h = h*31 + lettera (A=1..Z=26) in aritmetica i32 con overflow."""
    h = 0
    for c in nome:
        h = (h * MOLTIPLICATORE + ord(c) - 64) & 0xFFFFFFFF
    return h - (1 << 32) if h >= (1 << 31) else h


def provincia(sigla):
    """Sigla di 2 lettere -> l1*26 + l2 (A=1..Z=26), come codfisc.mc."""
    return (ord(sigla[0]) - 64) * 26 + (ord(sigla[1]) - 64)


def impacchetta(codice):
    """'H501' -> 8501: lettera (A=1..Z=26) * 1000 + numero."""
    if not re.fullmatch(r"[A-Z]\d{3}", codice):
        raise ValueError(f"codice catastale non valido: {codice!r}")
    return (ord(codice[0]) - 64) * 1000 + int(codice[1:])


def data_iso(testo):
    """'1861-03-17' -> 18610317."""
    return int(testo.replace("-", ""))


def leggi_xlsx(percorso):
    """Righe del primo foglio come liste di stringhe (solo libreria standard)."""
    with zipfile.ZipFile(percorso) as z:
        condivise = []
        if "xl/sharedStrings.xml" in z.namelist():
            for si in ET.fromstring(z.read("xl/sharedStrings.xml")).iter(NS + "si"):
                condivise.append("".join(t.text or "" for t in si.iter(NS + "t")))
        foglio = ET.fromstring(z.read("xl/worksheets/sheet1.xml"))
    righe = []
    for riga in foglio.iter(NS + "row"):
        celle = {}
        for c in riga.iter(NS + "c"):
            indice = 0
            for lettera in re.match(r"[A-Z]+", c.get("r")).group():
                indice = indice * 26 + ord(lettera) - 64
            v = c.find(NS + "v")
            if c.get("t") == "s":
                valore = condivise[int(v.text)]
            elif c.get("t") == "inlineStr":
                valore = "".join(t.text or "" for t in c.iter(NS + "t"))
            else:
                valore = v.text if v is not None and v.text else ""
            celle[indice - 1] = valore
        if celle:
            righe.append([celle.get(i, "") for i in range(max(celle) + 1)])
    return righe


def carica(dati):
    """nome normalizzato -> codice -> {'periodi': set di (inizio, fine), 'province': set}."""
    luoghi = defaultdict(lambda: defaultdict(lambda: {"periodi": set(), "province": set()}))

    with open(dati / "ANPR_archivio_comuni.csv", encoding="utf-8", newline="") as f:
        for r in csv.DictReader(f):
            codice = r["CODCATASTALE"]
            if codice == "ND":
                continue
            periodo = (data_iso(r["DATAISTITUZIONE"]), data_iso(r["DATACESSAZIONE"]))
            for denominazione in (r["DENOMINAZIONE_IT"], r["ALTRADENOMINAZIONE"]):
                nome = normalizza(denominazione)
                if nome:
                    voce = luoghi[nome][codice]
                    voce["periodi"].add(periodo)
                    voce["province"].add(provincia(r["SIGLAPROVINCIA"]))

    righe = leggi_xlsx(dati / "tabella_2_statiesteri.xlsx")
    intestazione = righe[0]
    col_codice = intestazione.index("CODAT")
    col_nome = intestazione.index("DENOMINAZIONE")
    for r in righe[1:]:
        r = r + [""] * (len(intestazione) - len(r))
        codice = r[col_codice].strip()
        if not codice:
            continue
        nome = normalizza(r[col_nome])
        if nome:
            voce = luoghi[nome][codice]
            voce["periodi"].add((INIZIO_SEMPRE, FINE_MAI))
            voce["province"].add(provincia(ESTERO))

    cessati = dati / "stati-cessati.csv"
    if cessati.exists():
        with open(cessati, encoding="utf-8", newline="") as f:
            for r in csv.DictReader(f, delimiter=";"):
                nome = normalizza(r["denominazione"])
                periodo = (data_iso(r["inizio"]), data_iso(r["fine"]))
                voce = luoghi[nome][r["codice"]]
                voce["periodi"].add(periodo)
                voce["province"].add(provincia(ESTERO))
    return luoghi


def controlla_collisioni(luoghi):
    visti = {}
    for nome in luoghi:
        h = hash32(nome)
        if h in visti:
            raise SystemExit(f"collisione di hash: {visti[h]} e {nome} ({h})")
        visti[h] = nome


def caso_multiplo(codici):
    """Corpo del caso per un nome con piu' codici: conta i candidati validi."""
    i = "      "
    righe = [f"{i}conta come se fosse 0", f"{i}inData come se fosse 0"]
    for codice, voce in sorted(codici.items()):
        righe.append(f"{i}ok come se fosse 0")
        for inizio, fine in sorted(voce["periodi"]):
            righe.append(f"{i}che cos'è data? maggiore uguale a {inizio}: che cos'è data? "
                         f"minore uguale a {fine}: ok come se fosse 1 "
                         f"e velocità di esecuzione e velocità di esecuzione")
        righe.append(f"{i}che cos'è ok? 1: inData come se fosse 1 e velocità di esecuzione")
        casi = " ".join(f"o magari {p}:" for p in sorted(voce["province"]))
        righe.append(f"{i}che cos'è prov? 0: {casi} "
                     f"o tarapia tapioco: ok come se fosse 0 e velocità di esecuzione")
        righe.append(f"{i}che cos'è ok? 1: conta come se fosse conta più 1 "
                     f"r come se fosse {impacchetta(codice)} e velocità di esecuzione")
    righe.append(f"{i}che cos'è conta?")
    righe.append(f"{i}  0: che cos'è inData? 0: r come se fosse -3 "
                 f"o tarapia tapioco: r come se fosse -1 e velocità di esecuzione")
    righe.append(f"{i}  o magari maggiore di 1: r come se fosse -2")
    righe.append(f"{i}e velocità di esecuzione")
    return righe


def genera(luoghi):
    righe = [
        "bituma luoghi.mc - FILE GENERATO da tools/importa-luoghi.py: non modificare a mano.",
        "bituma Fonti in dati/ (vedi dati/FONTI.md). Una riga per nome con un solo codice catastale.",
        "bituma luogo(h, data, prov): h hash del nome normalizzato, data AAAAMMGG, prov l1*26+l2 oppure 0.",
        "bituma Restituisce lettera*1000+numero del codice, -1 sconosciuto, -2 ambiguo, -3 non valido alla data.",
        "blinda la supercazzola Necchi luogo con h Necchi, data Necchi, prov Necchi o scherziamo?",
        "  voglio r, Necchi come se fosse -1",
        "  voglio conta, Necchi come se fosse 0",
        "  voglio inData, Necchi come se fosse 0",
        "  voglio ok, Necchi come se fosse 0",
        "  che cos'è h?",
    ]
    for n, nome in enumerate(sorted(luoghi, key=hash32)):
        etichetta = f"    {'' if n == 0 else 'o magari '}{hash32(nome)}:"
        codici = luoghi[nome]
        if len(codici) == 1:
            righe.append(f"{etichetta} r come se fosse {impacchetta(next(iter(codici)))}")
        else:
            righe.append(etichetta)
            righe.append(f"bituma {nome}")
            righe.extend(caso_multiplo(codici))
    righe += ["  e velocità di esecuzione", "  vaffanzum r!", ""]
    return "\n".join(righe)


def main():
    radice = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
    luoghi = carica(radice / "dati")
    controlla_collisioni(luoghi)
    testo = genera(luoghi)
    dimensione = len(testo.encode())
    if dimensione > LIMITE:
        raise SystemExit(f"luoghi.mc di {dimensione} byte supera {LIMITE}: mcc non compila oltre 1 MiB")
    (radice / "src" / "luoghi.mc").write_text(testo, encoding="utf-8")
    multipli = sum(1 for c in luoghi.values() if len(c) > 1)
    print(f"luoghi.mc: {len(luoghi)} nomi, {multipli} con piu' codici, {dimensione} byte")


if __name__ == "__main__":
    main()
