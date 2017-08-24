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
set feedback on

declare
    l_session pls_integer ;
BEGIN
    l_session := debug.init_persistent('worker:*', debug_impl.COLORS_256);
END;
/

declare
  d1 debug := new debug('worker');
  d2 debug := new debug('business');
  d3 debug := new debug('entity');
  w1 debug := new debug('worker:1');
  w2 debug := new debug('worker:2');
begin
  d1.log('some work');
  d2.log('some other work');
  w1.log('some work');
  w2.log('some work');
--  dbms_lock.sleep(2);
  d2.log('some completely different work');
  d1.log('some work');
  w1.log('some work');
--  dbms_lock.sleep(1);
  w2.log('some work');
  d2.log('some other work');
  d3.log('wat');
  d2.log('some completely different work');
  d1.log('some work');
--  dbms_lock.sleep(75);
  w1.log('some work');
  w2.log('some work');
  d2.log('some other work');
  w1.log('some work');
  w2.log('some work');
  d2.log('some completely different work');
end;
/