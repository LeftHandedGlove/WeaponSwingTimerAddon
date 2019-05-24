LHGWST_utils = {}

-- Sends the given message to the chat frame with the addon name in front.
LHGWST_utils.PrintMsg = function(msg)
	chat_msg = LHGWST_core.addon_name_message .. msg
	DEFAULT_CHAT_FRAME:AddMessage(chat_msg)
end

-- Rounds the given number to the given step.
-- If num was 1.17 and step was 0.1 then this would return 1.1
LHGWST_utils.SimpleRound = function(num, step)
    return floor(num / step) * step
end