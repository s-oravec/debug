# debug

Yet Another PL/SQL debug package, because sometimes you just want to watch application's flow online.

## Features

- namespace filtering
- time diffs computed by namespace
- persistent storage of debug

### namespace filtering

```
create or replace procedure applyBusinessRule (
    a_id_worker in pls_integer
) is
    worker   debug('worker:' || id);
    business debug('business');
begin
    worker.log('starting');
    
end;
```

## SQLcl features

- ANSI colors
- online watching
