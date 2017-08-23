create or replace package debug_impl as

    subtype typ_Boolean is varchar2 (1);
    BOOLEAN_TRUE  constant typ_Boolean := 'Y';
    BOOLEAN_FALSE constant typ_Boolean := 'N';

    procedure init (
      filter in varchar2,
      colors in varchar2
    );

    function is_enabled (
        namespace in varchar2
    ) return typ_Boolean;

end;
/