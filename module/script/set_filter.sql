set feedback on
set verify off

@@_get_current_sessionid.sql

prompt
prompt Set namespace filter for session and/or debug group
accept filter      prompt ">> Enter namespace filter [*]: "      default "*"
accept debug_group prompt ">> Enter debug group: "   default ""
accept sessionId   prompt ">> Enter sessionId [current sesionId=&&g_currentSessionId]: " default "&&g_currentSessionId"

@@_set_filter_impl.sql "&&filter" "&&debug_group" "&&sessionId"

set feedback on

undefine debug_group
undefine sessionId
undefine filter
