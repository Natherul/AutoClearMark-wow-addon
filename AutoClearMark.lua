BINDING_HEADER_DEJAAUTOMARK = "AutoClearMark"
_G["BINDING_NAME_CLICK AutoClearMark:LeftButton"] = "Show Markers(Hold)"

local ADDON_NAME, namespace = ... 	--localization
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local addoninfo = 'v'..version
local AutoClearMark, gdbprivate = ...

gdbprivate.gdbdefaults = {
}
gdbprivate.gdbdefaults.gdbdefaults = {
}

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "AutoClearMark" then
			local function initDB(gdb, gdbdefaults)
				if type(gdb) ~= "table" then gdb = {} end
				if type(gdbdefaults) ~= "table" then return gdb end
				for k, v in pairs(gdbdefaults) do
					if type(v) == "table" then
						gdb[k] = initDB(gdb[k], v)
					elseif type(v) ~= type(gdb[k]) then
						gdb[k] = v
					end
				end
				return gdb
			end

			AutoClearMarkDB = initDB(AutoClearMarkDB, gdbprivate.gdbdefaults) --the first per account saved variable. The second per-account variable DCS_ClassSpecDB is handled in DCS_Layouts.lua
			gdbprivate.gdb = AutoClearMarkDB --fast access for checkbox states
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

local AutoClearMark, private = ...

private.defaults = {
}
private.defaults.dcsdefaults = {
}

AutoClearMark = {};

----------------------------
-- Saved Variables Loader --
----------------------------
local loader = CreateFrame("Frame")
	loader:RegisterEvent("ADDON_LOADED")
	loader:SetScript("OnEvent", function(self, event, arg1)
		if event == "ADDON_LOADED" and arg1 == "AutoClearMark" then
			local function initDB(db, defaults)
				if type(db) ~= "table" then db = {} end
				if type(defaults) ~= "table" then return db end
				for k, v in pairs(defaults) do
					if type(v) == "table" then
						db[k] = initDB(db[k], v)
					elseif type(v) ~= type(db[k]) then
						db[k] = v
					end
				end
				return db
			end

			AutoClearMarkDBPC = initDB(AutoClearMarkDBPC, private.defaults) --saved variable per character, currently not used.
			private.db = AutoClearMarkDBPC

			self:UnregisterEvent("ADDON_LOADED")
		end
	end)

-----------------
-- AutoClearMark
-----------------

local function DAM_Mark()
	SetRaidTarget("player", 0)
end

local TankHealerMarkFrame = CreateFrame("Frame", "TankHealerMarkFrame",UIParent)

TankHealerMarkFrame:SetScript("OnEvent", function(self, event, ...)
	DAM_Mark()
end)



---------------------
-- DAM Slash Setup --
---------------------
local RegisteredEvents = {};
local damslash = CreateFrame("Frame", "AutoClearMarkSlash", UIParent)

damslash:SetScript("OnEvent", function (self, event, ...) 
	if (RegisteredEvents[event]) then 
	return RegisteredEvents[event](self, event, ...) 
	end
end)

function RegisteredEvents:ADDON_LOADED(event, addon, ...)
	if (addon == "AutoClearMark") then
		--SLASH_DEJAAUTOMARK1 = (L["/dam"])
		SLASH_DEJAAUTOMARK1 = "/dam"
		SlashCmdList["DEJAAUTOMARK"] = function (msg, editbox)
			AutoClearMark.SlashCmdHandler(msg, editbox)	
	end
    DEFAULT_CHAT_FRAME:AddMessage("AutoClearMark loaded successfully. Automatically enabling auto disable of marks! Configure with /dam",0,192,255)
    TankHealerMarkFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    TankHealerMarkFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    TankHealerMarkFrame:RegisterEvent("INSPECT_READY")
    TankHealerMarkFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
    TankHealerMarkFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
	end
end

for k, v in pairs(RegisteredEvents) do
	damslash:RegisterEvent(k)
end

function AutoClearMark.ShowHelp()
	print(addoninfo)
	print("AutoClearMark Slash commands (/dam):")
	print("  /dam on: Enables AutoClearMark automatic mode.")
	print("  /dam off: Disables AutoClearMark automatic mode.")
	print("  /dam mark: Marks the targets regardless of automatic mode status.")
end

function AutoClearMark.SlashCmdHandler(msg, editbox)
    msg = string.lower(msg)
	--print("command is " .. msg .. "\n")
	--if (string.lower(msg) == L["config"]) then --I think string.lowermight not work for Russian letters
	if (msg == "on") then
		TankHealerMarkFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
		TankHealerMarkFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		TankHealerMarkFrame:RegisterEvent("INSPECT_READY")
        TankHealerMarkFrame:RegisterEvent("PLAYER_LEAVE_COMBAT")
        TankHealerMarkFrame:RegisterEvent("PLAYER_ENTER_COMBAT")
		print("AutoClearMark automatic mode has been turned on.")
	elseif (msg == "off") then
		TankHealerMarkFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		TankHealerMarkFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		TankHealerMarkFrame:UnregisterEvent("INSPECT_READY")
        TankHealerMarkFrame:UnregisterEvent("PLAYER_LEAVE_COMBAT")
        TankHealerMarkFrame:UnregisterEvent("PLAYER_ENTER_COMBAT")
		print("AutoClearMark automatic mode has been turned off.")
		gdbprivate.gdb.gdbdefaults = gdbprivate.gdbdefaults.gdbdefaults
	elseif (msg == "mark") then
		DAM_Mark()
		print("AutoClearMark has marked the targets.")
		gdbprivate.gdb.gdbdefaults = gdbprivate.gdbdefaults.gdbdefaults
	else
		AutoClearMark.ShowHelp()
	end
end
	SlashCmdList["DEJAAUTOMARK"] = AutoClearMark.SlashCmdHandler;

-- toggle frame, has no visible parts. exists as a place to accept a click run a snippet
local toggleframe = CreateFrame("Button","AutoClearMark",UIParent,"SecureHandlerClickTemplate")
	toggleframe:RegisterForClicks("AnyDown")
	toggleframe:SetScript("OnClick", function (self, button, down)
		DAM_Mark()
		print("AutoClearMark has marked the targets.")
	end)
