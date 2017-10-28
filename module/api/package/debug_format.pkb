create or replace package body debug_format as

    ----------------------------------------------------------------------------
    procedure set_colors (
        colors in colors_type
    ) is
    begin
        debug_format_impl.set_colors(colors);
    end;

    ----------------------------------------------------------------------------
    function use_colors return boolean is
    begin
        return debug_format_impl.use_colors;
    end;

    ----------------------------------------------------------------------------
    function color_for_namespace (
        namespace in namespace_type
    ) return color_type is
    begin
        return debug_format_impl.color_for_namespace(namespace);
    end;

    ----------------------------------------------------------------------------
    function get_debug_lines(
        last_id_debug_log in debug_log_identifier_type,
        debug_group       in debug_group_identifier_type default null,
        row_count         in pls_integer default DEFAULT_ROW_COUNT
    ) return debug_lines pipelined is
    begin
        for l_row in (select *
                        from debug_log
                       where 1 = 1
                         and id_debug_group = debug_group
                         and id_debug_log > last_id_debug_log
                       order by id_debug_log
                       fetch first row_count rows only)
        loop
            pipe row (
                debug_line(
                    l_row.id_debug_log,
                    debug_format_impl.format_line(
                        l_row.namespace,
                        l_row.value,
                        l_row.ts_created,
                        l_row.diff
                    )
                )
            );
        end loop;
    end;

    ----------------------------------------------------------------------------
    function get_debug_records(
        last_id_debug_log in debug_log_identifier_type,
        debug_group       in debug_group_identifier_type default null,
        row_count         in pls_integer default DEFAULT_ROW_COUNT
    ) return debug_records pipelined is
    begin
        for l_row in (select *
                        from debug_log
                       where 1 = 1
                         and id_debug_group = debug_group
                         and id_debug_log > last_id_debug_log
                       order by id_debug_log
                       fetch first row_count rows only)
        loop
            pipe row (
                debug_record(
                    l_row.id_debug_log,
                    l_row.id_debug_group,
                    l_row.id_debug_session,
                    l_row.namespace,
                    l_row.value,
                    l_row.ts_created,
                    l_row.diff
                )
            );
        end loop;
    end;

end;
/