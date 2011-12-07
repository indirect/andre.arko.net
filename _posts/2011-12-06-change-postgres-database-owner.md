---
title: Change Postgres database owner
layout: post
---
Since this took some digging to find, I'm just going to post it for posterity (and myself in the future):

```sql
UPDATE pg_class SET relowner = (SELECT oid 
    FROM pg_roles WHERE rolname = '$USER') 
  WHERE relname IN (SELECT relname
    FROM pg_class, pg_namespace 
    WHERE pg_namespace.oid = pg_class.relnamespace
    AND pg_namespace.nspname = 'public');
```

Change $USER to be the name of the user you want to be the new owner of the DB.