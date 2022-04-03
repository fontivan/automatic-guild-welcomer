
-- Global table for storing everything
local AutoGuild = {
	patterns = {
		login = {
			"has come online."
		},
		level = {
			"ding"
		}
	},
	rate_limit = {
		last_message_sent = 0,
		min_message_time = 10
	},
	frame = {}
};

-- Rate limited function to send messages to chat channel
function AutoGuild:SendMessage(message, channel)

	-- Check if the message is valid
	if message == nil or message == "" then
		return;
	end

	-- Check if the channel is valid
	if channel == nil or channel == "" then
		return;
	end

	-- Get the current timestamp (epoch in seconds)
	-- luacheck: push ignore 113
	local current_time = time(date("!*t"));
	-- luacheck: pop

	-- Check against the last timestamp
	-- The current time must be greater then the last time
	-- the message was sent plus the minimum time between messages
	if current_time > AutoGuild.rate_limit.min_message_time + AutoGuild.rate_limit.last_message_sent then

		-- Send the chat message
		-- luacheck: push ignore 113
		SendChatMessage(message, channel);
		-- luacheck: pop

		-- Record the time we sent the message
		AutoGuild.rate_limit.last_message_sent = current_time;

	end

	return;
end

-- Trim any excess whitespace from the string
function AutoGuild:TrimString(input)

	-- Protect against a bad input
	if input == nil
	then
		return "";
	end

	-- Return the trimmed string
	return string.gsub(input, "%s+", "");
end

-- Return the first element from a string split operation
function AutoGuild:GetFirstElement (input, sep)

	-- Protect against a bad input
	if input == nil then
		return "";
	end

	-- Protect againt an optional argument
	if sep == nil then
			sep = "%s";
	end

	-- Return the first match from the separator.
	results = string.gmatch(input, "([^"..sep.."]+)")
	return results[1]
end

-- Check if the player that logged in was a guildy, and if so, send a welcome message
function AutoGuild:WelcomeBack(message)

	-- Fetch the number of players in the guild
	-- luacheck: push ignore 113
	local player_count = GetNumGuildMembers();
	-- luacheck: pop

	-- Strip the player name of the person who just logged in
	local detected_player = AutoGuild.GetFirstElement(message);

	-- Loop over the player indexes and see if any of them were the player that logged in
	for i=1,player_count+1 do

		-- Get the name of the guild member of that index position
		-- luacheck: push ignore 113
		local guild_member = AutoGuild.GetFirstElement(GetGuildRosterInfo(i), "-");
		-- luacheck: pop

		-- If the person that just logged in is in our guild then welcome them back
		if detected_player:match(guild_member) then
			AutoGuild.SendMessage("wb", "GUILD");
			return;
		end
	end
end

-- Create a frame and register to the system messages
-- luacheck: push ignore 113
AutoGuild.frame = CreateFrame("Frame");
-- luacheck: pop
AutoGuild.frame:RegisterEvent("CHAT_MSG_SYSTEM");
AutoGuild.frame:RegisterEvent("PLAYER_LEVEL_UP");
AutoGuild.frame:RegisterEvent("CHAT_MSG_GUILD");

-- On receiving a message, run this function
AutoGuild.frame:SetScript("OnEvent", function (_, event, message, ...)

	-- If we aren't in a guild then do nothing
	-- luacheck: push ignore 113
	if not IsInGuild() then
	-- luacheck: pop
		return;
	end

	-- Check if its a system message
	if event == "CHAT_MSG_SYSTEM" then

		-- Check if the message was a login message
		for _, pattern in pairs(AutoGuild.patterns.login) do
			if message:match(pattern) then
				AutoGuild.WelcomeBack(message);
				return;
			end
		end

	-- end CHAT_MESSAGE_SYSTEM
	end

	-- Check if its a level up
	if event == "PLAYER_LEVEL_UP" then
		AutoGuild.SendMessage("ding", "GUILD");
		return;
	-- end PLAYER_LEVEL_UP
	end

	-- Check if its a guild message
	if event == "CHAT_MSG_GUILD" then

		-- Check against the patterns for incoming level up messages
		for _, pattern in pairs(AutoGuild.patterns.level) do
			if message:match(pattern) then
				AutoGuild.SendMessage("grats", "GUILD");
				return;
			end
		end

	-- end CHAT_MSG_GUILD
	end

end);
