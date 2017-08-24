create or replace package body debug_impl as

    gc_DUMMY constant pls_integer := 1;

    type typ_ColorsTable is table of pls_integer;

    -- NoFormat Start
    gc_16_COLORS_TAB constant typ_ColorsTable :=
    typ_ColorsTable(
        6, 2, 3, 4, 5, 1
    );
    gc_256_COLORS_TAB constant typ_ColorsTable :=
    typ_ColorsTable(
        20, 21, 26, 27, 32, 33, 38, 39, 40, 41, 42, 43, 44, 45, 56, 57, 62, 63, 68,
        69, 74, 75, 76, 77, 78, 79, 80, 81, 92, 93, 98, 99, 112, 113, 128, 129, 134,
        135, 148, 149, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171,
        172, 173, 178, 179, 184, 185, 196, 197, 198, 199, 200, 201, 202, 203, 204,
        205, 206, 207, 208, 209, 214, 215, 220, 221
    );
    -- NoFormat End

    g_filter debug_impl.typ_Filter;
    g_colors typ_ColorsTable := typ_ColorsTable();

    type typ_Namespaces is table of debug_impl.typ_Namespace;
    g_enabled_namespaces    typ_Namespaces;

    ----------------------------------------------------------------------------
    function parse_namespaces(value in varchar2) return typ_Namespaces
    is
        l_result typ_Namespaces := typ_Namespaces();
    begin
        if value is not null then
            for idx in 1 .. nvl(length(regexp_replace(value, '[^,]')),0) + 1 loop
                l_result.extend();
                l_result(l_result.last) := replace(regexp_substr(value, '[^,]+', 1, idx), '*', '%');
            end loop;
        end if;
        return l_result;
    end;

    ----------------------------------------------------------------------------
    procedure init (
        filter in varchar2,
        colors in varchar2
    ) is
    begin
        g_filter := filter;
        g_enabled_namespaces := parse_namespaces(filter);
        if colors = COLORS_NO then
            g_colors := typ_ColorsTable();
        elsif colors = COLORS_16 then
            g_colors := gc_16_COLORS_TAB;
        elsif colors = COLORS_256 then
            g_colors := gc_256_COLORS_TAB;
        end if;
    end;

    ----------------------------------------------------------------------------
    function use_colors return boolean
    is
    begin
        return g_colors.count > 0;
    end;

    ----------------------------------------------------------------------------
    function to_binary_integer(value in integer) return binary_integer is
        -- for signed 32 bit integer
        max_positive constant pls_integer := power(2, 31) - 1;
        min_negative constant pls_integer := - power(2, 31);
    begin
        if value between min_negative and max_positive then
            return value;
        elsif value > max_positive then
            return to_binary_integer(min_negative + (value - max_positive) - 1);
        elsif value < min_negative then
            return to_binary_integer(max_positive + value - min_negative + 1);
        else
            return null;
        end if;
    end;

    ----------------------------------------------------------------------------
    function fake_shl(value in pls_integer, positions in pls_integer) return pls_integer
    is
    begin
        -- just make it simple, doesn't have to be precise
        if nvl(value, 0) = 0 then
            return value;
        elsif sign(value) = 1 then
            return mod(cast(value as integer) * power(2, positions), power(2, 31) - 1);
        else
            return mod(cast(value as integer) * power(2, positions), power(2, 31));
        end if;
    end;

    ----------------------------------------------------------------------------
    function select_color(namespace in varchar2) return pls_integer
    is
        hash pls_integer := 0;
    begin
        if not use_colors then
            return -1;
        else
            for idx in 1 .. length(namespace) loop
                hash := fake_shl(hash, 5) - hash + ascii(substr(namespace, idx, 1));
                -- convert to 32bit integer if overflows
                hash := to_binary_integer(hash);
            end loop;
            return g_colors(mod(abs(hash), g_colors.count) + 1);
        end if;
    end;

    ----------------------------------------------------------------------------
    procedure register_namespace (
        namespace in varchar2
    ) is
    begin
        null;
    end;

    ----------------------------------------------------------------------------
    function is_enabled (
        namespace in varchar2
    ) return typ_Boolean is
    begin
        for idx in 1 .. g_enabled_namespaces.count loop
            if namespace like g_enabled_namespaces(idx) then
                return debug_impl.BOOLEAN_TRUE;
            end if;
        end loop;
        return debug_impl.BOOLEAN_FALSE;
    end;

    ----------------------------------------------------------------------------
    function ternary_operator (
        boolean_expression in boolean,
        value_when_true    in varchar2,
        value_when_false   in varchar2
    ) return varchar2
    is
    begin
        if boolean_expression then
            return value_when_true;
        else
            return value_when_false;
        end if;
    end;

    ----------------------------------------------------------------------------
    function color_string (
        str   in varchar2,
        color in pls_integer
    ) return varchar2
    is
    begin
        if not use_colors then
            return str;
        else
            return chr(27) || '[3' || ternary_operator(color < 8, color, '8;5;' || color) || 'm'
                || str
                || chr(27) || '[0m';
        end if;
    end;

    ----------------------------------------------------------------------------
    function humanize (
        dsinterval interval day to second
    ) return varchar2
    is
    begin
        if dsinterval < numtodsinterval(1, 'second') / 1000 then
            return '+0ms';
        elsif dsinterval < numtodsinterval(1, 'second') then
            return '+' || (1000 * to_number('0.' || substr(regexp_substr(to_char(dsinterval), '[^\.]+', 1, 2), 1, 12))) || 'ms';
        elsif dsinterval < numtodsinterval(1, 'minute') then
            return '+' || ltrim(substr(regexp_substr(to_char(dsinterval), '[^:]+', 1, 3), 1, 6), '0') || 's';
        elsif dsinterval < numtodsinterval(1, 'hour') then
            return '+' || ltrim(substr(regexp_substr(to_char(dsinterval), '[^ ]+', 1, 2), 4, 7), '0') || 'min';
        else
            return '+' || ltrim(substr(regexp_substr(to_char(dsinterval), '[^ ]+', 1, 2), 1, 8),'0') || 'h';
        end if;
    end;

begin
    init(debug_impl.FILTER_DEFAULT, debug_impl.COLORS_NO);
end;
/