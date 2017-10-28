set termout off
column g_currentSessionId new_value g_currentSessionId
select sys_context('userEnv','sessionId') as g_currentSessionId from dual;
set termout on
