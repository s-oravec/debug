rem
rem uninstall package
rem
rem Usage
rem     SQL > @uninstall.sql
rem
rem Load package
@@package.sql

prompt Uninstall package Implementation
@module/implementation/uninstall.sql

prompt Uninstall package API
@module/api/uninstall.sql

rem undefine package globals
@@undefine_globals.sql
