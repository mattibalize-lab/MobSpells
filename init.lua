local _, addon = ...
addon.name = "MobSpells"

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, a1)
  if a1 == addon.name then
    if not MobSpellsCfg then
      MobSpellsCfg = {
        colorHealing = { r = 0.2, g = 0.75, b = 0.2, a = 1 },
        colorMagical = { r = 0.75, g = 0.2, b = 0.75, a = 1 },
        colorPhysical = { r = 0.9, g = 0.5, b = 0.2, a = 1 },
        showAbilitiesDesc = 1,
        modifierKey = 4
      }
    end
  end
end)
