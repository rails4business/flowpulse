# Taxbranch Flow: Previsione → Progetto → Operativa

Questo progetto gestisce ogni percorso/servizio seguendo tre stadi distinti ma collegati:

1. **Genera Impresa (previsione)**  
   - Serve per raccogliere fondi, definire sponsor e pianificare la sostenibilità economica.  
   - `branch_kind: generaimpresa`  
   - Collega i campi `generaimpresa_target_*` (domain/service/journey) per indicare cosa si sta finanziando.  
   - Richiede che esista almeno un branch Rails4B con gli stessi target: è la “campagna” che prepara il lancio.

2. **Rails4B (progettazione/prototipo)**  
   - Gestisce l’officina interna: commitment, timeline, costi e prototipi.  
   - `branch_kind: rails4b`  
   - Collega i campi `rails4b_target_*` per dire quale service/journey si sta costruendo.  
   - È il ponte tra la previsione (Genera Impresa) e l’erogazione (Frontline).  
   - I report Rails4B calcolano costi/tempo tramite i commitment associati.

3. **Frontline (operativa)**  
   - È il ramo pubblico dove vivono post, pagine e percorsi per utenti finali.  
   - `branch_kind: frontline`  
   - Di norma è quello collegato al dominio principale e ai contenuti pubblici.  
   - Un branch Rails4B può puntare al relativo frontline tramite `taxbranch_id` del service/journey.

## Catena obbligatoria
- **Genera Impresa → Rails4B → Frontline**  
  - Il ramo Genera Impresa deve sempre agganciarsi a un ramo Rails4B equivalente (stessi target).  
  - Il ramo Rails4B deve dichiarare cosa sta costruendo (service/journey/domain) e può recuperare il relativo ramo Frontline.  
  - Questa catena è validata automaticamente nel modello `Taxbranch`.

## Implementazione
- `app/models/taxbranch.rb`: enum `branch_kind` + validazioni:  
  - Rails4B richiede almeno un target.  
  - Genera Impresa richiede un target e un partner Rails4B.  
- `app/views/superadmin/taxbranches/_form.html.erb`: mostra blocchi diversi in base al tipo (previsione/progetto/operativa).  
- Dashboard Domain/Service/Journey elencano i branch di ogni tipo e mostrano i relativi KPI (costs per Rails4B, funding per Genera Impresa, stato per Frontline).

## Best Practice per i dev
- Quando crei un nuovo percorso, parti da:  
  1. Ramo **Genera Impresa** per raccogliere interesse e fondi (collega ai target).  
  2. Ramo **Rails4B** per costruire il progetto (collega agli stessi target).  
  3. Una volta pronto, collega il ramo **Frontline** per rendere pubblico il servizio.  
- Mantieni i target sincronizzati: se cambi service/journey di riferimento, aggiorna entrambi i branch (funding + officina) per non spezzare la catena.
