undefine l_id_debug_group
undefine l_sessionId

define l_id_debug_group = "&1"
define l_sessionId      = "&2"

set feedback on
prompt .. Resuming debug for session and/or debug group. (sessionId="&&l_sessionId", debug_group="&&l_id_debug_group")
set feedback off

declare
    l_id_debug_group integer := to_number('&&l_id_debug_group');
    l_sessionId      integer := to_number('&&l_sessionId');
begin
    debug_adm.resume_debug(l_id_debug_group, l_sessionId);
end;
/

set feedback on
prompt done
prompt

set termout on
undefine l_id_debug_group
undefine l_sessionId
