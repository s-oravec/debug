set feedback on
set verify off

@@_get_current_sesionid.sql

prompt
prompt Purge debug log messages for session and/or debug group
accept debug_group prompt ">> Enter debug group: " default ""
accept sessionId   prompt ">> Enter sessionId [current sessionId=&&g_currentSessionId]: "   default "&&g_currentSessionId"

@@_purge_log.sql "&&debug_group" "&&sessionId"

set feedback on

undefine debug_group
undefine sessionId