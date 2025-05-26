package.path = package.path .. ";/processing/topics/helper/?.lua"
local dir = ";/processing/topics/roads_bikelanes/"
package.path = package.path .. dir .. "roads/?.lua"
package.path = package.path .. dir .. "maxspeed/?.lua"
package.path = package.path .. dir .. "surfaceQuality/?.lua"
package.path = package.path .. dir .. "lit/?.lua"
package.path = package.path .. dir .. "bikelanes/?.lua"
package.path = package.path .. dir .. "bikelanes/categories/?.lua"
package.path = package.path .. dir .. "bikeroutes/?.lua"
package.path = package.path .. dir .. "paths/?.lua"require("Set")
require("JoinSets")
require("Metadata")
require("MergeTable")
require("ExtractPublicTags")
require("Round")
require("DefaultId")


-- TODO: which of those are required?
require("Set")
require("JoinSets")
require("Metadata")
require("ExcludeHighways")
require("ExcludeByWidth")
require("ConvertCyclewayOppositeSchema")
require("Maxspeed")
require("Lit")
require("RoadClassification")
require("RoadGeneralization")
require("SurfaceQuality")
require("Bikelanes")
require("BikelanesPresence")
require("MergeTable")
require("CopyTags")
require("IsSidepath")
require("ExtractPublicTags")
require("Round")
require("DefaultId")
require("PathsGeneralization")
require("RoadTodos")
require("CollectTodos")
require("ToMarkdownList")
require("ToTodoTags")
require("BikeSuitability")
require("Log")


local roadsTable = osm2pgsql.define_table({
  name = 'cqi_roads',
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


local pathsTable = osm2pgsql.define_table({
  name = 'cqi_paths',
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
  local tags = object.tags

  -- ====== (A) Filter-Guards ======
  if not tags.highway then return end

  -- Skip stuff like "construction", "proposed", "platform" (Haltestellen), "rest_area" (https://wiki.openstreetmap.org/wiki/DE:Tag:highway=rest%20area)
  local allowed_highways = JoinSets({ HighwayClasses, PathClasses })
  if not allowed_highways[tags.highway] then return end

  -- Skip any area. See https://github.com/FixMyBerlin/private-issues/issues/1038 for more.
  if tags.area == 'yes' then return end

  -- ====== (B) General conversions ======
  -- Calculate and format length, see also https://github.com/osm2pgsql-dev/osm2pgsql/discussions/1756#discussioncomment-3614364
  -- Use https://epsg.io/5243 (same as `presenceStats.sql`); update `atlas_roads--length--tooltip` if changed.
  local length = Round(object:as_linestring():transform(5243):length(), 2)

  -- ====== (C) Compute results and insert ======
  local results = {
    name = tags.name or tags.ref or tags['is_sidepath:of:name'],
    length = length,
    _updated_age = AgeInDays(object.timestamp)
  }

  local publicTags = ExtractPublicTags(object)
  local meta = Metadata(object)
  -- meta.age = cycleway._age
  --
  local insert_table = {
    id = DefaultId(object),
    tags = publicTags,
    meta = meta,
    geom = object:as_linestring(),
  }

  if HighwayClasses[object.tags.highway] then
    roadsTable:insert(insert_table)
  elseif PathClasses[object.tags.highway] then
    pathsTable:insert(insert_table)
  end
end
