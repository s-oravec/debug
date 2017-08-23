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
        self.namespace := namespace;        
        self.enabled := debug_impl.is_enabled(namespace);
        return;
    end;

    ----------------------------------------------------------------------------
    member procedure log(
        value in varchar2
    ) is
    begin
        if self.enabled = debug_impl.BOOLEAN_TRUE then
           dbms_output.put_line(self.namespace || ' ' || value);
        end if;  
    end;

end;
/
