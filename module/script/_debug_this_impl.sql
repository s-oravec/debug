undefine l_id_debug_group
undefine l_filter
undefine l_colors

define l_id_debug_group = "&1"
define l_filter         = "&2"
define l_colors         = "&3"

set feedback on
prompt .. Setting debug on for this session and optionally adding it into debug group. (debug_group="&&l_id_debug_group", filter="&&l_filter", colors="&&l_colors")
set feedback off

declare
    l_id_debug_group integer := to_number('&&l_id_debug_group');
    l_filter         varchar2(4000):= nvl('&&l_filter', '*');
    l_colors         varchar2(255) := nvl('&&l_colors', '256') || '_COLORS';
begin
    debug_adm.debug_this(l_id_debug_group, l_filter, l_colors);
end;
/

set feedback on
prompt done
prompt

set termout on
undefine l_filter
undefine l_colors

set serveroutput on size unlimited
