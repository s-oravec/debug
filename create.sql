rem
rem Creates package schema/schemas
rem
rem Usage
rem     SQL > @create.sql <configuration>
rem
rem Options
rem
rem     configuration - manual     - asks for configuration parameters
rem                   - configured - supplied configuration is used
rem
set verify off
define l_configuration = "&1"

rem Load package
@@package.sql

prompt Create schemas
@@module/dba/create_&&l_configuration..sql

rem undefine script locals
undefine l_configuration

rem undefine package globals
@@undefine_globals.sql
