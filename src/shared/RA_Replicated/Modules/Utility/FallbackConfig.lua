-- saves a total of 1 (ONE!!!) line of code anywhere its used!!!

local conf = {}
conf.__index = conf

-- (args, fallbacks)
function conf.new(args, fallbacks)
    local self = {}

    for k,v in pairs(fallbacks) do
        self[k] = v
    end
    for k,v in pairs(args) do
        self[k] = v
    end
    
    setmetatable(self, conf)
    return self
end

-- (key)
function conf:Get(key)
    return self[key]
end

return conf