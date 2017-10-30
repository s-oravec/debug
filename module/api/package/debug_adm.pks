create or replace package debug_adm as

    -- debug group identifier type
    subtype debug_group_identifier_type is integer;

    -- filter type
    subtype filter_type is varchar2(4000);

    -- character bool type
    subtype charbool_type is varchar2(1);

    -- group description type
    subtype description_type is varchar2(255);

    -- default description
    DESCRIPTION_NONE constant description_type := 'None';

    -- charbool true
    CHARBOOL_TRUE  constant charbool_type := 'Y';

    -- charbool false
    CHARBOOL_FALSE constant charbool_type := 'N';

    -- filter - all namespaces
    ALL_NAMESPACES constant filter_type := '*';

    /**
    -- creates debug group
    --
    -- Debug Groups UseCase Scenario
    --
    -- 1. create group (create_group)
    -- 2. add sessions which you want to debug into group (debug_this/debug_other)
    -- 3. watch group in SQLcl from other session (using module/script/watch.sql)
    -- 4. drop group (drop_group)
    --
    -- optionally
    -- - pause/resume debugging (pause_debug/resume_debug)
    -- - purge logs (purge_log)
    --
    -- params
    --
    -- - filter      - see debug_this
    -- - description - some description (optional)
    --
    -- returns debug group identifier
    --
    */
    function create_group (
        filter      in filter_type default ALL_NAMESPACES,
        description in description_type default DESCRIPTION_NONE
    ) return debug_group_identifier_type;

    /**
    -- drops debug group and logs, stops debugging in all these sessions
    --
    -- params
    --
    -- - debug_group debug group identifier
    --
    */
    procedure drop_group (
        debug_group in debug_group_identifier_type
    );

    /**
    -- checks if groups still exists
    */
    function group_exists (debug_group in debug_group_identifier_type) return charbool_type;

    /**
    -- starts debug in this session only or add it to existing debug group (if debug_group parameter is passed)
    --
    -- !!! warning - debug not in group cannot be watched from other session
    --
    -- params
    --
    -- - debug_group - debug group identifier - see create_group
    -- - filter
    --   - like expressions without escape (sorry), separated by ,
    --   - * - all namespaces will be enabled (default)
    -- - colors - colors settings for namespace "coloring" in ANSI terminals. Use debug_format.COLORS_NO if your terminal does not support ANSI colors
    --   - debug_format.COLORS_NO - no colors
    --   - debug_format.COLORS_16 - 16 colors
    --   - debug_format.COLORS_256 - 256 colors
    */
    -- TODO: test colors in SQL*Plus
    procedure debug_this (
        debug_group in debug_group_identifier_type default null,
        filter      in filter_type default ALL_NAMESPACES,
        colors      in debug_format.colors_type default debug_format.COLORS_NO
    );

    /**
    -- adds session with sessionId to group identified by debug_group
    --
    -- params
    --
    -- - debug_group - debug group identifier - see create_group
    -- - sessionId = sys_context('userenv','sessionId') = v$session.audsid
    -- - filter -
    --
    */
    procedure debug_other (
        debug_group in debug_group_identifier_type,
        sessionId   in integer,
        filter      in filter_type default ALL_NAMESPACES
    );

    /**
    -- pause debugging
    --
    -- params
    --
    -- - debug_group - all sessions in debug_group
    -- - sessionId - only sessions identified by sessionId
    --
    */
    procedure pause_debug (
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    );

    /**
    -- resume debugging
    --
    -- params
    --
    -- - debug_group - all sessions in debug_group
    -- - sessionId - only session identified by sessionId
    --
    */
    procedure resume_debug (
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    );

    /**
    -- set filter - change after init
    --
    -- params
    --
    -- - filter - see debug_this
    -- - debug_group - for all sessions in debug_session
    -- - sessionId - only for session identified by sessionId
    --
    */
    procedure set_filter (
        filter      in filter_type,
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    );

    /**
    -- deletes debug log messages
    --
    -- params
    --
    -- - debug_group - for all sessions in debug_group
    -- - sessionId - only for session identified by sessionId
    --
    */
    -- TODO: rename to purge
    procedure purge_log (
        debug_group in debug_group_identifier_type default null,
        sessionId   in integer default null
    );

end;
/