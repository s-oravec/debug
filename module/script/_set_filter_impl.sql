undefine l_filter
undefine l_id_debug_group
undefine l_sessionId

define l_filter         = "&1"
define l_id_debug_group = "&2"
define l_sessionId      = "&3"

set feedback on
prompt .. Setting namespace filter in this session or session identified by sessionId and/or debug group. (filter="&&l_filter", sessionId="&&l_sessionId", id_debug_group="&&l_id_debug_group")
set feedback off

declare
    l_id_debug_group integer := to_number('&&l_id_debug_group');
    l_sessionId      integer := to_number('&&l_sessionId');
    l_filter         varchar2(4000):= nvl('&&l_filter', '*');
begin
    debug_adm.set_filter(l_filter, l_id_debug_group, l_sessionId);
end;
/

set feedback on
prompt done
prompt

set termout on
undefine l_id_debug_group
undefine l_sessionId
undefine l_filter
