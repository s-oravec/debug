rem Tables
prompt .. Dropping table DEBUG_GROUP
drop table debug_group cascade constraints;

prompt .. Dropping table DEBUG_LOG
drop table debug_log cascade constraints;

prompt .. Dropping table DEBUG_SESSION
drop table debug_session cascade constraints;

rem Sequences
prompt .. Dropping sequence DEBUG_GROUP_ID
drop sequence debug_group_id;

prompt .. Dropping sequence DEBUG_SESSION_ID
drop sequence debug_session_id;

prompt .. Dropping sequence DEBUG_LOG_ID
drop sequence debug_log_id;

rem Code
prompt .. Dropping package DEBUG_TYPES
drop package debug_types;

prompt .. Dropping package DEBUG_UTIL
drop package debug_util;

prompt .. Dropping package DEBUG_IMPL
drop package debug_impl;

prompt .. Dropping package debug_format_IMPL
drop package debug_format_impl;


