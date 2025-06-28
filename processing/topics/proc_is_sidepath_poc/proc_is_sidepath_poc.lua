package.path = package.path .. ";/processing/topics/helper/?.lua"
local dir = ";/processing/topics/proc_is_sidepath_poc/"
package.path = package.path .. dir .. "sidepath/?.lua"

require('HighwayClasses')
require('Sidepath')
require('DefaultId')
require('ExtractPublicTags')
require('Metadata')

local is_sidepath_set = IsSidepathSet('/data/hashes/is_sidepath.idlines.txt')

local paths_table = osm2pgsql.define_table({
  name = 'with_proc_is_sidepath',
  ids = { type = 'any', id_column = 'osm_id', type_column = 'osm_type' },
  columns = {
    { column = 'id',      type = 'text'  },
    { column = 'tags',    type = 'jsonb' },
    { column = 'meta',    type = 'jsonb' },
    { column = 'geom',    type = 'linestring' },
    { column = 'minzoom', type = 'integer' },
  },
  indexes = {
    { column = 'geom', method = 'gist' },
    { column = 'id',   method = 'btree', unique = true }
  }
})


function osm2pgsql.process_way(object)
  -- SidpathDict.get will only load the dict once
  local tags = object.tags
  local id =  tonumber(object.id)

  local s = is_sidepath_set:get()
  if PathClasses[tags.highway] and s[id] then
    tags.proc_is_sidepath = 'yes'
  else
    tags.proc_is_sidepath = 'no'
  end
  if PathClasses[tags.highway] then
    paths_table:insert({
      id = DefaultId(object),
      tags = ExtractPublicTags(object),
      meta = Metadata(object),
      geom = object:as_linestring(),
    })
  end

end
