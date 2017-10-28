set feedback on
set verify off

prompt
prompt Create debug group
accept filter      prompt ">> Enter namespace filter [*]: " default "*"
accept description prompt ">> Enter description [None]: "   default "None"

@@_create_group_impl.sql "&&description" "&&filter"

set feedback on

prompt
prompt You may now
prompt
prompt 1. add other session identified by <sessionId> into debug group using
prompt SQL> exec debug_adm.debug_other(&&l_id_debug_group, <sessionId>);;
prompt
prompt 2. add your session into debug group using
prompt SQL> exec debug_adm.debug_this(&&l_id_debug_group);;
prompt
