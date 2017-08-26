# debug

Simple PL/SQL debug package (kind a port of JavaScript [debug](https://github.com/visionmedia/debug) package), because sometimes you just want to watch application's flow online.

<iframe width="560" height="315" src="https://www.youtube.com/embed/8rg3l4X6ZGM?rel=0" frameborder="0" allowfullscreen></iframe>

# warning - currently tested only from within schema, where it is deployed.

## Features

- **SQL\*Plus and SQLcl**
  - namespace filtering
    - specify during `init_session`, `init_persistent` or `set_filter`
    - filter defined as list of SQL `like` expressions delimited by `,`
    - only filtered namespace debug messages are stored/output
  - time diffs computed by debug namespace instance
  - persistent storage of debug (actually just side effect)
- **SQLcl specific features**
  - ANSI colors
  - online watching

## API

### init_session

Initializes debug in calling session only. Debug messages are spooled to `DBMS_OUTPUT` ->  so you can see them after anonymous block returns.

**Params**
- **filter**
  - `like` expressions without escape (sorry), separated by `,`
  - `*` - all namespaces will be enabled (**default**)
- **colors** - number of colors used in output - `'NO_COLORS'` | `'16_COLORS'` | `'256_COLORS'` (default is `'NO_COLORS'`)

> Warning!!! - Cannot be watched (yet)

```
exec debug.init_session;

declare
  s1 debug := new debug('api');
  b1 debug := new debug('business');
begin
    dbms_lock.sleep(dbms_random.value(0, 5));
    s1.log('call');
    dbms_lock.sleep(0.01);
    b1.log('validating input');
    dbms_lock.sleep(0.1);
    b1.log('input is valid');
    dbms_lock.sleep(0.1);
    b1.log('applying business rule');
    dbms_lock.sleep(dbms_random.value(0.1, 1));
    b1.log('commit');
    dbms_lock.sleep(0.001);
    s1.log('return');
end;
/

2017-05-23T21:20:24.846 api call
2017-05-23T21:20:24.856 business validating input
2017-05-23T21:20:24.956 business input is valid
2017-05-23T21:20:25.055 business applying business rule
2017-05-23T21:20:25.956 business commit
2017-05-23T21:20:25.956 api return

```

### init_persistent

Initializes debug with persistence into table, so it can be watched online from other session. Multisession debugging and watching (e.g.: server + workers, async using jobs, multiple sessions, ..) requires persistence.

**Params**
- **filter** - see init_session
- **colors** - see init_session

**Returns** 
  - **session identifier** - pass this identifier in debugged session in call to  `join_persistent`

### join_persistent

Join persistent debugging. Debug messages for filtered namespaces will be spooled to output in watching session.

**Params**
- **session** - session identifier returned by `init_persistent`

### set_filter

Changes filter after init.

**Params**
- **filter** - see init_session
- **session** - session identifier returned by `init_persistent`

### debug

Creates debug object. Create debug object and then use `log` member method to log debug messages.

**Params**
- **namespace** - choose you naming scheme, namespaces may be filtered using filter passed into init (or changed using set_filter)
  
### log

Logs if namespace is enabled (matches filter).

**Params**
- **value** - value to be logged. You are responsible for conversion into `varchar2`

### enable

Enables namespace. Valid only in scope, in which the debug object is created. Use `set_filter` method to change it for all instances with same namespace.

### disable

Not `enable`.

## Schema scripts

Connect as DBA (sys is the best) and

### create

Create schema for **debug** as configured in `package.sql`
```
SQL> @create configured
```
Or create in interactive mode 
```
SQL> @create manual
```

### grant

Or you may wish to install debug in already existing schema. Then use the `grant.sql` script to grant privileges required by **debug**

```
SQL> @grant <existing_schema>
```

### drop

Again either configured or manual. **And it drops cascade. So be carefull. You have been warned**

```
SQL> @drop configured
```
or
```
SQL> @drop manual
```

## Install scripts

You can install either from some privileged deployer user or from within "target" schema.

### set_current_schema

Use this script to change `current_schema`

```
SQL> @set_current_schema <target_schema>
```

### install

Installs module in `current_schema`. (see `set_current_schema`). Can be installed as 

- **public** - grants required privileges on module API to public (see `/module/api/grant_public.sql`)

```
SQL> @install public
```

- **peer** - sometimes you may want to use package only by schema, where it is deployed - then install it as **peer** package

```
SQL> @install peer
```

### uninstall

Drops all objects created by install.

```
SQL> @uninstall
```

## Use debug from different schemas

When you want to use **debug** from other schemas, you have basically 2 options
- either reference objects granted to `PUBLIC` with qualified name (`<schema>.<object>`)
- or create synonyms and simplify everything (upgrades, move to other schema, use other debug package, ...)

These scripts will help you with latter

### set_dependency_ref_owner

Creates depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @set_dependency_ref_owner  <schema_where_debug_is_installed>
```

### unset_dependency_ref_owner

Removes depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @unset_dependency_ref_owner  <schema_where_debug_is_installed>
```
