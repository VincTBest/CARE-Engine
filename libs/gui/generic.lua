
function CreateConfig(d)
    local cfg = { Value = d }

    cfg.Set=function(v) cfg.Value=v end
    cfg.Get = function() return cfg.Value end

    return cfg
end
