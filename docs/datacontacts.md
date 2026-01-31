# Datacontacts & Mycontacts

## Scopo
I `Datacontacts` rappresentano i **dati reali di contatto** (anagrafica/fiscale) che appartengono a un Lead.  
I `Mycontacts` gestiscono **il permesso di accesso** ai contatti: all’inizio il contatto può appartenere a chi lo inserisce (professionista), poi può essere trasferito al Lead quando questo viene creato/riconosciuto.

## Modello e campi principali
Tabella: `datacontacts`
- `lead_id`: riferimento al lead proprietario
- `first_name`, `last_name`, `email`, `phone`
- `date_of_birth`, `place_of_birth`
- `fiscal_code`, `vat_number`
- `billing_name`, `billing_address`, `billing_city`, `billing_zip`, `billing_country`

Nota: i campi possono essere estesi in base a esigenze di fatturazione o segmentazione.

## Relazioni
- `Datacontact` -> `Lead` (owner reale del contatto)
- `Mycontact` -> permesso di accesso/gestione del contatto
- Al momento **non esiste** una relazione diretta con `Commitment`

## Scelta consigliata (single source)
1) **Datacontact = dati reali (unica fonte)**  
2) **Mycontact = accesso + ownership (chi può vedere/modificare)**  

Vantaggi:
- niente duplicazioni
- meno rischio di incoerenze
- gestione privacy più semplice

## Ownership & permessi (flusso reale)
1. **Inserimento iniziale**: il professionista crea un contatto → i dati appartengono a lui (ownership), e sono accessibili solo tramite `Mycontact`.
2. **Fase di lead**: quando si genera/riconosce il Lead corretto, l’ownership del contatto viene trasferita al Lead (responsabilità).
3. **Sicurezza/Privacy**: prima del trasferimento i dati possono essere **criptati** o non esportabili, per evitare “circolazione” involontaria.

## Implicazioni tecniche
- Se il contatto non è ancora assegnato al Lead, l’accesso passa solo dal `Mycontact`.
- Serve gestire con attenzione **criptazione** e **trasferimento** (per evitare perdita o duplicazione).

## Flusso tipico
1. Creazione/aggiornamento del contatto dalla sezione admin o da flussi lead.
2. Il contatto rimane “del professionista” finché non viene confermato il lead corretto.
3. Trasferimento dell’ownership al Lead (eventuale decrittazione/merge).
4. Uso del contatto in fase di prenotazioni/servizi/eventi se necessario.

## UX/Interfacce
- Ricerca per nome/email
- Form con dati anagrafici e fiscali
- Collegamento a `Lead`

## Estensioni possibili
- Collegare `Commitment` a **`mycontact_id`** (non `datacontact_id`) se serve associare un impegno a un contatto specifico, rispettando i permessi.
- Eventuale collegamento `Eventdate`/`Booking` → `mycontact_id` per storicizzare la partecipazione senza esporre direttamente il contatto reale.

## Note operative
- Se si decide di collegare i `Commitments` ai contatti, serve:
  - migration con `mycontact_id`
  - associazioni `belongs_to`/`has_many`
  - aggiornamento dei form e filtri.
