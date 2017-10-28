create or replace type debug as object
(
    -- attributes
    namespace varchar2(255),
    this_tick timestamp,
    prev_tick timestamp,

    -- creates debug object
    -- - create debug object and then use log mmeber method to log debug messages
    --
    -- params
    -- - namespace - choose you naming scheme, namespaces may be filtered - see debug_adm package methods
    --
    constructor function debug(
        namespace in varchar2
    ) return self as result,

    -- logs if namespace is enabled
    --
    -- params
    -- - value
    --
    member procedure log(
        value in varchar2
    ),

    -- returns 'Y' when enabled, 'N' when disabled
    member function is_enabled return varchar2

);
/
