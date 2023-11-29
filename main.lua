Main = {
    Shootingstyles = {
        {"Reset","default"},
        {"Hillbilly","Hillbilly","combat@aim_variations@1h@hillbilly","aim_variation_a"},
        {"Gang","Gang1H","combat@aim_variations@1h@gang","aim_variation_a"},
    },
}

RegisterCommand('s_anim',function(source,args) Main:OpenStyles() end)
RegisterKeyMapping("s_anim","Select shooting style","keyboard","F5")
RegisterNUICallback("exit" ,function(data,cb) SetNuiFocus(false,false) Main.open = false end)

RegisterNUICallback("changestyle" ,function(data) 
    Main:WeaponStyle(data.style)
end)


function Main:OpenStyles() 
    SetNuiFocus(true,true)
    SendNUIMessage({
        action = 'openMenu'
    })
    open = true
end

function Main:WeaponStyle(k)
    print(Main.Shootingstyles[tonumber(k)][2])
    DecorSetInt(PlayerPedId(),"gunstyle",tonumber(k))
    SetWeaponAnimationOverride(PlayerPedId(),GetHashKey(Main.Shootingstyles[tonumber(k)][2]))
    ClearPedTasks(PlayerPedId())
end

CreateThread(function() -- used some code from : https://github.com/Loffes/weaponstyles/blob/main/client/update.lua
    while not NetworkIsSessionStarted() do
        Wait(1000)
    end

    DecorRegister("gunstyle",3)

    CreateThread(function()
        while true do
            Wait(250)
            local ped,gunstyle = PlayerPedId(),DecorGetInt(PlayerPedId(),"gunstyle")

            if gunstyle and gunstyle > 1 then
                local dict,anim = Main.Shootingstyles[gunstyle][3],Main.Shootingstyles[gunstyle][4]
                if dict and anim and IsPedArmed(ped,4) then
                    while not HasAnimDictLoaded(dict) do
                        Wait(25)
                        RequestAnimDict(dict)
                    end

                    local _,hash = GetCurrentPedWeapon(ped,1)
                    if IsPlayerFreeAiming(PlayerId()) or (IsControlPressed(0,24) and GetAmmoInClip(ped,hash) > 0) then
                        if not IsEntityPlayingAnim(ped,dict,anim,3) then
                            TaskPlayAnim(ped,dict,anim,8.0,-8.0,-1,49,0,0,0,0)
                        end
                    elseif IsEntityPlayingAnim(ped,dict,anim,3) then
                        ClearPedTasks(ped)
                    end
                end
            else
                Wait(750)
            end
        end
    end)

    while true do
        local sleep = 2500

        for _,player in pairs(GetActivePlayers()) do
            local ped = GetPlayerPed(player)
            local gunstyle = DecorGetInt(ped,"gunstyle")

            if gunstyle and gunstyle > 0 and Main.Shootingstyles[gunstyle] then
                SetWeaponAnimationOverride(ped,Main.Shootingstyles[gunstyle][2])
            end
        end

        Wait(2500)
    end
end)