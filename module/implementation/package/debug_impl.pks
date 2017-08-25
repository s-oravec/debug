create or replace package debug_impl as

    subtype typ_CharBool is varchar2 (1);
    CHARBOOL_TRUE  constant typ_CharBool := 'Y';
    CHARBOOL_FALSE constant typ_CharBool := 'N';

    subtype typ_Colors is varchar2(30);
    subtype typ_Color  is pls_integer;

    COLORS_NO  constant typ_Colors := 'NO_COLORS';
    COLORS_16  constant typ_Colors := '16_COLORS';
    COLORS_256 constant typ_Colors := '256_COLORS';

    subtype typ_Filter is varchar2(4000);

    FILTER_ALL_NAMESPACES constant typ_Filter := '*';
    FILTER_DEFAULT constant typ_Filter := '';

    subtype typ_Namespace is varchar2(4000);

    procedure init_session (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors
    );

    function init_persistent (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors
    ) return debug_session.id_debug_session%type;

    procedure join_persistent (
        a_id_debug_session in debug_session.id_debug_session%type
    );

    procedure set_filter (
        a_filter           in typ_Filter,
        a_id_debug_session in debug_session.id_debug_session%type default null
    );

    procedure register_debug_object (
        a_debug in debug
    );

    function is_enabled (
        a_namespace in typ_Namespace
    ) return typ_CharBool;

    function select_color(a_namespace in typ_Namespace) return typ_Color;

    procedure log (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    );

end;
/