Wrapper = {
    resname = GetCurrentResourceName(),
    blip = {},
    cam = {},
    zone = {},
    cars = {},
    object = {},
    ServerCallbacks = {}
}

-- RESETS

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    TriggerEvent(Wrapper.resname.."Wrapper:Reset")
end)
  

RegisterNetEvent(Wrapper.resname.."Wrapper:Reset",function()
    for k,v in pairs(Wrapper.object) do 
        DeleteObject(v)
    end
    for k,v in pairs(Wrapper.blip) do
        RemoveBlip(v)
    end
end)

--

function Wrapper:ClearBlips()
    for k,v in pairs(Wrapper.blip) do
        RemoveBlip(v)
    end
    for k,v in pairs(Config.MainLoc.Peds) do
        Wrapper:Blip(k .. 'pedblips ','Blacklist', v.pos,v.blip.sprite,v.blip.color,v.blip.scale)
    end
end

function Wrapper:DeleteObject(id)
    DeleteObject(Wrapper.object[id])
end

function Wrapper:LoadModel(model) -- Load Model
    local modelHash = model
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
      Wait(0)
    end
end


function Wrapper:Target(id,label,pos,event,type) -- QBTarget target create
    if Config.Settings.Target == "QB" then 
        local sizex = 1
        local sizey = 1
        exports["qb-target"]:AddBoxZone(id, pos, sizex, sizey, {
            name = id,
            heading = "90.0",
            minZ = pos - 5,
            maxZ = pos + 5
        }, {
            options = {
                {
                    type = "client",
                    event = event,
                    icon = "fas fa-button",
                    label = label,
                }
            },
            distance = 1.5
        })
    end
    if Config.Settings.Target == "OX" then
        Wrapper.zone[id] = exports["ox_target"]:addBoxZone({ -- -1183.28, -884.06, 13.75
        coords = vec3(pos.x,pos.y,pos.z ),
        size = vec3(1, 1, 1),
        rotation = 45,
        debug = false,
        options = {
            {
                name = id,
                event = event,
                icon = "fa-solid fa-cube",
                label = label,
            },
        }
    })
    end
    if Config.Settings.Target == "BT" then 
        local _id = id
        exports["bt-target"]:AddBoxZone(_id, vector3(pos.x,pos.y,pos.z), 0.4, 0.6, {
            name=_id,
            heading=91,
            minZ = pos.z - 1,
            maxZ = pos.z + 1
            }, {
                options = {
                    {
                        type = "client",
                        event = event,
                        icon = "fa-solid fa-cube",
                        label = label,
                    },
                },
                distance = 1.5
            })
    end
    if Config.Settings.Target == "ST" then 
        TriggerEvent('bbv-blacklist:standalone:target',id,label,pos,event)
    end
end

local stwait = 1000

RegisterNetEvent('bbv-blacklist:standalone:target',function(id,label,pos,event)
    while true do 
        Wait(stwait)
        local mypos = GetEntityCoords(PlayerPedId())
        local pedpos = vec3(pos.x,pos.y,pos.z)
        local dist = #(mypos - pedpos)
        if dist < 1 then 
            stwait = 0
            Wrapper:DisplayHelpText(Lang.TalkToNpc ..label)
            if IsControlJustReleased(0, Config.Settings.InteractKey) then
                TriggerEvent(event)
            end
        else
            stwait = 1000
        end
    end
end)

function Wrapper:TargetRemove(sendid) -- Remove QBTarget target
    if Config.Settings.Target == "QB" then 
        exports["qb-target"]:RemoveZone(sendid)
    end 
    if Config.Settings.Target == "OX" then 
        exports["ox_target"]:removeZone(Wrapper.zone[sendid])
    end
    if Config.Settings.Target == "BT" then 
        exports["bt-taget"]:RemoveZone(sendid)
    end
    return
end

function Wrapper:Blip(id,label,pos,sprite,color,scale) -- Create Normal Blip on Map
    Wrapper.blip[id] = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite (Wrapper.blip[id], sprite)
    SetBlipDisplay(Wrapper.blip[id], 4)
    SetBlipScale  (Wrapper.blip[id], scale)
    SetBlipAsShortRange(Wrapper.blip[id], true)
    SetBlipColour(Wrapper.blip[id], color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(Wrapper.blip[id])
    return
end

function Wrapper:RemoveBlip(id)
    RemoveBlip(Wrapper.blip[id])
end

function Wrapper:Notify(txt,tp,time) -- QBCore notify
    if Config.Settings.Framework == "QB" then 
    QBCore.Functions.Notify(txt, tp, time)
    end
    if Config.Settings.Framework == "ESX" then 
        ESX.ShowNotification(txt)
    end
    if Config.Settings.Framework == "ST" then 
        self:Prompt(txt)
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    for k,v in pairs(Wrapper.cars) do 
        DeleteVehicle(v)
    end
end)

function Wrapper:Prompt(msg) --Msg is part of the Text String at B
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg) -- B
	DrawNotification(true, false) -- Look on that website for what these mean, I forget. I think one is about flashing or not
end


function Wrapper:CreateObject(id,prop,coords,network,misson) -- Create object / prop
    RequestModel(prop)
    while not HasModelLoaded(prop) do
      Wait(0)
    end
    Wrapper.object[id] = CreateObject(GetHashKey(prop), coords , network or false,misson or false)
    PlaceObjectOnGroundProperly(Wrapper.object[id])
    SetEntityHeading(Wrapper.object[id], coords.w)
    FreezeEntityPosition(Wrapper.object[id], true)
    SetEntityAsMissionEntity(Wrapper.object[id], true, true)
end

function Wrapper:DisplayHelpText(txt)
    SetTextComponentFormat("STRING")
    AddTextComponentString(txt)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end