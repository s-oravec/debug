create or replace package body debug_impl as

    g_paused  debug_types.typ_Charbool := debug_types.CHARBOOL_FALSE;
    type typ_Filters is table of debug_types.typ_Filter;
    g_enabled_filters typ_Filters;
    g_log_to_dbms_output boolean := false;

    -- parse filter
    ----------------------------------------------------------------------------
    function parse_filter(a_filter in debug_types.typ_Filter) return typ_Filters
    is
        l_result typ_Filters := typ_Filters();
    begin
        if a_filter is not null then
            for idx in 1 .. nvl(length(regexp_replace(a_filter, '[^,]')),0) + 1 loop
                -- append
                l_result.extend();
                l_result(l_result.last) := replace(regexp_substr(a_filter, '[^,]+', 1, idx), '*', '%');
            end loop;
        end if;
        return l_result;
    end;

    -- validate at least one not null
    ----------------------------------------------------------------------------
    procedure validate_debug_grp_or_sessid (
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_sessionid      in debug_types.typ_SessionId default null
    ) is
    begin
        if a_sessionid is null and a_id_debug_group is null then
            raise_application_error(-20000, 'Specify at least one of id_debug_group and sessionId.');
        end if;
    end;

    -- create debug group
    ----------------------------------------------------------------------------
    function create_group (
        a_filter      in debug_types.typ_Filter default debug_types.ALL_NAMESPACES,
        a_description in debug_types.typ_Description default debug_types.DESCRIPTION_NONE
    ) return debug_types.typ_DebugGroupId
    is
        pragma autonomous_transaction;
        l_result debug_types.typ_DebugGroupId;
    begin
        --
        insert
          into debug_group
        values (
            debug_group_id.nextval,
            a_description,
            nvl(a_filter, debug_types.ALL_NAMESPACES),
            debug_types.CHARBOOL_FALSE
        )
        returning id_debug_group into l_result
        ;
        --
        commit;
        --
        return l_result;
        --
    end;

    -- drop group
    ----------------------------------------------------------------------------
    procedure drop_group (
        a_id_debug_group in debug_types.typ_DebugGroupId
    ) is
        pragma autonomous_transaction;
    begin
        --
        delete from debug_group where id_debug_group = a_id_debug_group;
        commit;
        --
    end;

    -- debug this session
    ----------------------------------------------------------------------------
    procedure debug_this (
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_filter         in debug_types.typ_Filter default debug_types.ALL_NAMESPACES,
        a_colors         in debug_types.typ_Colors default debug_types.COLORS_NO
    ) is
        pragma autonomous_transaction;
    begin
        --
        g_paused := debug_types.CHARBOOL_FALSE;
        if a_id_debug_group is null then
            -- debuging only this session - do not persist
            g_enabled_filters := parse_filter(a_filter);
            --
            dbms_output.put_line('set_colors:' || a_colors);
            debug_format_impl.set_colors(a_colors);
            g_log_to_dbms_output := true;
            --
        else
            -- reset enabled filters
            g_enabled_filters    := typ_Filters();
            g_log_to_dbms_output := false;
            --
            begin
                insert
                    into debug_session
                values (
                    debug_session_id.nextval,
                    a_id_debug_group,
                    sys_context('userEnv','sessionId'),
                    a_filter,
                    debug_types.CHARBOOL_FALSE)
                ;
            exception
                when dup_val_on_index then
                    update debug_session
                       set filter = a_filter,
                           paused = debug_types.CHARBOOL_FALSE
                     where id_debug_group = a_id_debug_group
                       and sessionId = sys_context('userEnv','sessionId')
                ;
            end;
            --
            commit;
            --
        end if;
        --
    end;

    -- debug other session session
    ----------------------------------------------------------------------------
    procedure debug_other (
        a_id_debug_group in debug_types.typ_DebugGroupId,
        a_sessionId      in debug_types.typ_SessionId,
        a_filter         in debug_types.typ_Filter default debug_types.ALL_NAMESPACES
    ) is
        pragma autonomous_transaction;
    begin
        -- validate params
        validate_debug_grp_or_sessid(a_id_debug_group, a_sessionId);
        --
        insert into debug_session values (debug_session_id.nextval, a_id_debug_group, a_sessionId, a_filter, debug_types.CHARBOOL_FALSE);
        --
        commit;
        --
    end;

    -- set pause implementation
    ----------------------------------------------------------------------------
    procedure set_pause (
        a_id_debug_group in debug_types.typ_DebugGroupId,
        a_sessionId      in debug_types.typ_SessionId,
        a_value          in debug_types.typ_Charbool
    ) is
        pragma autonomous_transaction;
    begin
        -- no debug group/sessionId passed or sessionId passed same as current sessionId
        if (a_id_debug_group is null and a_sessionId is null) or a_sessionId = sys_context('userEnv', 'sessionId') then
            g_paused := a_value;
        end if;
        -- if at least one of debug group/sessionId passed
        if a_id_debug_group is not null or a_sessionId is not null then
            -- by group
            -- set paused on debug group
            update debug_group set paused = a_value where id_debug_group = a_id_debug_group;
            -- set paused on
            -- - all sessions in group
            -- - all session with same sessionId
            -- - if both passed then only sessionId in that group
            update debug_session
               set paused = a_value
             where (a_sessionId is null or sessionId = a_sessionId)
               and (a_id_debug_group is null or id_debug_group = a_id_debug_group)
            ;
            --
        end if;
        --
        commit;
        --
    end;

    -- pause debug
    ----------------------------------------------------------------------------
    procedure pause_debug (
        a_id_debug_group in debug_types.typ_DebugGroupId,
        a_sessionId      in debug_types.typ_SessionId
    ) is
    begin
        set_pause(a_id_debug_group, a_sessionId, debug_types.CHARBOOL_TRUE);
    end;

    -- resume debug
    ----------------------------------------------------------------------------
    procedure resume_debug (
        a_id_debug_group in debug_types.typ_DebugGroupId,
        a_sessionId      in debug_types.typ_SessionId
    ) is
    begin
        set_pause(a_id_debug_group, a_sessionId, debug_types.CHARBOOL_FALSE);
    end;

    -- set filter
    ----------------------------------------------------------------------------
    procedure set_filter (
        a_filter         in debug_types.typ_Filter,
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_sessionId      in debug_types.typ_SessionId default null
    ) is
        pragma autonomous_transaction;
    begin
        -- no debug group/sessionId passed or sessionId passed same as current sessionId
        if (a_id_debug_group is null and a_sessionId is null) or a_sessionId = sys_context('userEnv', 'sessionId') then
            g_enabled_filters := parse_filter(a_filter);
        end if;
        -- if at least one of debug group/sessionId passed
        if a_id_debug_group is not null or a_sessionId is not null then
            -- by group
            -- set paused on debug group
            update debug_group set filter = a_filter where id_debug_group = a_id_debug_group;
            -- set filter on
            -- - all sessions in group
            -- - all session with same sessionId
            -- - if both paaed then only sessionId in that group
            update debug_session
               set filter = a_filter
             where (a_sessionId is null or sessionId = a_sessionId)
               and (a_id_debug_group is null or id_debug_group = a_id_debug_group)
            ;
        end if;
        --
        commit;
        --
    end;

    -- purge log
    ----------------------------------------------------------------------------
    procedure purge_log (
        a_id_debug_group in debug_types.typ_DebugGroupId default null,
        a_sessionId      in debug_types.typ_SessionId default null
    ) is
        pragma autonomous_transaction;
    begin
        -- purge messages for group
        delete from debug_log where id_debug_group = a_id_debug_group;
        -- purge for sessionId
        delete
          from debug_log
         where id_debug_session = (select id_debug_session
                                     from debug_session
                                    where sessionId = a_sessionId)
        ;
        --
        commit;
        --
    end;

    -- in this session
    ----------------------------------------------------------------------------
    function is_enabled_in_this(
        a_sessionId in debug_types.typ_SessionId,
        a_namespace in debug_types.typ_Namespace
    ) return debug_types.typ_CharBool
    is
        l_enabled_filters typ_Filters;
    begin
        if g_paused = debug_types.CHARBOOL_FALSE then
            -- enabled within this session - using debug_this
            for l_idx in 1 .. g_enabled_filters.count loop
                if a_namespace like g_enabled_filters(l_idx) then
                    return debug_types.CHARBOOL_TRUE;
                end if;
            end loop;
        end if;
        --
        return debug_types.CHARBOOL_FALSE;
        --
    end;

    -- checks enabled filters in table
    ----------------------------------------------------------------------------
    function is_enabled_in_table (
        a_sessionId in debug_types.typ_SessionId,
        a_namespace in debug_types.typ_Namespace
    ) return debug_types.typ_CharBool
    result_cache
    is
        l_enabled_filters typ_Filters;
    begin
        --
        for l_debug_session in (
            -- all debug sessions with sessionId = a_sessionId
            -- and not paused
            -- TODO: index candidate - debug_session(paused, sessionId) compress (1)
            select * from debug_session where sessionId = a_sessionId and paused = debug_types.CHARBOOL_FALSE)
        loop
            l_enabled_filters := parse_filter(l_debug_session.filter);
            for l_idx in 1 .. l_enabled_filters.count loop
                if a_namespace like l_enabled_filters(l_idx) then
                    return debug_types.CHARBOOL_TRUE;
                end if;
            end loop;
        end loop;
        --
        return debug_types.CHARBOOL_FALSE;
        --
    end;

    ----------------------------------------------------------------------------
    function is_enabled (
        a_sessionId in debug_types.typ_SessionId,
        a_namespace in debug_types.typ_Namespace
    ) return debug_types.typ_CharBool
    is
    begin
        if is_enabled_in_this(a_sessionId, a_namespace) = debug_types.CHARBOOL_TRUE then
            return debug_types.CHARBOOL_TRUE;
        else
            return is_enabled_in_table(a_sessionId, a_namespace);
        end if;
    end;

    -- save message to dbms_output
    ----------------------------------------------------------------------------
    procedure log_to_dbms_output (
        a_namespace in debug_types.typ_Namespace,
        a_value     in debug_types.typ_LogValue,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    ) is
    begin
        dbms_output.put_line(
            debug_format_impl.format_line(
                a_namespace,
                a_value,
                a_this_tick,
                a_diff
            )
        );
    end;


    -- save message to persistent storage
    ----------------------------------------------------------------------------
    procedure log_to_persistent_storage (
        a_namespace in debug_types.typ_Namespace,
        a_value     in debug_types.typ_LogValue,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    ) is
        pragma autonomous_transaction ;
    begin
        insert
          into debug_log
        select debug_log_id.nextval,
               id_debug_group,
               id_debug_session,
               a_namespace,
               a_value,
               a_this_tick,
               a_diff
          from debug_session
         where sessionId = sys_context('userEnv','sessionId')
           and paused = debug_types.CHARBOOL_FALSE
        ;
        commit;
    exception
        when others then
            rollback;
            raise;
    end;

    -- log messege depending on session - either to table or to dbms_output
    ----------------------------------------------------------------------------
    procedure log (
        a_namespace in debug_types.typ_Namespace,
        a_value     in debug_types.typ_LogValue,
        a_this_tick in timestamp,
        a_diff      in interval day to second
    ) is
    begin
        if g_log_to_dbms_output then
            log_to_dbms_output(a_namespace, a_value, a_this_tick, a_diff);
        else
            log_to_persistent_storage(a_namespace, a_value, a_this_tick, a_diff);
        end if;
    end;

begin
    g_enabled_filters := typ_Filters();
end;
/