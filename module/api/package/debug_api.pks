create or replace package debug_api as

    subtype typ_Colors is varchar2(30);

    COLORS_NO  constant typ_Colors := 'NO_COLORS';
    COLORS_16  constant typ_Colors := '16_COLORS';
    COLORS_256 constant typ_Colors := '256_COLORS';

    subtype typ_Filter is varchar2(4000);

    FILTER_ALL_NAMESPACES constant typ_Filter := '*';
    FILTER_DEFAULT        constant typ_Filter := '';

    subtype typ_Namespace is varchar2(4000);

end;
/