set feedback on
set verify off

prompt
prompt Drop debug group
accept id_debug_group prompt ">> Enter debug group identifier [null]: " default ""

@@_drop_group_impl "&&id_debug_group"

undefine id_debug_group