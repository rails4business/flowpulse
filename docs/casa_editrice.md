# Casa Editrice (Flowpulse)

## Obiettivo
Documentare la "casa editrice" del progetto: struttura editoriale, contenuti, pricing e collegamenti ai percorsi esistenti (Taxbranch + Post).

## Scelta attuale
Per ora **non** introduciamo un nuovo modello `Book` nel database. Usiamo:
- **Taxbranch** come struttura gerarchica (indice, capitoli, sottocapitoli).
- **Post** come contenuto principale (testo, media, metadata editoriali già presenti).

Questa scelta riduce la complessità e permette di procedere più velocemente con l’Accademia.

## Quando introdurre un modello Book
Introdurre `Book` ha senso se servono metadati commerciali dedicati (es. prezzi, formati, SKU, copertine distinte), o se un libro deve vivere separato dal contenuto editoriale generico.

Campi tipici ipotizzati (non ancora creati):
- `title`, `description`
- `cover_image`, `images_folder`
- `euro_price_online`, `euro_price_audio`, `euro_price_physical`
- `dash_price_online`, `dash_price_audio`, `dash_price_physical`
- `slug`, `url_yml_index`, `url_chapters`
- `lead_id`, `taxbranch_id`

## Struttura contenuti (attuale)
- **Indice libro**: Taxbranch padre (root) con `children` ordinati.
- **Capitoli**: Taxbranch figli, ognuno con il proprio Post.
- **Contenuti**: Nel Post, con formattazione, media e metadati disponibili.

## Routing editoriale (idea)
Le pagine restano allineate alla gerarchia dei Taxbranch. In futuro, se verrà introdotto `Book`, potrà puntare a un Taxbranch root, mantenendo invariata la struttura editoriale.

## Prossimi step (da valutare)
- Decidere se introdurre `Book` solo quando la parte commerciale è prioritaria.
- Definire naming consistente per prezzi (EUR/DASH) e formato (online/audio/physical).
- Se necessario: mappare Taxbranch -> Book (1:1) e costruire viste dedicate.
