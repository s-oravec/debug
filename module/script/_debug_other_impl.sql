undefine l_id_debug_group
undefine l_sessionId
undefine l_filter

define l_id_debug_group = "&1"
define l_sessionId      = "&2"
define l_filter         = "&3"

set feedback on
prompt .. Setting debug on for session in debug group. (debug_group="&&l_id_debug_group", sessionId="&&l_sessionId", filter="&&l_filter")
set feedback off

declare
    l_id_debug_group integer := to_number('&&l_id_debug_group');
    l_sessionId      integer := to_number('&&l_sessionId');
    l_filter         varchar2(4000):= nvl('&&l_filter', '*');
begin
    debug_adm.debug_other(l_id_debug_group, l_sessionId, l_filter);
end;
/

set feedback on
prompt done
prompt

set termout on
undefine l_id_debug_group
undefine l_sessionId
undefine l_filter
