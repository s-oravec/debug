create or replace package body debug_impl as

    type typ_Colors is table of pls_integer;
    -- NoFormat Start
    gc_16_COLORS_TAB constant typ_Colors :=
    typ_Colors(
        6, 2, 3, 4, 5, 1
    );
    gc_256_COLORS_TAB constant typ_Colors :=
    typ_Colors(
        20, 21, 26, 27, 32, 33, 38, 39, 40, 41, 42, 43, 44, 45, 56, 57, 62, 63, 68,
        69, 74, 75, 76, 77, 78, 79, 80, 81, 92, 93, 98, 99, 112, 113, 128, 129, 134,
        135, 148, 149, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171,
        172, 173, 178, 179, 184, 185, 196, 197, 198, 199, 200, 201, 202, 203, 204,
        205, 206, 207, 208, 209, 214, 215, 220, 221
    );
    -- NoFormat End

    g_filter debug_api.typ_Filter;

    type typ_Namespaces is table of pls_integer index by debug_api.typ_Filter;
    g_namespaces typ_Namespaces;

    ----------------------------------------------------------------------------
    procedure init (
      filter in varchar2,
      colors in varchar2
    ) is
    begin
        g_filter := filter;
        -- TODO: parse filter and append namespaces to g_namespaces
        g_namespaces('worker1') := 1;
    end;

    ----------------------------------------------------------------------------
    function is_enabled (
        namespace in varchar2
    ) return typ_Boolean is
    begin
        if g_filter = debug_api.ALL_NAMESPACES then
            return debug_impl.BOOLEAN_TRUE;
        else
            if g_namespaces.exists(namespace) then
                return debug_impl.BOOLEAN_TRUE;
            else
                return debug_impl.BOOLEAN_FALSE;
            end if;
        end if;
    end;

begin
    null;
end;
/