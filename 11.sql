DROP TABLE IF EXISTS input;
CREATE TABLE IF NOT EXISTS input (
    inputline TEXT,
    y SERIAL
);
COPY input (
    inputline 
    )
FROM '/Users/ludwig/Library/CloudStorage/OneDrive-Persönlich/Dokumente/Projekte/adventofcode/11.txt';

WITH
    observation as (
        SELECT
            cast(generate_series as BIGINT) as x,
            cast(i.y as BIGINT) as y,
            (string_to_array(i.inputline, NULL))[generate_series] as symbol
        FROM
            input i,
            generate_series(1,140)
    ),
    filled_x as (
        SELECT x
        FROM observation
        WHERE symbol = '#'
        GROUP BY x
    ),
    empty_x as (
        select obs.x
        from
                observation obs
            LEFT JOIN
                filled_x fx
            ON fx.x = obs.x
        WHERE fx.x is NULL
        group by obs.x
    ),
    filled_y as (
        SELECT y
        FROM observation
        WHERE symbol = '#'
        GROUP BY y
    ),
    empty_y as (
        select obs.y
        from
                observation obs
            LEFT JOIN
                filled_y fy
            ON fy.y = obs.y
        WHERE fy.y is NULL
        group by obs.y
    ),
    -- for part 1, use factor 1. for part 2, use factor 999999
    expanded_space as (
        SELECT
            s.x + (select 999999 * count(*) from empty_x ex where ex.x < s.x) as x,
            s.y + (select 999999 * count(*) from empty_y ey where ey.y < s.y) as y,
            symbol
        FROM
            observation s
        where symbol = '#'
    ),
    galaxy_pairs as (
        SELECT
            s1.x as x1,
            s1.y as y1,
            s2.x as x2,
            s2.y as y2
        FROM
            expanded_space s1
            INNER JOIN
            expanded_space s2
            -- logic to make sure every pair is counted exactly once
            ON (   (s1.x = s2.x
                  AND
                    s1.y < s2.y)
               OR
                 (s1.x < s2.x)
               )
               AND s1.symbol=s2.symbol
        WHERE
            s1.symbol='#'
    ),
    galaxy_distance as (
        select
            *,
            abs(x2-x1) + abs(y2-y1) as distance
        from galaxy_pairs gp
    )

SELECT sum(distance) from galaxy_distance;