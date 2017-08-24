create or replace package debug_impl as

    subtype typ_Boolean is varchar2 (1);
    BOOLEAN_TRUE  constant typ_Boolean := 'Y';
    BOOLEAN_FALSE constant typ_Boolean := 'N';

    subtype typ_Colors is varchar2(30);
    subtype typ_Color  is pls_integer;

    COLORS_NO  constant typ_Colors := 'NO';
    COLORS_16  constant typ_Colors := '16_COLORS';
    COLORS_256 constant typ_Colors := '256_COLORS';

    subtype typ_Filter is varchar2(4000);

    FILTER_ALL_NAMESPACES constant typ_Filter := '*';
    FILTER_DEFAULT constant typ_Filter := '';

    subtype typ_Namespace is varchar2(4000);

    procedure init (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors
    );

    function init_persistent (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors,
        a_session in debug_session.id_debug_session%type
    ) return debug_session.id_debug_session%type;

    function use_colors return boolean;

    procedure register_namespace (
        a_namespace in typ_Namespace
    );

    function is_enabled (
        a_namespace in typ_Namespace
    ) return typ_Boolean;

    function select_color(a_namespace in typ_Namespace) return typ_Color;

    function color_string (
        a_str   in varchar2,
        a_color in typ_Color
    ) return varchar2;

    procedure log (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_diff      in interval day to second
    );

end;
/