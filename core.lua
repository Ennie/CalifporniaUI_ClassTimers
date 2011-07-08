
-- // rFilter3
-- // zork - 2010

--get the addon namespace
local addon, ns = ...

--get the config
local cfg = ns.cfg


-- califpornia
local cFilterIcons = {}
local cFilterIconRows = {}
local cFilterRowCount = 1
local cFilterRowIconCount = 0
-----------------------------
-- FUNCTIONS
-----------------------------

--format time func
local GetFormattedTime = function(time)
	local text
	local d, h, m, s = ChatFrame_TimeBreakDown(time);
	if( time <= 0 ) then
		text = ""
	elseif( time < 3600 and time >= 60) then
		text = format("%02d:%02d", m, s);
	elseif( time < 60 ) then
		text = format("%02ds", s);
	else
		text = format("%02d:%02d", h, m);
	end
	return text
end

-- califpornia
local cSetIconPosition = function(icon)
	if cFilterRowCount == 1 and cFilterRowIconCount == 0 then
		icon:SetPoint(unpack(cfg.apos))
		cFilterIconRows[cFilterRowCount] = {}
		cFilterRowIconCount = 1
	elseif cFilterRowIconCount == cfg.rowicons then
		if cfg.growth_y == "DOWN" then
			icon:SetPoint("TOP", cFilterIconRows[cFilterRowCount][1], "BOTTOM", 0, -cfg.space_y)
		else
			icon:SetPoint("BOTTOM", cFilterIconRows[cFilterRowCount][1], "TOP", 0, cfg.space_y)
		end
		cFilterRowCount = cFilterRowCount + 1
		cFilterRowIconCount = 1
		cFilterIconRows[cFilterRowCount] = {}
	else
		if cfg.growth_x == "RIGHT" then
			icon:SetPoint("LEFT", cFilterIconRows[cFilterRowCount][cFilterRowIconCount], "RIGHT", cfg.space_x, 0)
		else
			icon:SetPoint("RIGHT", cFilterIconRows[cFilterRowCount][cFilterRowIconCount], "LEFT", -cfg.space_x, 0)
		end
		cFilterRowIconCount = cFilterRowIconCount + 1
	end
	cFilterIconRows[cFilterRowCount][cFilterRowIconCount] = icon
end

local createIcon = function(f)
	if not f.enabled then return end

	local w = cfg.size

	local i = CreateFrame("FRAME",nil,UIParent)
	i:SetSize(w, w)
	cSetIconPosition(i)

--	if not f.spellid and f.cd_itemid then
--		local itm_spell = GetItemSpell(f.cd_itemid)
--		f.spellid = 
--	end
	local gsi_name, gsi_rank, gsi_icon, gsi_powerCost, gsi_isFunnel, gsi_powerType, gsi_castingTime, gsi_minRange, gsi_maxRange = GetSpellInfo(f.spellid)
	
	
	local gl = i:CreateTexture(nil, "BACKGROUND",nil,-8)
	gl:SetPoint("TOPLEFT",i,"TOPLEFT",-w*3.3/32,w*3.3/32)
	gl:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",w*3.3/32,-w*3.3/32)
	gl:SetTexture("Interface\\AddOns\\CalifporniaUI_ClassTimers\\media\\simplesquare_glow")
	gl:SetVertexColor(0, 0, 0, 1)

	local ba = i:CreateTexture(nil, "BACKGROUND",nil,-7)
	ba:SetAllPoints(i)
	ba:SetTexture("Interface\\AddOns\\CalifporniaUI_ClassTimers\\media\\d3portrait_back2")
	
	local t = i:CreateTexture(nil,"BACKGROUND",nil,-6)
	t:SetPoint("TOPLEFT",i,"TOPLEFT",w*3/32,-w*3/32)
	t:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",-w*3/32,w*3/32)
	t:SetTexture(gsi_icon)
	t:SetTexCoord(0.1,0.9,0.1,0.9)
	if cfg.desaturate then
		t:SetDesaturated(1)
	end

	local bo = i:CreateTexture(nil,"BACKGROUND",nil,-4)
	bo:SetTexture("Interface\\AddOns\\CalifporniaUI_ClassTimers\\media\\simplesquare_roth")
	bo:SetVertexColor(0.37,0.3,0.3,1)
	bo:SetAllPoints(i)
	
	local time = i:CreateFontString(nil, "BORDER")
	time:SetFont(unpack(cfg.timefont))
	time:SetPoint("BOTTOM", 0, 0)
	time:SetTextColor(1, 0.8, 0)
	--time:SetShadowColor(0,0,0,1)
	--time:SetShadowOffset(w*1/32, -w*1/32)
	
	local count = i:CreateFontString(nil, "BORDER")
	count:SetFont(unpack(cfg.timefont))
	count:SetPoint("TOPRIGHT", 0,0)
	--count:SetShadowColor(0,0,0,1)
	--count:SetShadowOffset(-w*1/32, -w*1/32)
	count:SetTextColor(1, 1, 1)
	count:SetJustifyH("RIGHT")
	
	i.glow = gl
	i.border = bo
	i.back = ba
	i.time = time
	i.count = count
	i.icon = t
	f.iconframe = i
	f.buff_active = false		-- only for multi icons
	f.name = gsi_name
	f.rank = gsi_rank
	f.texture = gsi_icon	

end


local cUpdateEntry = function(entry)
	if not entry.enabled then
		entry.iconframe:SetAlpha(0)
		return
	end
	if entry.spec and entry.spec ~= GetActiveTalentGroup() then
		entry.iconframe:SetAlpha(0)
		return
	end
	if not UnitExists(entry.unit) and entry.validate_unit then
		entry.iconframe:SetAlpha(0)
		return
	end
	if not InCombatLockdown() and entry.hide_ooc then
		entry.iconframe:SetAlpha(0)
		return
	end

	-- update buffs and debuffs
	if entry.type == "multi" or entry.type == "buff" or entry.type == "debuff" then
		local ua_filter
		if entry.type == "debuff" then
			ua_filter = "HARMFUL"
		else
			ua_filter = "HELPFUL"
		end
		local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spID
		local a_found = false
		if entry.spelllist and entry.spelllist[1] then
			for i=1, #entry.spelllist, 1 do
				local gsi_name, gsi_rank, gsi_icon = GetSpellInfo(entry.spelllist[i])
				if gsi_name then
					name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spID = UnitAura(entry.unit, gsi_name, gsi_rank, ua_filter)
					if name and (not entry.ismine or (entry.ismine and caster == "player")) then
						entry.name = gsi_name
						entry.rank = gsi_rank
						entry.texture_list = gsi_icon
						entry.iconframe.icon:SetTexture(entry.texture_list)
						a_found = true
						break
					end
				end
			end
		end
		if not a_found then
			name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spID = UnitAura(entry.unit, entry.name, entry.rank, ua_filter)
			if name and (not entry.ismine or (entry.ismine and caster == "player")) then
				a_found = true
			end
		end
		if a_found then
			if caster == "player" and cfg.highlightPlayerSpells then
				entry.iconframe.border:SetVertexColor(0.2,0.6,0.8,1)
			elseif cfg.highlightPlayerSpells then
				entry.iconframe.border:SetVertexColor(0.37,0.3,0.3,1)
			end
			entry.iconframe.icon:SetAlpha(cfg.alpha.found.icon)
			entry.iconframe:SetAlpha(cfg.alpha.found.frame)
			if cfg.desaturate then
				entry.iconframe.icon:SetDesaturated(nil)
			end
			if count and count > 1 then
				entry.iconframe.count:SetText(count)
			else
				entry.iconframe.count:SetText("")
			end
			local value = expires-GetTime()
			if value < 10 then
				entry.iconframe.time:SetTextColor(1, 0.4, 0)
			else
				entry.iconframe.time:SetTextColor(1, 0.8, 0)
			end
			entry.iconframe.time:SetText(GetFormattedTime(value))

		else
			entry.iconframe:SetAlpha(cfg.alpha.not_found.frame)
			entry.iconframe.icon:SetAlpha(cfg.alpha.not_found.icon)
			if entry.spelllist and entry.spelllist[1] then
				entry.iconframe.icon:SetTexture(entry.texture)
			end
			entry.iconframe.time:SetText("")
			entry.iconframe.count:SetText("")
			entry.iconframe.time:SetTextColor(1, 0.8, 0)
			if cfg.highlightPlayerSpells then
				entry.iconframe.border:SetVertexColor(0.37,0.3,0.3,1)
			end 
			if cfg.desaturate then
				entry.iconframe.icon:SetDesaturated(1)
			end
		end
		entry.buff_active = a_found
	end

	-- update cooldown
	if (entry.type == "multi" and not entry.buff_active) or entry.type == "cd" then
		local start, duration, enable
		if entry.cd_itemid then
			start, duration, enable = GetItemCooldown(entry.cd_itemid)
		else
			start, duration, enable = GetSpellCooldown(entry.spellid)
		end
		if start and duration then
			local now = GetTime()		
			local value = start+duration-now
			if(value > 0) and duration > 2 then
				-- item is on cooldown show time
				entry.iconframe.icon:SetAlpha(cfg.alpha.cooldown.icon)
				entry.iconframe:SetAlpha(cfg.alpha.cooldown.frame)
				entry.iconframe.count:SetText("")
				entry.iconframe.border:SetVertexColor(0.37,0.3,0.3,1)
				if cfg.desaturate then
					entry.iconframe.icon:SetDesaturated(1)
				end
				if value < 10 then
					entry.iconframe.time:SetTextColor(1, 0.4, 0)
				else
					entry.iconframe.time:SetTextColor(1, 0.8, 0)
				end
				entry.iconframe.time:SetText(GetFormattedTime(value))
			elseif entry.cd_itemid and GetItemCount(entry.cd_itemid, nil, true) == 0 then
				entry.iconframe.icon:SetAlpha(cfg.alpha.cooldown.icon)
				entry.iconframe:SetAlpha(cfg.alpha.cooldown.frame)
				entry.iconframe.count:SetText("")
				entry.iconframe.border:SetVertexColor(0.37,0.3,0.3,1)
				if cfg.desaturate then
					entry.iconframe.icon:SetDesaturated(1)
				end
				entry.iconframe.time:SetTextColor(1, 0.4, 0)
				entry.iconframe.time:SetText(cfg.itemouttext)
			else
				entry.iconframe:SetAlpha(cfg.alpha.no_cooldown.frame)
				entry.iconframe.icon:SetAlpha(cfg.alpha.no_cooldown.icon)
				entry.iconframe.time:SetText(cfg.readytext)
				entry.iconframe.count:SetText("")
				entry.iconframe.time:SetTextColor(0, 0.8, 0)
				entry.iconframe.border:SetVertexColor(0.4,0.6,0.2,1)
				if cfg.desaturate then
					entry.iconframe.icon:SetDesaturated(nil)
				end
			end
		end
		-- check item in inventory
	end
	-- temp weapon enchants like poisons
	if entry.type == "enchant" then
		if not entry.inv_slot then return end
		local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges, hasThrownEnchant, thrownExpiration, thrownCharges = GetWeaponEnchantInfo()
		entry.texture = GetInventoryItemTexture("player", entry.inv_slot)
		entry.iconframe.icon:SetTexture(entry.texture)
		local enabled, duration, charges
		if entry.inv_slot == 16 then
			enabled = hasMainHandEnchant
			if enabled then
				expiration = mainHandExpiration/1000
				charges = mainHandCharges
			end
		elseif entry.inv_slot == 17 then
			enabled = hasOffHandEnchant
			if enabled then
				expiration = offHandExpiration/1000
				charges = offHandCharges
			end
		elseif entry.inv_slot == 18 then
			enabled = hasThrownEnchant
			if enabled then
				expiration = mainThrownExpiration/1000
				charges = thrownCharges
			end
		end
		if enabled and expiration > 0 then
			entry.iconframe.icon:SetAlpha(cfg.alpha.found.icon)
			entry.iconframe:SetAlpha(cfg.alpha.found.frame)
			if cfg.desaturate then
				entry.iconframe.icon:SetDesaturated(nil)
			end
			if charges and charges > 1 then
				entry.iconframe.count:SetText(charges)
			else
				entry.iconframe.count:SetText("")
			end
			if expiration < 10 then
				entry.iconframe.time:SetTextColor(1, 0.4, 0)
			else
				entry.iconframe.time:SetTextColor(1, 0.8, 0)
			end
			entry.iconframe.time:SetText(GetFormattedTime(expiration))
		else
			entry.iconframe:SetAlpha(cfg.alpha.not_found.frame)
			entry.iconframe.icon:SetAlpha(cfg.alpha.not_found.icon)
			entry.iconframe.time:SetText("")
			entry.iconframe.count:SetText("")
			entry.iconframe.time:SetTextColor(1, 0.8, 0)
			if cfg.desaturate then
				entry.iconframe.icon:SetDesaturated(1)
			end
		end
	end
	-- done!
end

local cUpdateAll = function(data)
	for i=1, #data, 1 do
		entry =  data[i]
		if entry.enabled then
			cUpdateEntry(entry)
		end
	end
end

local lastupdate = 0
local cFilterOnUpdate = function(self,elapsed)
	lastupdate = lastupdate + elapsed	
	if lastupdate > cfg.updatetime then
		lastupdate = 0
		if cfg.track_class and cfg.IconList[cfg.player_class] then
			cUpdateAll(cfg.IconList[cfg.player_class])
		end
		if cfg.track_items then
			cUpdateAll(cfg.IconList["ITEMS"])
		end
		if cfg.track_enchants then
			cUpdateAll(cfg.IconList["ENCHANTS"])
		end
	end
end




local count = 0

-- create class specific icons
if cfg.track_class and cfg.IconList[cfg.player_class] then
	for i=1, #cfg.IconList[cfg.player_class], 1 do
		local data = cfg.IconList[cfg.player_class][i]
		if data.enabled then
			createIcon(data)
			count=count+1
		end
	end
end

if cfg.track_items then
	for i=1, #cfg.IconList["ITEMS"], 1 do
		local data = cfg.IconList["ITEMS"][i]
		if data.enabled then
			createIcon(data)
			count=count+1
		end
	end
end
if cfg.track_enchants then
	for i=1, #cfg.IconList["ENCHANTS"], 1 do
		local data = cfg.IconList["ENCHANTS"][i]
		if data.enabled then
			createIcon(data)
			count=count+1
		end
	end
end
if count > 0 then
	
	local a = CreateFrame("Frame")

	a:SetScript("OnEvent", function(self, event)
		if(event=="PLAYER_LOGIN") then
			self:SetScript("OnUpdate", cFilterOnUpdate)
		end
	end)
	
	a:RegisterEvent("PLAYER_LOGIN")

end




