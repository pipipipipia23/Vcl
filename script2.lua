--!strict

-- [[ Prevent some bugs ]]
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer:FindFirstChild('leaderstats')
task.wait(1)

-- [[ Luraph ENV ]]
if not LPH_OBFUSCATED then
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_NO_UPVALUES = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_JIT = function(...) return ... end
    LPH_ENCSTR = function(...) return ... end
    LPH_ENCNUM = function(...) return ... end
end

-- [[ Secure current script ]]
for i = 0, 1 do
    local this : LocalScript = getfenv(i).script
    if not this or this ~= script then -- Executor issue
        clonefunction(cloneref(game.Players.LocalPlayer).Kick)(game.Players.LocalPlayer, 'Executor Issue')
        task.wait(1)
        while true do debug.traceback() end
    end

    this.Name = ''
    this.Parent = nil
end

-- [[ Add missing executor's ENVs ]]
getgenv().isnetworkowner = isnetworkowner or function(part) return part.ReceiveAge == 0 end
getgenv().cloneref = cloneref or (function()
    loadstring("local a=Instance.new('Part')for b,c in pairs(getreg())do if type(c)=='table'and#c then if rawget(c,'__mode')=='kvs'then for d,e in pairs(c)do if e==a then getgenv().InstanceList=c;break end end end end end;local f={}function f.invalidate(g)if not InstanceList then return end;for b,c in pairs(InstanceList)do if c==g then InstanceList[b]=nil;return g end end end;if not cloneref then getgenv().cloneref=f.invalidate end")()
    return getgenv().cloneref
end)()
getgenv().clonefunction = clonefunction or newcclosure(function(...) return newcclosure(...) end)
getgenv().request = (request or http_request) or newcclosure(function(tbl)
    return warn('Bad executor')
end)
getgenv().log = function(...)
    if LPH_OBFUSCATED then return end
    return print('[DEBUG]', ...)
end

-- [[ Custom Local ENVs ]]
PLACE_ID = game.PlaceId :: number?
JOB_ID = game.JobId :: string?
CLIENT_FPS = 60 :: number

-- [[ Services ]]
local Services = setmetatable({}, {
    __index = function(self, serviceName)
        return cloneref(game:Services(serviceName))
    end,
    __newindex = function()
        while true do end
    end,
    __tostring = function()
        while true do end
    end,
    __call = function(self, serviceName)
        return cloneref(game:GetService(serviceName))
    end
})

local coreGui : CoreGui = cloneref(game.CoreGui)
local workspace : Workspace = Services('Workspace')
local playerService : Players = Services('Players')
local replicatedStorage : ReplicatedStorage = Services('ReplicatedStorage')
local httpService : HttpService = Services('HttpService')
local teleportService : TeleportService = Services('TeleportService')
local runService : RunService = Services('RunService')

-- [[ Varibles ]]
local player : Player = Services('Players').LocalPlayer
local playerGui : PlayerGui= player:WaitForChild('PlayerGui')
local playerScripts : Folder = player:WaitForChild('PlayerScripts')

local knit = require(replicatedStorage.Packages.Knit)
local rebirthsList = require(replicatedStorage.Shared.List.Rebirths)

-- [[ Functions ]]
local char : () -> Model
char = LPH_NO_VIRTUALIZE(function()
    if player.Character and 
       player.Character:IsDescendantOf(workspace) and
       player.Character:FindFirstChild('HumanoidRootPart') and
       player.Character:FindFirstChild('Humanoid') and
       player.Character.Humanoid.Health > 0 then
        return player.Character
    end
    
    task.wait()
    return char()
end)

local function safeTaskWait(time : number)
    time = time or 0
    return task.wait(time * (CLIENT_FPS / 60))
end

-- [[ Modules ]]
local userModule = {}
userModule.__index = userModule

function userModule.__new()
    local self = setmetatable({}, userModule)
    return self
end

function userModule:__init()
    self.clickService = knit.GetService('ClickService')
    self.rebirthService = knit.GetService('RebirthService')
    self.dataController = knit.GetController('DataController')
    self.rebirthsList = rebirthsList

    local lastUpdateTime : number = os.time()
    local frameCount : number = 0

    runService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
        frameCount = frameCount + 1
    
        local currentTime : number = tick()
        local elapsed : number = currentTime - lastUpdateTime
    
        if elapsed >= 1 then
            CLIENT_FPS = math.floor(frameCount / elapsed)
            frameCount = 0
            lastUpdateTime = currentTime
        end
    end))

    coreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(obj : any)
        if obj.Name == 'ErrorPrompt' then
            repeat
                teleportService:Teleport(PLACE_ID, player)
                task.wait()
            until false
        end
    end)
end

function userModule:getMapToUnlock()
    return tonumber(self.dataController.data.maps[#self.dataController.data.maps]) + 1
end

function userModule:click()
    self.clickService.click:Fire()
end

function userModule:rebirth()
    for i = #self.rebirthsList, 1, -1 do
        self.rebirthService:rebirth(self.rebirthsList[i])
    end
end

function userModule:farm()
    local needToUnlock = self:getMapToUnlock()
    local quest = self.dataController.data.mapQuests
    if needToUnlock == 2 then
        
    end
end

-- [[ Init ]]
local user = userModule.__new()
user:__init()

task.spawn(function()
    while safeTaskWait(0) do
        user:click()
        task.spawn(user.rebirth, user)
    end
end)
