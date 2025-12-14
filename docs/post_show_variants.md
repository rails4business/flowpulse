# Varianti `posts#show`

| Template                                | Uso principale                                                    | Note                                                    |
|-----------------------------------------|-------------------------------------------------------------------|---------------------------------------------------------|
| `show.html+post.erb`                    | Default generico per categorie pubbliche                          | Layout griglia, mostra i figli pubblici del taxbranch.  |
| `show.html+exercise_sheet.erb`          | Schede esercizi interattive                                      | Supporta modalità fullscreen e modal via Turbo Frame.   |
| `show.html+program_course.erb`          | Percorsi multi-modulo (weeks/days/sections + schede)             | Usa partial `course_week`, `course_day`, `course_sheet`. |
| `show.html+week_program.erb`            | Focus sulla settimana: elenco dei day e pulsante “Inizia”        | “Segna fatto” per day, preview scheda in modal.         |
| `show.html+day_program.erb`             | Programma giornaliero con più schede                             | Bottone completamento giorno + lista schede collegate.  |
| `show.html+all_sheets.erb`              | Indice di tutte le schede del corso                              | Raggruppa per categoria e linka alle `exercise_sheet`.  |
| `show.html+exercise_sheet.erb` (modal)  | Variante caricata nel `sheet_modal`                              | Layout overlay, bottone “Segna scheda completata”.      |
| `show.html+program_course.erb` (print)  | Per stampa/ PDF (da aggiungere)                                  | Idea: versione semplificata per report cartacei.        |

Ogni variante vive in `app/views/posts/` e viene selezionata dal `Taxbranch#slug_category`/`#display_label`. Per aggiungerne una nuova:

1. Creare `show.html+<slug>.erb`.
2. Associare il taxbranch impostando `slug_category` o `variant`.
3. Aggiungere eventuali partial e documentare qui.
