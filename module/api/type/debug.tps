create or replace type debug as object
(
    -- attributes
    -- TODO: move them to non API object type
    namespace varchar2(255),
    color     integer,
    enabled   varchar2(1),
    this_tick timestamp,
    prev_tick timestamp,

    -- static methods
    -- change settings in current session/or persisted sessions

    -- initialize debug in this session only
    --
    -- params
    -- - filter
    --   - like expressions without escape (sorry), separated by ,
    --   - * - all namespaces will be enabled (default)
    -- - colors - number of colors used in output - 'NO_COLORS' | '16_COLORS' | '256_COLORS' (default is 'NO_COLORS')
    --
    -- !!! warning - cannot be watched
    --
    static procedure init_session (
        filter  in varchar2 default '*',
        colors  in varchar2 default 'NO_COLORS'
    ),

    -- initialize debug with persistence into table, so it can be watched online from other session
    -- multisession debugging and watching (server + workers, async using jobs, multiple sessions) requires persistence
    --
    -- params
    -- - filter - see init_session
    -- - colors - see init_session
    -- returns session identifier - pass this identifier in debugged session in join_persistent
    --
    static function init_persistent (
        filter  in varchar2 default '*',
        colors  in varchar2 default 'NO_COLORS'
    ) return integer,

    -- join persistent debugging
    --
    -- params
    -- - session - session identifier returned by init_persistent
    --
    static procedure join_persistent (
        session in integer
    ),

    -- set filter - change after init
    --
    -- params
    -- - filter
    -- - session
    --
    static procedure set_filter (
        filter  in varchar2,
        session in integer default null
    ),

    -- creates debug object - create debug object and thent use log mmeber method to log debug messages
    --
    -- params
    -- - namespace - choose you naming scheme, namespaces may be filtered using filter passed into init (or changed using set_filter)
    --
    constructor function debug(
        namespace in varchar2
    ) return self as result,

    -- logs if namespace is enabled (matches filter)
    --
    -- params
    -- - value
    --
    member procedure log(
        value in varchar2
    ),

    -- valid only for member = in scope of debug object instance
    -- use set_filter static method to change
    --
    member procedure enable(self in out debug),

    -- valid only for member = in scope of debug object instance
    --
    member procedure disable(self in out debug)

);
/
