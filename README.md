# debug

Simple PL/SQL debug package (kind a port of JavaScript [debug](https://github.com/visionmedia/debug) package), because sometimes you just want to watch application's flow online.

> Warning: Screencap with previous version of API!!! New screencap coming soon.
 
[![](https://img.youtube.com/vi/8rg3l4X6ZGM/0.jpg))](https://www.youtube.com/watch?v=8rg3l4X6ZGM "Watch debug in action on YouTube")

# Warning: Currently tested only from within schema, where it is deployed.

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

## PL/SQL API

### `debug` constructor

Creates `debug` object for debug `namespace` - all messages logged using `log` method are in this debug namespace. Log can be filtered for specific namespace/namespaces.

**Parameters**

- **namespace** - debug namesapce.

> Best practice: Prefix with your package name.

### `member procedure log`

- **value** - value to be logged. You are responsible for conversion into `varchar2`

Logs 
 
This is simplest sample use of debug.

- Start debugging current session

```
SQL> @module/script/debug_this

Debug this session and add it to debug group (optionally)
>> Enter debug group [null]: 
>> Enter namespace filter [*]: 
>> Enter colors [256] (NO | 16 | 256): 
.. Setting debug on for this session and optionally adding it into debug group. (debug_group="", filter="*", colors="256")
done
```

- Create simple PL/SQL block

```
SQL> declare
  2      d debug := new debug('my-test'); -- create debug object with namespace "my-test"
  3  begin
  4      d.log('Hello World!'); -- log some debug message
  5  end;
  6  /
  
my-test Hello World! +0ms << this is output from debug [namesapce] [message] [offset from last debug message in namespace]
```  

### `debug_adm.create_group`

Creates debug group, which can aggregate debug messages from multiple sessions. Initializes debug with persistence into table, so it can be watched online from other session. Multisession debugging and watching (e.g.: server + workers, async using jobs, multiple sessions, ..) requires persistence.

**Params**

- **filter**
  - `like` expressions without escape (sorry), separated by `,`
  - `*` - all namespaces will be enabled (**default**)
- **description** - just some description

```
SQL> var debug_group number
SQL> exec :debug_group := debug_adm.create_group;
```

### `debug_adm.drop_group`

Drops debug group and debug log mesasges. Effectively stops debugging and watching in all sessions in group.

```
exec debug_adm.drop_group(:debug_group);
```

### `debug_adm.group_exists`

**Params**

- **debug_group** - debug group identifier

**Returns**

- `Y` - if debug group exists 
- `N` - otherwise

```
select debug_adm.group_exists(:debug_group);
```

### `debug_adm.debug_this`

Starts debug in this session only or add this session to existing debug group (if debug_group parameter is passed)

> Warning: Debug not in group cannot be watched from other session

**Parameters**

- **debug_group** - debug group identifier. see [`debug_adm.create_group`](#debug-adm.create-group)
- **filter**
    - like expressions without escape (sorry), separated by ,
    - * - all namespaces will be enabled (default)
- **colors** - colors settings for namespace "coloring" in ANSI terminals. Use debug_format.COLORS_NO if your terminal does not support ANSI colors
    - debug_format.COLORS_NO - no colors
    - debug_format.COLORS_16 - 16 colors
    - debug_format.COLORS_256 - 256 colors

**Sample usage**

```
SQL> exec debug_adm.debug_this;
SQL> declare
  2      d debug := new debug('my-test');
  3  begin
  4      d.log('Hello World!');
  5  end;
  6  /
  
my-test Hello World! +0ms
```

### `debug_adm.debug_other`

Add other session, identified by sessionId (`sys_context('userEnv','sessionId'` or `v$session.audsid`) to debug group.

**Parameters**

- **debug_group** - debug group identifier. see [`debug_adm.create_group`](#debug-adm.create-group)
- **sessionId** - sessionId of session to be added to group (`sys_context('userEnv','sessionId'` or `v$session.audsid`)
- **filter**
    - like expressions without escape (sorry), separated by ,
    - * - all namespaces will be enabled (default)

**Sample usage**

Session to be debugged.

```
SQL> set srveroutput on size unlimited
SQL> exec dbms_output.put_line(sys_context('userEnv','sessionId'));

1710605

SQL> exec my_server_test;
```

From other session, watching debug messages from debugged session.

```
SQL> var debug_group number
SQL> exec :debug_group := debug_adm.create_group;
SQL> column debug_group new_value debug_group
SQL> select :debug_group as debug_group from dual;
SQL> exec debug_adm.debug_other(:debug_group, 1710605);
SQL> script watch_group.js &&debug_group
```

### `debug_adm.pause_debug`

Pause debug for session and/or debug group.

**Parameters**

- **debug_group** - debug group to be paused. see [`debug_adm.create_group`](#debug-adm.create-group)
- **sessionId** - sessionId of session to be paused

One session can be in more groups, so 

- if called with `debug_group` then stops debugging of whole debug group
- if called with `sessionId` then stops debugging of session with `sessionId` in all debug groups
- if called with both `debug_group` and `sessionId` then stops debugging of session with `sessionId` in specified debug group

**Sample usage**

```
SQL> exec debug_adm.pause_debug(3);
```

### `debug_adm.resume_debug`

Resume debug for session and/or debug group.

**Parameters**

- **debug_group** - debug group to be paused. see [`debug_adm.create_group`](#debug-adm.create-group)
- **sessionId** - sessionId of session to be paused

see [`debug_adm.pause_debug`](#debug_adm.pause_debug) for detailed info about values of parameters

### `debug_adm.purge_log`

Purge messages from log for session and/or debug group.

- **debug_group** - debug group, which log message to be purged. see [`debug_adm.create_group`](#debug-adm.create-group)
- **sessionId** - sessionId of session, which log message to be purged

see [`debug_adm.pause_debug`](#debug_adm.pause_debug) for detailed info about values of parameters

### `debug_adm.set_filter`

Change namespace filter session and/or debug group.

- **filter** - new value for filter - see [`debug_adm.debug_this`](#debug_adm.debug_this)
- **debug_group** - debug group, which log message to be purged
- **sessionId** - sessionId of session, which log message to be purged

see [`debug_adm.pause_debug`](#debug_adm.pause_debug) for detailed info about values of parameters

## Package scripts

Connect as DBA or privileged user (`SYS` is the best) and

### create

Create schema for **debug** as configured in `package.sql`

```
SQL> @create configured <environment>
```

Or create in interactive mode 

```
SQL> @create manual <environment>
```

**Choose from &gt;environment&lt; values**

- `development` - for development of **debug** package - schema receives more privileges
- `production`  - if you just want to use **debug**

### grant

Or you may wish to install debug in already existing schema. Then use the `grant.sql` script to grant privileges required by **debug** package.
Pass **environment** parameter to grant `development` or `production` privileges.

```
SQL> @grant <packageSchema> <environment>
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

- **public** - grants required privileges on module API to `PUBLIC` (see `/module/api/grant_public.sql`)

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

These scripts will help you with latter, by either creating or dropping synonyms for **debug** package API in that schema.

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
