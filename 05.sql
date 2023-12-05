-- read in text
DROP TABLE IF EXISTS input;
CREATE TABLE IF NOT EXISTS input (
    inputline TEXT,
    n SERIAL
);

COPY input (
    inputline 
    )
FROM '/Users/ludwig/Library/CloudStorage/OneDrive-Persönlich/Dokumente/Projekte/adventofcode/05.txt';
TABLE input;

-- part 1
WITH
    seeds (seed_id) as (
        select
            cast (unnest(regexp_matches(inputline, '[0-9]+', 'g')) as bigint) as seed_id
        from
            input
        where n = 1
        ),
    maps as (
        select n,
               cast(split_part(inputline, ' ', 1) as bigint) as out_start,
               cast(split_part(inputline, ' ', 2) as bigint) as in_start,
               cast(split_part(inputline, ' ', 3) as bigint) as r
               
        from input
        where regexp_count(inputline, '[0-9]+') = 3
    ),
    seed_to_soil as (
        select * from maps
        where n between 4 and 40
    ),
    soil_to_fertilizer as (
        select * from maps
        where n between 43 and 52
    ),
    fertilizer_to_water as (
        select * from maps
        where n between 55 and 90
    ),
    water_to_light as (
        select * from maps
        where n between 93 and 138
    ),
    light_to_temperature as (
        select * from maps
        where n between 141 and 168
    ),
    temperature_to_humidity as (
        select * from maps
        where n between 171 and 210
    ),
    humidity_to_location as (
        select * from maps
        where n between 213 and 254
    ),
    soils as (
        select seed_id - in_start + out_start as id
        from seeds s, seed_to_soil s2
        where s.seed_id >= in_start
          and s.seed_id < s2.in_start + s2.r
    ),
    fertilizers as (
        select id - in_start + out_start as id
        from soils s, soil_to_fertilizer s2
        where s.id >= in_start
          and s.id < s2.in_start + s2.r
    ),
    waters as (
        select id - in_start + out_start as id
        from fertilizers s, fertilizer_to_water s2
        where s.id >= in_start
          and s.id < s2.in_start + s2.r
    ),
    lights as (
        select id - in_start + out_start as id
        from waters s, water_to_light s2
        where s.id >= in_start
          and s.id < s2.in_start + s2.r
    ),
    temperatures as (
        select id - in_start + out_start as id
        from lights s, light_to_temperature s2
        where s.id >= in_start
          and s.id < s2.in_start + s2.r
    ),
    humidities as (
        select id - in_start + out_start as id
        from temperatures s, temperature_to_humidity s2
        where s.id >= in_start
          and s.id < s2.in_start + s2.r
    ),
    locations as (
        select id - in_start + out_start as id
        from humidities s, humidity_to_location s2
        where s.id >= in_start
          and s.id < s2.in_start + s2.r
    )
SELECT min(id) from locations;

-- no part 2, I tried implementing ranges but it was too much for me in the end