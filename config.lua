-- // cFilter by Califpornia. Based on zork`s rFilter3
-- // rFilter3
-- // zork - 2010

--get the addon namespace
local addon, ns = ...

--object container
local cfg = CreateFrame("Frame") 

cfg.rf3_BuffList, cfg.rf3_DebuffList, cfg.rf3_CooldownList = {}, {}, {}

local player_name, _ = UnitName("player")
_, cfg.player_class = UnitClass("player")

-----------------------------
-- CONFIG
-----------------------------

cfg.highlightPlayerSpells = true
cfg.updatetime			= 0.2 --how fast should the timer update itself


-- Califpornia addition
-- anchor point for all icons
cfg.readytext = "rdy"
cfg.itemouttext = "out"
cfg.apos = {"TOPLEFT", "UIParent", "CENTER", -204, -144}
cfg.growth_x = "RIGHT"
cfg.growth_y = "UP"
cfg.space_x = 2
cfg.space_y = 2
cfg.rowicons = 12
cfg.size = 32
cfg.desaturate = true
cfg.alpha = {
	cooldown = {
		frame = 1,
		icon = 0.6,
	},
	no_cooldown = {
		frame = 1,
		icon = 1,		
	},
	found = {
		frame = 1,
		icon = 1,
	},
	not_found = {
		frame = 0.4,
		icon = 0.6,          
	},
}
cfg.track_class = true
cfg.track_enchants = false
cfg.track_items = true
cfg.track_equip_slots = true
cfg.timefont = {"Interface\\AddOns\\CalifporniaUI\\media\\fonts\\big_noodle_tilting.ttf", 14, "OUTLINE"}
cfg.IconList = {
	["ENCHANTS"] = {
		-- MH
		{
			enabled		= true,
			type			= "enchant",
			spec			= nil, 
			spellid		= 51730,
		        spelllist		= nil,
			cd_itemid		= nil,
			inv_slot		= 16,
		},
		-- OH
		{
			enabled		= true,
			type			= "enchant",
			spec			= nil, 
			spellid		= 51730,
		        spelllist		= nil,
			cd_itemid		= nil,
			inv_slot		= 17,
		},
		-- Thrown
		{
			enabled		= true,
			type			= "enchant",
			spec			= nil, 
			spellid		= 51730,
		        spelllist		= nil,
			cd_itemid		= nil,
			inv_slot		= 18,
		},
	},
	["ITEMS"] = {
		-- potions
	},
	["PALADIN"] = {
		-- Common
		-- Buffs
		-- GoaK
		{
			enabled		= true,
			type			= "multi",
			spec			= nil, 
			spellid		= 86150,
			unit			= "player",
		},
		-- Avenging Wrath
		{
			enabled		= true,
			type			= "multi",
			spec			= nil, 
			spellid		= 31884,
			unit			= "player",
		},
		-- Inquisition
		{
			enabled		= true,
			type			= "buff",
			spec			= 1, 
			spellid		= 84963,
			unit			= "player",
		},
		-- Zealotry
		{
			enabled		= true,
			type			= "multi",
			spec			= 1, 
			spellid		= 85696,
			unit			= "player",
		},
		-- Divine Purpose
		{
			enabled		= true,
			type			= "buff",
			spec			= 1, 
			spellid		= 90174,
			unit			= "player",
		},
		-- Art of War
		{
			enabled		= true,
			type			= "buff",
			spec			= 1, 
			spellid		= 59578,
			unit			= "player",
		},
		-- Enlightened Judgements
		{
			enabled		= true,
			type			= "buff",
			spec			= nil, 
			spellid		= 53657,
		        spelllist		= {
				53655,	-- rank 1
				53656,	-- rank 2
			},
			unit			= "player",
		},
		-- Censure
		{
			enabled		= true,
			type			= "debuff",
			spec			= nil, 
			spellid		= 31803,
			unit			= "target",
			validate_unit	= true,
			ismine		= true,
		},
		-- Forbearance
		{
			enabled		= true,
			type			= "debuff",
			spec			= nil, 
			spellid		= 25771,
			unit			= "player",
			validate_unit	= true,
		},
		-- Cata STR pot
		{
			enabled		= true,
			type			= "multi",
			spec			= nil, 
			spellid		= 79634,
		        spelllist		= nil,
			cd_itemid		= 58146,
			cd_slotid		= nil,
			unit			= "player",
			validate_unit	= false,
			hide_ooc		= false,
			ismine		= false,
		},
		-- Eng gloves
		{
			enabled		= true,
			type			= "multi",
			spec			= nil, 
			spellid		= 96229,
			cd_itemid		= GetInventoryItemID("player", 10),
			cd_slotid		= nil,
			unit			= "player",
			validate_unit	= false,
			hide_ooc		= false,
			ismine		= false,
		},
		-- Seals
		{
			enabled		= true,
			type			= "buff",
			spec			= nil, 
			spellid		= 31801, -- Seal of Truth
		        spelllist		= {
				20154,	-- Seal of Righteousness
				20164,	-- Seal of Justice
				20165,	-- Seal of Insight
				31801,	-- Seal of Truth
			},
			unit			= "player",
		},
	},
	["SHAMAN"] = {
		-- Common
		-- Shields
		{
			enabled		= true,
			type			= "buff",
			spec			= nil, 
			spellid		= 324,	-- lightning shield
		        spelllist		= {
				324,
				52127,	-- water shield
				974,	-- earth shield on self
			},
			unit			= "player",
		},
	},
	["WARRIOR"] = {
		-- Common
		-- Sunder Armor
		{
			enabled		= true,
			type			= "debuff",
			spec			= nil, 
			spellid		= 58567,
			unit			= "target",
			validate_unit	= true,
		},
	},
	["HUNTER"] = {
		-- Common
		-- Sunder Armor
		{
			enabled		= true,
			type			= "debuff",
			spec			= nil, 
			spellid		= 1978,
			unit			= "target",
			validate_unit	= true,
			ismine		= true,
		},
	},
	["MAGE"] = {
		-- Blink
		{
			enabled		= true,
			-- multi = cd+duration, debuff = debuff, buff = buff, cd = cooldown :)
			type			= "multi",
			spec			= nil, 
			spellid		= 1953,
			-- If aura have analogs check them all, because other classes can do the same (c)
		        spelllist		= nil,
			-- if you wish track things like pots and/or eng enchants you should put item ID or slot here
			cd_itemid		= nil,
			cd_slotid		= nil,
			unit			= "player",
			-- only show the icon if unit is found
			validate_unit	= false,
			 -- hide icon out of combat
			hide_ooc		= false,
			ismine		= false,
		},
		-- Mirror Image
		{
			enabled		= true,
			type			= "multi",
			spec			= nil, 
			spellid		= 55342,
		        spelllist		= {70747},	-- 4t10 bonus
			cd_itemid		= nil,
			cd_slotid		= nil,
			unit			= "player",
			validate_unit	= false,
			hide_ooc		= false,
			ismine		= false,
		},
		-- Ice Block
		{
			enabled		= true,
			type			= "multi",
			spec			= nil, 
			spellid		= 45438,
		        spelllist		= nil,
			cd_itemid		= nil,
			cd_slotid		= nil,
			unit			= "player",
			validate_unit	= false,
			hide_ooc		= false,
			ismine		= false,
		},
		-- Mana Gem
		{
			enabled		= true,
			type			= "multi",
			spec			= nil, 
			spellid		= 5405,
		        spelllist		= {83098},	-- Improved Mana Gem
			cd_itemid		= 36799,
			cd_slotid		= nil,
			unit			= "player",
			validate_unit	= false,
			hide_ooc		= false,
			ismine		= false,
		},
		-- DEBUFFS
		-- slow
		{
			enabled		= true,
			type			= "debuff",
			spec			= nil, 
			spellid		= 31589,
		        spelllist		= nil,
			cd_itemid		= nil,
			cd_slotid		= nil,
			unit			= "target",
			validate_unit	= true,
			hide_ooc		= false,
			ismine		= false,
		},
	}
}

--[[
Regular inventory items
0 = ammo 
1 = head 
2 = neck 
3 = shoulder 
4 = shirt 
5 = chest 
6 = belt 
7 = legs 
8 = feet 
9 = wrist 
10 = gloves 
11 = finger 1 
12 = finger 2 
13 = trinket 1 
14 = trinket 2 
15 = back 
16 = main hand 
17 = off hand 
18 = ranged 
19 = tabard 
20 = first bag (the rightmost one) 
21 = second bag 
22 = third bag 
23 = fourth bag (the leftmost one) 

When bank frame is open
40 to 67 = the 28 bank slots 
68 = first bank bag slot 
69 = second bank bag slot 
70 = third bank bag slot 
71 = fourth bank bag slot 
72 = fifth bank bag slot 
73 = sixth bank bag slot 
74 = seventh bank bag slot
]]


-----------------------------
-- HANDOVER
-----------------------------

--object container to addon namespace
ns.cfg = cfg