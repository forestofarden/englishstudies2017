SET search_path = warehouse;

-- matrix for chord of genre to genre

CREATE OR REPLACE FUNCTION simple_genre(genre TEXT) RETURNS TEXT AS $$
  SELECT CASE WHEN genre IN ('comédie',
                             'comédie - drame',
                             'comédie héroïque',
                             'comédie-ballet',
                             'drame',
                             'tragi-comédie',
                             'tragi-comédie / tragédie',
                             'tragédie') THEN genre
              WHEN genre IS NULL THEN NULL
              ELSE 'other'
  END
$$ LANGUAGE SQL;

COPY (
  select count(distinct date) as performances,
         simple_genre(play_1.genre) as genre_1,
         simple_genre(play_2.genre) as genre_2,
         simple_genre(play_3.genre) as genre_3
  from sales_facts
  left outer join play_dim play_1 ON (play_1.id = play_1_id)
  left outer join play_dim play_2 ON (play_2.id = play_2_id)
  left outer join play_dim play_3 ON (play_3.id = play_3_id)
  group by genre_1, genre_2, genre_3
  order by performances desc
) TO '/tmp/genre_performances.csv' WITH CSV HEADER;

DROP FUNCTION simple_genre(TEXT);
