undefine l_colors
define l_colors = "&1"

set feedback on
prompt .. Setting colors. (colors="&&l_colors")
set feedback off

declare
    l_colors varchar2(255) := upper('&&l_colors') ||'_COLORS';
begin
    debug_format.set_colors(l_colors);
end;
/

set feedback on
prompt done
prompt

undefine l_colors