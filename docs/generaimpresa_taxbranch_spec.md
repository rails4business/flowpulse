# GeneraImpresa / Rails4B Linking for Taxbranch

## Obiettivo
Ogni percorso (taxbranch) deve avere due facce distinte:
1. **Rails4B / Officina** – progettazione interna, gestione commitment, costi e timeline.
2. **GeneraImpresa** – area pubblica per raccolta fondi, sponsor, ruoli da finanziare e ritorni.

A oggi abbiamo solo i campi `rails4b_mode` + target (domain/service/journey). Servono spec simmetriche per GeneraImpresa.

## Migrazioni previste
- `add_column :taxbranches, :generaimpresa_mode, :boolean, default: false, null: false`
- `add_column :taxbranches, :generaimpresa_target_domain_id, :integer`
  - Index + FK verso `domains.id`
- `add_column :taxbranches, :generaimpresa_target_service_id, :integer`
  - Index + FK verso `services.id`
- `add_column :taxbranches, :generaimpresa_target_journey_id, :integer`
  - Index + FK verso `journeys.id`
- Campi per tracking economico del branch GeneraImpresa:
  - `:funding_goal_euro` (decimal)
  - `:funding_raised_euro` (decimal)
  - `:sponsor_packages` (jsonb) per salvare tiers / reward

## Modello `Taxbranch`
- belongs_to opzionali per i nuovi target (come già per Rails4B)
- Scope helper: `rails4b_nodes`, `generaimpresa_nodes`
- Validazioni: se `generaimpresa_mode` true → deve avere almeno un target (service/journey o domain) per sapere cosa finanzia.
- Metodi utili:
  - `#funding_gap_euro = funding_goal_euro - funding_raised_euro`
  - `#has_funding_gap?`
  - `#mirror_branch` per recuperare il branch gemello (Rails4B ↔ GeneraImpresa) se esiste.

## Form `superadmin/taxbranches/_form`
- Blocchi separati:
  - “Rails4B / Officina” (già fatto)
  - **Nuovo** “GeneraImpresa / Funding” con:
    - Checkbox `generaimpresa_mode`
    - Select per domain/service/journey target
    - Input per goal/raised
    - Textarea `sponsor_packages` (JSON editor semplice)
- Tooltip che spiega: “se attivo, questo ramo è visibile come campagna di funding per portare fuori il progetto sviluppato su Rails4B”.

## Controller `superadmin/taxbranches_controller`
- Strong params includono i nuovi campi.
- Quando salvi, se attivi GeneraImpresa ma non hai definito target, mostra errore.

## Dashboard
- **Domain GeneraImpresa**: aggiungi sezione “Funding” che aggrega i `funding_goal/raised` dei branch generaimpresa nel sottoalbero e calcola break-even.
- **Service / Journey show**: se associati a un branch generaimpresa, mostra badge che linka alla campagna.
- **Nuove pagine** `superadmin/taxbranches#rails4b` e `#generaimpresa`:
  - Rails4B: già pronta? (in taxbranch show c'è solo “post”). Valutare una view dedicata come per services/journey.
  - GeneraImpresa: mostra stato raccolta fondi, sponsor packages e CTA per creare enrollment speciali.

## Business Logic
- Commitment = costo officina.
- Funding (GeneraImpresa) = capitale da raccogliere per coprire commitment e aprire il servizio.
- Workflow:
  1. Crei branch Rails4B → costruisci progetto.
  2. Attivi branch GeneraImpresa gemello → definisci target service/journey + goal.
  3. Quando `funding_raised_euro` >= `funding_goal_euro`, branch può “graduare” a pubblico: aggiornare `visibility` su taxbranch/service/journey.

## TODO Futuro
- Automazioni per aggiornare `funding_raised_euro` quando arrivano pagamenti da sponsor.
- Grafici di andamento funding nel tempo.
- Notifiche per investitori quando il progetto passa da officina a pubblico.
