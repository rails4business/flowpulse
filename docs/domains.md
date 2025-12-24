---
title: Domains
parent: Versione 3 10 ottobre 2025
grand_parent: Sviluppo
nav_order: 09
---

# Domains

Scopo: usare i domini come porta di accesso ai rami Taxbranch, risolvendo
il ramo root direttamente dall'host della richiesta.

## Decisioni chiave

- Un unico albero Taxbranch.
- Ogni Domain punta a un taxbranch root (entry point).
- Current.domain e Current.taxbranch sono risolti da request.host.
- Domini gestibili solo da superadmin.
- Supporto multi-dominio con HTTPS.

## Perche Taxbranch has_many :domains

Un taxbranch puo avere piu host:
- alias (es. www, redirect, dominio storico)
- domini per lingue diverse
- ambienti/staging

Quindi un solo dominio sarebbe troppo limitante: serve has_many.

## Regola per il domain attivo

1. Il domain attivo si risolve sempre da request.host.
2. Se non esiste un Domain che matcha l'host, si applica un fallback:
   - 404 o redirect al dominio principale.

## Risalire dal taxbranch al domain (per lingua)

Se hai solo il taxbranch e vuoi scegliere un Domain:
- cerca tra i domini collegati uno con language = lingua utente
- se non c'e, usa il Domain marcato come primary
- se non c'e primary, usa il primo disponibile

## Lingua utente (futuro)

Per ora la lingua e determinata dal Domain (language).
In futuro aggiungere:
- selettore lingua in UI (IT/EN)
- se loggato: salva su lead.locale
- se non loggato: salva in session/cookie
- fallback finale: Domain.language

## Routing entry point

posturacorretta.org/taxbranches/
in base alla request.host parte dal taxbranch collegato al Domain.

## Modello Domain (base)

bin/rails g scaffold Domain \
  host:string:uniq \
  language:string \
  title:string \
  description:text \
  favicon_url:string \
  square_logo_url:string \
  horizontal_logo_url:string \
  provider:string \
  taxbranch:references

## DomainResolver

Il resolver normalizza l'host e risolve Domain + taxbranch via cache.
Current.domain e Current.taxbranch sono sempre derivati da request.host.

## Note aperte

- Gate posts vs blog/corsi: definire se usare modelli dedicati.
