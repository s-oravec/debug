create or replace package debug_impl as

    -- admin methods
    function create_group (
        a_filter      in debug_types.typ_Filter default debug_types.ALL_NAMESPACES,
        a_description in debug_types.typ_Description default debug_types.DESCRIPTION_NONE
    ) return debug_types.typ_DebugGroupId;

    procedure drop_group (
        a_id_debug_group in debug_types.typ_DebugGroupId
    );

    procedure debug_this (
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_filter         in debug_types.typ_Filter default debug_types.ALL_NAMESPACES,
        a_colors         in debug_types.typ_Colors default debug_types.COLORS_NO
    );

    procedure debug_other (
        a_id_debug_group in debug_types.typ_DebugGroupId,
        a_sessionId      in debug_types.typ_SessionId,
        a_filter         in debug_types.typ_Filter default debug_types.ALL_NAMESPACES
    );

    procedure pause_debug (
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_sessionId      in debug_types.typ_SessionId default null
    );

    procedure resume_debug (
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_sessionId      in debug_types.typ_SessionId default null
    );

    procedure set_filter (
        a_filter         in debug_types.typ_Filter,
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_sessionId      in debug_types.typ_SessionId default null
    );

    procedure purge_log (
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_sessionId      in debug_types.typ_SessionId default null
    );

    function is_enabled (
        a_sessionId in debug_types.typ_SessionId,
        a_namespace in debug_types.typ_Namespace
    ) return debug_types.typ_CharBool;

    procedure log (
        a_namespace in debug_types.typ_Namespace,
        a_value     in debug_types.typ_LogValue,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    );

end;
/