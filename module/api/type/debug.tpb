create or replace type body debug is

    ----------------------------------------------------------------------------
    static procedure init_session (
        filter  in varchar2,
        colors  in varchar2
    ) is
    begin
        debug_impl.init_session(filter, colors);
    end;

    ----------------------------------------------------------------------------
    static function init_persistent (
        filter  in varchar2,
        colors  in varchar2
    ) return integer
    is
    begin
        return debug_impl.init_persistent(filter, colors);
    end;

    ----------------------------------------------------------------------------
    static procedure join_persistent (
        session in integer
    )
    is
    begin
        debug_impl.join_persistent(session);
    end;

    ----------------------------------------------------------------------------
    static procedure set_filter (
        filter  in varchar2,
        session in integer
    ) is
    begin
        debug_impl.set_filter(filter, session);
    end;

    ----------------------------------------------------------------------------
    constructor function debug(
        namespace in varchar2
    ) return self as result is
    begin
        -- validate namespace
        if regexp_like(namespace, '%|\*|\\|,') then
            raise_application_error(-20000, 'Invalid characters in namespace name. "%*\"');
        end if;
        -- set attributes
        self.namespace := namespace;
        self.color     := debug_impl.select_color(namespace);
        self.enabled   := debug_impl.is_enabled(namespace);
        self.this_tick := systimestamp;
        self.prev_tick := systimestamp;
        -- register
        debug_impl.register_debug_object(self);
        --
        return;
    end;

    ----------------------------------------------------------------------------
    member procedure log(
        value in varchar2
    ) is
        l_diff interval day (9) to second (6);
    begin
        if self.enabled = debug_impl.CHARBOOL_TRUE then
            self.this_tick := systimestamp;
            l_diff := self.this_tick - self.prev_tick;
            self.prev_tick := self.this_tick;
            debug_impl.log(self.namespace, value, self.color, self.this_tick, l_diff);
        end if;
    end;

    ----------------------------------------------------------------------------
    member procedure enable(self in out debug) is
    begin
        self.enabled := debug_impl.CHARBOOL_TRUE;
    end;

    ----------------------------------------------------------------------------
    member procedure disable(self in out debug) is
    begin
        self.enabled := debug_impl.CHARBOOL_FALSE;
    end;


end;
/
