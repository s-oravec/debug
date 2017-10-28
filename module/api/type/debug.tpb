create or replace type body debug is

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
        self.this_tick := systimestamp;
        self.prev_tick := systimestamp;
        --
        return;
    end;

    ----------------------------------------------------------------------------
    member procedure log(
        value in varchar2
    ) is
        l_diff interval day (9) to second (6);
    begin
        if debug_impl.is_enabled(sys_context('userEnv','sessionId'), self.namespace) = debug_types.CHARBOOL_TRUE then
            self.this_tick := systimestamp;
            l_diff := self.this_tick - self.prev_tick;
            self.prev_tick := self.this_tick;
            debug_impl.log(self.namespace, value, self.this_tick, l_diff);
        end if;
    end;

    ----------------------------------------------------------------------------
    member function is_enabled return varchar2
    is
    begin
        return debug_impl.is_enabled(sys_context('userEnv','sessionId'), self.namespace);
    end;

end;
/
