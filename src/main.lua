local Params = {}

__love = love
love = {}
__os = os
os = {}
__io = io
io = {}

for line in __love.filesystem.lines("params/quiet.txt") do
    local n = tostring(line):gsub("%s", "")
    Params.q = tonumber(n)
end

__params = Params

--

local fileInfo = __love.filesystem.getInfo("env/main.sb")

if fileInfo and fileInfo.type == "file" then
    if Params.q == 0 then
        print("Loading libraries")
    end   

    local sb = require("sb")

    --__os.execute("cls")

    --#region

    local code = ""
    for line in __love.filesystem.lines("env/main.sb") do
        code = code .. line .. "\n"
    end

    sb:Run(code)
else
    print("main.sb does not exist")
end

if Params.q == 0 then
    print("Exiting Scratch Basic")
end

__os.exit(0, true) -- close everything