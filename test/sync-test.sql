undefine iterations
define iterations = &1

set feedback off

begin
  dbms_session.reset_package;
end;
/

begin
  dbms_output.enable;
end;
/

set serveroutput on size unlimited
set verify off
set feedback on

begin
    debug.join_persistent(&&id_debug_session);
end;
/

prompt
prompt .. Running test in debug mode
rem set feedback off

declare
  s1 debug := new debug('api');
  b1 debug := new debug('business');
begin
  for i in 1 .. &&iterations loop
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
  end loop;
end;
/

set feedback on
prompt done
prompt
