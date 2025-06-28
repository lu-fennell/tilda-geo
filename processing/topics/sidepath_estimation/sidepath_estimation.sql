\set QUIET on
\set ON_ERROR_STOP on

-- set parameter defaults
\set buffer_size 22.0
\set buffer_distance 100.0
\set outfile /data/hashes/is_sidepath.idlines.txt
   
-- reset sequence for checkpoint numbering
\o /dev/null
SELECT setval('checkpoint_nr_sequence', 1);

-- set output to the result file
\o :outfile

\echo `date` 'Start generating is_sidepath ids'

-- set appropiate formatting 
\pset format unaligned
\pset tuples_only on

-- run the query
SELECT * FROM sidepath_idlist_yes(:buffer_distance, :buffer_size);

\echo `date` 'Done writing is_sidepath ids to:' :outfile

