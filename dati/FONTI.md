# Fonti della tabella dei luoghi

`src/luoghi.mc` è generato da `tools/importa-luoghi.py` a partire da questi file.
Per aggiornarli: `make luoghi` (riscarica i file ANPR e rigenera), poi `make codfisc`,
`make test` e `make verifica-luoghi`.

| File | Fonte | Scaricato |
|---|---|---|
| `ANPR_archivio_comuni.csv` | ANPR, archivio storico dei comuni: https://www.anagrafenazionale.interno.it/area-tecnica/archivio-storico-dei-comuni/ (file https://www.anagrafenazionale.interno.it/wp-content/uploads/ANPR_archivio_comuni.csv) | 2026-09-28 |
| `tabella_2_statiesteri.xlsx` | ANPR, tabelle di decodifica, tabella 2 «Stati esteri»: https://www.anagrafenazionale.interno.it/area-tecnica/tabelle-di-decodifica/ (file https://www.anagrafenazionale.interno.it/wp-content/uploads/tabella_2_statiesteri.xlsx) | 2026-09-28 |

Note:
- dei comuni si usano `DENOMINAZIONE_IT` e `ALTRADENOMINAZIONE` (nomi bilingui), con periodi
  e sigle di provincia di ogni riga; le righe con codice `ND` sono scartate;
- degli stati si usano le righe con `CODAT` valorizzato (anche `NASCITA=N`) e la sola colonna
  `DENOMINAZIONE`; agli stati si assegna la sigla `EE`.
