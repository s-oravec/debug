set feedback on
set verify off

prompt
prompt Debug other session this session (optionally add to debug group)
accept debug_group prompt ">> Enter debug group (mandatory): "   default ""
accept sessionId   prompt ">> Enter sessionId (mandatory): "     default ""
accept filter      prompt ">> Enter namespace filter [*]: " default "*"

@@_debug_other_impl.sql "&&debug_group" "&&sessionId" "&&filter"

set feedback on

undefine debug_group
undefine sessionId
undefine filter
