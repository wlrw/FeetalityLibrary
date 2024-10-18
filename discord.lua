local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local vynixuModules = {
	Functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()
}
local assets = {
    NotificationSound = LoadCustomAsset("https://github.com/RegularVynixu/Utilities/raw/main/Discord%20Inviter/Assets/Notification.mp3")
}
local module = {}

local function getInviteCode(sInvite)
    for i = #sInvite, 1, -1 do
        local char = sInvite:sub(i, i)
        if char == "/" then
            return sInvite:sub(i + 1, #sInvite)
        end
    end
    return sInvite
end

local function getInviteData(sInvite)
    local success, result = pcall(function()
		return HttpService:JSONDecode(request({
            Url = "https://ptb.discord.com/api/invites/".. getInviteCode(sInvite),
            Method = "GET"
        }).Body)
	end)
    if not success then
        warn("Failed to get invite data:\n".. result)
        return
    end
    return success, result
end

module.Join = function(sInvite)
    assert(type(sInvite) == "string", "<string> Invalid invite provided")
    local success, result = getInviteData(sInvite)
	if success and result then
        request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                args = {
                    code = result.code
                },
                nonce = HttpService:GenerateGUID(false)
            })
        })
        
        local sound = Instance.new("Sound")
        sound.Volume = 1
        sound.PlayOnRemove = true
        sound.SoundId = assets.NotificationSound
        sound:Destroy()
	end
end

-- Main
return module
