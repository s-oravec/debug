create or replace package debug_util as

    function humanize (
        a_dsinterval interval day to second
    ) return varchar2;

    function color_string (
        a_string in varchar2,
        a_color  in debug_types.typ_Color
    ) return varchar2;

    function fake_shl(a_value in pls_integer, a_positions in pls_integer) return pls_integer;

    function to_binary_integer(a_value in integer) return binary_integer;

end;
/