-- TODO: the json lib should be stored in "helpers" or installed with luarocks, probably
local dir = ";/processing/topics/cqi/"
package.path = package.path .. dir .. "sidepath_dict/?.lua"
local json = require('json')

-- TODO: annotate with type annotations
local function read_sidepath_dict(path)
  print('TODO: start reading sidepath_dict')
  local start = os.time()
  local linecount = 0
  local buffercount = 0
  local result = {}
  for l in io.lines(path) do
    linecount = linecount + 1
    local json_line = json.decode(l)
    local buffer_id, count, road_ids, road_highways, road_names = table.unpack(json_line)
    if result[buffer_id] == nil then
      buffercount = buffercount + 1
      result[buffer_id] = {
        count = count,
        road_ids = road_ids,
        road_highways = road_highways,
        road_names = road_names
      }
      else
        print('ERROR: duplicate entry', buffer_id)
      end
  end
  print('TODO: done reading sidepath_dict in', os.difftime(os.time(), start), 's')
  print('  LINES in sidpath_dict jsonl: ', linecount)
  print('  ENTRIES in sidepath dict: ', buffercount)
  return result
end


local function read_sidepath_dicts(path)
  print('TODO: start reading sidepath_dict')
  local start = os.time()
  local linecount = 0
  local buffercount = 0
  local result = {
    counts = {},
    road_ids = {},
    highways = {},
    names = {},
  }
  for l in io.lines(path) do
    linecount = linecount + 1
    local json_line = json.decode(l)
    local buffer_id, count, road_ids, road_highways, road_names = table.unpack(json_line)
    if result.counts[buffer_id] == nil then
      buffercount = buffercount + 1
      result.counts[buffer_id] = count
      result.road_ids[buffer_id] = road_ids
      result.highways[buffer_id] = road_highways
      result.names[buffer_id] = road_names
      else
        print('ERROR: duplicate entry', buffer_id)
      end
  end
  print('TODO: done reading sidepath_dict in', os.difftime(os.time(), start), 's')
  print('  LINES in sidpath_dict jsonl: ', linecount)
  print('  ENTRIES in sidepath dict: ', buffercount)
  return result
end

--- @param t { [string]: number }
--- @return number?
local function maxvalue(t)
  local m = nil
  for _, v in pairs(t) do
    if not m or v > m then
      m = v
    end
  end
  return m
end

--- @param count number
--- @param t { [string]: number }
--- @return boolean
function IsSidepath(count, t)
  local mv = maxvalue(t)
  return mv ~= nil and count * 0.66 <= mv
end


-- TODO: could be a general helper function for "lazy-init" globals
-- TODO: SidepathDict is a bad name
function SidepathDict(path)
  local sidepath_dict = nil
  return {
    get = function(self)
      if sidepath_dict == nil then
        sidepath_dict = read_sidepath_dict(path)
      end
      return sidepath_dict
    end
  }
end

-- TODO: remove after benchmark
function SidepathDicts(path)
  local sidepath_dicts = nil
  return {
    get = function(self)
      if sidepath_dicts == nil then
        sidepath_dicts = read_sidepath_dicts(path)
      end
      return sidepath_dicts
    end
  }
end


