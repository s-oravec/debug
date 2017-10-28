create or replace package debug_format as

    subtype namespace_type is varchar2(255);
    subtype color_type is pls_integer;
    subtype colors_type is varchar2(30);
    subtype debug_group_identifier_type is integer;
    subtype debug_log_identifier_type is integer;

    COLORS_NO  constant colors_type := 'NO_COLORS';
    COLORS_16  constant colors_type := '16_COLORS';
    COLORS_256 constant colors_type := '256_COLORS';

    DEFAULT_COLORS constant colors_type := COLORS_NO;

    DEFAULT_ROW_COUNT constant pls_integer := 10;

    procedure set_colors (
        colors in colors_type
    );

    function use_colors return boolean;

    function color_for_namespace (
        namespace in namespace_type
    ) return color_type;

    function get_debug_lines(
        last_id_debug_log in debug_log_identifier_type,
        debug_group       in debug_group_identifier_type default null,
        row_count         in pls_integer default DEFAULT_ROW_COUNT
    ) return debug_lines pipelined;

    function get_debug_records(
        last_id_debug_log in debug_log_identifier_type,
        debug_group       in debug_group_identifier_type default null,
        row_count         in pls_integer default DEFAULT_ROW_COUNT
    ) return debug_records pipelined;

end;
/