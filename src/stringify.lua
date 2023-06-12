local stringify = {}

function stringify.split(str, a)	
	local result = {}
    local pattern = string.format("([^%s]+)", a)
    
    for substring in str:gmatch(pattern) do
        table.insert(result, substring)
    end
    
    return result
end

return stringify