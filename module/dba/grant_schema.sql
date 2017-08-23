define l_schema_name = &1

prompt .. Granting privileges to package &&g_package_name in schema &&l_schema_name

prompt .. Granting CREATE PROCEDURE to &&l_schema_name
grant create procedure to &&l_schema_name;

undefine l_schema_name
