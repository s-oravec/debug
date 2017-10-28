set feedback on

prompt Set output format colors
accept colors prompt ">> Enter colors [256] (NO | 16 | 256): " default "256"
prompt

@@_set_colors_impl.sql "&&colors"

undefine colors
