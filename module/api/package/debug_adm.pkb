create or replace package body debug_adm as

    ----------------------------------------------------------------------------
    function create_group (
        filter      in filter_type default ALL_NAMESPACES,
        description in description_type default DESCRIPTION_NONE
    ) return debug_group_identifier_type is
    begin
        return debug_impl.create_group(filter, description);
    end;

    ----------------------------------------------------------------------------
    procedure drop_group (
        debug_group in debug_group_identifier_type
    ) is
    begin
        debug_impl.drop_group(debug_group);
    end;

    ----------------------------------------------------------------------------
    function group_exists (debug_group in debug_group_identifier_type) return charbool_type is
    begin
        for grp in (select * from debug_group where id_debug_group = debug_group) loop
            return charbool_true;
        end loop;
        return charbool_false;
    end;

    ----------------------------------------------------------------------------
    procedure debug_this (
        debug_group in debug_group_identifier_type default null,
        filter      in filter_type default ALL_NAMESPACES,
        colors      in debug_format.colors_type default debug_format.COLORS_NO
    ) is
    begin
        debug_impl.debug_this(debug_group, filter, colors);
    end;

    ----------------------------------------------------------------------------
    procedure debug_other (
        debug_group in debug_group_identifier_type,
        sessionId   in integer,
        filter      in filter_type default ALL_NAMESPACES
    ) is
    begin
        debug_impl.debug_other(debug_group, sessionId, filter);
    end;

    ----------------------------------------------------------------------------
    procedure pause_debug (
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    ) is
    begin
        debug_impl.pause_debug(debug_group, sessionId);
    end;

    ----------------------------------------------------------------------------
    procedure resume_debug (
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    ) is
    begin
        debug_impl.resume_debug(debug_group, sessionId);
    end;

    ----------------------------------------------------------------------------
    procedure set_filter (
        filter      in filter_type,
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    ) is
    begin
        debug_impl.set_filter(filter, debug_group, sessionId);
    end;

    ----------------------------------------------------------------------------
    procedure purge_log (
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    ) is
    begin
        debug_impl.set_filter(debug_group, sessionId);
    end;

end;
/