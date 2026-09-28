#!/usr/bin/env python3
"""Test di copertura della tabella dei luoghi: ogni denominazione ufficiale, per ogni
codice e periodo, passa da ./codfisc e il risultato si confronta con l'oracolo Python.

Uso: python3 tools/verifica-luoghi.py [eseguibile]   (default ./codfisc)
Legge direttamente le fonti in dati/ (non usa src/luoghi.mc) e scrive le differenze
su stdout; termina con 1 se ce n'e' almeno una.
"""
import csv
import datetime
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from oracolo import codice_fiscale, lettere  # noqa: E402

RADICE = Path(__file__).resolve().parent.parent
DATI = RADICE / "dati"
PRIMO = datetime.date(1861, 1, 1)
ULTIMO = datetime.date(2099, 12, 31)


def iso(testo):
    return datetime.date.fromisoformat(testo)


def fonti():
    """(denominazione originale, codice, inizio, fine, sigla o '') da tutte le fonti."""
    voci = []
    with open(DATI / "ANPR_archivio_comuni.csv", encoding="utf-8", newline="") as f:
        for r in csv.DictReader(f):
            if r["CODCATASTALE"] == "ND":
                continue
            fine = min(iso(r["DATACESSAZIONE"]), ULTIMO)
            for nome in (r["DENOMINAZIONE_IT"], r["ALTRADENOMINAZIONE"]):
                if nome:
                    voci.append((nome, r["CODCATASTALE"], iso(r["DATAISTITUZIONE"]), fine, r["SIGLAPROVINCIA"]))
    sys.path.insert(0, str(RADICE / "tools"))
    import importlib.util
    spec = importlib.util.spec_from_file_location("imp", RADICE / "tools" / "importa-luoghi.py")
    imp = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(imp)
    righe = imp.leggi_xlsx(DATI / "tabella_2_statiesteri.xlsx")
    h = righe[0]
    for r in righe[1:]:
        r = r + [""] * (len(h) - len(r))
        if r[h.index("CODAT")].strip():
            voci.append((r[h.index("DENOMINAZIONE")], r[h.index("CODAT")].strip(), PRIMO, ULTIMO, "EE"))
    cessati = DATI / "stati-cessati.csv"
    if cessati.exists():
        with open(cessati, encoding="utf-8", newline="") as f:
            for r in csv.DictReader(f, delimiter=";"):
                voci.append((r["denominazione"], r["codice"], iso(r["inizio"]), min(iso(r["fine"]), ULTIMO), "EE"))
    return voci


def atteso(candidati, data, sigla):
    """Regola della spec: un solo codice -> quello; altrimenti filtro per data e sigla."""
    codici = {c for c, _, _, _ in candidati}
    if len(codici) == 1:
        return next(iter(codici))
    sigle = defaultdict(set)
    for c, _, _, s in candidati:
        sigle[c].add(s)
    validi = {c for c, inizio, fine, _ in candidati if inizio <= data <= fine and (not sigla or sigla in sigle[c])}
    in_data = any(inizio <= data <= fine for _, inizio, fine, _ in candidati)
    if len(validi) == 1:
        return next(iter(validi))
    if len(validi) > 1:
        return "ERRORE: luogo ambiguo, indicare la provincia"
    return "ERRORE: luogo sconosciuto" if in_data else "ERRORE: luogo non valido alla data di nascita"


def main():
    eseguibile = sys.argv[1] if len(sys.argv) > 1 else str(RADICE / "codfisc")
    per_nome = defaultdict(list)
    originali = {}
    for nome, codice, inizio, fine, sigla in fonti():
        chiave = "".join(lettere(nome))
        per_nome[chiave].append((codice, inizio, fine, sigla))
        originali.setdefault(chiave, set()).add(nome)

    righe, attesi = [], []
    for chiave, candidati in per_nome.items():
        prove = set()
        for _, inizio, fine, sigla in candidati:
            inizio, fine = max(inizio, PRIMO), min(fine, ULTIMO)
            if inizio > fine:
                continue
            data = inizio + (fine - inizio) // 2
            prove.add((data, ""))
            if sigla:
                prove.add((data, sigla))
        for nome in sorted(originali[chiave]):
            for data, sigla in sorted(prove):
                esito = atteso(candidati, data, sigla)
                if not esito.startswith("ERRORE"):
                    esito = codice_fiscale("Rossi", "Mario", "M", data.day, data.month, data.year, esito)
                luogo = f"{nome};{sigla}" if sigla else nome
                righe.append(f"Rossi;Mario;M;{data.day:02d}/{data.month:02d}/{data.year};{luogo}")
                attesi.append(esito)

    uscita = subprocess.run([eseguibile], input="\n".join(righe) + "\n", capture_output=True,
                            text=True, encoding="utf-8").stdout.splitlines()
    differenze = [(r, a, u) for r, a, u in zip(righe, attesi, uscita) if a != u]
    if len(uscita) != len(righe):
        differenze.append(("(numero di righe)", str(len(righe)), str(len(uscita))))
    for r, a, u in differenze[:50]:
        print(f"{r}\n  atteso: {a}\n  avuto:  {u}")
    print(f"{len(righe)} righe verificate, {len(differenze)} differenze")
    sys.exit(1 if differenze else 0)


if __name__ == "__main__":
    main()
