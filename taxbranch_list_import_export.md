# Taxbranch Import/Export (Superadmin)

## Obiettivo
Gestire l’esportazione e l’importazione di **Taxbranch + Post collegati** come **un unico processo** (1 export + 1 import).

---

## Route e UI

- Pagina: `GET /superadmin/taxbranches/:id/export_import`
- Accesso: **Tab “Import/Export”** nella pagina del Taxbranch

---

## Export (unico pacchetto)

### Cosa esporta
- Subtree completo del taxbranch `:id`
- Dati Taxbranch
- Post collegati a ciascun taxbranch (se presenti)

### Formato (CSV unico)
Un file unico con colonne per Taxbranch e Post.

```csv
slug,slug_category,slug_label,parent_slug,lead_id,visibility,status,position,home_nav,post_title,post_content_md,post_content,post_slug,post_lead_id
branch/postura,branch,Postura,,12,public_node,published,1,true,"Postura base","...md...",,"postura-base",12
branch/postura/respirazione,branch,Respirazione,branch/postura,12,public_node,published,2,false,,,,,
```

---

## Import (unico processo)

### Form (Tab Import/Export)
- File CSV unico
- Parent Taxbranch fisso: `:id`
- Lead ID default: `Current.user.lead_id`
- Duplicati: `skip / update / error`
- Position: usa `position` se presente, altrimenti ordine righe

### Logica Import (2 passaggi)

1. **Taxbranch**
   - crea/aggiorna i taxbranch senza ancestry
   - usa `slug` come chiave primaria
   - salva `parent_slug` come riferimento

2. **Ancestry**
   - risolve `parent_slug` → `parent_id`
   - se `parent_slug` vuoto → parent fisso `:id`

3. **Post**
   - se `post_title` o `post_content_md` presenti:
     - crea/aggiorna `post` associato al taxbranch

---

## Note importanti

- `parent_id` diretto non si usa: **gli ID cambiano**
- `slug` resta la chiave stabile
- `lead_id` default: `Current.user.lead_id` (modificabile in form)
- Import e export sono **un unico file**

---

## Endpoint proposti

- `GET /superadmin/taxbranches/:id/export_import`
- `GET /superadmin/taxbranches/:id/export`
- `POST /superadmin/taxbranches/:id/import`

