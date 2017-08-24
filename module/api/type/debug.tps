create or replace type debug as object
(
    namespace varchar2(255),
    color     integer,
    enabled   varchar2(1),
    prev_tick timestamp,

    static procedure init (
        filter  in varchar2 default '*',         -- debug_api.ALL_NAMESPACES
        colors  in varchar2 default '16_COLORS' -- debug_api.COLORS_16
    ),

    static function init_persistent (
        filter  in varchar2 default '*',         -- debug_api.ALL_NAMESPACES
        colors  in varchar2 default '16_COLORS', -- debug_api.COLORS_16
        session in integer default null
    ) return integer,

    constructor function debug(
        namespace in varchar2
    ) return self as result,

    member procedure log(
        value in varchar2
    ),

    member function diff (self in out nocopy debug) return interval day to second
    
);
/
