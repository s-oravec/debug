rem Tables
prompt .. Creating table DEBUG_GROUP
@@table/debug_group.tab

prompt .. Creating table DEBUG_SESSION
@@table/debug_session.tab

prompt .. Creating table DEBUG_LOG
@@table/debug_log.tab

rem Sequences
prompt .. Creating sequence DEBUG_GROUP_ID
@@sequence/debug_group_id.seq

prompt .. Creating sequence DEBUG_SESSION_ID
@@sequence/debug_session_id.seq

prompt .. Creating sequence DEBUG_LOG_ID
@@sequence/debug_log_id.seq

rem Code Specifications
prompt .. Creating package DEBUG_TYPES
@@package/debug_types.pks

prompt .. Creating package DEBUG_UTIL
@@package/debug_util.pks

prompt .. Creating package DEBUG_FORMAT_IMPL
@@package/debug_format_impl.pks

prompt .. Creating package DEBUG_IMPL
@@package/debug_impl.pks

rem Code Bodies
prompt .. Creating package body DEBUG_UTIL
@@package/debug_util.pkb

prompt .. Creating package body DEBUG_IMPL
@@package/debug_impl.pkb

prompt .. Creating package body DEBUG_FORMAT_IMPL
@@package/debug_format_impl.pkb


