create or replace package debug_impl as

    subtype typ_Boolean is varchar2 (1);
    BOOLEAN_TRUE  constant typ_Boolean := 'Y';
    BOOLEAN_FALSE constant typ_Boolean := 'N';

    subtype typ_Colors is varchar2(30);

    COLORS_NO  constant typ_Colors := 'NO';
    COLORS_16  constant typ_Colors := '16_COLORS';
    COLORS_256 constant typ_Colors := '256_COLORS';

    subtype typ_Filter is varchar2(4000);

    FILTER_ALL_NAMESPACES constant typ_Filter := '*';
    FILTER_DEFAULT constant typ_Filter := '';

    subtype typ_Namespace is varchar2(4000);

    procedure init (
        filter in varchar2,
        colors in varchar2
    );

    function use_colors return boolean;

    procedure register_namespace (
        namespace in varchar2
    );

    function is_enabled (
        namespace in varchar2
    ) return typ_Boolean;

    function select_color(namespace in varchar2) return pls_integer;

    function color_string (
        str   in varchar2,
        color in pls_integer
    ) return varchar2;

    function humanize (
        dsinterval interval day to second
    ) return varchar2;

end;
/