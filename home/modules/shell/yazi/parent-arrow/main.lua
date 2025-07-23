local function entry(_, args)
	local parent = cx.active.parent
	if not parent then return end

	local target = parent.files[parent.cursor + 1 + args[1]]
	if target and target.cha.is_dir then
		ya.emit("cd", { target.url })
	end
end

return { entry = entry }
