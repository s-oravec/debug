set feedback on
set verify off

prompt
prompt .. Initializing persistent debug session
prompt
accept filter prompt ">>> Enter debug filter [*]: " default "*"
accept colors prompt ">>> Enter colors [256] (NO | 16 | 256): " default "256"
prompt

set feedback off

var id_debug_session number
declare
    l_filter varchar2(4000) := nvl('&&filter', '*');
    l_colors varchar2(255) := upper('&&colors') ||'COLORS';
begin
    :id_debug_session := debug.init_persistent(l_filter, debug_impl.colors_256);
end;
/

set termout off
column id_debug_session new_value id_debug_session
select :id_debug_session as id_debug_session from dual;
set termout on

set feedback on

prompt done
prompt
prompt You may start your debugging session using
prompt
prompt declare
prompt     session pls_integer;
prompt begin
prompt     session := debug.init_persistent(session => &&id_debug_session);
prompt end;
prompt /
prompt
prompt Now watching session &&id_debug_session
prompt

script watch.js &&id_debug_session
