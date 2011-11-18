class ShortcutGrinder < OSX::NSObject

def evaluate(filename)
	filename.split("\n").each do |line|
		OSX::NSLog("Ligne")
	end
end

end
