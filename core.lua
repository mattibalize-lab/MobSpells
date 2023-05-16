GameTooltip:HookScript("OnTooltipSetUnit", function(self)
  local unit = select(2, self:GetUnit())
  if unit then
    local id = tonumber((UnitGUID(unit)):sub(-10, -7), 16)
    if id > 0 then
      if MobdexDB and MobdexDB[id] then
        for i = 1, #MobdexDB[id] do
          local sid, school = MobdexDB[id][i][1], MobdexDB[id][i][2]
          local color
          local sName, _, sIcon = GetSpellInfo(sid)
          local sDesc = GetSpellDescription(sid)

          local words = {}
          for word in sDesc:gmatch("%S+") do
            table.insert(words, word)
          end

          local desc = ""
          for j, word in ipairs(words) do
            desc = desc .. word .. " "
            if j % 12 == 0 then
              desc = desc .. "\n"
            end
          end

          if school == 1 then color = "|cffffa500" else color = "|cffff0000" end
          self:AddLine("|T" .. sIcon .. ":24|t" .. color .. " " .. sName .. "|r|n" .. desc, 1, 1, 1)
        end
      end
    end
  end
end)
