-- parsing input
DROP TABLE IF EXISTS input;

CREATE TABLE IF NOT EXISTS input (
    inputline TEXT
);

COPY input (
     inputline 
    )
FROM 'path-to-02.txt'
;

WITH
    gamenumber as (
        SELECT
            inputline,
            regexp_matches(inputline, '(Game )([0-9]+)(: )(.*)', 'g') as parsed
        FROM input
    ),

    parsed as (
        SELECT
            inputline,
            parsed[2] as game_id,
            unnest(string_to_array(unnest(string_to_array(parsed[4], ';')), ',')) as games
        FROM gamenumber
    ),
    parsed2 as (
        SELECT
            game_id,
            CAST ((string_to_array(TRIM(games), ' '))[1] as INTEGER) as number_of_cubes,
            (string_to_array(TRIM(games), ' '))[2] as color
        FROM parsed
    ),
    forbidden_bags as (
        SELECT
            game_id
        FROM
            parsed2
        WHERE
            color='red' AND number_of_cubes > 12
            OR color='green' AND number_of_cubes > 13
            OR color='blue' AND number_of_cubes > 14
    ),
    legal_bags as (
        SELECT
            DISTINCT p.game_id
        FROM
            parsed p
        LEFT JOIN
            forbidden_bags f
        ON f.game_id = p.game_id
        WHERE
            f.game_id IS NULL
    ),
    --- this is the solution to part 1
    part1 as (
        SELECT sum(cast(game_id as integer)) from legal_bags
    ),
    minimum_cubes as (
        SELECT
            game_id,
            color,
            max(number_of_cubes) as min_number
        FROM parsed2
        GROUP BY game_id, color
    ),
    with_power as (
        SELECT
            round(exp(sum(ln(min_number)))) as power,
            game_id
        FROM minimum_cubes
        GROUP BY game_id
    )
SELECT
    sum("power")
FROM with_power

