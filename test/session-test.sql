set serveroutput on size unlimited
set verify off

set feedback on
prompt .. Running test in debug mode
set feedback off

declare
  s1 debug := new debug('api');
  b1 debug := new debug('business');
begin
    dbms_lock.sleep(dbms_random.value(0, 5));
    s1.log('call');
    dbms_lock.sleep(0.01);
    b1.log('validating input');
    dbms_lock.sleep(0.1);
    b1.log('input is valid');
    dbms_lock.sleep(0.1);
    b1.log('applying business rule');
    dbms_lock.sleep(dbms_random.value(0.1, 1));
    b1.log('commit');
    dbms_lock.sleep(0.001);
    s1.log('return');
end;
/

set feedback on
prompt done
prompt
