set feedback on
set verify off

@@_get_current_sessionid.sql

prompt
prompt Resume debug for session and/or debug group
accept debug_group prompt ">> Enter debug group: "   default ""
accept sessionId   prompt ">> Enter sessionId [current sessionId=&&g_currentSessionId]: " default "&&g_currentSessionId"

@@_resume_debug_impl.sql "&&debug_group" "&&sessionId"

set feedback on

undefine debug_group
undefine sessionId
