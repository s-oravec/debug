create or replace type debug as object
(
    namespace varchar2(255),
    enabled   varchar2(1), -- private

    static procedure init(
        filter in varchar2 default '*', -- debug_api.ALL_NAMESPACES
        colors in varchar2 default '16_COLORS' -- debug_api.COLORS_16
    ),

    constructor function debug(
        namespace in varchar2
    ) return self as result,

    member procedure log(
        value in varchar2
    )
    
);
/