local Utils = {}

Utils.random = math.random

math.randomseed(os.time())

function Utils.MergeTables(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                Utils.MergeTables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function Utils.UUID() 
    local template ='xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and Utils.random(0, 0xf) or Utils.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function Utils.TableContains(t, value)
    for i=1,table.maxn(t) do
        if t[i] == value then return true end
    end

    return false
end

function Utils.TableFind(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

return Utils