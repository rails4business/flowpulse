# Taxbranch Modes & Targets

### Obiettivo
Rendere ogni `taxbranch` esplicito rispetto al ruolo che ricopre nel ciclo di vita di un servizio:

1. `frontline` (pubblico): contenuti e percorsi accessibili agli utenti finali.
2. `rails4b` (officina): prototipazione interna, gestione commitment e costi.
3. `generaimpresa` (funding/governance): campagne per raccogliere fondi e validare la sostenibilità.

### Migrazione prevista
- Sostituire `rails4b_mode` con una enum `taxbranch_mode` (intero, default frontline).
- Introdurre le foreign key opzionali per collegare branch rails4b/generaimpresa al relativo Domain/Service/Journey:
  - `rails4b_target_domain_id`, `rails4b_target_service_id`, `rails4b_target_journey_id`
  - `generaimpresa_target_domain_id`, `generaimpresa_target_service_id`, `generaimpresa_target_journey_id`

### Modello
```rb
enum taxbranch_mode: { frontline: 0, rails4b: 1, generaimpresa: 2 }

belongs_to :rails4b_target_domain,    class_name: "Domain",  optional: true
belongs_to :rails4b_target_service,   class_name: "Service", optional: true
belongs_to :rails4b_target_journey,   class_name: "Journey", optional: true
belongs_to :generaimpresa_target_domain,  class_name: "Domain",  optional: true
...
```

Helper utili:
- `def rails4b_partner` e `def generaimpresa_partner` per trovare il branch gemello con stessi target.
- `def funding_gap_euro` quando il branch è `generaimpresa`.

### Form e controller
- Nel form superadmin mostrare blocchi condizionati in base alla `taxbranch_mode`.
  - Se `rails4b`: select per target service/journey, eventuali note sui costi.
  - Se `generaimpresa`: select target + campi per funding goal/raised.
- Aggiornare strong params.

### Dashboard
- Domain/Service/Journey view devono leggere i branch associati per mostrare informazioni operative (officina) e finanziarie (GeneraImpresa).
- Eventuali future automation (pagamenti sponsor → funding_raised).

### Decisione
Restiamo sulle foreign key esplicite (niente polimorfico) per mantenere chiara la semantica e sfruttare i vincoli FK. Se un giorno servisse più flessibilità, si potrà introdurre una tabella di link generici.
