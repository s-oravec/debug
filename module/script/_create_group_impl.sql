undefine l_description
undefine l_filter

define l_description = "&1"
define l_filter      = "&2"

var id_debug_group number

set feedback on
prompt .. Creating debug group. (filter="&&l_filter", description="&&l_description")
set feedback off

declare
    l_filter      varchar2(4000) := nvl('&&l_filter', '*');
    l_description varchar2(4000) := nvl('&&l_description', '*');
begin
    :id_debug_group := debug_adm.create_group(l_filter, l_description);
end;
/

set feedback on
prompt done
prompt

set termout off

column l_id_debug_group new_value l_id_debug_group
select :id_debug_group as l_id_debug_group from dual;

spool l_id_debug_group.sql
prompt define l_id_debug_group = &&l_id_debug_group
spool off

set termout on
undefine l_filter
undefine l_description