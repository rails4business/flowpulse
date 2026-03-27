# Experience Type V1

## Obiettivo
Definire un campo dedicato e chiuso per stabilire **che tipo di esperienza utente** deve mostrare un `Post`, senza sovraccaricare `slug_category` o `meta`.

Questo documento fissa una direzione V1 semplice, estendibile nel tempo.

## Principio
- `Taxbranch` = nodo canonico del flusso
- `Post` = interfaccia/esperienza mostrata all'utente
- `experience_type` = tipo di esperienza renderizzata dal `Post`
- `meta` su `Taxbranch` = regole speciali dello step
- YAML = contenuto strutturato dei questionari

## Perche introdurre `experience_type`
Oggi `slug_category` rischia di fare troppe cose insieme:
- tassonomia
- semantica operativa
- scelta della vista
- comportamento dello step

Separare il tipo di esperienza evita ambiguita e rende piu semplice evolvere l'app.

## Regola architetturale
Il rendering del `Post` deve dipendere da `experience_type`, non direttamente da `slug_category`.

Il completamento dello step deve continuare a dipendere dal `Taxbranch`, non dal `Post`.

Quindi:
- il `Post` decide **come si presenta**
- il `Taxbranch` decide **come si completa**

## Campo consigliato
Nome consigliato:

- `experience_type`

Alternative possibili ma meno preferite:
- `post_experience_type`
- `interaction_type`

## Lista iniziale V1
Valori iniziali chiusi:

- `article`
- `questionnaire`
- `profile_completion`
- `booking`
- `event`
- `lesson`
- `service_visit`

## Significato dei valori

### `article`
Contenuto da leggere.

Uso:
- pagine informative
- contenuti editoriali
- introduzioni di percorso

### `questionnaire`
Esperienza di compilazione questionario.

Uso:
- questionari YAML
- test iniziali
- raccolta risposte strutturate

Nota:
- il questionario strutturato resta definito via YAML
- il riferimento al file resta sul `Taxbranch`

### `profile_completion`
Esperienza guidata di completamento profilo.

Uso:
- wizard `Datacontact`
- raccolta dati utente
- step di onboarding

### `booking`
Esperienza di prenotazione o richiesta.

Uso:
- richiesta appuntamento
- prenotazione guidata

### `event`
Esperienza legata a un evento o presenza.

Uso:
- partecipazione a incontro
- conferma presenza
- calendario

### `lesson`
Esperienza didattica/modulo.

Uso:
- lezione
- modulo academy
- contenuto formativo sequenziale

### `service_visit`
Esperienza legata a un servizio o visita.

Uso:
- visita
- prestazione
- accesso a servizio operativo

## Cosa non fare
- non usare `slug_category` come unico driver della vista
- non mettere tutta la logica di completamento nel `Post`
- non mettere il questionario completo in `questionnaire_config` se puo stare in YAML
- non spostare il riferimento strutturale del questionario nel `Post`

## Regola sui questionari
Per i questionari:

- il `Post` puo avere `experience_type = questionnaire`
- il `Taxbranch` continua a indicare il file YAML
- il YAML contiene la definizione strutturata
- `questionnaire_config` dovrebbe ridursi al minimo necessario

## Ruolo del `meta`
`meta` va usato solo per regole speciali o configurazioni operative mirate.

Esempi corretti:
- `step_handler`
- `completion_rule`

`meta` non deve diventare il contenitore generico di tutta la semantica del `Post`.

## Configurazione applicativa
In applicazione deve esistere una mappa centrale dei tipi supportati.

Esempio concettuale:

- `article` -> vista contenuto standard
- `questionnaire` -> renderer questionario
- `profile_completion` -> wizard profilo
- `booking` -> flusso prenotazione
- `event` -> esperienza evento
- `lesson` -> vista lezione/modulo
- `service_visit` -> vista servizio/visita

La mappa puo vivere inizialmente in Ruby, non serve metterla in DB.

## Direzione V1
Per la V1:

1. introdurre `experience_type`
2. usare una allowlist chiusa
3. mettere fallback a `article`
4. usare `experience_type` per scegliere la vista del `Post`
5. lasciare `Taxbranch` responsabile di sblocco e completion

## Sintesi
Decisione fissata:

- introdurre `experience_type` come campo dedicato
- non usare `slug_category` come driver principale della vista
- mantenere `Taxbranch` come nodo operativo del flusso
- mantenere `Post` come contenitore dell'esperienza utente
- mantenere YAML per la definizione dei questionari
