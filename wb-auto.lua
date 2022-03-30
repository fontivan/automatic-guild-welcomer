
-- Used to detect whether the system message was a login or logout message
local WbAuto_LoginMessage = ERR_FRIEND_ONLINE_SS:gsub("|Hplayer:%%s|h%[%%s%]|h", "|Hplayer:.+|h%%[.+%%]|h")

-- Returns true if the message matches the login format.
local function WbAuto_IsLoginMessage(msg)
	if msg.find(WbAuto_LoginMessage) then
		return true
	end
	return false
end

-- Send the WB message if the event was a login message
local function WbAuto_SendWbMessage(self, event, msg)
	SendChatMessage("wb", "GUILD")
end

-- The filter is used to grab all messages matching the filter
local function WbAuto_LoginMessageFilter(self, event, msg)
	return WbAuto_IsLoginMessage(msg)
end

-- Create a frame and set up the wb
local WbAutoFrame = CreateFrame("WbAuto")
WbAutoFrame:RegisterEvent("CHAT_MSG_SYSTEM")
WbAutoFrame:SetScript("OnEvent", WbAuto_SendWbMessage)

-- Add the filter to the chat frame
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", WbAuto_LoginMessageFilter)
