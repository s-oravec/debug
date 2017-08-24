create or replace type body debug is

    ----------------------------------------------------------------------------
    static procedure init(
        filter in varchar2 default '*',
        colors in varchar2 default '16_COLORS'
    ) is
    begin
        debug_impl.init(filter, colors);
    end;

    ----------------------------------------------------------------------------
    constructor function debug(
        namespace in varchar2
    ) return self as result is
    begin
        --
        if regexp_like(namespace, '%|\*|\\|,') then
            raise_application_error(-20000, 'Invalid characters in namespace name. "%*\"');
        end if;
        --
        self.namespace := namespace;
        --
        debug_impl.register_namespace(namespace);
        --
        self.color     := debug_impl.select_color(namespace);
        self.enabled   := debug_impl.is_enabled(namespace);
        self.prev_tick := systimestamp;
        --
        return;
    end;

    ----------------------------------------------------------------------------
    member procedure log(
        value in varchar2
    ) is
    begin
        if self.enabled = debug_impl.BOOLEAN_TRUE then
            if debug_impl.use_colors then
                dbms_output.put_line(
                    ' '
                    || debug_impl.color_string(self.namespace, self.color)
                    || ' '
                    || value
                    || ' '
                    || debug_impl.color_string(debug_impl.humanize(self.diff), self.color)
                );
            else
                dbms_output.put_line(
                    replace(to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SS.FF3'), ' ', 'T')
                    || ' '
                    || self.namespace
                    || ' '
                    || value
                );
            end if;
        end if;
    end;

    ----------------------------------------------------------------------------
    member function diff(self in out nocopy debug) return interval day to second
    is
        now    timestamp := systimestamp;
        result interval day (9) to second (6);
    begin
        result := now - self.prev_tick;
        self.prev_tick := now;
        return result;
    end;

end;
/
