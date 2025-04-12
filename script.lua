wait(10)
loadstring(game:HttpGet("https://raw.githubusercontent.com/pipipipipia23/ansdwasdz/refs/heads/main/quanhlow"))()
loadstring(game:HttpGet("https://files.cuonggdev.com/RCU_Track.lua"))()
repeat wait() until game:IsLoaded()

local Services = setmetatable({}, {
    __index = function(_, Name)
        return cloneref(game:GetService(Name))
    end
})
local plr = Services.Players.LocalPlayer
-- Client
local Knit = require(Services.ReplicatedStorage.Packages.Knit);
local Client = require(game:GetService("ReplicatedStorage").Packages._Index["sleitnick_comm@1.0.1"].comm.Client.ClientRemoteSignal)
-- Services
local runService = Services.RunService
local ClickService = Knit.GetService("ClickService")
local EggService = Knit.GetService("EggService")
local RebirthService = Knit.GetService("RebirthService")
local UpgradeService = Knit.GetService("UpgradeService")
local RewardService = Knit.GetService("RewardService")
local PrestigeService = Knit.GetService("PrestigeService")
local FarmService = Knit.GetService("FarmService")
local FallingStarsService = Knit.GetService("FallingStarsService")
local PetService = Knit.GetService("PetService")
local BuildingService = Knit.GetService("BuildingService")
local InventoryService = Knit.GetService("InventoryService")
local IndexService = Knit.GetService("IndexService")

-- Controller
local DataController = Knit.GetController("DataController")
local EggController = Knit.GetController("EggController")
local FallingStarsController = Knit.GetController("FallingStarsController")
local AuraController = Knit.GetController("AuraController")

-- Data
local dataUpgrade = require(Services.ReplicatedStorage.Shared.List.Upgrades)
local PlaytimeRewards = require(Services.ReplicatedStorage.Shared.List.PlaytimeRewards)
local Achievements = require(Services.ReplicatedStorage.Shared.List.Achievements)
local FarmData = require(Services.ReplicatedStorage.Shared.List.Farms)
local EggData = require(Services.ReplicatedStorage.Shared.List.Pets.Eggs)
local PetData = require(Services.ReplicatedStorage.Shared.List.Pets.Pets)
local ValuesData = require(Services.ReplicatedStorage.Shared.Values)
local MapData = require(Services.ReplicatedStorage.Shared.List.Maps)
local utils = require(Services.ReplicatedStorage.Shared.Util)
local values = require(Services.ReplicatedStorage.Shared.Values)
local IndexValues = require(Services.ReplicatedStorage.Shared.List.IndexRewards)

-- Env
local Map = {}

-- Anti afk
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

-- Extra Functions
function fireHehe(remote, ...)
    return remote.Fire(remote, ...)
end

function fireHuhu(remote, ...)
    return remote(remote, ...)
end

function getData(name) 
    if name then
        return DataController.data[name]
    end
    return DataController.data
end

function collectChest(getdata)
    local miniChests = getdata.miniChests
    
    for _, mapObj in pairs(workspace.Game.Maps:GetChildren()) do
        if mapObj:FindFirstChild("MiniChests") then
            for _, chest in pairs(mapObj.MiniChests:GetChildren()) do
                if chest:FindFirstChild("Touch") then
                    local id = chest:GetAttribute("miniChestId")
                    local name = chest:GetAttribute("miniChestName")
                    
                    if miniChests[name] then
                        chest:Destroy()
                    else
                        RewardService:claimMiniChest(id, name)
                        task.wait(0.1) -- Small wait to prevent spamming
                    end
                end
            end
        end
    end
end

collectChest(getData())

-- teleport to floating platform
function teleportFloat()
    local character = plr.Character or plr.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Configuration
    local platformHeight = math.random(1500, 2000) -- Random height between 50 and 100
    local platformSize = Vector3.new(20, 1, 20)
    local randomOffsetRange = math.random(800, 1000)

    -- Generate random offsets for X and Z
    local randomX = math.random(-randomOffsetRange, randomOffsetRange)
    local randomZ = math.random(-randomOffsetRange, randomOffsetRange)

    -- Current player position
    local currentPosition = humanoidRootPart.Position

    -- Create new platform
    local platform = Instance.new("Part")
    platform.Size = platformSize
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.SmoothPlastic
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Transparency = 0.3

    -- Position the platform above the player with random X and Z offsets
    platform.Position = Vector3.new(
        currentPosition.X + randomX,
        currentPosition.Y + platformHeight,
        currentPosition.Z + randomZ
    )

    -- Parent the platform to the workspace
    platform.Parent = workspace
    platform.Name = "FloatingPlatform"

    wait(0.5)

    -- Teleport the player onto the platform
    humanoidRootPart.CFrame = CFrame.new(
        platform.Position.X,
        platform.Position.Y + (platformSize.Y / 2) + 2, -- Add half platform height + 2 to stand on top
        platform.Position.Z
    )
end
teleportFloat()
-- Optimize performance settings
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    UserSettings().GameSettings.MasterVolume = 0
    UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
end)

pcall(function() 
    for i,v in getrunningscripts() do
        local a,b =pcall(function() 
            v.Disabled = true
        end) 
        if a ~= false then
            v.Disabled = true
        end
    end
end)

pcall(function()
    workspace.Coffins:Destroy()
    workspace.Debris:Destroy()
    workspace.Game.Cutscenes:Destroy()
    workspace.Game.Pets:Destroy()
end)

pcall(function()
    for i,v in pairs(game.Players:GetPlayers()) do
        if v ~= plr then
            v.Character:Destroy()
        end
    end
end)

pcall(function()
    for i,v in pairs(workspace.Game.Maps:GetChildren()) do
        if v:FindFirstChild("MiniChests") then
            for i1,v1 in pairs(v:GetChildren()) do
                if v1.Name ~= "MiniChests" then
                    v:Destroy()
                end
            end
        else
            v:Destroy()
        end
    end
end)

for k,v in plr.PlayerGui:GetChildren() do 
    v:Destroy()
end
runService:Set3dRenderingEnabled(false)
function getMaxRebirth(getdata)
    return getdata.upgrades["rebirthButtons"] or 0
end

function upgrade(getdata)
    -- Cache gems for less access operations
    local gems = getdata.gems
    local toUpgrade = {}
    
    for i,v in pairs(dataUpgrade) do
        if i ~= "freeAutoClicker" then
            local data = getdata.upgrades[i]
            if data then
                local final = v.upgrades[data + 1]
                if final and gems >= final.cost then
                    table.insert(toUpgrade, i)
                end
            elseif v.upgrades[1].cost <= gems then
                table.insert(toUpgrade, i)
            end
        end
    end
    
    -- Batch upgrades when possible
    for _, upgradeType in ipairs(toUpgrade) do
        UpgradeService:upgrade(upgradeType)
        task.wait(0.1) -- Small delay to prevent server overload
    end
end

function claimPlaytimeRewards(getdata)
    local sessionTime = getdata.sessionTime
    local claimed = getdata.claimedPlaytimeRewards
    local toClaimRewards = {}
    
    for i, v in pairs(PlaytimeRewards) do
        if not table.find(claimed, i) and (v.required - sessionTime) <= 0 then
            table.insert(toClaimRewards, i)
        end
    end
    
    for _, rewardId in ipairs(toClaimRewards) do
        RewardService:claimPlaytimeReward(rewardId)
        task.wait(1)
    end
end

function claimDaily(getdata)
    local dayrs = getdata.dayReset
    if workspace:GetServerTimeNow() - dayrs > 86400 then
        RewardService:claimDailyReward()
    end
end

function claimAchievements()
    local achievementsList = {}
    
    for i in pairs(Achievements) do
        table.insert(achievementsList, i)
    end
    
    for _, achievement in ipairs(achievementsList) do
        RewardService:claimAchievement(achievement)
        task.wait(0.1)
    end
end

function FarmerServices(getdata)
    local gems = getdata.gems
    local farms = getdata.farms
    
    for farmName, farmConfig in pairs(FarmData) do
        local hasUnlock = farms[farmName]
        
        if hasUnlock then
            local nextUpgrade = farmConfig.upgrades[hasUnlock.stage + 1]
            if nextUpgrade and nextUpgrade.price <= gems then
                FarmService:upgrade(farmName)
                task.wait(0.1)
            end
        else
            if farmName == "farmer" then
                FarmService:upgrade(farmName)
            else
                FarmService:buy(farmName)
            end
            task.wait(0.1)
        end
    end
end

function ClaimFarm(data)
    local farms = data.farms
    local farmList = {}
    
    for i in pairs(farms) do
        if i ~= "farmer" then
            table.insert(farmList, i)
        end
    end
    
    for _, farmName in ipairs(farmList) do
        FarmService:claim(farmName)
        task.wait(0.5) -- Reduced wait time
    end
end

function ClaimRewardsIndex(data) 
    local rewards = data.claimedIndexRewards
    for i,v in pairs(IndexValues) do
        if table.find(rewards, i) == nil then
            IndexService:claimIndexReward(i)
            task.wait(0.1) -- Reduced wait time
        end
    end
end

function claimFallingStars()
    local starsList = {}
    for i in pairs(FallingStarsController._debounce) do
        table.insert(starsList, i)
    end
    
    for _, starId in ipairs(starsList) do
        FallingStarsService:claimStar(starId)
        task.wait(0.1)
    end
end

function openEgg()
    local getdata = getData()
    local clicks = getdata.clicks
    local bestEggName = "Forest"
    
    -- Find best available egg
    for eggName, eggInfo in pairs(EggData) do
        if eggInfo.requiredMap == #getdata.maps and eggInfo.cost * 5 < clicks and not eggInfo.canHatch then
            bestEggName = eggName
            break
        end
    end
    -- Open egg if we can afford it
    local maxmap = MapData[#getdata.maps + 1]
    -- if not maxmap then
    --     bestEggName = "15M"
    -- end
    local selectedEgg = EggData[bestEggName]
    if selectedEgg and selectedEgg.cost * 5 < clicks then
        fireHehe(EggService.openEgg, bestEggName, 10)
    else
    end
    
    -- Handle rewards
    claimPlaytimeRewards(getdata)
    claimDaily(getdata)
end

function getPotion(getdata)
    for i,v in pairs(getdata.inventory.potion) do
        return {i,v.am}
    end
    return {"", 0}
end

function getFruit(getdata)
    for i,v in pairs(getdata.inventory.fruit) do
        return {i,v.am}
    end
    return {"", 0}
end

function getBox(getdata)
    for i,v in pairs(getdata.inventory.box) do
        return {i,v.am}
    end
    return {"", 0}
end

function getEpicluck(getdata)
    for i,v in pairs(getdata.inventory.exclusive) do
        if v.nm == "epicLuck" then
            return i
        end
    end
    return ""
end

function rollAura(getdata)
    local dicedata = getdata.inventory.auraDice or {}
    for _, diceData in pairs(dicedata) do
        if diceData.nm and diceData.nm ~= "fireAuraDice" then
            AuraController:roll(diceData.nm)
            task.wait(0.1)
        end
    end
end

function autoQuestPotion(getdata)
    local thismap = #getdata.maps + 1
    local questinmap = MapData[thismap] and MapData[thismap].quests or {}
    local potion = getPotion(getdata) or false
    local fruit = getFruit(getdata) or false
    local box = getBox(getdata) or false
    local epicLuck = getEpicluck(getdata) or false
    
    if (not potion and not fruit and not box and not epicLuck) then return end

    if MapData[thismap] == nil then
        InventoryService:useItem(potion[1], {["use"] = potion[2]})
        wait(.5)
        InventoryService:useItem(fruit[1], {["use"] = fruit[2]})
        wait(.5)
        InventoryService:useItem(box[1], {["use"] = box[2]})
        wait(.5)
        InventoryService:useItem(epicLuck, {["use"] = 1})
    end
    
    for questId, questInfo in pairs(questinmap) do
        local questProgress = getdata.mapQuests[questId]
        if questProgress and questProgress < questInfo.amount then
            if string.find(string.lower(questInfo.quest), "potions") then
                InventoryService:useItem(potion[1], {["use"] = 1})
                break -- Only use one potion per call
            elseif string.find(string.lower(questInfo.quest), "dice") then
                rollAura(getdata)
            end
        end
    end
end

function makeGolden(id)
    PetService:craft(id, true)
end

function equipPet(getdata)
    local petInventory = getdata.inventory.pet
    local tbl = {}
    for id, petData in next, petInventory do
        local data = utils.itemUtils.getItemFromId(getdata, id)
        tbl[#tbl+1] = {
            itemId = id,
            item = data
        }
    end

    table.sort(tbl, function(a, b)
        return a.item:getMultiplier(getdata, {
            ignoreServer = true
        }) > b.item:getMultiplier(getdata, {
            ignoreServer = true
        })
    end)

    for _, v240 in tbl do
        if v240.item:getAmount() > 5 and not v240.item.cl and not v240.item.sh then
            makeGolden({v240.itemId})
        end
        if v240.item:getAmount() > 5 and v240.item.cl ~= nil and not v240.item.sh then
            makeGolden({v240.itemId})
        end
    end

    local tbl2 = {};
    for _, v240 in tbl do
        if #tbl2 < values.petsEquipped(player, getdata) then
            for _ = 1, v240.item:getAmount() do
                if #tbl2 < values.petsEquipped(player, getdata) then
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
    for v243, _ in getdata.equippedPets do
        v242[#v242 + 1] = v243
    end
    PetService:unequipPet(v242)
    PetService:equipPet(tbl2)
end

FallingStarsService.spawnStar:Connect(function(...)
    local args = {...}
    -- Optimize: only claim stars when they appear
    task.spawn(claimFallingStars)
end)

-- Main function with optimized waits
function SomeThing()
    local data = getData()
    
    PrestigeService:claim()
    task.wait(0.3)
    
    -- Group related operations
    upgrade(data)
    claimAchievements()
    task.wait(0.3)
    
    -- Farm operations
    pcall(function()
        FarmerServices(data)
        task.wait(0.3)
        ClaimFarm(data)
    end)
    task.wait(0.3)
    
    -- Pet and item operations
    equipPet(data)
    autoQuestPotion(data)
    task.wait(0.3)

    ClaimRewardsIndex(data)
    task.wait(0.3)
    
    -- Map operations
    BuildingService:build("woodenBridge")
    collectChest(data)
end

-- Optimized loops with better error handling
task.spawn(function()
    while true do
        local success, err = pcall(function()
            fireHehe(ClickService.click)
        end)
        task.wait(0.05) -- Slightly throttled to reduce server load
    end
end)

task.spawn(function()
    while true do
        pcall(openEgg)
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        pcall(function()
            local maxRebirth = getMaxRebirth(getData())
            fireHuhu(RebirthService.rebirth, 3 + maxRebirth)
        end)
        task.wait(2)
    end
end)

task.spawn(function()
    while true do
        local success, err = pcall(SomeThing)
        if not success then
            print("SomeThing error:", err)
        end
        task.wait(2)
    end
end)
