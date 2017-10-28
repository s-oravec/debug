set feedback on
set verify off

prompt
prompt Debug this session and add it to debug group (optionally)
accept debug_group prompt ">> Enter debug group [null]: "           default ""
accept filter      prompt ">> Enter namespace filter [*]: "         default "*"
accept colors      prompt ">> Enter colors [256] (NO | 16 | 256): " default "256"

@@_debug_this_impl.sql "&&debug_group" "&&filter" "&&colors"

set feedback on

undefine debug_group
undefine filter
undefine colors
