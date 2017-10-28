column id_debug_group format 999999999 new_value id_debug_group
column description    format a30 word_wrapped
column filter         format a30 word_wrapped
column paused         format a6

select *
  from debug_group
 order by id_debug_group;