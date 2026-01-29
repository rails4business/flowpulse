# Rails4b (Taxbranch) - Design Notes

## Obiettivo
Portare la pagina Rails4b del **Taxbranch** allo stesso livello concettuale della pagina Rails4b dei **Services**, ma basata sui journeys del taxbranch e con una vista più ricca (partono/arrivano).

## Scopo della pagina
Percorsi (journeys) legati al taxbranch:
- quelli che **partono** dal taxbranch
- quelli che **arrivano** al taxbranch
- con distinzione per tipo di collegamento tra taxbranch e service

## Filtri principali
Direzione:
- `partono` → `taxbranch_id = @taxbranch.id`
- `arrivano` → `end_taxbranch_id = @taxbranch.id`
- `tutti` → OR dei due

## Categorie (sezioni) da mostrare
1) **Service ↔ Service (railservice)**
   - taxbranch di partenza ha service
   - taxbranch di arrivo ha service
   - identificabile con `journey.railservice?`

2) **Service → Taxbranch (prodotto)**
   - taxbranch di partenza ha service
   - taxbranch di arrivo **senza** service
   - identificabile con `journey.journey_function?`

3) **Taxbranch ↔ Taxbranch (puro)**
   - né start né end hanno service
   - incluso ma **taggato** come "Taxbranch ↔ Taxbranch"

## Include / Exclude
- I journeys con `service_id` **non sono esclusi**: vengono **inclusi e taggati**
- Vengono mostrati sia `@taxbranch.journeys` (partono) sia `@taxbranch.incoming_journeys` (arrivano)

## UI prevista (per la tab Rails4b in GeneraImpresa taxbranch)
- Filtri a pill: `Tutti` / `Partono` / `Arrivano`
- Tre sezioni con conteggi e liste
- Ogni journey mostra:
  - Nome o ID
  - Tag tipo: "Service↔Service", "Service→Taxbranch", "Taxbranch↔Taxbranch"
  - Tag direzione: "Partono" / "Arrivano"
  - Tag `service_id` se presente
  - Link a `superadmin_journey_path(journey)`

## Prossimi step (implementazione)
- Preparare dataset combinato in controller:
  - base scope: partono/arrivano/tutti
  - calcolo tag tipo (railservice / function / pure)
  - indicare direzione
- Aggiornare view `superadmin/taxbranches/rails4b.html.erb`
  - sezione filtri
  - 3 liste separate

