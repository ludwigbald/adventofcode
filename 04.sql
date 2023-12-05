-- import file in background, table input, column c1

WITH RECURSIVE
	split AS (
      SELECT
      	regexp_split_to_array(c1, '[:|]') as numbers
      FROM
      	input
    ),
    winning_number as (
      SELECT
      	CAST(unnest(regexp_matches(numbers[2], '[0-9]+', 'g')) as integer) as n,
        CAST((regexp_match(numbers[1], '[0-9]+'))[1] as integer) as game_id
      from split
    ),
    chosen_number as (
      SELECT
      	CAST(unnest(regexp_matches(numbers[3], '[0-9]+', 'g')) as integer) as n,
        CAST((regexp_match(numbers[1], '[0-9]+'))[1] as integer) as game_id
      from split
    ),
    number_of_wins AS (
      SELECT
      	count(ch.n) as matches,
      	w.game_id as game_id
      FROM
      	winning_number w
      	LEFT JOIN
      	chosen_number ch
      	ON w.game_id = ch.game_id
      	   AND w.n=ch.n
      GROUP BY w.game_id
      ),
      part1 as (
      	SELECT 
          sum(POWER(2,matches-1)) as result
        from
          number_of_wins
        WHERE matches > 0
      ),
      -- part 2, we need WITH RECURSIVE for this
      -- first, precompute which card causes which copies
      card_relations AS (
      	SELECT
        	a.game_id as source_card,
        	b.game_id as duplicated_card
       	FROM
        	number_of_wins a, number_of_wins b
        WHERE
        	a.game_id < b.game_id
        AND b.game_id <= a.game_id + a.matches
      ),
      -- next, this is the recursive table!
      -- this outputs one row per card
      cards_with_copies(game_id) AS (
        	-- start with one copy of each card
      		SELECT game_id from number_of_wins
        UNION ALL
        	-- recursive call: add those cards that are directly caused by the previous iteration
        	SELECT r.duplicated_card as game_id
        	from
        		card_relations r
        	INNER JOIN
        		cards_with_copies c -- <-- the "recursive" call, this resolves to the previously added set
        	ON c.game_id = r.source_card
        -- after computation, all sets are unioned together (keeping duplicates)
      )
SELECT count(*) from cards_with_copies;