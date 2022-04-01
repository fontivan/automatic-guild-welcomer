-- Return the first element from a string split operation
function WbAuto_GetFirstElement (input, sep)

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
		return WbAuto_TrimString(str)
	end
end

-- Trim any excess whitespace from the string
function WbAuto_TrimString(input)

	-- Protect against a bad input
	if input == nil
	then
		return ""
	end

	-- Return the trimmed string
	return string.gsub(input, "%s+", "")
end

-- Create a frame and register to the system messages
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_SYSTEM")

-- Detection strings that will trigger the addon
local patterns = {
	"has come online."
};

-- On receiving a message, run this function
f:SetScript("OnEvent", function (self, event, message, ...)

	-- Check if the message was valid based on the detection strings
	local valid = false
	for _, pattern in pairs(patterns) do
		if message:match(pattern) then
			valid = true
			break
		end
	end

	-- If the event was not valid then do nothing
	if not valid then
		return
	end

	-- If we aren't in a guild then do nothing
	if not IsInGuild() then
		return
	end

	-- Fetch the number of players in the guild
	local player_count = GetNumGuildMembers()

	-- Strip the player name of the person who just logged in
	-- Substring to remove the first and last characters since they are square brackets
	local detected_player = WbAuto_GetFirstElement(message)

	-- Loop over the player indexes and see if any of them were the player that logged in
	for i=1,player_count+1 do

		-- Get the name of the guild member of that index position
		local guild_member = WbAuto_GetFirstElement(GetGuildRosterInfo(i), "-")

		-- If the person that just logged in is in our guild then welcome them back
		if detected_player:match(guild_member) then
			SendChatMessage("wb", "GUILD")
			return
		end
	end
end)
