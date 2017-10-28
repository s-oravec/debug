create or replace package body debug_util as

    -- convert integer to signed 32bit integer = binary_integer
    ----------------------------------------------------------------------------
    function to_binary_integer(a_value in integer) return binary_integer is
        -- for signed 32 bit integer
        MAX_POSITIVE constant pls_integer := power(2, 31) - 1;
        MIN_NEGATIVE constant pls_integer := - power(2, 31);
    begin
        if a_value between MIN_NEGATIVE and MAX_POSITIVE then
            return a_value;
        elsif a_value > MAX_POSITIVE then
            return to_binary_integer(MIN_NEGATIVE + (a_value - MAX_POSITIVE) - 1);
        elsif a_value < MIN_NEGATIVE then
            return to_binary_integer(MAX_POSITIVE + a_value - MIN_NEGATIVE + 1);
        else
            return null;
        end if;
    end;

    -- supersimplified shift left operator
    ----------------------------------------------------------------------------
    function fake_shl(a_value in pls_integer, a_positions in pls_integer) return pls_integer
    is
    begin
        -- just make it simple, doesn't have to be precise
        if nvl(a_value, 0) = 0 then
            return a_value;
        elsif sign(a_value) = 1 then
            return mod(cast(a_value as integer) * power(2, a_positions), power(2, 31) - 1);
        else
            return mod(cast(a_value as integer) * power(2, a_positions), power(2, 31));
        end if;
    end;

    -- ternary operator (as seen elsewhere ...) - for varchar2
    -- no special null treatment of a_boolean_expression
    ----------------------------------------------------------------------------
    function ternary_operator (
        a_boolean_expression in boolean,
        a_value_when_true    in varchar2,
        a_value_when_false   in varchar2
    ) return varchar2
    is
    begin
        if a_boolean_expression then
            return a_value_when_true;
        else
            return a_value_when_false;
        end if;
    end;

    -- apply color to string
    ----------------------------------------------------------------------------
    function color_string (
        a_string in varchar2,
        a_color  in debug_types.typ_Color
    ) return varchar2
    is
    begin
        if a_color is null then
            return a_string;
        else
            return chr(27) || '[3' || ternary_operator(a_color < 8, a_color, '8;5;' || a_color) || 'm'
                || a_string
                || chr(27) || '[0m';
        end if;
    end;

    -- humanize day to second interval
    ----------------------------------------------------------------------------
    function humanize (
        a_dsinterval interval day to second
    ) return varchar2
    is
    begin
        if a_dsinterval < numtodsinterval(1, 'second') / 1000 then
            return '+0ms';
        elsif a_dsinterval < numtodsinterval(1, 'second') then
            return '+' || (1000 * to_number('0.' || substr(regexp_substr(to_char(a_dsinterval), '[^\.]+', 1, 2), 1, 12))) || 'ms';
        elsif a_dsinterval < numtodsinterval(1, 'minute') then
            return '+' || ltrim(substr(regexp_substr(to_char(a_dsinterval), '[^:]+', 1, 3), 1, 6), '0') || 's';
        elsif a_dsinterval < numtodsinterval(1, 'hour') then
            return '+' || ltrim(substr(regexp_substr(to_char(a_dsinterval), '[^ ]+', 1, 2), 4, 7), '0') || 'min';
        else
            return '+' || ltrim(substr(regexp_substr(to_char(a_dsinterval), '[^ ]+', 1, 2), 1, 8),'0') || 'h';
        end if;
    end;

end;
/