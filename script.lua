wait(10)

repeat wait() until game:IsLoaded()

local Services = setmetatable({}, {
    __index = function(_, Name)
        return cloneref(game:GetService(Name))
    end
})
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

-- Env
local Map = {}

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

-- Optimize performance settings
pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    UserSettings().GameSettings.MasterVolume = 0
    UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
end)

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
        task.wait(0.1)
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
            FarmService:buy(farmName)
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
        if eggInfo.requiredMap == #getdata.maps and eggInfo.cost * 5 < clicks then
            bestEggName = eggName
            break
        end
    end
    
    -- Open egg if we can afford it
    local selectedEgg = EggData[bestEggName]
    if selectedEgg and selectedEgg.cost * 5 < clicks then
        fireHehe(EggService.openEgg, bestEggName, 5)
    end
    
    -- Handle rewards
    claimPlaytimeRewards(getdata)
    claimDaily(getdata)
end

function getPotion(getdata)
    for potionName in pairs(getdata.inventory.potion) do
        return potionName
    end
    return nil
end

function autoQuestPotion(getdata)
    local thismap = #getdata.maps + 1
    local questinmap = MapData[thismap] and MapData[thismap].quests or {}
    local potion = getPotion(getdata)
    
    if not potion then return end
    
    for questId, questInfo in pairs(questinmap) do
        local questProgress = getdata.mapQuests[questId]
        if questProgress and questProgress >= questInfo.amount and 
           string.find(string.lower(questInfo.quest), "potions") then
            InventoryService:useItem(potion, {["use"] = 1})
            break -- Only use one potion per call
        end
    end
end

function equipPet(getdata)
    -- Fix missing plr variable
    local maxslot = ValuesData.petsEquipped(getdata.player or game.Players.LocalPlayer, getdata)
    local inventory = getdata.inventory.pet
    local equippedPets = getdata.equippedPets
    
    -- Sort pets by multiplier
    local ListPets = {}
    for petName, petData in pairs(inventory) do
        if PetData[petData.nm] then -- Add safety check
            table.insert(ListPets, {
                name = petName,
                dame = PetData[petData.nm].multiplier
            })
        end
    end
    
    table.sort(ListPets, function(a, b)
        return a.dame > b.dame
    end)
    
    -- Get best pets to equip
    local ListHighest = {}
    for _, petInfo in ipairs(ListPets) do
        local amount = inventory[petInfo.name].am or 1
        for i = 1, amount do
            if #ListHighest >= maxslot then
                break
            end
            table.insert(ListHighest, petInfo.name)
        end
        if #ListHighest >= maxslot then
            break
        end
    end
    
    -- Find pets to unequip
    local UnequipPet = {}
    for petName in pairs(equippedPets) do
        local found = false
        for _, bestPet in ipairs(ListHighest) do
            if petName == bestPet then
                found = true
                break
            end
        end
        if not found then
            table.insert(UnequipPet, petName)
        end
    end
    
    -- Update equipped pets
    if #UnequipPet > 0 then
        PetService:unequipPet(UnequipPet)
        task.wait(0.2)
    end
    
    if #ListHighest > 0 then
        PetService:equipPet(ListHighest)
    end
end

function rollAura(getdata)
    for _, diceData in pairs(getdata.inventory.auraDice) do
        if diceData.nm and diceData.nm ~= "fireAuraDice" then
            AuraController:roll(diceData.nm)
            task.wait(0.1)
        end
    end
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
    rollAura(data)
    autoQuestPotion(data)
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
