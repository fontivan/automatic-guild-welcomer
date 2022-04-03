-- Return the first element from a string split operation
local function AutoGuild_GetFirstElement (input, sep)

	-- Protect against a bad input
	if input == nil then
		return ""
	end

	-- Protect againt an optional argument
	if sep == nil then
			sep = "%s"
	end

	-- Return the first match from the separator.
	for str in string.gmatch(input, "([^"..sep.."]+)") do
		return AutoGuild_TrimString(str)
	end
end

-- Trim any excess whitespace from the string
local function AutoGuild_TrimString(input)

	-- Protect against a bad input
	if input == nil
	then
		return ""
	end

	-- Return the trimmed string
	return string.gsub(input, "%s+", "")
end

-- Check if the player that logged in was a guildy, and if so, send a welcome message
local function AutoGuild_WelcomeBack(message)

	-- Fetch the number of players in the guild
	local player_count = GetNumGuildMembers()

	-- Strip the player name of the person who just logged in
	local detected_player = AutoGuild_GetFirstElement(message)

	-- Loop over the player indexes and see if any of them were the player that logged in
	for i=1,player_count+1 do

		-- Get the name of the guild member of that index position
		local guild_member = AutoGuild_GetFirstElement(GetGuildRosterInfo(i), "-")

		-- If the person that just logged in is in our guild then welcome them back
		if detected_player:match(guild_member) then
			SendChatMessage("wb", "GUILD")
			return
		end
	end

end

-- Send a level up message to guild chat
local function AutoGuild_LevelUp()
	SendChatMessage("ding", "GUILD")
	return
end

-- Create a frame and register to the system messages
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")

-- Detection strings that will trigger the addon
local login_patterns = {
	"has come online."
};

local level_patterns = {
	"Congratulations, you have reached level"
};

-- On receiving a message, run this function
f:SetScript("OnEvent", function (self, event, message, ...)

	-- If we aren't in a guild then do nothing
	if not IsInGuild() then
		return
	end

	-- Check if the message was a login message
	for _, pattern in pairs(login_patterns) do
		if message:match(pattern) then
			AutoGuild_WelcomeBack(message)
			return
		end
	end

	-- Check if the message was a level up message
	for _, pattern in pairs(level_patterns) do
		if message:match(pattern) then
			AutoGuild_LevelUp()
			return
		end
	end

end)
