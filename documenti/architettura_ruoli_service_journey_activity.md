# Architettura Operativa: Ruoli, Service, Journey, Eventdate, Commitment, Activity

## Scopo
Questo documento riassume il ragionamento architetturale per costruire un flusso operativo semplice e scalabile per Igiene Posturale, con particolare attenzione a:

- ruoli
- mappa operativa
- esecuzione reale degli step
- autonomia vs supporto professionista

Non e una specifica tecnica finale: e una base di allineamento prima della programmazione.

## Problema centrale
Uno stesso step (es. questionario iniziale) puo essere svolto:

- in autonomia dall'utente
- con supporto tutor/professionista

Serve quindi un modello che non duplichi la logica e che distingua bene:

- cosa e previsto
- cosa e stato realmente fatto
- da chi

## Principio guida
`commitment = previsto`  
`activity = eseguito`

Questo evita confusione e permette tracciamento chiaro anche con piu attori.

## Ruolo del Taxbranch
Il taxbranch resta il riferimento canonico dello step (classificazione), ma non basta da solo a rappresentare la mappa operativa.

- Taxbranch: tassonomia/albero (struttura logica)
- Service + Journey: mappa dei flussi (grafo operativo)

Nota: nel modello attuale il legame taxbranch/service tende a essere univoco, quindi conviene usare i journey per modellare percorsi e varianti.

## Schema concettuale consigliato
1. **Taxbranch** (definizione step)
   - `allowed_actor_roles` (es. utente, tutor, insegnante)
   - `execution_mode` (`self`, `assisted`, `both`)
   - opzionale `requires_eventdate`

2. **Commitment** (piano operativo dentro un evento)
   - `role_name` atteso (chi dovrebbe fare cosa)
   - `taxbranch_id` dello step collegato

3. **Activity** (azione realmente svolta)
   - `taxbranch_id`
   - `actor_role` (chi l'ha fatta davvero)
   - `actor_ref`
   - `source` (`self_service` o `eventdate_commitment`)
   - `status`, `payload`

## Caso pratico: Questionario iniziale
### A) Compilato in autonomia
- nessun eventdate
- 1 activity:
  - `actor_role: utente`
  - `source: self_service`

### B) Compilato con tutor (colloquio)
- crea eventdate
- crea 2 commitment (`tutor`, `utente`)
- activity finali:
  - almeno 1 activity di completamento questionario (actor effettivo)
  - opzionale activity supporto tutor

## Flusso macro del percorso
`Service -> Journey -> Eventdate -> Commitment -> Activity`

Il taxbranch non sostituisce activity: la classifica.

## Step multi-modalita (autonomia / assistito)
Non duplicare il taxbranch.

- stesso taxbranch (es. "Questionario iniziale")
- modalita indicata a runtime su activity/eventdate-commitment:
  - `self`
  - `assisted_tutor`
  - `assisted_professional`

Regola:
- `mode=self` -> solo activity
- `mode=assisted_*` -> eventdate + commitments + activity

## Service con checklist di taxbranch (idea valida)
Un service puo contenere una checklist di taxbranch collegati (flaggabili), con metadati per link:

- `required` (true/false)
- `allowed_modes` (`self`, `assisted`)
- `allowed_roles` (`utente`, `tutor`, `insegnante`)
- `order`

Vantaggi:
- niente duplicazioni
- riuso degli step
- flessibilita operativa
- UX leggibile

## Ruoli dominio
Distinzione da mantenere:

- `domain.operative_roles`: catalogo ruoli disponibili
- `domain_membership + certificates.role_name`: ruoli realmente assegnati alla persona nel dominio

## Decisione pratica per partire
Partire con mappa semplice "Valutazione iniziale" e mantenere questo assetto:

- step reali a calendario: `eventdate`
- piano sessione: `commitment`
- tracciamento esecuzione: `activity`
- classificazione step: `taxbranch`

Con questa base si puo crescere senza rifare il modello.

## Decisione campi su Taxbranch (aggiornamento)
Per evitare ambiguita, i campi ruolo vengono esplicitati su `taxbranches`:

- `performed_by_roles` (jsonb array)
- `target_roles` (jsonb array)
- `execution_mode` (string: `self`, `assisted`, `both`)

### Perche su Taxbranch
- il taxbranch rappresenta lo step canonico
- le regole rimangono coerenti anche se lo step e riusato in piu servizi
- i service possono fare override solo quando serve (eccezioni di contesto)

### Interpretazione operativa
- `performed_by_roles`: chi puo eseguire lo step
- `target_roles`: su chi/ per chi e pensato lo step
- `execution_mode`:
  - `self` = in autonomia
  - `assisted` = con operatore
  - `both` = entrambi possibili

### Esempi
- Questionario iniziale:
  - `performed_by_roles`: `utente`, `tutor`, `insegnante`
  - `target_roles`: `utente`
  - `execution_mode`: `both`
- Appuntamento coordinativo:
  - `performed_by_roles`: `coordinatore_operativo`
  - `target_roles`: `utente`, `insegnante`
  - `execution_mode`: `assisted`
