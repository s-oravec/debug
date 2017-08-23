accept l_schema_name prompt "Pete schema [&&g_schema_name] : " default "&&g_schema_name"

@@drop_implementation.sql

undefine l_schema_name