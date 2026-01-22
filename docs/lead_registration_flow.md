# Lead Registration Flow

## 1) Signup → User + Lead
- Form: `app/views/registrations/new.html.erb`
- Controller: `RegistrationsController#create`
  - Legge `email`, `password`, `referral_code`
  - Crea `Lead` (email + username provvisorio)
  - Crea `User` con password
  - Collega `user.lead = lead`
  - Login automatico (sessione)

## 2) Completa profilo
- Form: `app/views/registrations/edit.html.erb`
- Controller: `RegistrationsController#update`
  - Aggiorna `User` e `Lead`
  - Se `Lead` non esiste, lo crea e collega all’utente

## 3) Stato registrazione (approvazione interna)
- Modello: `app/models/user.rb`
  - `state_registration`: `pending` → `approved`
  - Campi utili: `approved_at`, `approved_by_lead_id`
  - Metodo: `User#approve!(approved_by_lead:)`

## 4) Iscrizione ai servizi
- `Enrollment` = iscrizione al servizio/percorso
  - Controller: `EnrollmentsController#create`
  - Stato iniziale: `requested`
- `Booking` = partecipazione a un `Eventdate`
  - Controller: `BookingsController`

---

## Verifica interna del Lead (proposta semplice)
Obiettivo: chi approva può lasciare traccia della verifica.

**Tracciamento minimo (già disponibile)**
- `users.state_registration`
- `users.approved_at`
- `users.approved_by_lead_id`

**Tracciamento estendibile (se serve audit)**
- Aggiungere una `note` o un `Eventdate` “check” legato al lead
- Salvare in `meta`:
  - `verified_by`
  - `verification_notes`
  - `verification_date`

---

## Pagine / Controller usabili dai Tutor

### 1) Vista elenco Lead da approvare
- `Superadmin::LeadsController#index`
  - Filtri: `pending`, `approved`, `rejected`
- View: `app/views/superadmin/leads/index.html.erb`
  - Pulsante Approva in `_row.html.erb`

### 2) Azione Approva
- `Superadmin::LeadsController#approve`
  - Imposta `user.state_registration = :approved`
  - Set `approved_by_lead_id`

### 3) Area Lead (inviti / approvazioni)
- `Account::LeadsController#index`
  - Mostra lead invitati dal tutor
  - Bottone Approva (se tutor/manager)

---

## Flow riassunto (lineare)
1. User compila form → `RegistrationsController#create`
2. Vengono creati `Lead` + `User`, login automatico
3. Lead completa il profilo → `RegistrationsController#update`
4. Tutor/Superadmin approva → `Superadmin::LeadsController#approve`
5. Lead può iscriversi a un servizio (`Enrollment`) e partecipare a eventi (`Booking`)
