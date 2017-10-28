undefine l_id_debug_group
define l_id_debug_group = "&1"

set feedback on
prompt .. Dropping debug group. (debug_group="&&l_id_debug_group")
set feedback off

declare
    l_id_debug_group integer := to_number ('&&l_id_debug_group');
begin
    debug_adm.drop_group(l_id_debug_group);
end;
/

set feedback on
prompt done
prompt

undefine l_id_debug_group
