# Taxbranch Questionnaire - Istruzioni

## Obiettivo
Usare `Taxbranch` come puntatore del questionario e un file YAML in `config/data/questionnaires/` come sorgente delle domande.

Le compilazioni utente vengono salvate in `Activity` (non in `Eventdate`).

## Configurazione Taxbranch (superadmin)
Per un taxbranch con `slug_category: questionnaire`:
- seleziona il file nel campo `Questionario`
- il sistema salva in `taxbranch.meta`:
  - `questionnaire_source`
  - `questionnaire_version`
  - `scoring` (se presente nel YAML)

Esempio `meta`:
```json
{
  "questionnaire_source": "config/data/questionnaires/questionario_orientamento.yml",
  "questionnaire_version": "v1",
  "scoring": {
    "enabled": false
  }
}
```

## Formato YAML
File: `config/data/questionnaires/<nome>.yml`

Campi root consigliati:
- `slug`
- `title`
- `version`
- `locale`
- `intro`
- `scoring`
- `questions` (array)

Esempio minimo:
```yaml
slug: questionario_orientamento
title: Questionario di Orientamento
version: v1
locale: it
scoring:
  enabled: false
questions:
  - code: q1
    position: 1
    movement: Hai una diagnosi medica attiva?
    kind: single_choice
    options:
      - value: si
        label: Si
      - value: no
        label: No
```

## Tipi domanda supportati
- `single_choice`
- `multi_choice` (estendibile lato UI)
- `open_text`
- `scale`

## Domande dinamiche (`show_if`)
Una domanda può essere visibile solo in certe condizioni.

Sintassi supportata:
- `show_if` come singola condizione
- `show_if.all` (AND)
- `show_if.any` (OR)

Operatori supportati:
- `eq`
- `neq`
- `in`
- `not_in`
- `present`
- `blank`

Esempio:
```yaml
- code: q1_diagnosi_attiva
  kind: single_choice
  options:
    - { value: si, label: Si }
    - { value: no, label: No }

- code: q1b_quale_diagnosi
  kind: open_text
  show_if:
    all:
      - question: q1_diagnosi_attiva
        operator: eq
        value: si
```

Nel renderer:
- lo stepper mostra solo `visible_questions`
- `Domanda X di N` e barra progresso si autoregolano su `N` visibili.

## Salvataggio compilazione
Action: `POST /posts/:id/submit_questionnaire`

Service: `QuestionnaireSubmission`

Record creato: `Activity` con:
- `kind: questionnaire_submission`
- `status: recorded`
- `lead_id`, `domain_id`, `taxbranch_id`
- `occurred_at`
- `score_total`, `score_max`, `level_code` (se scoring attivo)
- `payload`:
  - `answers`
  - `score_result`
  - `questionnaire_source`
  - `questionnaire_version`

## Scoring
Se nel YAML/`meta` c'e:
```yaml
scoring:
  enabled: true
```
il sistema calcola:
- `total`
- `max_total`
- `percentage`
- `level_code`, `level_label`
- `interpretation`, `recommendation`

## Note operative
- Il path della source deve restare relativo: `config/data/questionnaires/...yml`
- Non usare path assoluti nel `meta`.
- `Eventdate` resta per agenda/eventi, non per ogni submission questionario.
