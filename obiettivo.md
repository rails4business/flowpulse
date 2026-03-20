# Obiettivo V1 Accademia

1. **Congela lo schema step**  
Definisci 3 categorie operative finali: `questionnaire`, `activity`, `academy_module` e non cambiarle fino al primo rilascio.

2. **Configura `meta` per step speciali**  
Per `tx_id_516` imposta `step_handler` + `completion_rule` (dati contatto obbligatori).

3. **Chiudi il flusso iscrizione completo**  
Verifica sequenza reale: `Orientamento -> Test mobilità -> Raccolta dati utente` con sblocco progressivo corretto.

4. **Completa logica “done” activity**  
Ogni step deve avere criterio univoco di completamento e passare a `archived` con `occurred_at`.

5. **Rendi coerente la UI risultato test**  
Controlla semaforo in 3 punti: fine questionario, modal dashboard, activity show.

6. **Pulisci i fallback e i duplicati**  
Blocca creazioni duplicate activity (già fatto), verifica stesso comportamento su tutti gli entrypoint.

7. **Validazioni minime dati utente**  
Imposta required veri per datacontact (email/telefono/nome/cognome + formato telefono).

8. **Ruoli minimi per go-live**  
Conferma ruoli usati nel flusso attuale: `utente`, `tutor`, `insegnante` (gli altri dopo).

9. **Smoke test end-to-end**  
Test manuale con 2 utenti: uno nuovo e uno già a metà percorso, da dashboard fino al primo modulo accademia.

10. **Tag “v1 accademia” e poi refactor**  
Quando il flusso funziona, congelalo e solo dopo fai semplificazione architetturale (senza toccare behavior).
