set feedback on

prompt |
prompt | Debug package scripts
prompt |
prompt | - list_groups  - List created groups.
prompt |
prompt | - create_group - Asks for namespace filter and creates debug group.
prompt |                  Identifier of new debug group is stored in id_debug_group substitution variable
prompt |                  and spooled into l_id_debug_group.sql file (in the SQL Path)
prompt |
prompt | - drop_group   - Asks for debug group to drop and drops it.
prompt |                  This effectively stops watching of the debug group and delete log records.
prompt |
prompt | - debug_this   - Adds current session to debug group, or spools debug directly after each call.
prompt |                  You can set namespace filter and colors.
prompt |
prompt | - debug_other  - Adds other session to debug group with optional namespace filter.
prompt |
prompt | - pause_debug  - Pauses debug for session and/or debug group.
prompt |
prompt | - resume_debug - Resumes debug for session and/or debug group.
prompt |
prompt | - set_filter   - Sets new namespace filter for the session and/or debug group.
prompt |
prompt | - purge_log    - Purges log for session and/or debug group.
prompt |
prompt | - set_colors   - Sets colors for output.
prompt |
