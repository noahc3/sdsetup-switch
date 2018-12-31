ordered_table = {}

function ordered_table.insert(t, k, v)
  if not rawget(t._values, k) then -- new key 
    t._keys[#t._keys + 1] = k
  end
  if v == nil then -- delete key too.
    ordered_table.remove(t, k)
  else -- update/store value
    t._values[k] = v 
  end
end

local function find(t, value)
  for i,v in ipairs(t) do
    if v == value then
      return i
    end
  end
end  

function ordered_table.remove(t, k)
  local v = t._values[k]
  if v ~= nil then
    table.remove(t._keys, find(t._keys, k))
    t._values[k] = nil
  end
  return v
end

function ordered_table.index(t, k)
    return rawget(t._values, k)
end

function ordered_table.pairs(t)
  local i = 0
  return function()
    i = i + 1
    local key = t._keys[i]
    if key ~= nil then
      return key, t._values[key]
    end
  end
end

function ordered_table.new(init)
  init = init or {}
  local t = {_keys={}, _values={}}
  local n = #init
  if n % 2 ~= 0 then
    error"in ordered_table initialization: key is missing value"
  end
  for i=1,n/2 do
    local k = init[i * 2 - 1]
    local v = init[i * 2]
    if t._values[k] ~= nil then
      error("duplicate key:"..k)
    end
    t._keys[#t._keys + 1]  = k
    t._values[k] = v
  end
  return setmetatable(t,
    {__newindex=ordered_table.insert,
    __len=function(t) return #t._keys end,
    __pairs=ordered_table.pairs,
    __index=t._values
    })
end

return ordered_table