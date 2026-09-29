
function CreateConfig(d)
    local cfg = { Value = d }

    cfg.Set=function(v) cfg.Value=v end
    cfg.Get = function() return cfg.Value end

    return cfg
end

function FindCenter(w1, w2)
    return w1/2 - w2/2
end
