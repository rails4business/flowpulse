---
title: Pricing Taxbranch
parent: Versione 3 10 ottobre 2025
grand_parent: Sviluppo
nav_order: 10
---

# Pricing per Taxbranch

Obiettivo: spostare le card Service (name/description/prezzo) in una pagina
dedicata alle tariffe del taxbranch.

## Proposta

- Nuova pagina: `posts/:id/pricing`
- La pagina mostra le card dei Service collegati al taxbranch.
- I Service restano gestiti dal superadmin, ma l'esposizione pubblica
  passa per la pagina pricing.

## Uso nel flusso pubblico

- Il bottone "Mostra" (da admin) punta alla pagina pricing del post.
- Nel post show book:
- se `taxbranch.visibility == participants_only`, mostra un link alla
  pagina pricing (invece delle card).
  - altrimenti si possono mostrare le card direttamente o mantenere il link.

## Regole prezzo

- `price_enrollment_euro == nil` -> non mostrare il prezzo.
- `price_enrollment_euro == 0` -> mostrare "Gratuito".
- altrimenti mostrare il valore in euro.

## Contenuti Service

Ogni Service puo avere contenuto markdown in `content_md`, utilizzato
per descrizioni estese nella pagina pricing o nel dettaglio admin.

## Note aperte

- scegliere il nome route definitivo: `pricing` o `prices`.
- decidere se la pagina pricing usa layout "book" o un layout dedicato.

## Logica di ereditarieta (bozza)

Scenario: un taxbranch puo avere piu Services. I Services possono
coprire i rami figli (ereditarieta) con livelli diversi.

Proposta di regola:

1) Services diretti del taxbranch
- Se il taxbranch ha servizi propri, sono sempre attivi per quel nodo.

2) Eredita dal parent
- Se il taxbranch non ha servizi propri, eredita quelli del parent piu vicino.

3) Livelli di copertura (esempio)
- Service "Basic": copre solo il primo livello di figli.
- Service "Plus": copre tutti i discendenti.

4) Conflitti
- Se un child ha servizi propri, questi hanno priorita rispetto agli ereditati.

Note:
- Questa regola richiede un attributo che definisca il livello di copertura
  del Service (es. coverage: "children_only" | "all_descendants").
- In assenza di un attributo, l'ereditarieta resta ambigua.

## Opzione alternativa: inclusioni esplicite tra Services

Invece di usare la gerarchia dei taxbranch, si crea una relazione diretta
tra i servizi: un service "padre" include uno o piu services "figli".

Schema suggerito (alternativa semplice):

services
- included_in_service_id (es. "Extra Capitoli" incluso in "Libro Completo")

Regola:
- Se l'utente ha enrollment al service "Libro Completo", allora ha accesso
  anche ai servizi che lo indicano come included_in_service_id.
- Il service "Basic" non include nulla, quindi non copre gli extra.

## Esempio concreto (libro)

- Taxbranch "Libro" ha due servizi:
  - "Libro Basic"
  - "Libro Completo" (o "All")

- Alcuni capitoli extra sono figli (o sotto-rami) con un service dedicato:
  - "Extra Capitoli"

Regola di inclusione:
- Se l'utente ha l'enrollment a "Libro Completo", allora include anche
  "Extra Capitoli".
- Se l'utente ha l'enrollment a "Libro Basic", allora NON include
  "Extra Capitoli".

Implicazione:
- Serve una regola di copertura/ereditarieta che permetta a un service
  "All" di includere i servizi dei sotto-rami, mentre il "Basic" no.
