package.path = package.path .. ";/processing/topics/helper/?.lua"
local dir = ";/processing/topics/cqi/"
package.path = package.path .. dir .. "sidepath_dict/?.lua"

require('SidepathDict')
local inspect = require('inspect')

local sidepath_dict = SidepathDict('/data/hashes/sidepath_dict_germany.jsonl')

-- TODO: we have no real table yet to fill.. we are just testing sidepath_dict reading
local dummy_table = osm2pgsql.define_table({
  name = 'cqi_dummy_table',
  ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
  columns = {
    { column = 'id',      type = 'text',      not_null = true },
    { column = 'tags',    type = 'jsonb' },
    { column = 'meta',    type = 'jsonb' },
    { column = 'geom',    type = 'linestring' },
  },
  indexes = {
    { column = 'geom', method = 'gist' },
    { column = 'id',   method = 'btree', unique = true }
  }
})


-- TODO: remove.. just to see that something has happened
local printed = false
function osm2pgsql.process_way(object)
  -- SidpathDict.get will only load the dict once
  local d = sidepath_dict:get()
  -- TODO: remove.. just to see that something has happened
  if not printed then
    printed = true
    local id, entry = next(d)
    print('TODO: first entry: ', id, inspect(entry))
  end
end
