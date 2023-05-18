local _, addon = ...
local InterfaceOptionsFrame_OpenToCategory, GameTooltip, MobSpellsDB, SlashCmdList =
    _G.InterfaceOptionsFrame_OpenToCategory, _G.GameTooltip, _G.MobSpellsDB,
    _G.SlashCmdList

function ARGB2HEX(a, r, g, b)
  local argb = bit.bor(bit.lshift(a, 24), bit.lshift(r, 16), bit.lshift(g, 8), b)
  local hex = string.format("%08X", argb)
  return "|c" .. hex
end

local function UpdateTooltip(self, info)
  if MobSpellsCfg["showAbilitiesLabel"] then self:AddLine("|r|nAbilities:", 1, 1, 1) end

  local healing = MobSpellsCfg["colorHealing"]
  local magical = MobSpellsCfg["colorMagical"]
  local physical = MobSpellsCfg["colorPhysical"]

  for i = 1, #MobSpellsDB[self.MobSpellID] do
    local sid, school = MobSpellsDB[self.MobSpellID][i][1], MobSpellsDB[self.MobSpellID][i][2]
    local color
    local sName, _, sIcon = GetSpellInfo(sid)
    local sDesc = GetSpellDescription(sid)

    local words = {}
    for word in sDesc:gmatch("%S+") do
      table.insert(words, word)
    end

    if school == 1 then
      color = ARGB2HEX(physical.a * 255, physical.r * 255, physical.g * 255, physical.b * 255)
    else
      color = ARGB2HEX(magical.a * 255, magical.r * 255, magical.g * 255, magical.b * 255)
    end

    local desc = ""
    for j, word in ipairs(words) do
      desc = desc .. word .. " "
      if j % 12 == 0 then
        desc = desc .. "\n"
      end
    end

    if sName:lower():find("heal") or sDesc:lower():find("heal") then
      color = ARGB2HEX(healing.a * 255, healing.r * 255, healing.g * 255, healing.b * 255)
    end
    local str = "|T" .. sIcon .. ":24|t" .. color .. " " .. sName .. "|r|n"

    if info and MobSpellsCfg["showAbilitiesDesc"] or (MobSpellsCfg["showAbilitiesDesc"] and MobSpellsCfg["modifierKey"] == 4) then
      self:AddLine(str .. desc, 1, 1, 1)
    else
      self:AddLine(str, 1, 1, 1)
    end
  end

  self:Show()
end

local modKeys = {
  { "LALT",   "RALT" },
  { "LCTRL",  "RCTRL" },
  { "LSHIFT", "RSHIFT" },
}
local fmod, mod = CreateFrame("Frame"), false
fmod:RegisterEvent("CHANNEL_VOICE_UPDATE")
fmod:RegisterEvent("MODIFIER_STATE_CHANGED")
fmod:SetScript("OnEvent", function(_, evt, key, a2)
  if evt == "CHANNEL_VOICE_UPDATE" then
    -- for some reason when you alt + tab out of the game
    -- MODIFIER_STATE_CHANGED is not fired, but this evt does
    mod = false
  else
    local mKey = MobSpellsCfg["modifierKey"]
    if mKey ~= 4 and (key == modKeys[mKey][1] or key == modKeys[mKey][2]) and a2 == 1 then
      mod = true
    else
      mod = false
    end
    GameTooltip:SetUnit("mouseover")
  end
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
  local unit = select(2, self:GetUnit())
  if unit then
    local id = tonumber((UnitGUID(unit)):sub(-10, -7), 16)
    if id and id > 0 and MobSpellsDB and MobSpellsDB[id] then
      self.MobSpellID = id
      if mod then
        UpdateTooltip(self, true)
      else
        UpdateTooltip(self, false)
      end
    else
      self.MobSpellID = nil
    end
  else
    self.MobSpellID = nil
  end
end)

SLASH_MOBSPELLS1 = "/mobspells"
SlashCmdList["MOBSPELLS"] = function()
  InterfaceOptionsFrame_OpenToCategory(addon.panel)
end
