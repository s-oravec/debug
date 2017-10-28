create or replace package debug_types as

    subtype typ_Filter       is debug_group.filter%type;
    subtype typ_DebugGroupId is debug_group.id_debug_group%type;
    subtype typ_Namespace    is debug_log.namespace%type;
    subtype typ_LogValue     is debug_log.value%type;

    subtype typ_CharBool     is varchar2(1);
    subtype typ_SessionId    is integer;
    subtype typ_Color        is pls_integer;
    subtype typ_Colors       is varchar2(30);
    subtype typ_Description  is varchar2(255);

    DESCRIPTION_NONE constant typ_Description := 'None';

    CHARBOOL_TRUE  constant typ_CharBool := 'Y';
    CHARBOOL_FALSE constant typ_CharBool := 'N';

    ALL_NAMESPACES constant typ_Filter := '*';

    COLORS_NO  constant typ_Colors := 'NO_COLORS';
    COLORS_16  constant typ_Colors := '16_COLORS';
    COLORS_256 constant typ_Colors := '256_COLORS';

end;
/