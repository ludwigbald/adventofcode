DROP TABLE IF EXISTS calibration;

CREATE TABLE IF NOT EXISTS calibration (
    calibration TEXT,
    id SERIAL
);

COPY calibration(calibration)
FROM 'PATH_TO_01.txt'
;

-- part 1:
WITH
    digits as (
        SELECT
            regexp_replace(calibration, '[[:alpha:]]', '', 'g') as trimmed
        from calibration
        ),

    numbers as (
        select
            cast (
                -- first digit
                left(trimmed, 1)
                ||
                -- last digit
                right(trimmed,1)
                as integer 
            )as number
        from digits),

    total as (
        select
            sum(number)
        from numbers
    ) 

select * from total;

-- part 2:

WITH
    trimmed as (
        select
            array(SELECT
                regexp_matches(
                    calibration,
                    '[1-9]|one|two|three|four|five|six|seven|eight|nine',
                    'g')
            ) as trimmed
        from calibration
        ),

    numbers as (
        select
            trimmed[1][1] as first_digit,
            trimmed[array_upper(trimmed,1)][1] as second_digit
        from trimmed
    ),

    dictionary as (
        select array['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'] as words
    ),

    digits as (
        select
            COALESCE(array_position(dictionary.words, first_digit),
                     CAST(first_digit as integer)
            ) as first_digit,
            
            COALESCE(array_position(dictionary.words, second_digit),
                     CAST(second_digit as integer)
            ) as second_digit
        from numbers, dictionary
    ),

    total as (
        select
            sum(first_digit*10+second_digit)
        from digits
    )

select * from total;