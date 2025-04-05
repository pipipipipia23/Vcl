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
local ClickService = Knit.GetService("ClickService")
local EggService = Knit.GetService("EggService")
local RebirthService = Knit.GetService("RebirthService")
local UpgradeService = Knit.GetService("UpgradeService")
local RewardService = Knit.GetService("RewardService")
local PrestigeService = Knit.GetService("PrestigeService")
local FarmService = Knit.GetService("FarmService")
local FallingStarsService = Knit.GetService("FallingStarsService")
local PetService = Knit.GetService("PetService")
-- Controller
local DataController = Knit.GetController("DataController")
local EggController = Knit.GetController("EggController")
local FallingStarsController = Knit.GetController("FallingStarsController")

-- Data
local dataUpgrade = require(Services.ReplicatedStorage.Shared.List.Upgrades)
local PlaytimeRewards = require(Services.ReplicatedStorage.Shared.List.PlaytimeRewards)
local Achievements = require(Services.ReplicatedStorage.Shared.List.Achievements)
local FarmData = require(Services.ReplicatedStorage.Shared.List.Farms)
local EggData = require(Services.ReplicatedStorage.Shared.List.Pets.Eggs)
local PetData = require(Services.ReplicatedStorage.Shared.List.Pets.Pets)
local ValuesData = require(Services.ReplicatedStorage.Shared.Values)

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

-- v.am

function getMaxRebirth()
    return getData("upgrades")["rebirthButtons"] or 0
end

-- Setup Map
-- for i,v in pairs(workspace.Game.Maps:GetDescendants()) do
--     if v.Name == "NextMap" then
--         v.Parent
--     end
-- end

-- function 
function upgrade()
    for i,v in pairs(dataUpgrade) do
        if i ~= "freeAutoClicker" then
            local data = getData("upgrades")[i]
            if data then
                local final = v.upgrades[data + 1]
                if final ~= nil then
                    if getData().gems >= final.cost then
                        UpgradeService:upgrade(i)
                    end
                end
            else
                if v.upgrades[1].cost <= getData().gems then
                    UpgradeService:upgrade(i)
                end
            end
        end
    end
end

function collectChest()
    for i,v in pairs(workspace.Game.Maps:GetChildren()) do
        if v:FindFirstChild("MiniChests") then
            for i1,v1 in pairs(v.MiniChests:GetChildren()) do
                if v1:FindFirstChild("Touch") then
                    local id = v1:GetAttribute("miniChestId");
                    local name = v1:GetAttribute("miniChestName");
                    if getData().miniChests[name] then
                        v1:Destroy()
                    else
                        RewardService:claimMiniChest(id, name)
                    end
                end
            end
        end
    end
end

function claimPlaytimeRewards()
    for i,v in pairs(PlaytimeRewards) do
        local sstime = getData("sessionTime")
        local claimed = getData("claimedPlaytimeRewards")
        if table.find(claimed, i) == nil and (v.required - sstime) <= 0 then
            RewardService:claimPlaytimeReward(i)
        end
    end    
end

function claimDaily()
    local dayrs = getData("dayReset")
    if workspace:GetServerTimeNow() - dayrs > 86400 then
        RewardService:claimDailyReward()
    end
end

function claimAchievements()
    for i,v in pairs(Achievements) do
        RewardService:claimAchievement(i)
    end
end

function FarmerServices()
    for i,v in pairs(FarmData) do
        local hasUnlock = getData().farms[i]
        if hasUnlock then
            local data = hasUnlock
            local datareal = v.upgrades
            local nexup = datareal[data.stage + 1]
            if nexup ~= nil then
                if nexup.price <= getData().gems then
                    FarmService:upgrade(i)
                end
            end
        else
            FarmService:buy(i)
        end
    end
end

function ClaimFarm()
    for i,v in pairs(getData().farms) do
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
    for i,v in pairs(EggData) do
        if v.requiredMap == #getData("maps") and v.cost < getData("clicks") then
            eggName = i
            fireHehe(EggService.openEgg, eggName, 99)
            break
        end
    end
    if eggName == "Basic" then
        if EggData[eggName].cost < getData("clicks") then
            fireHehe(EggService.openEgg, eggName, 99)
        end
    end
end

function equipPet()
    local ListPets = {}
    local ListHighest = {}
    local UnequipPet = {}
    local maxslot = ValuesData.petsEquipped(plr, getData())
    for i,v in pairs(getData().inventory.pet) do
        table.insert(ListPets,{
            name = i,
            dame = PetData[v.nm].multiplier
        })
    end
    table.sort(ListPets, function(a,b)
        return a.dame > b.dame
    end)
    for i,v in pairs(ListPets) do -- lưu ý lấy max slot rồi giới hạn cho nó ở list tối đa slot pet thôi nhé
        local number = getData().inventory.pet[v.name].am or 1
        for i1 = 1, number do
            if #ListHighest >= maxslot then
                break
            else
                table.insert(ListHighest, v.name)
            end
        end
    end
    for i,v in pairs(getData("equippedPets")) do
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

function SomeThing()
    fireHuhu(RebirthService.rebirth, 3 + getMaxRebirth())
    PrestigeService:claim()
    upgrade()
    claimPlaytimeRewards()
    claimDaily()
    claimAchievements()
    FarmerServices()
    ClaimFarm()
    equipPet()
    collectChest()
end

-- loop
task.spawn(function()
    while task.wait() do
        fireHehe(ClickService.click)
    end
end)

task.spawn(function()
    while task.wait(1) do
        pcall(openEgg)
    end
end)

task.spawn(function()
    while task.wait(3) do
        pcall(SomeThing)
    end
end)
--
