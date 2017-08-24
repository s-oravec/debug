create or replace type body debug is

    ----------------------------------------------------------------------------
    static procedure init (
        filter  in varchar2 default '*',
        colors  in varchar2 default '16_COLORS'
    ) is
    begin
        debug_impl.init(filter, colors);
    end;

    ----------------------------------------------------------------------------
    static function init_persistent (
        filter  in varchar2 default '*',         -- debug_api.ALL_NAMESPACES
        colors  in varchar2 default '16_COLORS', -- debug_api.COLORS_16
        session in integer default null
    ) return integer
    is
    begin
        return debug_impl.init_persistent(filter, colors, session);
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
            debug_impl.log(self.namespace, value, self.color, self.diff);
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
