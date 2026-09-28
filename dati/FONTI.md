# Fonti della tabella dei luoghi

`src/luoghi.mc` è generato da `tools/importa-luoghi.py` a partire da questi file.
Per aggiornarli: `make luoghi` (riscarica i file ANPR e rigenera), poi `make codfisc`,
`make test` e `make verifica-luoghi`.

| File | Fonte | Scaricato |
|---|---|---|
| `ANPR_archivio_comuni.csv` | ANPR, archivio storico dei comuni: https://www.anagrafenazionale.interno.it/area-tecnica/archivio-storico-dei-comuni/ (file https://www.anagrafenazionale.interno.it/wp-content/uploads/ANPR_archivio_comuni.csv) | 2026-09-28 |
| `tabella_2_statiesteri.xlsx` | ANPR, tabelle di decodifica, tabella 2 «Stati esteri»: https://www.anagrafenazionale.interno.it/area-tecnica/tabelle-di-decodifica/ (file https://www.anagrafenazionale.interno.it/wp-content/uploads/tabella_2_statiesteri.xlsx) | 2026-09-28 |
| `stati-cessati.csv` | Curato a mano dalla consultazione dell'Agenzia delle Entrate, «Ricerca Stati Esteri», continente Europa, stati marcati «Soppresso»: https://arcom.agenziaentrate.gov.it/CitizenArCom/ (il sito ha un captcha e nessun download in blocco) | 2026-09-28 |

Note:
- dei comuni si usano `DENOMINAZIONE_IT` e `ALTRADENOMINAZIONE` (nomi bilingui), con periodi
  e sigle di provincia di ogni riga; le righe con codice `ND` sono scartate;
- degli stati si usano le righe con `CODAT` valorizzato (anche `NASCITA=N`) e la sola colonna
  `DENOMINAZIONE`; agli stati si assegna la sigla `EE`.
- `stati-cessati.csv`: l'archivio dell'Agenzia delle Entrate non pubblica le date di soppressione.
  Sono inclusi solo gli stati soppressi il cui nome non coincide con quello di uno stato attuale,
  quindi il periodo (1861-03-17 … 9999-12-31) non conta. Esclusi gli 8 ex stati sovietici con
  codice europeo soppresso (Armenia Z137, Azerbaigian Z141, Georgia Z136, Kazakhstan Z152,
  Kirghizistan Z142, Tagikistan Z147, Turkmenistan Z151, Uzbekistan Z143): con lo stesso nome
  esiste il codice asiatico attuale (Z252–Z259) e senza date non si possono distinguere.
  Altri continenti non ancora consultati.
