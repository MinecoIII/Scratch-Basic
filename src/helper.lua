vlua = {}

local love = __love

function vlua.exit() -- exits or stops the program -> nil 
    if __params.q == 0 then
        print("Exiting Lua")
    end
    __os.exit(0, true)
end

function vlua.read(prefix) -- Gets the command prompt input, prefix?: string? | nil, -> nil
    __io.write(tostring(prefix or ""))
    local v = __io.read()

    return v
end

vlua.__index = vlua
return vlua