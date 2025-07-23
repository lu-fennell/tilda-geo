-- TODO: the json lib should be stored in "helpers" or installed with luarocks, probably
local inspect = require('inspect')

-- TODO: annotate with type annotations
local function read_sidepath_set(path)
  print('TODO: start reading is_sidepath_set')
  local start = os.time()
  local linecount = 0
  local result = {}
  for l in io.lines(path) do
    linecount = linecount + 1
    local osm_id = tonumber(l)
    if osm_id == nil then
      print('ERROR: cannot parse key for line:', inspect(l))
      return
    end
    if result[osm_id] == nil then
      result[osm_id] = true
      else
        print('ERROR: duplicate entry', osm_id)
      end
  end
  print('TODO: done reading sidepath_dict in', os.difftime(os.time(), start), 's')
  print('  ids in is_sidpath_set: ', linecount)
  return result
end

---comment
---@param path string
---@return table
function IsSidepathSet(path)
  local sidepath_dict = nil
  return {
    get = function(self)
      if sidepath_dict == nil then
        sidepath_dict = read_sidepath_set(path)
      end
      return sidepath_dict
    end
  }
end

