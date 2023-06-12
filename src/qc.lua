local QC = {}

function QC:Error(Text)
	warn("ERROR: "..Text)
end

function QC:Warn(Text)
	warn("WARNING: "..Text)
end

function QC:Print(Text)
	__io.write(Text .. "\n")
end

return QC