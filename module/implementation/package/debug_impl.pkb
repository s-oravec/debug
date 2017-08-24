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

    g_filter  typ_Filter;
    g_session debug_session.id_debug_session%type;
    g_colors  typ_ColorsTable := typ_ColorsTable();

    type typ_Namespaces is table of typ_Namespace;
    g_enabled_namespaces    typ_Namespaces;

    ----------------------------------------------------------------------------
    function parse_namespaces(a_value in varchar2) return typ_Namespaces
    is
        l_result typ_Namespaces := typ_Namespaces();
    begin
        if a_value is not null then
            for idx in 1 .. nvl(length(regexp_replace(a_value, '[^,]')),0) + 1 loop
                l_result.extend();
                l_result(l_result.last) := replace(regexp_substr(a_value, '[^,]+', 1, idx), '*', '%');
            end loop;
        end if;
        return l_result;
    end;

    ----------------------------------------------------------------------------
    procedure init_impl (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors,
        a_session in debug_session.id_debug_session%type
    ) is
    begin
        g_session := a_session;
        g_filter  := a_filter;
        g_enabled_namespaces := parse_namespaces(a_filter);
        case a_colors
            when COLORS_16 then g_colors := gc_16_COLORS_TAB;
            when COLORS_256 then g_colors := gc_256_COLORS_TAB;
            else g_colors := typ_ColorsTable();
        end case;
    end;

    ----------------------------------------------------------------------------
    procedure init (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors
    ) is
    begin
        init_impl(a_filter, a_colors, null);
    end;

    ----------------------------------------------------------------------------
    function init_persistent (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors,
        a_session in debug_session.id_debug_session%type
    ) return debug_session.id_debug_session%type
    is
        pragma autonomous_transaction;
        l_result debug_session.id_debug_session%type;
        l_filter typ_Filter := a_filter;
        l_colors typ_Colors := a_colors;
    begin
        --
        begin
            if a_session is not null then
                select filter, colors, id_debug_session
                  into l_filter, l_colors, l_result
                  from debug_session
                 where id_debug_session = a_session;
            else
                insert into debug_session
                values (debug_session_id.nextval, a_filter, a_colors)
                returning id_debug_session, a_filter, a_colors into l_result, l_filter, l_colors;
            end if;
        exception
            when no_data_found then
                raise_application_error(-20000, 'Session with id ' || a_session || ' not found');
        end;
        --
        init_impl(l_filter, l_colors, l_result);
        commit;
        --
        return l_result;
        --
    exception
        when others then
            rollback;
            raise;
    end;

    ----------------------------------------------------------------------------
    function use_colors return boolean
    is
    begin
        return g_colors.count > 0;
    end;

    ----------------------------------------------------------------------------
    function to_binary_integer(a_value in integer) return binary_integer is
        -- for signed 32 bit integer
        MAX_POSITIVE constant pls_integer := power(2, 31) - 1;
        MIN_NEGATIVE constant pls_integer := - power(2, 31);
    begin
        if a_value between MIN_NEGATIVE and MAX_POSITIVE then
            return a_value;
        elsif a_value > MAX_POSITIVE then
            return to_binary_integer(MIN_NEGATIVE + (a_value - MAX_POSITIVE) - 1);
        elsif a_value < MIN_NEGATIVE then
            return to_binary_integer(MAX_POSITIVE + a_value - MIN_NEGATIVE + 1);
        else
            return null;
        end if;
    end;

    ----------------------------------------------------------------------------
    function fake_shl(a_value in pls_integer, a_positions in pls_integer) return pls_integer
    is
    begin
        -- just make it simple, doesn't have to be precise
        if nvl(a_value, 0) = 0 then
            return a_value;
        elsif sign(a_value) = 1 then
            return mod(cast(a_value as integer) * power(2, a_positions), power(2, 31) - 1);
        else
            return mod(cast(a_value as integer) * power(2, a_positions), power(2, 31));
        end if;
    end;

    ----------------------------------------------------------------------------
    function select_color(a_namespace in typ_Namespace) return typ_Color
    is
        l_hash pls_integer := 0;
    begin
        if not use_colors then
            return -1;
        else
            for l_idx in 1 .. length(a_namespace) loop
                l_hash := fake_shl(l_hash, 5) - l_hash + ascii(substr(a_namespace, l_idx, 1));
                -- convert to 32bit integer if overflows
                l_hash := to_binary_integer(l_hash);
            end loop;
            return g_colors(mod(abs(l_hash), g_colors.count) + 1);
        end if;
    end;

    ----------------------------------------------------------------------------
    procedure register_namespace (
        a_namespace in typ_Namespace
    ) is
    begin
        null;
    end;

    ----------------------------------------------------------------------------
    function is_enabled (
        a_namespace in typ_Namespace
    ) return typ_Boolean is
    begin
        for l_idx in 1 .. g_enabled_namespaces.count loop
            if a_namespace like g_enabled_namespaces(l_idx) then
                return BOOLEAN_TRUE;
            end if;
        end loop;
        return BOOLEAN_FALSE;
    end;

    ----------------------------------------------------------------------------
    function ternary_operator (
        boolean_expression in boolean,
        a_value_when_true    in varchar2,
        a_value_when_false   in varchar2
    ) return varchar2
    is
    begin
        if boolean_expression then
            return a_value_when_true;
        else
            return a_value_when_false;
        end if;
    end;

    ----------------------------------------------------------------------------
    function color_string (
        a_str   in varchar2,
        a_color in typ_Color
    ) return varchar2
    is
    begin
        if not use_colors then
            return a_str;
        else
            return chr(27) || '[3' || ternary_operator(a_color < 8, a_color, '8;5;' || a_color) || 'm'
                || a_str
                || chr(27) || '[0m';
        end if;
    end;

    ----------------------------------------------------------------------------
    function humanize (
        a_dsinterval interval day to second
    ) return varchar2
    is
    begin
        if a_dsinterval < numtodsinterval(1, 'second') / 1000 then
            return '+0ms';
        elsif a_dsinterval < numtodsinterval(1, 'second') then
            return '+' || (1000 * to_number('0.' || substr(regexp_substr(to_char(a_dsinterval), '[^\.]+', 1, 2), 1, 12))) || 'ms';
        elsif a_dsinterval < numtodsinterval(1, 'minute') then
            return '+' || ltrim(substr(regexp_substr(to_char(a_dsinterval), '[^:]+', 1, 3), 1, 6), '0') || 's';
        elsif a_dsinterval < numtodsinterval(1, 'hour') then
            return '+' || ltrim(substr(regexp_substr(to_char(a_dsinterval), '[^ ]+', 1, 2), 4, 7), '0') || 'min';
        else
            return '+' || ltrim(substr(regexp_substr(to_char(a_dsinterval), '[^ ]+', 1, 2), 1, 8),'0') || 'h';
        end if;
    end;

    ----------------------------------------------------------------------------
    procedure log_to_dbms_output (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_diff      in interval day to second
    ) is
    begin
        if use_colors then
            dbms_output.put_line(
                ' '
                || color_string(a_namespace, a_color)
                || ' '
                || a_value
                || ' '
                || color_string(humanize(a_diff), a_color)
            );
        else
            dbms_output.put_line(
                replace(to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SS.FF3'), ' ', 'T')
                || ' '
                || a_namespace
                || ' '
                || a_value
            );
        end if;
    end;

    ----------------------------------------------------------------------------
    procedure log_to_persistent_storage (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_diff      in interval day to second
    ) is
        pragma autonomous_transaction ;
    begin
        insert
          into debug_log
        values (
            debug_log_id.nextval,
            g_session,
            a_namespace,
            a_value,
            a_color,
            a_diff
        );
        commit;
    exception
        when others then
            rollback;
            raise;
    end;

    ----------------------------------------------------------------------------
    procedure log (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_diff      in interval day to second
    ) is
    begin
        if g_session is null then
            log_to_dbms_output(a_namespace, a_value, a_color, a_diff);
        else
            log_to_persistent_storage(a_namespace, a_value, a_color, a_diff);
        end if;
    end;

begin
    init(FILTER_DEFAULT, COLORS_NO);
end;
/