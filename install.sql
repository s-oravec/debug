rem
rem install package
rem
rem Usage
rem     SQL > @install.sql <privileges>
rem
rem Options
rem
rem     privileges - public - installs package and grants API to public
rem                - peer   - installs package and grants API to peers - use whitelist grants
rem
set verify off
define l_privileges = "&1"

rem Load package
@@package.sql

prompt Installing package Implementation
@module/implementation/install.sql

prompt Installing package API
@module/api/install.sql

prompt Granting privileges on package API
@module/api/grant_&&l_privileges..sql

show error

rem undefine locals
undefine l_privileges

rem undefine package globals
@@undefine_globals.sql
