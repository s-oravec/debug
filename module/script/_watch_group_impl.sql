undefine l_id_debug_group
define l_id_debug_group = "&1"

set feedback on
prompt .. Watching debug group. (debug_group="&&l_id_debug_group")
prompt

script watch_group.js &&l_id_debug_group

undefine l_id_debug_group
