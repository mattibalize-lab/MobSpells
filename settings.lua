local _, addon = ...
local InterfaceOptions_AddCategory, UIDropDownMenu_AddButton, UIDropDownMenu_CreateInfo, UIDropDownMenu_DisableDropDown, UIDropDownMenu_EnableDropDown, UIDropDownMenu_Initialize, UIDropDownMenu_SetSelectedID, UIDropDownMenu_SetText, UIDropDownMenu_SetWidth =
    _G["InterfaceOptions_AddCategory"],
    _G["UIDropDownMenu_AddButton"], _G["UIDropDownMenu_CreateInfo"], _G["UIDropDownMenu_DisableDropDown"],
    _G["UIDropDownMenu_EnableDropDown"],
    _G["UIDropDownMenu_Initialize"],
    _G["UIDropDownMenu_SetSelectedID"],
    _G["UIDropDownMenu_SetText"],
    _G["UIDropDownMenu_SetWidth"]

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, a1)
  if a1 == addon.name then
    addon.panel = CreateFrame("Frame", nil, UIParent)
    addon.panel.name = addon.name
    InterfaceOptions_AddCategory(addon.panel)

    -- title
    local label = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    label:SetPoint("TOPLEFT", 16, -16)
    label:SetText(addon.name .. " (v." .. GetAddOnMetadata(addon.name, "Version") .. ")")

    -- description
    local desc = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -8)
    desc:SetText("Adds open-world mob's spells to tooltips!")

    -- color header
    local colorLabel = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    colorLabel:SetPoint("TOPLEFT", desc, "CENTER", 14, -24)
    colorLabel:SetText("Tooltip Spell Colors")

    local function CreateColorPreview(label, colorKey)
      local preview = CreateFrame("Frame", nil, addon.panel)
      preview:SetSize(16, 16)
      preview:SetPoint("TOPLEFT", label, "TOPLEFT", -20, 0)
      local backdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 2,
      }
      local color = MobSpellsCfg[colorKey]
      preview:SetBackdrop(backdrop)
      preview:SetBackdropColor(color.r, color.g, color.b, color.a)
      preview:SetBackdropBorderColor(0, 0, 0, 1)

      local function ColorPickerCallback(restore)
        local r, g, b, a = MobSpellsCfg[colorKey].r, MobSpellsCfg[colorKey].g, MobSpellsCfg[colorKey].b,
            MobSpellsCfg[colorKey].a

        if restore then
          -- user bailed out
          r, g, b, a = unpack(restore);
        else
          a, r, g, b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
        end
        MobSpellsCfg[colorKey].r, MobSpellsCfg[colorKey].g, MobSpellsCfg[colorKey].b, MobSpellsCfg[colorKey].a =
            r, g, b, a

        preview:SetBackdropColor(r, g, b, a)
      end

      preview:SetScript("OnMouseDown", function()
        ColorPickerFrame.func = ColorPickerCallback
        ColorPickerFrame:Hide()
        ColorPickerFrame:Show()
      end)
      preview:EnableMouse(true)

      return preview
    end

    local colorHealingLabel = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    colorHealingLabel:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 70, -42)
    colorHealingLabel:SetText("Healing")
    CreateColorPreview(colorHealingLabel, "colorHealing")
    local colorMagicalLabel = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    colorMagicalLabel:SetPoint("TOPLEFT", colorHealingLabel, "TOPLEFT", 100, 0)
    colorMagicalLabel:SetText("Magical")
    CreateColorPreview(colorMagicalLabel, "colorMagical")
    local colorPhysicalLabel = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    colorPhysicalLabel:SetPoint("TOPLEFT", colorMagicalLabel, "TOPLEFT", 100, 0)
    colorPhysicalLabel:SetText("Physical")
    CreateColorPreview(colorPhysicalLabel, "colorPhysical")

    -- settings header
    local settingsLabel = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    settingsLabel:SetPoint("TOPLEFT", colorLabel, "TOPLEFT", 30, -60)
    settingsLabel:SetText("Settings")

    -- show abilities description checkbox
    local showAbilitiesCheckbox = CreateFrame("CheckButton", "showAbilitiesCheckbox", addon.panel,
      "InterfaceOptionsCheckButtonTemplate")
    showAbilitiesCheckbox:SetPoint("TOPLEFT", desc, "TOPLEFT", 0, -104)
    showAbilitiesCheckbox:SetChecked(MobSpellsCfg.showAbilitiesDesc)

    -- show abilities description label
    local showAbilitiesDesc = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    showAbilitiesDesc:SetPoint("TOPLEFT", showAbilitiesCheckbox, "TOPRIGHT", 8, -5)
    showAbilitiesDesc:SetText("Show abilities description")

    -- mod key label
    local modifierKeyLabel = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    modifierKeyLabel:SetPoint("TOPLEFT", showAbilitiesCheckbox, "TOPLEFT", 2, -30)
    modifierKeyLabel:SetText("Modifier key")
    local modKeys = {
      "ALT Key",
      "CTRL Key",
      "SHIFT Key",
      "None"
    }

    -- mod keys dropdown
    local modKeysDropdown = CreateFrame("Frame", "modKeysDropdown", addon.panel, "UIDropDownMenuTemplate")
    modKeysDropdown:SetPoint("TOPLEFT", modifierKeyLabel, "TOPLEFT", -14, -16)
    UIDropDownMenu_SetWidth(modKeysDropdown, 100)
    UIDropDownMenu_SetText(modKeysDropdown, modKeys[MobSpellsCfg.modifierKey])
    UIDropDownMenu_Initialize(modKeysDropdown, function()
      local info = UIDropDownMenu_CreateInfo()
      for k, v in ipairs(modKeys) do
        info.text = v
        info.value = k
        info.checked = (k == MobSpellsCfg.modifierKey)
        info.func = function(self)
          UIDropDownMenu_SetSelectedID(modKeysDropdown, self:GetID())
          MobSpellsCfg.modifierKey = self.value
        end
        UIDropDownMenu_AddButton(info)
      end
    end)
    if not MobSpellsCfg.showAbilitiesDesc then
      UIDropDownMenu_DisableDropDown(modKeysDropdown)
    end

    -- show abilities description checkbox function
    -- defined here because UIDropDownMenu exists here.
    showAbilitiesCheckbox:SetScript("OnClick", function(self)
      MobSpellsCfg.showAbilitiesDesc = self:GetChecked()
      if self:GetChecked() then
        UIDropDownMenu_EnableDropDown(modKeysDropdown)
      else
        UIDropDownMenu_DisableDropDown(modKeysDropdown)
      end
    end)

    -- show abilities label checkbox
    local showAbilitiesLabelCheckbox = CreateFrame("CheckButton", "showAbilitiesCheckbox", addon.panel,
      "InterfaceOptionsCheckButtonTemplate")
    showAbilitiesLabelCheckbox:SetPoint("TOPLEFT", showAbilitiesCheckbox, "TOPLEFT", 0, -80)
    showAbilitiesLabelCheckbox:SetScript("OnClick", function(self)
      MobSpellsCfg.showAbilitiesLabel = self:GetChecked()
    end)
    showAbilitiesLabelCheckbox:SetChecked(MobSpellsCfg.showAbilitiesLabel)

    -- show abilities label
    local showAbilitiesLabel = addon.panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    showAbilitiesLabel:SetPoint("TOPLEFT", showAbilitiesLabelCheckbox, "TOPRIGHT", 8, -5)
    showAbilitiesLabel:SetText("Show \"Abilities:\" label")
  end
end)
