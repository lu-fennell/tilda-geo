package.path = package.path .. ";/processing/topics/helper/?.lua"
package.path = package.path .. ";/processing/topics/sidepath_estimation/relevant_ways/?.lua"

require("Set")
require("JoinSets")
require("Metadata")
require("MergeTable")
require("HighwayClasses")
require("ExtractPublicTags")
require("Round")
require("DefaultId")
require("IsSidepathRelevant")

local roadsTable = osm2pgsql.define_table({
  name = '_sidepath_estimation_roads',
  ids = { type = 'any', id_column = 'id', type_column = 'osm_type' },
  columns = {
    { column = 'tags',    type = 'jsonb' },
    { column = 'geom',    type = 'linestring' },
  },
  indexes = {
    { column = 'geom', method = 'gist' },
    { column = 'id',   method = 'btree', unique = true }
  }
})


local pathsTable = osm2pgsql.define_table({
  name = '_sidepath_estimation_paths',
  ids = { type = 'any', id_column = 'id', type_column = 'osm_type' },
  columns = {
    { column = 'tags',    type = 'jsonb' },
    { column = 'geom',    type = 'linestring' },
    { column = 'minzoom', type = 'integer' },
  },
  indexes = {
    { column = 'geom', method = 'gist' },
    { column = 'id',   method = 'btree', unique = true }
  }
})


function osm2pgsql.process_way(object)

  local road_highway_classes = JoinSets({
    HighwayClasses,
    MajorRoadClasses,
    MinorRoadClasses
  })
  local path_highway_classes = PathClasses
  
  local tags = object.tags

  -- ====== (A) Filter-Guards ======
  if not tags.highway then return end

  -- Skip ways that are not relevant for sidepath estimation
  -- if not IsSidepathRelevant(tags) then return end
   
  -- Skip any area. See https://github.com/FixMyBerlin/private-issues/issues/1038 for more.
  if tags.area == 'yes' then return end


  -- ====== (B) Compute results and insert ======

  local publicTags = ExtractPublicTags(object)

  local insert_table = {
    tags = publicTags,
    geom = object:as_linestring(),
  }

  if road_highway_classes[object.tags.highway] then
    roadsTable:insert(insert_table)
  elseif path_highway_classes[object.tags.highway] then
    pathsTable:insert(insert_table)
  end
end
