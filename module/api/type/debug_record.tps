create or replace type debug_record as object(
    id_debug_log     number,
    id_debug_group   number,
    id_debug_session number,
    namespace        varchar2(4000),
    value            varchar2(4000),
    ts_created       timestamp,
    diff             interval day (9) to second (6)
);
/