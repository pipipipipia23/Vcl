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
DAY_RESET_TIME = 86400 :: number?

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

-- [[ Knit ]]
local knit = require(replicatedStorage.Packages.Knit)
local upgradesList = require(replicatedStorage.Shared.List.Upgrades)
local playtimeRewardsList = require(replicatedStorage.Shared.List.PlaytimeRewards)
local achievementsList = require(replicatedStorage.Shared.List.Achievements)
local farmsList = require(replicatedStorage.Shared.List.Farms)
local eggs = require(replicatedStorage.Shared.List.Pets.Eggs)
local clickService = knit.GetService('ClickService')
local rebirthService = knit.GetService('RebirthService')
local upgradeService = knit.GetService('UpgradeService')
local dataController = knit.GetController('DataController')
local rewardService = knit.GetService('RewardService')
local farmService = knit.GetService('FarmService')
local fallingStarsController = knit.GetController('FallingStarsController')
local fallingStarsService = knit.GetService('FallingStarsService')
local eggService = knit.GetService('EggService')
local prestigeService = knit.GetService('PrestigeService')
local utils = require(replicatedStorage.Shared.Util)
local petService = knit.GetService('PetService')
local values = require(replicatedStorage.Shared.Values)

-- [[ Sub Functions ]]
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

local function safeTaskWait(time : number) : number
    time = time or 0
    return task.wait(time * (CLIENT_FPS / 60))
end

local function fireRemote(remote, ...) : any
    return remote.Fire(remote, ...)
end

local function callRemote(remote, ...) : any
    return remote(remote, ...)
end

-- [[ Main Functions ]]
local function click() : any
    clickService.click:Fire()
end

local function rebirth() : any
    local success, value = pcall(function()
        return dataController.data.upgrades.rebirthButtons
    end)

    local rebirthValue = 3 + ((success and value) or 0)
    rebirthService:rebirth(rebirthValue)
end

local function upgrade() : any
    for i, v in pairs(upgradesList) do
        if i ~= 'freeAutoClicker' then
            local data = dataController.data['upgrades'][i]
            if data then
                local final = v.upgrades[data + 1]
                if final ~= nil then
                    if dataController.data.gems >= final.cost then
                        upgradeService:upgrade(i)
                    end
                end
            else
                if v.upgrades[1].cost <= dataController.data.gems then
                    upgradeService:upgrade(i)
                end
            end
        end
    end
end

local function collectChest() : any
    for i,v in pairs(workspace.Game.Maps:GetChildren()) do
        if v:FindFirstChild('MiniChests') then
            for i1,v1 in pairs(v.MiniChests:GetChildren()) do
                if v1:FindFirstChild('Touch') then
                    local id = v1:GetAttribute('miniChestId');
                    local name = v1:GetAttribute('miniChestName');
                    if dataController.data.miniChests[name] then
                        v1:Destroy()
                    else
                        rewardService:claimMiniChest(id, name)
                    end
                end
            end
        end
    end
end

function claimPlaytimeRewards() : any
    for i,v in pairs(playtimeRewardsList) do
        local sessionTime : number = dataController.data['sessionTime']
        local claimedTable : table = dataController.data['claimedPlaytimeRewards']
        if table.find(claimedTable, i) == nil and (v.required - sessionTime) <= 0 then
            rewardService:claimPlaytimeReward(i)
        end
    end
end

function claimDaily() : any
    local dayReset = dataController.data['dayReset']
    if workspace:GetServerTimeNow() - dayReset > DAY_RESET_TIME then
        rewardService:claimDailyReward()
    end
end

function claimAchievements() : any
    for i, v in pairs(achievementsList) do
        rewardService:claimAchievement(i)
    end
end

function farmer() : any
    for i, v in pairs(farmsList) do
        local hasUnlock = dataController.data.farms[i]
        if hasUnlock then
            local data = hasUnlock
            local datareal = v.upgrades
            local nexup = datareal[data.stage + 1]
            if nexup ~= nil then
                if nexup.price <= dataController.data.gems then
                    farmService:upgrade(i)
                end
            end
        else
            farmService:buy(i)
        end
    end
end

function claimFarm() : any
    for i, v in pairs(dataController.data.farms) do
        if i ~= 'farmer' then
            farmService:claim(i)
            wait(2)
        end
    end
end

function claimFallingStars() : any
    for i,v in pairs(fallingStarsController._debounce) do
        fallingStarsService:claimStar(i)
    end
end

function openEgg()
    local eggName = 'Basic'
    for i,v in pairs(eggs) do
        if v.requiredMap == #dataController.data['maps'] and v.cost < dataController.data.clicks then
            eggName = i
            fireRemote(eggService.openEgg, eggName, 99)
            break
        end
    end
    if eggName == 'Basic' then
        if eggs[eggName].cost < dataController.data.clicks then
            fireRemote(eggService.openEgg, eggName, 99)
        end
    end
end

local function callAnotherFunctions() : any
    prestigeService:claim()
    rebirth()
    upgrade()
    claimAchievements()
    claimDaily()
    claimFallingStars()
    claimFarm()
    collectChest()
end

local function equipBest()
    local petInventory = dataController.data.inventory.pet
    local tbl = {}
    for id, petData in next, petInventory do
        local data = utils.itemUtils.getItemFromId(dataController.data, id)
        tbl[#tbl+1] = {
            itemId = id,
            item = data
        }
    end

    table.sort(tbl, function(a, b)
        return a.item:getMultiplier(dataController.data, {
            ignoreServer = true
        }) > b.item:getMultiplier(dataController.data, {
            ignoreServer = true
        })
    end)

    local tbl2 = {};
    for _, v240 in tbl do
        if #tbl2 < values.petsEquipped(player, dataController.data) then
            for _ = 1, v240.item:getAmount() do
                if #tbl2 < values.petsEquipped(player, dataController.data) then
                    tbl2[#tbl2 + 1] = v240.itemId
                else
                    break
                end
            end
        else
            break
        end
    end

    local v242 = {}
    for v243, _ in dataController.data.equippedPets do
        v242[#v242 + 1] = v243
    end
    petService:unequipPet(v242)
    petService:equipPet(tbl2)
end

-- [[ Init ]]
task.spawn(function()
    while safeTaskWait(0) do
        click()
    end
end)

task.spawn(function()
    while safeTaskWait(1) do
        pcall(openEgg)
        pcall(equipBest)
    end
end)

task.spawn(function()
    while safeTaskWait(5) do
        callAnotherFunctions()
    end
end)

task.spawn(function()
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
end)
