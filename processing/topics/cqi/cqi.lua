package.path = package.path .. ";/processing/topics/helper/?.lua"
local dir = ";/processing/topics/cqi/"
package.path = package.path .. dir .. "sidepath_dict/?.lua"

require('HighwayClasses')
require('SidepathDict')
require('DefaultId')
require('ExtractPublicTags')
require('Metadata')

local sidepath_dict = SidepathDict('/data/hashes/sidepath_dict_germany.jsonl')

local paths_table = osm2pgsql.define_table({
  name = 'cqi_paths_with_sidepath_info_table',
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


function osm2pgsql.process_way(object)
  -- SidpathDict.get will only load the dict once
  local tags = object.tags
  local id =  DefaultId(object)

  local d = sidepath_dict:get()
  local entry = d[id]
  if entry == nil then
    tags.proc_is_sidepath = false
  else
    tags.proc_is_sidepath = (
       IsSidepath(entry.count, entry.road_ids)
       or IsSidepath(entry.count, entry.road_highways)
       or IsSidepath(entry.count, entry.road_names)
    )
  end
  if PathClasses[tags.highway] then
    paths_table:insert({
      id = id,
      tags = ExtractPublicTags(tags),
      meta = Metadata(object),
      geom = object:as_linestring(),
    })
  end

end
