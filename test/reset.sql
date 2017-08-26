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