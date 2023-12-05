-- load the input
DROP TABLE IF EXISTS input;
CREATE TABLE IF NOT EXISTS input (
    inputline TEXT,
    y SERIAL
);
COPY input (
    inputline 
    )
FROM '/Users/ludwig/Library/CloudStorage/OneDrive-Persönlich/Dokumente/Projekte/adventofcode/03.txt';

WITH
    coords as (
        SELECT
            generate_series as x,
            i.y as y,
            (string_to_array(i.inputline, NULL))[generate_series] as symbol
        FROM
            input i,
            generate_series(1,140)
    ),
-- extract all the symbol locations from the input and store them in a separate table
    symbols as (
        SELECT *
        from coords
        WHERE symbol NOT IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.')
    ),
-- extract all the numbers and their bounding boxes and store them in a separate table
    numbers as (
        SELECT
            UNNEST(regexp_matches(inputline, '[0-9]+', 'g')) as n,
            y,
            inputline,
            generate_series()
        FROM
            input i
    ),
    numbers2 as (
        SELECT
            cast((regexp_match(n, '[0-9]+$'))[1] as integer) as n,
            y,
            length(n) - length((regexp_match(n, '[0-9]+$'))[1]) -1 as xmin,
            length(n) +1 as xmax,
            inputline
        FROM
            numbers
    ),
    part_numbers as (
        SELECT
            *
        FROM
                numbers2 n
            INNER JOIN
                symbols s
            ON
                 n.xmin <= s.x AND s.x <= n.xmax
             AND n.y -1 <= s.y AND s.y <= n.y +1
    )
SELECT n, y FROM numbers;




-- join the two