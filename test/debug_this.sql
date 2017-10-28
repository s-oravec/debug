begin
    debug_adm.debug_this;
    declare
        a debug := debug('api');
        b debug := debug('business');
    begin
        a.log('call');
        b.log('validating input');
        b.log('input is valid');
        b.log('applying business rule');
        b.log('commit');
        a.log('return');
    end;
end;
/
