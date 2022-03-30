
-- Convert the raw ui strings into search patterns
local function topattern(str)
	if not str then return "" end
	str = gsub(str, "%%%d?$?c", ".+")
	str = gsub(str, "%%%d?$?d", "%%d+")
	str = gsub(str, "%%%d?$?s", ".+")
	str = gsub(str, "([%(%)])", "%%%1")
	return str
end

-- Used to detect whether the system message was a login or logout message
local patterns = {
	-- topattern(ERR_FRIEND_OFFLINE_S),
	topattern(ERR_FRIEND_ONLINE_SS),
}

-- Create a frame and register to the system messages
local f = CreateNewFrame("WbAuto")
f:RegisterEvent("CHAT_MSG_SYSTEM")

-- On receiving a message, check if it matches the login pattern
f:SetScript("OnEvent", function (self, event, message, ...)
	if event == "CHAT_MSG_SYSTEM" then
		for i = 1, #patterns do
			if msg:match(pattern) then
				-- if it does, then send a
				SendChatMessage("wb", "GUILD")
			end
		end
	end
end)
