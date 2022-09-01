local Backup = {}
local ResetTime = 86400     -- reset every 86400 seconds (24 hours) of real time.
local SeperateFolder = true -- [Untested on Linux]Put each day in seperate dated folder instead of overwite(Takes up more space)
local BackupPlayers = true  -- "true" to backup all players .json files
local BackupWorld = true    -- "true" to backup world.json


customEventHooks.registerHandler("OnServerPostInit", function(eventStatus, pid)
        tes3mp.LogMessage(3, "Backups Online!!")
        BackupFunc = Backup.All
        Timer = tes3mp.CreateTimer("BackupFunc", time.seconds(ResetTime))
        tes3mp.StartTimer(Timer)
end)

local getPlayers = function(directory)
   local i, t, popen = 0, {}, io.popen
   local pfile = nil

   if tes3mp.GetOperatingSystemType() == "Windows" then
       pfile = popen('dir "' .. directory .. '" /b')
   else
       pfile = popen('find "' .. directory .. '" -maxdepth 1 -type f -printf "%f\n"')
   end

   for filename in pfile:lines() do
       i = i + 1
       t[i] = filename
   end
   pfile:close()

   return t
end

Backup.Date = function()
    Date = os.date("%m-%d-%Y(%I-%p)")
  return Date
end

Backup.All = function()
      if BackupPlayers == true then
         local directory = tes3mp.GetDataPath() .. "/player/"
         local Files = getPlayers(directory)
         local players = "/custom/backups/players/"
         if SeperateFolder == true then
                  os.execute("mkdir " .. tes3mp.GetDataPath() .. "\\custom\\backups\\players\\" .. Backup.Date())
         end
               for _,fileName in pairs(Files) do
                   local NoFileExtension = fileName:split(".")
                   local fileName = NoFileExtension[1]
                   
                   local PlayerData = jsonInterface.load("/player/" .. fileName .. ".json")
                   if SeperateFolder == true then
                      jsonInterface.save(players .. Backup.Date() .. "/" .. fileName .. ".json", PlayerData)
                   else
                      jsonInterface.save(players .. fileName .. ".json", PlayerData)
                   end
               end
         tes3mp.LogMessage(3, "(" .. #Files .. ")" .. "Players Backed Up!!")
      end
      if BackupWorld == true then
         local world = "/custom/backups/world/"
         local WorldData = jsonInterface.load("/world/world.json")
               if SeperateFolder == true then
                  os.execute("mkdir " .. tes3mp.GetDataPath() .. "\\custom\\backups\\world\\" .. Backup.Date())
                  jsonInterface.save(world .. Backup.Date() .. "/" .. "world.json", WorldData)
               else
                  jsonInterface.save(world .. "world.json", WorldData)
               end
         tes3mp.LogMessage(3, "World Backed Up!!")
      end

tes3mp.RestartTimer(Timer, time.seconds(ResetTime))
end
