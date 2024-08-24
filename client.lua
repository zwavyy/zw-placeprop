AddEventHandler('esx:onPlayerSpawn', function()
  SpawnObject()
end)

local cam
local inCam
local objectPosition = {}


function CamON(obj, coordsArma, heading)
    local coords = GetOffsetFromEntityInWorldCoords(obj, 0, -0.75, 0)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(cache.ped, true)

    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 250, 1, 0)
        SetCamCoord(cam, coords.x, coords.y, coords.z + 1.2)
        SetCamRot(cam, 0.0, 0.0, GetEntityHeading(obj))
        OpenCrafting(coordsArma, heading)
    else
        CamOFF()
        Wait(500)
        CamON()
    end
end

function InfoCrafting()
    Scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS");
    while not HasScaleformMovieLoaded(Scale) do
        Citizen.Wait(0)
    end

    BeginScaleformMovieMethod(Scale, "CLEAR_ALL");
    EndScaleformMovieMethod();

    --Destra
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(0);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_RIGHT_ONLY~");
    PushScaleformMovieMethodParameterString("Rotate right");
    EndScaleformMovieMethod();

    --Sinistra
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(1);
    PushScaleformMovieMethodParameterString("~INPUT_MOVE_LEFT_ONLY~");
    PushScaleformMovieMethodParameterString("Rotate Left");
    EndScaleformMovieMethod();

    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(2);
    PushScaleformMovieMethodParameterString("~INPUT_CELLPHONE_CANCEL~");
    PushScaleformMovieMethodParameterString("Exit");
    EndScaleformMovieMethod();


    BeginScaleformMovieMethod(Scale, "DRAW_INSTRUCTIONAL_BUTTONS");
    ScaleformMovieMethodAddParamInt(0);
    EndScaleformMovieMethod();

    DrawScaleformMovieFullscreen(Scale, 255, 255, 255, 255, 0);
end

function InfoPlaceCrafting()
    Scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS");
    while not HasScaleformMovieLoaded(Scale) do
        Citizen.Wait(0)
    end

    BeginScaleformMovieMethod(Scale, "CLEAR_ALL");
    EndScaleformMovieMethod();

    --Destra
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(0);
    PushScaleformMovieMethodParameterString("~INPUT_PICKUP~");
    PushScaleformMovieMethodParameterString("Place Prop");
    EndScaleformMovieMethod();

    --Rotate Left
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(1);
    PushScaleformMovieMethodParameterString("~INPUT_WEAPON_WHEEL_PREV~");
    PushScaleformMovieMethodParameterString("Rotate Right");
    EndScaleformMovieMethod();

    --Rotate Right
    BeginScaleformMovieMethod(Scale, "SET_DATA_SLOT");
    ScaleformMovieMethodAddParamInt(2);
    PushScaleformMovieMethodParameterString("~INPUT_WEAPON_WHEEL_NEXT~");
    PushScaleformMovieMethodParameterString("Rotate Left");
    EndScaleformMovieMethod();


    BeginScaleformMovieMethod(Scale, "DRAW_INSTRUCTIONAL_BUTTONS");
    ScaleformMovieMethodAddParamInt(0);
    EndScaleformMovieMethod();

    DrawScaleformMovieFullscreen(Scale, 255, 255, 255, 255, 0);
end

function CamOFF()
    -- lib.hideMenu('ApriCrafting')
    FreezeEntityPosition(PlayerPedId(), false)
    DeleteObject(obj)
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    -- SetLocalPlayerAsGhost(false)
    inCam = false
end

local confirmed
local heading

function RotationToDirection(rotation)
    local adjustedRotation =
    {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction =
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function DrawPropAxes(prop)
    local propForward, propRight, propUp, propCoords = GetEntityMatrix(prop)

    local propXAxisEnd = propCoords + propRight * 1.0
    local propYAxisEnd = propCoords + propForward * 1.0
    local propZAxisEnd = propCoords + propUp * 1.0

    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propXAxisEnd.x, propXAxisEnd.y, propXAxisEnd.z, 255, 0, 0,
        255)
    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propYAxisEnd.x, propYAxisEnd.y, propYAxisEnd.z, 0, 255, 0,
        255)
    DrawLine(propCoords.x, propCoords.y, propCoords.z + 0.1, propZAxisEnd.x, propZAxisEnd.y, propZAxisEnd.z, 0, 0, 255,
        255)
end

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination
        .x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end



RegisterNetEvent('zw-placeprop:placeProp')
AddEventHandler('zw-placeprop:placeProp', function(prop)
    prop = joaat(prop)
    heading = 0.0
    confirmed = false

    RequestModel(prop)
    while not HasModelLoaded(prop) do
        Wait(0)
    end

    local hit, coords

    while not hit do
        hit, coords = RayCastGamePlayCamera(10.0)
        Wait(0)
    end

    local propObject = CreateObject(prop, coords.x, coords.y, coords.z, true, false, true)

    CreateThread(function()
        while not confirmed do
            InfoPlaceCrafting()
            hit, coords, entity = RayCastGamePlayCamera(10.0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            SetEntityCoordsNoOffset(propObject, coords.x, coords.y, coords.z, false, false, false, true)
            FreezeEntityPosition(propObject, true)
            SetEntityCollision(propObject, false, false)
            SetEntityAlpha(propObject, 100, false)
            DrawPropAxes(propObject)
            Wait(0)

            if IsControlPressed(0, 15) then
                heading = heading + 5.0
            elseif IsControlPressed(0, 14) then 
                heading = heading - 5.0
            end

            if IsControlJustPressed(0, 177) then
                DeleteObject(propObject)
                confirmed = true
            end

            if heading > 360.0 then
                heading = 0.0
            elseif heading < 0.0 then
                heading = 360.0
            end

            SetEntityHeading(propObject, heading)

            if IsControlJustPressed(0, 38) then 
                local input = lib.inputDialog('Table Name', { '' })

                if not input then
                    DeleteObject(propObject)
                    return
                else
                    confirmed = true
                    SetEntityAlpha(propObject, 255, false)
                    SetEntityCollision(propObject, true, true)
                    TriggerServerEvent('zw-placeprop:SaveProp', input[1], coords.x, coords.y, coords.z, heading, prop)
                    table.insert(objectPosition, propObject)
                end
            end
        end
    end)
end)


function CreateMarker(coords)
    while view do
        Wait(0)
        DrawMarker(2, coords.x, coords.y, coords.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 255, 128, 0, 50, true, true, 2, nil, nil, false)
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    SpawnObject()
end)

function SpawnObject()
    local data = lib.callback.await('zw-placeprop:getProps', false)
    if data ~= nil then
        for _, v in ipairs(data) do
            local heading = 0.0 + v.heading
            local createCrafting = CreateObject(v.prop, v.coords.x, v.coords.y, v.coords.z, false, true,
                false)

            if createCrafting then
                SetEntityHeading(createCrafting, heading)
                SetEntityCollision(createCrafting, true, true)
                PlaceObjectOnGroundProperly(createCrafting)
                table.insert(objectPosition, createCrafting)
            else
            end
        end
    end
end

AddEventHandler("onResourceStop", function(re)
    if re == GetCurrentResourceName() then
        for _, v in pairs(objectPosition) do
            DeleteEntity(v)
        end
    end
end)