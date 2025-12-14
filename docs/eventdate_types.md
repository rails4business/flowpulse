# Eventdate: Todo vs Done

Gli `Eventdate` vengono usati sia come TODO pianificati, sia come log degli esercizi/booking completati. I campi da considerare:

| Campo                  | Significato                                           |
|------------------------|-------------------------------------------------------|
| `event_type`           | Macro‐categoria (`todo`, `event`, `done`, ecc.)        |
| `status`               | Stato del diario (solo per i TODO, es. `pending`)     |
| `kind_event`           | Tipo specifico di evento reale (`session`, `meeting`) |

## Todo
- `event_type: :todo`
- `status`: indica l’avanzamento (`pending`, `tracking`, `completed`)
- Quando segni un TODO come fatto, cambia `status` → `completed` ma resta `event_type: :todo` (serve per l’agenda).

## Done (log esecuzioni)
- Un nuovo Eventdate creato dal bottone “Fatto” su una scheda:
  - `event_type: :done`
  - `kind_event`: `:session`, `:online_call`, ecc. (descrive che tipo di lavoro hai fatto)
  - Facoltativamente collega `parent_eventdate_id` al TODO originale.

Questo approccio permette di filtrare:
- “TODO da fare” → `event_type: :todo` e `status != :completed`
- “Esecuzioni concluse” → `event_type: :done` (indipendente dal diario)
