wait(5)

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

FallingStarsService.spawnStar:Connect(function(...) --[[ Line: 287 ]]
    print("Started falling stars")
    local args = {...}
    table.foreach(args, print)
end);

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

-- v.am

function getMaxRebirth(getdata)
    return getdata.upgrades["rebirthButtons"] or 0
end

-- function 
function upgrade(getdata)
    for i,v in pairs(dataUpgrade) do
        if i ~= "freeAutoClicker" then
            local data = getdata.upgrades[i]
            if data then
                local final = v.upgrades[data + 1]
                if final ~= nil then
                    if getdata.gems >= final.cost then
                        UpgradeService:upgrade(i)
                    end
                end
            else
                if v.upgrades[1].cost <= getdata.gems then
                    UpgradeService:upgrade(i)
                end
            end
        end
    end
end

function collectChest(getdata)
    for i,v in pairs(workspace.Game.Maps:GetChildren()) do
        if v:FindFirstChild("MiniChests") then
            for i1,v1 in pairs(v.MiniChests:GetChildren()) do
                if v1:FindFirstChild("Touch") then
                    local id = v1:GetAttribute("miniChestId");
                    local name = v1:GetAttribute("miniChestName");
                    if getdata.miniChests[name] then
                        v1:Destroy()
                    else
                        RewardService:claimMiniChest(id, name)
                    end
                end
            end
        end
    end
end

function claimPlaytimeRewards(getdata)
    for i,v in pairs(PlaytimeRewards) do
        local sstime = getdata.sessionTime
        local claimed = getdata.claimedPlaytimeRewards
        if table.find(claimed, i) == nil and (v.required - sstime) <= 0 then
            RewardService:claimPlaytimeReward(i)
        end
    end    
end

function claimDaily(getdata)
    local dayrs = getdata.dayReset
    if workspace:GetServerTimeNow() - dayrs > 86400 then
        RewardService:claimDailyReward()
    end
end

function claimAchievements()
    for i,v in pairs(Achievements) do
        RewardService:claimAchievement(i)
    end
end

function FarmerServices(getdata)
    for i,v in pairs(FarmData) do
        local hasUnlock = getdata.farms[i]
        if hasUnlock then
            local data = hasUnlock
            local datareal = v.upgrades
            local nexup = datareal[data.stage + 1]
            if nexup ~= nil then
                if nexup.price <= getdata.gems then
                    FarmService:upgrade(i)
                end
            end
        else
            FarmService:buy(i)
        end
    end
end

function ClaimFarm(data)
    for i,v in pairs(data.farms) do
        if i ~= "farmer" then
            FarmService:claim(i)
            wait(2)
        end
    end
end

function claimFallingStars()
    for i,v in pairs(FallingStarsController._debounce) do
        FallingStarsService:claimStar(i)
    end
end

function openEgg()
    local eggName = "Basic"
    local getdata = getData()
    for i,v in pairs(EggData) do
        if v.requiredMap == #getdata.maps and v.cost * 5 < getdata.clicks then
            eggName = i
            fireHehe(EggService.openEgg, eggName, 5)
            break
        end
    end
    print(eggName)
    if eggName == "Basic" then
        if EggData[eggName].cost * 5 < getdata.clicks then
            fireHehe(EggService.openEgg, eggName, 5)
        end
    end
    claimPlaytimeRewards(getdata)
    claimDaily(getdata)
end

function getPotion(getdata)
    for i,v in pairs(getdata.inventory.potion) do
        return i
    end
end

function autoQuestPotion(getdata)
    local thismap = #getdata.maps + 1
    local questinmap = MapData[thismap].quests
    for i,v in pairs(questinmap) do
        if getdata.mapQuests[i] and getdata.mapQuests[i] >= v.amount then
            if string.find(string.lower(v.quest), "potions") then
                InventoryService:useItem(getPotion(getdata), {
                    ["use"] = 1
                })
            end
        end
    end
end

function equipPet(getdata)
    local ListPets = {}
    local ListHighest = {}
    local UnequipPet = {}
    local maxslot = ValuesData.petsEquipped(plr, getdata)
    for i,v in pairs(getdata.inventory.pet) do
        table.insert(ListPets,{
            name = i,
            dame = PetData[v.nm].multiplier
        })
    end
    table.sort(ListPets, function(a,b)
        return a.dame > b.dame
    end)
    for i,v in pairs(ListPets) do -- lưu ý lấy max slot rồi giới hạn cho nó ở list tối đa slot pet thôi nhé
        local number = getdata.inventory.pet[v.name].am or 1
        for i1 = 1, number do
            if #ListHighest >= maxslot then
                break
            else
                table.insert(ListHighest, v.name)
            end
        end
    end
    for i,v in pairs(getdata.equippedPets) do
        if table.find(ListHighest, i) then
            table.remove(ListHighest, i)
        else
            table.insert(UnequipPet, i)
        end
    end
    if #UnequipPet > 0 then
        PetService:unequipPet(UnequipPet)
    end
    PetService:equipPet(ListHighest)
end

function rollAura(getdata)
    for i,v in pairs(getdata.inventory.auraDice) do
        if v.nm ~= "fireAuraDice" then
            AuraController:roll(v.nm)
        end
    end
end

function SomeThing()
    local data = getData()
    PrestigeService:claim()
    task.wait(1)
    upgrade(data)
    task.wait(1)
    claimAchievements()
    task.wait(1)
    FarmerServices(data)
    task.wait(1)
    ClaimFarm(data)
    task.wait(1)
    equipPet(data)
    task.wait(1)
    rollAura(data)
    task.wait(1)
    autoQuestPotion(data)
    task.wait(1)
    BuildingService:build("woodenBridge")
    task.wait(1)
    collectChest(data)
end

-- loop
task.spawn(function()
    while task.wait() do
        fireHehe(ClickService.click)
    end
end)

task.spawn(function()
    while task.wait(2) do
        pcall(openEgg)
    end
end)

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            fireHuhu(RebirthService.rebirth, 3 + getMaxRebirth(getData()))
        end)
    end
end)

task.spawn(function()
    while task.wait(2) do
        local a,b = pcall(SomeThing)
        print(a,b)
    end
end)
--
