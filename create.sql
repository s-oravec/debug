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
rem     environment   - development - more privileges required for development
rem                   - production  - production ready
rem
set verify off
define l_configuration = "&1"
define l_environment   = "&2"

rem Load package
@@package.sql

rem init SQL*Plus settings
@sqlplus_init.sql

prompt Create schemas
@@module/dba/create_&&l_configuration..sql

rem finalize SQL*Plus
@@sqlplus_finalize.sql

rem undefine script locals
undefine l_configuration
undefine l_environment

rem undefine package globals
@@undefine_globals.sql
