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
    g_colors_table  typ_ColorsTable := typ_ColorsTable();

    g_filter  typ_Filter;
    g_colors  typ_Colors;
    g_session debug_session.id_debug_session%type;

    type typ_Filters is table of typ_Filter;
    g_enabled_filters    typ_Filters;

    type typ_DebugObjects is table of debug;
    g_registered_debug_objects typ_DebugObjects := typ_DebugObjects();


    -- disables all debug objects
    ----------------------------------------------------------------------------
    procedure disable_debug_objects is
    begin
        for idx in 1 .. g_registered_debug_objects.count loop
            g_registered_debug_objects(idx).disable;
        end loop;
    end;

    -- enables debug objects which namespace matches filter
    ----------------------------------------------------------------------------
    procedure enable_debug_objects_matching(a_filter in typ_Filter)
    is
    begin
        for idx in 1 .. g_registered_debug_objects.count loop
            if g_registered_debug_objects(idx).namespace like a_filter then
                g_registered_debug_objects(idx).enable;
            end if;
        end loop;
    end;

    -- parse filter and apply new settings on registered debug objects
    ----------------------------------------------------------------------------
    procedure parse_and_apply_filter(a_filter in typ_Filter)
    is
    begin
        -- reset settings
        g_enabled_filters := typ_Filters();
        disable_debug_objects;
        -- parse and apply new
        if a_filter is not null then
            for idx in 1 .. nvl(length(regexp_replace(a_filter, '[^,]')),0) + 1 loop
                -- append
                g_enabled_filters.extend();
                g_enabled_filters(g_enabled_filters.last) := replace(regexp_substr(a_filter, '[^,]+', 1, idx), '*', '%');
                -- apply
                if g_registered_debug_objects.count > 0 then
                    enable_debug_objects_matching(g_enabled_filters(g_enabled_filters.last));
                end if;
            end loop;
        end if;
    end;

    -- init implementation
    ----------------------------------------------------------------------------
    procedure init_impl (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors,
        a_session in debug_session.id_debug_session%type
    ) is
    begin
        --
        g_filter  := a_filter;
        g_colors  := a_colors;
        g_session := a_session;
        --
        case a_colors
            when COLORS_16 then g_colors_table := gc_16_COLORS_TAB;
            when COLORS_256 then g_colors_table := gc_256_COLORS_TAB;
            else g_colors_table := typ_ColorsTable();
        end case;
        --
        g_registered_debug_objects := typ_DebugObjects();
        parse_and_apply_filter(a_filter);
        --
    end;

    -- init for use within session initializing
    ----------------------------------------------------------------------------
    procedure init_session (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors
    ) is
        l_filter typ_Filter := nvl(a_filter, FILTER_ALL_NAMESPACES);
        l_colors typ_Colors := nvl(a_colors, COLORS_256);
    begin
        init_impl(l_filter, l_colors, null);
    end;

    -- multisession use requires persistence
    ----------------------------------------------------------------------------
    function init_persistent (
        a_filter  in typ_Filter,
        a_colors  in typ_Colors
    ) return debug_session.id_debug_session%type
    is
        pragma autonomous_transaction;
        l_result debug_session.id_debug_session%type;
        l_filter typ_Filter := nvl(a_filter, FILTER_ALL_NAMESPACES);
        l_colors typ_Colors := nvl(a_colors, COLORS_256);
    begin
        --
        insert into debug_session
        values (debug_session_id.nextval, l_filter, l_colors)
        returning id_debug_session into l_result;
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

    -- join existing persistent debug session > init this with existing values
    ----------------------------------------------------------------------------
    procedure join_persistent (
        a_id_debug_session in debug_session.id_debug_session%type
    ) is
        l_filter typ_Filter;
        l_colors typ_Colors;
    begin
        select filter, colors
          into l_filter, l_colors
          from debug_session
         where id_debug_session = a_id_debug_session;
        init_impl(l_filter, l_colors, a_id_debug_session);
    end;

    -- change filter after init
    -- either in this session or specified persistent session
    ----------------------------------------------------------------------------
    procedure set_filter (
        a_filter           in typ_Filter,
        a_id_debug_session in debug_session.id_debug_session%type default null
    ) is
        pragma autonomous_transaction;
    begin
        parse_and_apply_filter(a_filter);
        if a_id_debug_session is not null then
            update debug_session
               set filter = a_filter
             where id_debug_session = a_id_debug_session;
        end if;
        commit;
    exception
        when others then
            rollback;
            raise;
    end;

    -- hides this ugliness
    ----------------------------------------------------------------------------
    function use_colors return boolean
    is
    begin
        return g_colors_table.count > 0;
    end;

    -- convert integer to signed 32bit integer = binary_integer
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

    -- supersimplified shift left operator
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

    -- hash namespace value to color from colors colorspace
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
            return g_colors_table(mod(abs(l_hash), g_colors_table.count) + 1);
        end if;
    end;

    -- register
    ----------------------------------------------------------------------------
    procedure register_debug_object (
        a_debug in debug
    ) is
    begin
        g_registered_debug_objects.extend();
        g_registered_debug_objects(g_registered_debug_objects.last) := a_debug;
    end;

    -- checks enabled filters
    ----------------------------------------------------------------------------
    function is_enabled (
        a_namespace in typ_Namespace
    ) return typ_CharBool is
    begin
        for l_idx in 1 .. g_enabled_filters.count loop
            if a_namespace like g_enabled_filters(l_idx) then
                return CHARBOOL_TRUE;
            end if;
        end loop;
        return CHARBOOL_FALSE;
    end;

    -- ternary operator (as seen elsewhere ...) - for varchar2
    -- no special null treatment of of a_boolean_expression
    ----------------------------------------------------------------------------
    function ternary_operator (
        a_boolean_expression in boolean,
        a_value_when_true    in varchar2,
        a_value_when_false   in varchar2
    ) return varchar2
    is
    begin
        if a_boolean_expression then
            return a_value_when_true;
        else
            return a_value_when_false;
        end if;
    end;

    -- apply color to string
    ----------------------------------------------------------------------------
    function apply_color (
        a_string in varchar2,
        a_color  in typ_Color
    ) return varchar2
    is
    begin
        if not use_colors then
            return a_string;
        else
            return chr(27) || '[3' || ternary_operator(a_color < 8, a_color, '8;5;' || a_color) || 'm'
                || a_string
                || chr(27) || '[0m';
        end if;
    end;

    -- humanize day to second inteerval
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

    -- save message to dbms_output
    ----------------------------------------------------------------------------
    procedure log_to_dbms_output (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    ) is
    begin
        if use_colors then
            dbms_output.put_line(
                ' '
                || apply_color(a_namespace, a_color)
                || ' '
                || a_value
                || ' '
                || apply_color(humanize(a_diff), a_color)
            );
        else
            dbms_output.put_line(
                replace(to_char(a_this_tick, 'YYYY-MM-DD HH24:MI:SS.FF3'), ' ', 'T')
                || ' '
                || a_namespace
                || ' '
                || a_value
            );
        end if;
    end;

    -- save message to persistent storage
    ----------------------------------------------------------------------------
    procedure log_to_persistent_storage (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_this_tick in timestamp,
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
            a_this_tick,
            a_diff
        );
        commit;
    exception
        when others then
            rollback;
            raise;
    end;

    -- log messege depending on session - either to table or to dbms_output
    ----------------------------------------------------------------------------
    procedure log (
        a_namespace in typ_Namespace,
        a_value     in varchar2,
        a_color     in typ_Color,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    ) is
    begin
        if g_session is null then
            log_to_dbms_output(a_namespace, a_value, a_color, a_this_tick, a_diff);
        else
            log_to_persistent_storage(a_namespace, a_value, a_color, a_this_tick, a_diff);
        end if;
    end;

end;
/