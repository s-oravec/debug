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
  w0 debug := new debug('worker:manager');
  w1 debug := new debug('worker:1');
  w2 debug := new debug('worker:2');
begin
  w0.log('starting manager');
  dbms_lock.sleep(1.5);
  w1.log('starting worker 1');
  dbms_lock.sleep(1.5);
  w2.log('starting worker 2');
  for i in 1 .. &&iterations loop
    dbms_lock.sleep(dbms_random.value(0, 5));
    s1.log('call');
    dbms_lock.sleep(0.01);
    b1.log('validating input');
    dbms_lock.sleep(0.1);
    b1.log('input is valid');
    dbms_lock.sleep(0.001);
    b1.log('enqueue');
    dbms_lock.sleep(0.1);
    s1.log('return');
    if mod(i, 2) = 0 then
        dbms_lock.sleep(0.1);
        w1.log('dequeue');
        dbms_lock.sleep(0.1);
        b1.log('applying business rule');
        dbms_lock.sleep(dbms_random.value(0.1, 1));
        w1.log('commit');
        dbms_lock.sleep(0.001);
    else
        dbms_lock.sleep(0.1);
        w2.log('dequeue');
        dbms_lock.sleep(0.1);
        b1.log('applying business rule');
        dbms_lock.sleep(dbms_random.value(0.1, 1));
        w2.log('commit');
        dbms_lock.sleep(0.001);
    end if;
  end loop;
  w0.log('stopping');
  dbms_lock.sleep(0.5);
  w1.log('stopping worker 1');
  dbms_lock.sleep(1.5);
  w2.log('stopping worker 2');
  dbms_lock.sleep(1.5);
  w0.log('stopped');
end;
/

set feedback on
prompt done
prompt
