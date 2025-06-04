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
require("Set")
require("JoinSets")
require("Metadata")
require("MergeTable")
require("HighwayClasses")
require("ExtractPublicTags")
require("Round")
require("DefaultId")

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


-- TODO: move to utility class
local function bicycle_ok(tags) return tags.bicycle == 'yes' or tags.bicycle == 'designated' or tags.bicycle  == 'permissive' end
function osm2pgsql.process_way(object)


 -- TODO: in the original script, classes are the following:
 --   road:  '"highway" IS NOT \'cycleway\' AND "highway" IS NOT \'footway\' AND "highway" IS NOT \'path\' AND "highway" IS NOT \'bridleway\' AND "highway" IS NOT \'steps\' AND "highway" IS NOT \'track\''
 --   path: '"highway" IS \'cycleway\' OR "highway" IS \'footway\' OR "highway" IS \'path\' OR "highway" IS \'bridleway\' OR "highway" IS \'steps\''
 -- which version is correct?
  local cqi_road_highway_classes = JoinSets({
    HighwayClasses,
    MajorRoadClasses,
    MinorRoadClasses
  })
  local cqi_path_highway_classes = PathClasses
  
  local tags = object.tags

  -- ====== (A) Filter-Guards ======
  if not tags.highway then return end

  -- Skip stuff like "construction", "proposed", "platform" (Haltestellen), "rest_area" (https://wiki.openstreetmap.org/wiki/DE:Tag:highway=rest%20area)
  -- local allowed_highways = JoinSets({ cqi_road_highway_classes, cqi_path_highway_classes })
  -- if not allowed_highways[tags.highway] then return end
  --

  -- TODO: test against overpass example
  if not (
 --  way["highway"="path"]["bicycle"!="no"]["bicycle"!="dismount"];
    (tags.highway == 'path' and tags.bicycle ~= 'no' and tags.bicycle ~= 'dismount') or
 --  way["highway"="footway"]["bicycle"="yes"];
 --  way["highway"="footway"]["bicycle"="designated"];
 --  way["highway"="footway"]["bicycle"="permissive"];
    (tags.highway == 'footway' and bicycle_ok(tags)) or
 --  way["highway"="bridleway"]["bicycle"="yes"];
 --  way["highway"="bridleway"]["bicycle"="designated"];
 --  way["highway"="bridleway"]["bicycle"="permissive"];
    (tags.highway == 'bridleway' and bicycle_ok(tags)) or
 --  way["highway"="steps"]["bicycle"="yes"];
 --  way["highway"="steps"]["bicycle"="designated"];
 --  way["highway"="steps"]["bicycle"="permissive"];
    (tags.highway == 'steps' and bicycle_ok(tags)) or
 -- way["highway"="cycleway"];
 --  way["highway"="motorway"];
 --  way["highway"="motorway_link"];
 --  way["highway"="trunk"];
 --  way["highway"="trunk_link"];
 --  way["highway"="primary"];
 --  way["highway"="primary_link"];
 --  way["highway"="secondary"];
 --  way["highway"="secondary_link"];
 --  way["highway"="tertiary"];
 --  way["highway"="tertiary_link"];
 --  way["highway"="unclassified"];
 --  way["highway"="residential"];
 --  way["highway"="living_street"];
 --  way["highway"="pedestrian"];
 --  way["highway"="road"];
--  way["highway"="track"];
    Set({
      "cycleway",
      "motorway",
      "motorway_link",
      "trunk",
      "trunk_link",
      "primary",
      "primary_link",
      "secondary",
      "secondary_link",
      "tertiary",
      "tertiary_link",
      "unclassified",
      "residential",
      "living_street",
      "pedestrian",
      "road",
      "track",
    })[tags.highway] or
 --  way["highway"="service"][!"service"];
 --  way["highway"="service"]["service"="alley"];
    (tags.highway == 'service' and (tags.service == nil or tags.service == 'alley')) or
 --  way["highway"="service"]["bicycle"="yes"];
 --  way["highway"="service"]["bicycle"="designated"];
 --  way["highway"="service"]["bicycle"="permissive"];
    (tags.highway == 'service' and bicycle_ok(tags))
  ) then return end

  -- Skip any area. See https://github.com/FixMyBerlin/private-issues/issues/1038 for more.
  if tags.area == 'yes' then return end

  -- ====== (B) Compute results and insert ======

  local publicTags = ExtractPublicTags(object)
  local meta = Metadata(object)

  local insert_table = {
    id = DefaultId(object),
    tags = publicTags,
    meta = meta,
    geom = object:as_linestring(),
  }

  if cqi_road_highway_classes[object.tags.highway] then
    roadsTable:insert(insert_table)
  elseif cqi_path_highway_classes[object.tags.highway] then
    pathsTable:insert(insert_table)
  end
end
