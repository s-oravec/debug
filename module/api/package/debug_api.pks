create or replace package debug_api as

    subtype typ_Colors is varchar2(30);

    COLORS_16  constant typ_Colors := '16_COLORS';
    COLORS_256 constant typ_Colors := '256_COLORS';

    subtype typ_Filter is varchar2(4000);

    ALL_NAMESPACES constant typ_Filter := '*';

end;
/