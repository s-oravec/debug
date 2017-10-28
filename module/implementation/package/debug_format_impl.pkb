create or replace package body debug_format_impl as

    type typ_ColorTable is table of debug_types.typ_Color;

    -- NoFormat Start
    gc_16_COLORS_TAB constant typ_ColorTable := typ_ColorTable (
        6, 2, 3, 4, 5, 1
    );
    gc_256_COLORS_TAB constant typ_ColorTable := typ_ColorTable(
        20, 21, 26, 27, 32, 33, 38, 39, 40, 41, 42, 43, 44, 45, 56, 57, 62, 63, 68,
        69, 74, 75, 76, 77, 78, 79, 80, 81, 92, 93, 98, 99, 112, 113, 128, 129, 134,
        135, 148, 149, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171,
        172, 173, 178, 179, 184, 185, 196, 197, 198, 199, 200, 201, 202, 203, 204,
        205, 206, 207, 208, 209, 214, 215, 220, 221
    );
    gc_NO_COLORS_TAB constant typ_ColorTable := typ_ColorTable();    
    -- NoFormat End
    
    g_color_table  typ_ColorTable;

    type typ_NamespaceToColorMap is table of debug_types.typ_Color index by debug_types.typ_Namespace;
    g_namespace_to_color_cache typ_NamespaceToColorMap;

    -- set colors
    ----------------------------------------------------------------------------
    procedure set_colors (
        a_colors in debug_types.typ_Colors
    ) is
    begin
        -- delete cache 
        g_namespace_to_color_cache.delete();
        -- assign color table
        case a_colors
            when debug_types.COLORS_16 then
                g_color_table := gc_16_COLORS_TAB;
            when debug_types.COLORS_256 then
                g_color_table := gc_256_COLORS_TAB;
            else
                g_color_table := gc_NO_COLORS_TAB;
        end case;
    end;

    -- hides this ugliness
    ----------------------------------------------------------------------------
    function use_colors return boolean
    is
    begin
        return g_color_table.count > 0;
    end;

    -- hash namespace value to color from colors colorspace
    ----------------------------------------------------------------------------
    function color_for_namespace_impl(a_namespace in debug_types.typ_Namespace) return debug_types.typ_Color
    is
        l_hash pls_integer := 0;
    begin
        if not use_colors then
            return null;
        else
            for l_idx in 1 .. length(a_namespace) loop
                -- compute hash
                l_hash := debug_util.fake_shl(l_hash, 5) - l_hash + ascii(substr(a_namespace, l_idx, 1));
                -- convert to 32bit integer if overflows
                l_hash := debug_util.to_binary_integer(l_hash);
            end loop;
            return g_color_table(mod(abs(l_hash), g_color_table.count) + 1);
        end if;
    end;

    -- cache value if not cached and return cached
    ----------------------------------------------------------------------------
    function color_for_namespace(a_namespace in debug_types.typ_Namespace) return debug_types.typ_Color
    is
    begin
        if not g_namespace_to_color_cache.exists(a_namespace) then
            g_namespace_to_color_cache(a_namespace) := color_for_namespace_impl(a_namespace);
        end if;
        return g_namespace_to_color_cache(a_namespace);
    end;

    ----------------------------------------------------------------------------
    function format_line (
        a_namespace in debug_types.typ_Namespace,
        a_value     in debug_types.typ_LogValue,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    ) return varchar2
    is
        l_color debug_types.typ_Color;
    begin
        if use_colors then
            l_color := color_for_namespace(a_namespace);
            return
                ' '
                || debug_util.color_string(a_namespace, l_color)
                || ' '
                || a_value
                || ' '
                || debug_util.color_string(debug_util.humanize(a_diff), l_color)
            ;
        else
            return
                replace(to_char(a_this_tick, 'YYYY-MM-DD HH24:MI:SS.FF3'), ' ', 'T')
                || ' '
                || a_namespace
                || ' '
                || a_value
            ;
        end if;
    end;

begin
    g_color_table := gc_NO_COLORS_TAB;
end;
/
