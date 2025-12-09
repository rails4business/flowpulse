# Posizionamento & Priorità condivise

https://www.dreamers-community.it/#eventi e skool.com 
 per prendere spunto 

dividere tag_positioning in due tabelle: 
tag per legare positionig (nome categoria  urgenza importanza ed energia ) con un polimorfic(taxbranch o journey eventadate o commitment)
Spostare urgenza importanza ed energia da journey a positioning 


aggiungere anche visibilità pubblica o privata su positioning


Documento di lavoro per portare importance / urgency / energy dalle Journey
verso un modello più flessibile basato su posizionamenti e tag.

## Obiettivo

- Eliminare la duplicazione delle enum `importance`, `urgency`, `energy` sui
  singoli modelli operativi (Journey, Commitment, Eventdate).
- Gestire le priorità a livello di *posizionamento* (segmento strategico) in
  modo che tutti gli oggetti collegati ne ereditino automaticamente il “tono”.
- Consentire override locali solo quando necessario.

## Modello concettuale

1. **Positioning** (nuovo modello)
   - Campi proposti: `name`, `category`, `importance`, `urgency`, `energy`,
     opzionali `notes`, `color`.
   - Gestisce le enum (stessa mappatura oggi presente in `Journey`).
   - Può essere associato ai diversi oggetti tramite tag polimorfici.

2. **Tag** (nuovo modello, polimorfico)
   - Campi: `positioning_id`, `taggable_type`, `taggable_id`, `context` (facolt.).
   - Ogni tag collega un positioning a `Taxbranch`, `Journey`, `Commitment`,
     `Eventdate` o altri oggetti futuri.
   - Serve come join table e punto di estensione.

3. **Regole di ereditarietà**
   - Se un oggetto ha più positioning associati, calcoliamo un punteggio usando
     le enum (es. `importance_score + urgency_score + energy_score`).
   - Prevale il positioning con punteggio più alto; in caso di pareggio,
     applicare un ordinamento deterministico (created_at, categoria, ecc.).
   - Possibile fallback: valori di default definiti sul `Taxbranch` di
     appartenenza, così l’albero posizionamento → journey → commitment →
     eventdate ha sempre un riferimento.

## Passi di implementazione

1. **Migrazioni**
   - Creare tabella `positionings` con i campi e le enum.
   - Creare tabella `tags` con riferimento polimorfico a `taggable` e FK a
     `positionings`.
   - (Facoltativo) Migrare i record attuali da `TagPositioning` verso la nuova
     struttura, mantenendo categorie e naming.

2. **Modeling**
   - `Positioning` ha `has_many :tags, dependent: :destroy` e definisce le enum.
   - `Tag` `belongs_to :positioning` e `belongs_to :taggable, polymorphic: true`.
   - Nei modelli coinvolti (Taxbranch, Journey, Commitment, Eventdate) aggiungere
     `has_many :tags, as: :taggable` e `has_many :positionings, through: :tags`.

3. **Helpers / servizi**
   - Implementare un servizio `PositioningResolver` che, dato un oggetto,
     restituisce il positioning prevalente calcolando il punteggio.
   - Esporre metodi di convenienza tipo `effective_importance` per usare il
     positioning di riferimento.

4. **UI & filtri**
   - Aggiornare le viste (es. pagina Eventdates) per mostrare badge derivati dal
     positioning prevalente.
   - Consentire all’utente di selezionare positioning attraverso i tag nelle UI
     di Journey/Commitment/Eventdate.

## Note aperte

- Serve decidere se i Taxbranch possiedono sempre almeno un positioning di
  default (utile per ereditare anche quando mancano tag specifici).
- Valutare cosa succede quando un positioning viene eliminato: cascata sui tag
  e fallback automatico.
- Possibile aggiungere campi di ponderazione (es. pesi diversi per importance vs
  urgency) se la somma semplice non basta.

Questo file resta il riferimento per la feature; aggiornalo man mano che prendi
decisioni o cambi l’architettura proposta.
