---
title: Phase Taxbranch
parent: Versione 3 10 ottobre 2025
grand_parent: Sviluppo
nav_order: 11
---

# Fasi progetto (Taxbranch)

Scopo: definire lo stato ufficiale di un progetto/ramo e usare la fase
per governare visibilita, pagine pubbliche e servizi acquistabili.

## Enum fase

```
previsione -> progettazione -> realizzazione -> test -> attivo -> chiuso
```

La fase ufficiale e salvata su `Taxbranch.phase`.

## Differenza Taxbranch vs Journey

- **Taxbranch.phase** = stato complessivo del progetto (fonte unica).
- **Journey.phase** = stato operativo del singolo percorso/ciclo.

La UI pubblica deve seguire **Taxbranch.phase**.

## Pagina pubblica per fase

Se un capitolo/child non e in `attivo`, la pagina pubblica mostra
una view “coming soon” con:
- fase corrente
- note/avanzamento (es. `taxbranch.notes` o campo dedicato)

Solo in fase `attivo` si mostra il contenuto completo.

## Servizi e fase

I servizi restano visibili ma sono **enrollabili** solo se la fase del
taxbranch e compresa nel range:
- `enrollable_from_phase`
- `enrollable_until_phase`

## Link tra progetti (link_child_taxbranch_id)

Usare `link_child_taxbranch_id` per collegare fasi o progetti correlati
es.:
- GeneraImpresa (strategia/finanza) -> Rails4B (prototipo/prodotto)
- Rails4B -> Frontline (erogazione)

La fase principale rimane sul taxbranch “radice”; i link servono solo a
navigare tra rami correlati.

## Note aperte

- decidere dove salvare l’avanzamento testuale (notes vs campo dedicato).
- decidere se creare una pagina “phase” dedicata per il report di stato.
