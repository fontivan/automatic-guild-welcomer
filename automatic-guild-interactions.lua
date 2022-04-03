
-- Patterns to be matched against
local login_patterns = {
	"has come online."
};

local level_patterns = {
	"Congratulations, you have reached level"
};

local guild_level_up_patterns = {
	"ding"
};

-- Timestamp for the last message sent
local last_message_sent = 0;

-- Minimum time between message (seconds)
local min_message_time = 10;

-- Rate limited function to send messages to chat channel
function AutoGuild_SendMessage(message, channel)

	-- Check if the message is valid
	if message == nil or message == "" then
		return;
	end

	-- Check if the channel is valid
	if channel == nil or channel == "" then
		return;
	end

	-- Get the current timestamp (epoch in seconds)
	local current_time = time(date("!*t"));

	-- Check against the last timestamp
	-- The current time must be greater then the last time 
	-- the message was sent plus the minimum time between messages
	if current_time > min_message_time + last_message_sent then

		-- Send the chat message
		SendChatMessage(message, channel);

		-- Record the time we sent the message
		last_message_sent = current_time;

	end

	return;
end

-- Send a level up message to guild chat
function AutoGuild_LevelUp()
	AutoGuild_SendMessage("ding", "GUILD");
	return;
end

-- Send a grats message to guild chat
function AutoGuild_Grats()
	AutoGuild_SendMessage("grats", "GUILD");
	return;
end

-- Trim any excess whitespace from the string
function AutoGuild_TrimString(input)

	-- Protect against a bad input
	if input == nil
	then
		return "";
	end

	-- Return the trimmed string
	return string.gsub(input, "%s+", "");
end

-- Return the first element from a string split operation
function AutoGuild_GetFirstElement (input, sep)

	-- Protect against a bad input
	if input == nil then
		return "";
	end

	-- Protect againt an optional argument
	if sep == nil then
			sep = "%s";
	end

	-- Return the first match from the separator.
	for str in string.gmatch(input, "([^"..sep.."]+)") do
		return AutoGuild_TrimString(str);
	end
end

-- Check if the player that logged in was a guildy, and if so, send a welcome message
function AutoGuild_WelcomeBack(message)

	-- Fetch the number of players in the guild
	local player_count = GetNumGuildMembers();

	-- Strip the player name of the person who just logged in
	local detected_player = AutoGuild_GetFirstElement(message);

	-- Loop over the player indexes and see if any of them were the player that logged in
	for i=1,player_count+1 do

		-- Get the name of the guild member of that index position
		local guild_member = AutoGuild_GetFirstElement(GetGuildRosterInfo(i), "-");

		-- If the person that just logged in is in our guild then welcome them back
		if detected_player:match(guild_member) then
			AutoGuild_SendMessage("wb", "GUILD");
			return;
		end
	end
end

-- Create a frame and register to the system messages
local AutoGuildFrame = CreateFrame("Frame");
AutoGuildFrame:RegisterEvent("CHAT_MSG_SYSTEM");
AutoGuildFrame:RegisterEvent("PLAYER_LEVEL_UP");
AutoGuildFrame:RegisterEvent("CHAT_MSG_GUILD");

-- On receiving a message, run this function
AutoGuildFrame:SetScript("OnEvent", function (self, event, message, ...)

	-- If we aren't in a guild then do nothing
	if not IsInGuild() then
		return;
	end

	-- Check if its a system message
	if event == "CHAT_MSG_SYSTEM" then

		-- Check if the message was a login message
		for _, pattern in pairs(login_patterns) do
			if message:match(pattern) then
				AutoGuild_WelcomeBack(message);
				return;
			end
		end

	-- end CHAT_MESSAGE_SYSTEM
	end

	-- Check if its a level up
	if event == "PLAYER_LEVEL_UP" then
		AutoGuild_LevelUp();
		return;
	-- end PLAYER_LEVEL_UP
	end

	-- Check if its a guild message
	if event == "CHAT_MSG_GUILD" then

		-- Check against the patterns for incoming level up messages
		for _, pattern in pairs(guild_level_up_patterns) do
			if message:match(pattern) then
				AutoGuild_Grats();
				return;
			end
		end
	
	-- end CHAT_MSG_GUILD
	end

end);
