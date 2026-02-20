---
type: "chapter"
title: "Introduzione"
description: "Una chiave di lettura per orientarsi nel percorso"
slug: "introduzione-pc-gdc"
color: "neutro"
access: "draft"
---

[Contenuto da completare]

rails g model Book slug:string title:string description:text folder_md:string index_file:string price_euro:decimal price_dash:decimal access_mode:integer active:boolean
rails g model BookDomain book:references domain:references
