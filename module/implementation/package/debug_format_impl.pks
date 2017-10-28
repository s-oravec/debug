create or replace package debug_format_impl as

    procedure set_colors (
        a_colors in debug_types.typ_Colors
    );

    function use_colors return boolean;

    function color_for_namespace (
        a_namespace in debug_types.typ_Namespace
    ) return debug_types.typ_Color;

    function format_line (
        a_namespace in debug_types.typ_Namespace,
        a_value     in debug_types.typ_LogValue,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    ) return varchar2;

end;
/
