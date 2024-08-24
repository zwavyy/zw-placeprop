RegisterCommand('placeprop', function(source, args, rawCommand)
  local xPlayer = ESX.GetPlayerFromId(source)
  for k, v in pairs(Config.Permissions) do
      if v == xPlayer.getGroup() then
          TriggerClientEvent('zw-placeprop:placeProp', source, args[1])
          return
      end
  end
end)

RegisterNetEvent('zw-placeprop:SaveProp')
AddEventHandler('zw-placeprop:SaveProp', function(name, coordsx, coordsy, coordsz, heading, prop)
    local loadFile = LoadResourceFile(GetCurrentResourceName(), "./positionProps.json")
    if loadFile ~= nil then
        local extract = json.decode(loadFile)
        if type(extract) == "table" then
            table.insert(extract, {name = name, coords = vector3(coordsx, coordsy, coordsz), heading = heading, prop = prop})
            SaveResourceFile(GetCurrentResourceName(), "positionProps.json",  json.encode(extract, { indent = true }), -1)
        else
            local Table = {}
            table.insert(Table, {name = name, coords = vector3(coordsx, coordsy, coordsz), heading = heading, prop = prop})
            SaveResourceFile(GetCurrentResourceName(), "positionProps.json",  json.encode(Table, { indent = true }), -1)
        end
    end
end)

lib.callback.register('zw-placeprop:getProps', function(source)
  local loadFile= LoadResourceFile(GetCurrentResourceName(), "./positionProps.json")
  if loadFile ~= nil then
      local extract = json.decode(loadFile)
      return extract
  end
end)
