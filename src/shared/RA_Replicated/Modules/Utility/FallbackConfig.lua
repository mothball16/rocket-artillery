-- saves a total of 1 (ONE!!!) line of code anywhere its used!!!

local conf = {}
conf.__index = conf

-- (args, fallbacks)
function conf.new(args, fallbacks)
    local self = {}
    self.table = {}
    for k,v in pairs(fallbacks) do
        self.table[k] = v
    end
    for k,v in pairs(args) do
        self.table[k] = v
    end
    self.fallbacks = fallbacks
    
    setmetatable(self, conf)
    return self
end

function conf:Rewrite(args)
    self.table = {}
    for k,v in pairs(self.fallbacks) do
        self.table[k] = v
    end
    for k,v in pairs(args) do
        self.table[k] = v
    end
end

function conf:Overwrite(args)
    self.table = args
end

-- (key)
function conf:Get(key)
    return self.table[key]
end

function conf:ToRaw()
    return self.table
end
return conf