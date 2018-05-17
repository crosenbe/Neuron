--Neuron, a World of Warcraft® user interface addon.


local NEURON = Neuron
local GDB, CDB, player, realm, btnGDB, btnCDB

NEURON.NeuronButton = NEURON:NewModule("Button", "AceEvent-3.0", "AceHook-3.0")
local NeuronButton = NEURON.NeuronButton

NEURON.BUTTON = setmetatable({}, {__index = CreateFrame("CheckButton")})
local BUTTON = NEURON.BUTTON

local BTNIndex, SKINIndex = NEURON.BTNIndex, NEURON.SKINIndex

local L = LibStub("AceLocale-3.0"):GetLocale("Neuron")

local SKIN = LibStub("Masque", true)

local MacroDrag = NEURON.MacroDrag
local StartDrag = NEURON.StartDrag

local sIndex = NEURON.sIndex  --Spell index
local cIndex = NEURON.cIndex  --Battle pet & Mount index
local iIndex = NEURON.iIndex  --Items Index
local tIndex = NEURON.tIndex  --Toys Index

local ItemCache

local cmdSlash

local macroCache = {}


local configData = {
	btnType = "macro",

	mouseAnchor = false,
	clickAnchor = false,
	anchorDelay = false,
	anchoredBar = false,

	upClicks = true,
	downClicks = false,
	copyDrag = false,
	muteSFX = false,
	clearerrors= false,
	cooldownAlpha = 1,

	bindText = true,
	bindColor = "1;1;1;1",

	countText = true,
	spellCounts = false,
	comboCounts = false,
	countColor = "1;1;1;1",

	macroText = true,
	macroColor = "1;1;1;1",

	cdText = false,
	cdcolor1 = "1;0.82;0;1",
	cdcolor2 = "1;0.1;0.1;1",

	auraText = false,
	auracolor1 = "0;0.82;0;1",
	auracolor2 = "1;0.1;0.1;1",

	auraInd = false,
	buffcolor = "0;0.8;0;1",
	debuffcolor = "0.8;0;0;1",

	rangeInd = true,
	rangecolor = "0.7;0.15;0.15;1",

	skincolor = "1;1;1;1",
	hovercolor = "0.1;0.1;1;1",
	equipcolor = "0.1;1;0.1;1",

	scale = 1,
	alpha = 1,
	XOffset = 0,
	YOffset = 0,
	HHitBox = 0,
	VHitBox = 0,
}


local keyData = {
	hotKeys = ":",
	hotKeyText = ":",
	hotKeyLock = false,
	hotKeyPri = false,
}


local keyDefaults = {
	[1] = { hotKeys = ":1:", hotKeyText = ":1:" },
	[2] = { hotKeys = ":2:", hotKeyText = ":2:" },
	[3] = { hotKeys = ":3:", hotKeyText = ":3:" },
	[4] = { hotKeys = ":4:", hotKeyText = ":4:" },
	[5] = { hotKeys = ":5:", hotKeyText = ":5:" },
	[6] = { hotKeys = ":6:", hotKeyText = ":6:" },
	[7] = { hotKeys = ":7:", hotKeyText = ":7:" },
	[8] = { hotKeys = ":8:", hotKeyText = ":8:" },
	[9] = { hotKeys = ":9:", hotKeyText = ":9:" },
	[10] = { hotKeys = ":0:", hotKeyText = ":0:" },
	[11] = { hotKeys = ":-:", hotKeyText = ":-:" },
	[12] = { hotKeys = ":=:", hotKeyText = ":=:" },
}


local stateData = {
	actionID = false,

	macro_Text = "",
	macro_Icon = false,
	macro_Name = "",
	macro_Auto = false,
	macro_Watch = false,
	macro_Equip = false,
	macro_Note = "",
	macro_UseNote = false,
}


NEURON.SpecialActions = { vehicle = "Interface\\AddOns\\Neuron\\Images\\new_vehicle_exit", possess = "Interface\\Icons\\Spell_Shadow_SacrificialShield", taxi = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up",}

local SpecialActions = NEURON.SpecialActions

NEURON.PetActions = {
	petattack = { "Interface\\Icons\\Ability_GhoulFrenzy", L["Attack"], { 0, 1, 0, 1 }, "/petattack" },
	petfollow = { "Interface\\Icons\\Ability_Tracking", L["Follow"], { 0, 1, 0, 1 }, "/petfollow" },
	petmoveto = { "Interface\\Icons\\Ability_Hunter_Pet_Goto", L["Move To"], { 0, 1, 0, 1 }, "/petmoveto" },
	petassist = { "Interface\\Icons\\Ability_Hunter_Pet_Assist", L["Assist"], { 0, 1, 0, 1 }, "/petassist" },
	petdefensive = { "Interface\\Icons\\Ability_Defend", L["Defensive"], { 0, 1, 0, 1 }, "/petdefensive" },
	petpassive = { "Interface\\Icons\\Ability_Seal", L["Passive"], { 0, 1, 0, 1 }, "/petpassive" },
}

--local PetActions = NEURON.PetActions


--Spells that need their primary spell name overwritten
local AlternateSpellNameList = {
	[883] = true, --CallPet1
	[83242] = true, --CallPet2
	[83243] = true,  --CallPet3
	[83244] = true,  --CallPet4
	[83245] = true,  --CallPet5
}

local unitAuras = { player = {}, target = {}, focus = {} }

local alphaTimer, alphaDir = 0, 0

local autoCast = { speeds = { 2, 4, 6, 8 }, timers = { 0, 0, 0, 0 }, circle = { 0, 22, 44, 66 }, shines = {}, r = 0.95, g = 0.95, b = 0.32 }

local cooldowns, cdAlphas = {}, {}



-----------------------------------------------------------------------------
--------------------------INIT FUNCTIONS-------------------------------------
-----------------------------------------------------------------------------

--- **OnInitialize**, which is called directly after the addon is fully loaded.
--- do init tasks here, like loading the Saved Variables
--- or setting up slash commands.
function NeuronButton:OnInitialize()
	GDB, CDB = NeuronGDB, NeuronCDB

	btnGDB = GDB.buttons

	btnCDB = CDB.buttons

	ItemCache = NeuronItemCache

	cmdSlash = {
		[SLASH_CAST1] = true,
		[SLASH_CAST2] = true,
		[SLASH_CAST3] = true,
		[SLASH_CAST4] = true,
		[SLASH_CASTRANDOM1] = true,
		[SLASH_CASTRANDOM2] = true,
		[SLASH_CASTSEQUENCE1] = true,
		[SLASH_CASTSEQUENCE2] = true,
		[SLASH_EQUIP1] = true,
		[SLASH_EQUIP2] = true,
		[SLASH_EQUIP3] = true,
		[SLASH_EQUIP4] = true,
		[SLASH_EQUIP_TO_SLOT1] = true,
		[SLASH_EQUIP_TO_SLOT2] = true,
		[SLASH_USE1] = true,
		[SLASH_USE2] = true,
		[SLASH_USERANDOM1] = true,
		[SLASH_USERANDOM2] = true,
		["/cast"] = true,
		["/castrandom"] = true,
		["/castsequence"] = true,
		["/spell"] = true,
		["/equip"] = true,
		["/eq"] = true,
		["/equipslot"] = true,
		["/use"] = true,
		["/userandom"] = true,
		["/summonpet"] = true,
		["/click"] = true,
	}

	if (SKIN) then
		SKIN:Register("Neuron", NEURON.SKINCallback, true)
	end
end

--- **OnEnable** which gets called during the PLAYER_LOGIN event, when most of the data provided by the game is already present.
--- Do more initialization here, that really enables the use of your addon.
--- Register Events, Hook functions, Create Frames, Get information from
--- the game that wasn't available in OnInitialize
function NeuronButton:OnEnable()

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("ACTIONBAR_SHOWGRID")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")

	for k in pairs(unitAuras) do
		self:updateAuraInfo(k)
	end

	---these two hooks are to call a function to check if we dragged an ability off the bar or not
	self:SecureHookScript(WorldFrame, "OnMouseDown")

	self:SecureHook("ToggleCollectionsJournal")


end


--- **OnDisable**, which is only called when your addon is manually being disabled.
--- Unhook, Unregister Events, Hide frames that you created.
--- You would probably only use an OnDisable if you want to
--- build a "standby" mode, or be able to toggle modules on/off.
function NeuronButton:OnDisable()

end


------------------------------------------------------------------------------

function NeuronButton:PLAYER_TARGET_CHANGED()
	for k in pairs(unitAuras) do
		self:updateAuraInfo(k)
	end
end

function NeuronButton:ACTIONBAR_SHOWGRID()
	StartDrag = true
end

function NeuronButton:UNIT_AURA(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		self:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_SENT(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		self:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_START(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		self:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_SUCCEEDED(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		self:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_CHANNEL_START(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		self:updateAuraInfo(select(1,...))
	end
end

function NeuronButton:UNIT_SPELLCAST_SUCCEEDED(eventname, ...)
	if (unitAuras[select(1,...)]) then
		if (... == "player") then
		end
		self:updateAuraInfo(select(1,...))
	end
end


-------------------------------------------------------------------------------

------------------------------------------------------------
--------------------Intermediate Functions------------------
------------------------------------------------------------




function NeuronButton:AutoCastStart(shine, r, g, b)
	autoCast.shines[shine] = shine

	if (not r) then
		r, g, b = autoCast.r, autoCast.g, autoCast.b
	end

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Show(); sparkle:SetVertexColor(r, g, b)
	end
end


function NeuronButton:AutoCastStop(shine)
	autoCast.shines[shine] = nil

	for _,sparkle in pairs(shine.sparkles) do
		sparkle:Hide()
	end
end


--this function gets called via controlOnUpdate in the main Neuron.lua
---this function controlls the sparkley effects around abilities, if throttled then those effects are throttled down super slow. Be careful.
function NeuronButton.controlOnUpdate(self, elapsed)
	local cou_distance, cou_radius, cou_timer, cou_speed, cou_degree, cou_x, cou_y, cou_position

	for i in next,autoCast.timers do
		autoCast.timers[i] = autoCast.timers[i] + elapsed

		if ( autoCast.timers[i] > autoCast.speeds[i]*4 ) then
			autoCast.timers[i] = 0
		end
	end

	for i in next,autoCast.circle do
		autoCast.circle[i] = autoCast.circle[i] - i

		if ( autoCast.circle[i] < 0 ) then
			autoCast.circle[i] = 359
		end
	end

	for shine in next, autoCast.shines do
		cou_distance, cou_radius = shine:GetWidth(), shine:GetWidth()/2.7
		for i=1,4 do
			cou_timer, cou_speed, cou_degree = autoCast.timers[i], autoCast.speeds[i], autoCast.circle[i]

			if ( cou_timer <= cou_speed ) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree-270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree-270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = cou_timer/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
				end

			elseif (cou_timer <= cou_speed*2) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
				end

			elseif (cou_timer <= cou_speed*3) then
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed*2)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
				end
			else
				if (shine.shape == "circle") then
					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree))
					shine.sparkles[0+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+90)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+90))
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+180)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+180))
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)

					cou_x = ((cou_radius)*(4/math.pi))*(cos(cou_degree+270)); cou_y = ((cou_radius)*(4/math.pi))*(sin(cou_degree+270))
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "CENTER", cou_x, cou_y)
				else
					cou_position = (cou_timer-cou_speed*3)/cou_speed*cou_distance

					shine.sparkles[0+i]:SetPoint("CENTER", shine, "BOTTOMLEFT", 0, cou_position)
					shine.sparkles[4+i]:SetPoint("CENTER", shine, "TOPRIGHT", 0, -cou_position)
					shine.sparkles[8+i]:SetPoint("CENTER", shine, "TOPLEFT", cou_position, 0)
					shine.sparkles[12+i]:SetPoint("CENTER", shine, "BOTTOMRIGHT", -cou_position, 0)
				end
			end
		end
	end

	alphaTimer = alphaTimer + elapsed * 2.5

	if (alphaDir == 1) then
		if (1-alphaTimer <= 0) then
			alphaDir = 0; alphaTimer = 0
		end

	else
		if (alphaTimer >= 1) then
			alphaDir = 1; alphaTimer = 0
		end
	end
end

--this function gets called via controlOnUpdate in the main Neuron.lua
function NeuronButton.cooldownsOnUpdate(self, elapsed)
	local coolDown, formatted, size

	for cd in next,cooldowns do

		coolDown = floor(cd.duration-(GetTime()-cd.start))
		formatted, size = coolDown, cd.button:GetWidth()*0.45

		if (coolDown < 1) then
			if (coolDown < 0) then
				cooldowns[cd] = nil

				cd.timer:Hide()
				cd.timer:SetText("")
				cd.timerCD = nil
				cd.expirecolor = nil
				cd.cdsize = nil
				cd.active = nil
				cd.expiry = nil

			elseif (coolDown >= 0) then
				cd.timer:SetAlpha(cd.duration-(GetTime()-cd.start))

				if (cd.alphafade) then
					cd:SetAlpha(cd.duration-(GetTime()-cd.start))
				end
			end

		elseif (cd.timer:IsShown() and coolDown ~= cd.timerCD) then
			if (coolDown >= 86400) then
				formatted = math.ceil(coolDown/86400)
				formatted = formatted.."d"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 3600) then
				formatted = math.ceil(coolDown/3600)
				formatted = formatted.."h"; size = cd.button:GetWidth()*0.3
			elseif (coolDown >= 60) then
				formatted = math.ceil(coolDown/60)
				formatted = formatted.."m"; size = cd.button:GetWidth()*0.3
			elseif (coolDown < 6) then
				size = cd.button:GetWidth()*0.6
				if (cd.expirecolor) then
					cd.timer:SetTextColor(cd.expirecolor[1], cd.expirecolor[2], cd.expirecolor[3]); cd.expirecolor = nil
					cd.expiry = true
				end
			end

			if (not cd.cdsize or cd.cdsize ~= size) then
				cd.timer:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE"); cd.cdsize = size
			end

			cd.timerCD = coolDown
			cd.timer:SetAlpha(1)
			cd.timer:SetText(formatted)
		end
	end

	for cd in next,cdAlphas do
		coolDown = ceil(cd.duration-(GetTime()-cd.start))

		if (coolDown < 1) then
			cdAlphas[cd] = nil
			cd.button:SetAlpha(1)
			cd.alphaOn = nil

		elseif (not cd.alphaOn) then
			cd.button:SetAlpha(cd.button.cdAlpha)
			cd.alphaOn = true
		end
	end
end



function NeuronButton:updateAuraInfo(unit)

	local uai__ = 1
	local uai_index, uai_spell, uai_count, uai_duration, uai_timeLeft, uai_caster, uai_spellID
	uai_index = 1

	wipe(unitAuras[unit])

	repeat
		uai_spell, uai__, uai__, uai_count, uai__, uai_duration, uai_timeLeft, uai_caster, uai__, uai__, uai_spellID = UnitAura(unit, uai_index, "HELPFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "buff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)

	uai_index = 1

	repeat
		uai_spell, uai__, uai__, uai_count, uai__, uai_duration, uai_timeLeft, uai_caster = UnitAura(unit, uai_index, "HARMFUL")

		if (uai_duration and (uai_caster == "player" or uai_caster == "pet")) then
			unitAuras[unit][uai_spell:lower()] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
			unitAuras[unit][uai_spell:lower().."()"] = "debuff"..":"..uai_duration..":"..uai_timeLeft..":"..uai_count
		end

		uai_index = uai_index + 1

	until (not uai_spell)
end


function NeuronButton:isActiveShapeshiftSpell(spell)
	local shapeshift, texture, name, isActive = spell:match("^[^(]+")

	if (shapeshift) then
		for i=1, GetNumShapeshiftForms() do
			texture, name, isActive = GetShapeshiftFormInfo(i)
			if (isActive and name:lower() == shapeshift:lower()) then
				return texture
			end
		end
	end
end



function NeuronButton:SetTimer(cd, start, duration, enable, timer, color1, color2, cdAlpha)
	if ( start and start > 0 and duration > 0 and enable > 0) then
		cd:SetAlpha(1)
		CooldownFrame_Set(cd, start, duration, enable)
		--CooldownFrame_SetTimer(cd, start, duration, enable)

		if (duration >= GDB.timerLimit) then
			cd.duration = duration
			cd.start = start
			cd.active = true

			if (timer) then
				cd.timer:Show()
				if (not cd.expiry) then
					cd.timer:SetTextColor(color1[1], color1[2], color1[3])
				end
				cd.expirecolor = color2
			end

			cooldowns[cd] = true

			if (cdAlpha) then
				cdAlphas[cd] = true
			end

		elseif (cooldowns[cd]) then
			cd.duration = 1
		end

	else
		cd.duration = 0; cd.start = 0;
		CooldownFrame_Set(cd, 0, 0, 0)
	end
end


function NeuronButton:MACRO_HasAction(button)
	local hasAction = button.data.macro_Text

	if (button.actionID) then
		if (button.actionID == 0) then
			return true
		else
			return HasAction(button.actionID)
		end

	elseif (hasAction and #hasAction>0) then
		return true
	else
		return false
	end
end


function NeuronButton:MACRO_GetDragAction()
	return "macro"
end


function NeuronButton:MACRO_UpdateData(button, ...)

	local ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__


	if (button.macroparse) then
		ud_spell, ud_spellcmd, ud_show, ud_showcmd, ud_cd, ud_cdcmd, ud_aura, ud_auracmd, ud_item, ud_target, ud__ = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil

		for cmd, options in gmatch(button.macroparse, "(%c%p%a+)(%C+)") do
			--after gmatch, remove unneeded characters
			if (cmd) then cmd = cmd:gsub("^%c+", "") end
			if (options) then options = options:gsub("^%s+", "") end

			--find #ud_show option!
			if (not ud_show and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options); ud_showcmd = cmd
				--sometimes SecureCmdOptionParse will return "" since that is not what we want, keep looking
			elseif (ud_show and #ud_show < 1 and cmd:find("^#show")) then
				ud_show = SecureCmdOptionParse(options); ud_showcmd = cmd
			end

			--find #cdwatch option!
			if (not ud_cd and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			elseif (ud_cd and #ud_cd < 1 and cmd:find("^#cdwatch")) then
				ud_cd = SecureCmdOptionParse(options); ud_cdcmd = cmd
			end

			--find #aurawatch option!
			if (not ud_aura and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			elseif (ud_aura and #ud_aura < 1 and cmd:find("^#aurawatch")) then
				ud_aura = SecureCmdOptionParse(options); ud_auracmd = cmd
			end

			--find the ud_spell!
			if (not ud_spell and cmdSlash[cmd]) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			elseif (ud_spell and #ud_spell < 1) then
				ud_spell, ud_target = SecureCmdOptionParse(options); ud_spellcmd = cmd
			end
		end

		if (ud_spell and ud_spellcmd:find("/castsequence")) then
			ud__, ud_item, ud_spell = QueryCastSequence(ud_spell)
		elseif (ud_spell) then
			if (#ud_spell < 1) then
				ud_spell = nil
			elseif(GetItemInfo(ud_spell) or ItemCache[ud_spell]) then
				ud_item = ud_spell; ud_spell = nil
			elseif(tonumber(ud_spell) and GetInventoryItemLink("player", ud_spell)) then
				ud_item = GetInventoryItemLink("player", ud_spell); ud_spell = nil
			end
		end

		button.unit = ud_target or "target"

		if (ud_spell) then
			button.macroitem = nil
			if (ud_spell ~= button.macrospell) then

				ud_spell = ud_spell:gsub("!", "")
				button.macrospell = ud_spell

				if (sIndex[ud_spell:lower()]) then
					button.spellID = sIndex[ud_spell:lower()].spellID
				else
					button.spellID = nil
				end
			end
		else
			button.macrospell = nil; button.spellID = nil
		end

		if (ud_show and ud_showcmd:find("#showicon")) then
			if (ud_show ~= button.macroicon) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				button.macroicon = ud_show
				button.macroshow = nil
			end
		elseif (ud_show) then
			if (ud_show ~= button.macroshow) then
				if(tonumber(ud_show) and GetInventoryItemLink("player", ud_show)) then
					ud_show = GetInventoryItemLink("player", ud_show)
				end
				button.macroshow = ud_show
				button.macroicon = nil
			end
		else
			button.macroshow = nil
			button.macroicon = nil
		end

		if (ud_cd) then
			if (ud_cd ~= button.macrocd) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_cd)) then
					ud_aura = GetInventoryItemLink("player", ud_cd)
				end
				button.macrocd = ud_aura
			end
		else
			button.macrocd = nil
		end

		if (ud_aura) then
			if (ud_aura ~= button.macroaura) then
				if(tonumber(ud_aura) and GetInventoryItemLink("player", ud_aura)) then
					ud_aura = GetInventoryItemLink("player", ud_aura)
				end
				button.macroaura = ud_aura
			end
		else
			button.macroaura = nil
		end

		if (ud_item) then
			button.macrospell = nil;
			button.spellID = nil
			if (ud_item ~= button.macroitem) then
				button.macroitem = ud_item
			end
		else
			button.macroitem = nil
		end
	end
end


function NeuronButton:MACRO_SetSpellIcon(button, spell)
	local _, texture

	if (not button.data.macro_Watch and not button.data.macro_Equip) then

		spell = (spell):lower()
		if (sIndex[spell]) then
			local spell_id = sIndex[spell].spellID
			texture = GetSpellTexture(spell_id)

		elseif (cIndex[spell]) then
			texture = cIndex[spell].icon

		elseif (spell) then
			texture = GetSpellTexture(spell)
		end

		if (texture) then

			local shapeshift = NeuronButton:isActiveShapeshiftSpell(spell)

			if (shapeshift) then
				button.iconframeicon:SetTexture(shapeshift)
			else
				button.iconframeicon:SetTexture(texture)

			end

			button.iconframeicon:Show()
		else
			button.iconframeicon:SetTexture("")
			button.iconframeicon:Hide()
		end

	else
		if (button.data.macro_Watch) then
			--for i=1,select("#",GetMacroInfo(button.data.macro_Watch)) do
			--	NEURON:Print(select(i,GetMacroInfo(button.data.macro_Watch)))
			--end

			_, texture = GetMacroInfo(button.data.macro_Watch)
			--texture = "INTERFACE\\ICONS\\"..texture:match("[%w_]+$"):upper()
			button.data.macro_Icon = texture
		elseif (button.data.macro_Equip) then
			texture = GetEquipmentSetInfoByName(button.data.macro_Equip)
		end

		if (texture) then
			button.iconframeicon:SetTexture(texture)
			button.iconframeicon:Show()
		else
			button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	return texture
end


function NeuronButton:MACRO_SetItemIcon(button, item)
	local _,texture, link, itemID

	if (IsEquippedItem(item)) then --makes the border green when item is equipped and dragged to a button
		button.border:SetVertexColor(0, 1.0, 0, 0.2)
		button.border:Show()
	else
		button.border:Hide()
	end

	--There is stored icon and dont want to update icon on fly
	if (((type(button.data.macro_Icon) == "string" and #button.data.macro_Icon > 0) or type(button.data.macro_Icon) == "number")) then
		if (button.data.macro_Icon == "BLANK") then
			button.iconframeicon:SetTexture("")
		else
			button.iconframeicon:SetTexture(button.data.macro_Icon)
		end

	else
		_, link, _, _, _, _, _, _, _, texture = GetItemInfo(item)
		if (link) then

			_, itemID = link:match("(item:)(%d+)")

			if (itemID and not ItemCache[item]) then
				ItemCache[item] = itemID
			end
		end

		if (not texture) then

			if (ItemCache[item]) then
				texture = GetItemIcon("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
			end
		end

		if (texture) then
			button.iconframeicon:SetTexture(texture)
		else
			button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end
	end

	button.iconframeicon:Show()

	return button.iconframeicon:GetTexture()
end


function NeuronButton:ACTION_SetIcon(button, action)
	local actionID = tonumber(action)

	if (actionID) then
		if (actionID == 0) then
			if (button.specAction and SpecialActions[button.specAction]) then
				button.iconframeicon:SetTexture(SpecialActions[button.specAction])
			else
				button.iconframeicon:SetTexture(0,0,0)
			end

		else
			button.macroname:SetText(GetActionText(actionID))
			if (HasAction(actionID)) then
				button.iconframeicon:SetTexture(GetActionTexture(actionID))
			else
				button.iconframeicon:SetTexture(0,0,0)
			end
		end

		button.iconframeicon:Show()
	else
		button.iconframeicon:SetTexture("")
		button.iconframeicon:Hide()
	end

	return button.iconframeicon:GetTexture()
end


function NeuronButton:MACRO_UpdateIcon(button, ...)
	button.updateMacroIcon = nil
	button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")

	local spell, item, show, texture = button.macrospell, button.macroitem, button.macroshow, button.macroicon

	if (button.actionID) then
		texture = NeuronButton:ACTION_SetIcon(button, button.actionID)
	elseif (show and #show>0) then
		if(GetItemInfo(show) or ItemCache[show]) then
			texture = NeuronButton:MACRO_SetItemIcon(button, show)
		else
			texture = NeuronButton:MACRO_SetSpellIcon(button, show)
			NeuronButton:MACRO_SetSpellState(button, show)
		end

	elseif (spell and #spell>0) then
		texture = NeuronButton:MACRO_SetSpellIcon(button, spell)
		NeuronButton:MACRO_SetSpellState(button, spell)
	elseif (item and #item>0) then
		texture = NeuronButton:MACRO_SetItemIcon(button, item)
	elseif (#button.data.macro_Text > 0) then
		local equipset = button.data.macro_Text:match("/equipset%s+(%C+)")

		if (equipset) then
			equipset = equipset:gsub("%pnobtn:2%p ", "")
			local icon, _, isEquipped = GetEquipmentSetInfoByName(equipset)

			if (isEquipped) then
				button.border:Show()
			else
				button.border:Hide()
			end

			if (icon) then
				button.iconframeicon:SetTexture("INTERFACE\\ICONS\\"..icon:upper())
			end

		elseif (button.data.macro_Icon) then
			button.iconframeicon:SetTexture(button.data.macro_Icon)
		else
			button.iconframeicon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")
		end

		button.iconframeicon:Show()
	else
		button.macroname:SetText("")
		button.iconframeicon:SetTexture("")
		button.iconframeicon:Hide()
		button.border:Hide()
	end


	--druid fix for thrash glow not showing for feral druids.
	--Thrash Guardian: 77758
	--Thrash Feral: 106832
	--But the joint thrash is 106830 (this is the one that results true when the ability is procced)

	--Swipe(Bear): 213771
	--Swipe(Cat): 106785
	--Swipe(NoForm): 213764

	if (button.spellID and IsSpellOverlayed(button.spellID)) then
		NeuronButton:MACRO_StartGlow(button)
	elseif (spell == "Thrash()" and IsSpellOverlayed(106830)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		NeuronButton:MACRO_StartGlow(button)
	elseif (spell == "Swipe()" and IsSpellOverlayed(106785)) then --this is a hack for feral druids (Legion patch 7.3.0. Bug reported)
		NeuronButton:MACRO_StartGlow(button)
	elseif (button.glowing) then
		NeuronButton:MACRO_StopGlow(button)
	end

	return texture
end


function NeuronButton:MACRO_StartGlow(button)

	if (button.spellGlowDef) then
		ActionButton_ShowOverlayGlow(button)
	elseif (button.spellGlowAlt) then
		NeuronButton:AutoCastStart(button.shine)
	end

	button.glowing = true
end


function NeuronButton:MACRO_StopGlow(button)
	if (button.spellGlowDef) then
		ActionButton_HideOverlayGlow(button)
	elseif (button.spellGlowAlt) then
		NeuronButton:AutoCastStop(button.shine)
	end

	button.glowing = nil
end


function NeuronButton:MACRO_SetSpellState(button, spell)
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)
	if (maxCharges and maxCharges > 1) then
		button.count:SetText(charges)
	else
		button.count:SetText("")
	end

	local count = GetSpellCount(spell)
	if (count and count > 0) then
		button.count:SetText(count)
	end

	if (cIndex[spell:lower()]) then
		spell = cIndex[spell:lower()].spellID

		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell)) then
			button:SetChecked(1)
		else
			button:SetChecked(nil)
		end
	else
		if (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell) or NeuronButton:isActiveShapeshiftSpell(spell:lower())) then
			button:SetChecked(1)
		else
			button:SetChecked(nil)
		end
	end

	if ((IsAttackSpell(spell) and IsCurrentSpell(spell)) or IsAutoRepeatSpell(spell)) then
		button.mac_flash = true
	else
		button.mac_flash = false
	end

	button.macroname:SetText(button.data.macro_Name)
end


function NeuronButton:MACRO_SetItemState(button, item)

	if (GetItemCount(item,nil,true) and  GetItemCount(item,nil,true) > 1) then
		button.count:SetText(GetItemCount(item,nil,true))
	else
		button.count:SetText("")
	end

	if(IsCurrentItem(item)) then
		button:SetChecked(1)
	else
		button:SetChecked(nil)
	end
	button.macroname:SetText(button.data.macro_Name)
end

function NeuronButton:ACTION_UpdateState(button, action)
	local actionID = tonumber(action)

	button.count:SetText("")

	if (actionID) then
		button.macroname:SetText("")

		if (IsCurrentAction(actionID) or IsAutoRepeatAction(actionID)) then
			button:SetChecked(1)
		else
			button:SetChecked(nil)
		end

		if ((IsAttackAction(actionID) and IsCurrentAction(actionID)) or IsAutoRepeatAction(actionID)) then
			button.mac_flash = true
		else
			button.mac_flash = false
		end
	else
		button:SetChecked(nil)
		button.mac_flash = false
	end
end


function NeuronButton:MACRO_UpdateState(button, ...)

	local spell, item, show = button.macrospell, button.macroitem, button.macroshow


	if (button.actionID) then
		NeuronButton:ACTION_UpdateState(button, button.actionID)

	elseif (show and #show>0) then

		if (GetItemInfo(show) or ItemCache[show]) then
			NeuronButton:MACRO_SetItemState(button, show)
		else
			NeuronButton:MACRO_SetSpellState(button, show)
		end

	elseif (spell and #spell>0) then

		NeuronButton:MACRO_SetSpellState(button, spell)

	elseif (item and #item>0) then

		NeuronButton:MACRO_SetItemState(button, item)

	elseif (button:GetAttribute("macroShow")) then

		show = button:GetAttribute("macroShow")

		if (GetItemInfo(show) or ItemCache[show]) then
			NeuronButton:MACRO_SetItemState(button, show)
		else
			NeuronButton:MACRO_SetSpellState(button, show)
		end
	else
		button:SetChecked(nil)
		button.count:SetText("")
	end
end



function NeuronButton:MACRO_UpdateAuraWatch(button, unit, spell)

	local uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count, uaw_color

	if (spell and (unit == button.unit or unit == "player")) then
		spell = spell:gsub("%s*%(.+%)", ""):lower()

		if (unitAuras[unit][spell]) then
			uaw_auraType, uaw_duration, uaw_timeLeft, uaw_count = (":"):split(unitAuras[unit][spell])

			uaw_duration = tonumber(uaw_duration); uaw_timeLeft = tonumber(uaw_timeLeft)

			if (button.auraInd) then
				button.auraBorder = true

				if (uaw_auraType == "buff") then
					button.border:SetVertexColor(button.buffcolor[1], button.buffcolor[2], button.buffcolor[3], 1.0)
				elseif (uaw_auraType == "debuff" and unit == "target") then
					button.border:SetVertexColor(button.debuffcolor[1], button.debuffcolor[2], button.debuffcolor[3], 1.0)
				end

				button:Show()
			else
				button.border:Hide()
			end

			uaw_color = button.auracolor1

			if (button.auraText) then

				if (uaw_auraType == "debuff" and (unit == "target" or (unit == "focus" and UnitIsEnemy("player", "focus")))) then
					uaw_color = button.auracolor2
				end

				button.iconframeaurawatch.queueinfo = unit..":"..spell
			else

			end

			if (button.iconframecooldown.timer:IsShown()) then
				button.auraQueue = unit..":"..spell
				button.iconframeaurawatch.uaw_duration = 0
				button.iconframeaurawatch:Hide()

			elseif (button.auraText) then
				NeuronButton:SetTimer(button.iconframecooldown, 0, 0, 0)
				NeuronButton:SetTimer(button.iconframeaurawatch, uaw_timeLeft-uaw_duration, uaw_duration, 1, button.auraText, uaw_color)
			else
				NeuronButton:SetTimer(button.iconframeaurawatch, 0, 0, 0)
			end

			button.auraWatchUnit = unit

		elseif (button.auraWatchUnit == unit) then

			button.iconframeaurawatch.uaw_duration = 0
			button.iconframeaurawatch:Hide()
			button.iconframeaurawatch.timer:SetText("")
			button.border:Hide()
			button.auraBorder = nil
			button.auraWatchUnit = nil
			button.auraTimer = nil
			button.auraQueue = nil
		end
	end
end

function NeuronButton:MACRO_SetSpellCooldown(button, spell)
	spell = (spell):lower()
	local spell_id = spell

	if (sIndex[spell]) then
		spell_id = sIndex[spell].spellID
		local ZoneAbilityID = ZoneAbilityFrame.SpellButton.currentSpellID
		local GarrisonAbilityID = 161691

		--Needs work
		if (spell_id == GarrisonAbilityID and ZoneAbilityID) then spell_id = ZoneAbilityID end
	end

	local start, duration, enable = GetSpellCooldown(spell)
	local charges, maxCharges, chStart, chDuration = GetSpellCharges(spell)
	start, duration, enable = GetSpellCooldown(spell)

	if (duration and duration >= GDB.timerLimit and button.iconframeaurawatch.active) then
		button.auraQueue = button.iconframeaurawatch.queueinfo
		button.iconframeaurawatch.duration = 0
		button.iconframeaurawatch:Hide()
	end

	if (charges and maxCharges and maxCharges > 0 and charges < maxCharges) then
		StartChargeCooldown(button, chStart, chDuration);
	end

	NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
end

function NeuronButton:MACRO_SetItemCooldown(button, item)

	local id = ItemCache[item]

	if (id) then

		local start, duration, enable = GetItemCooldown(id)

		if (duration and duration >= GDB.timerLimit and button.iconframeaurawatch.active) then
			button.auraQueue = button.iconframeaurawatch.queueinfo
			button.iconframeaurawatch.duration = 0
			button.iconframeaurawatch:Hide()
		end

		NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end
end

function NeuronButton:ACTION_SetCooldown(button, action)

	local actionID = tonumber(action)

	if (actionID) then

		if (HasAction(actionID)) then

			local start, duration, enable = GetActionCooldown(actionID)

			if (duration and duration >= GDB.timerLimit and button.iconframeaurawatch.active) then
				button.auraQueue = button.iconframeaurawatch.queueinfo
				button.iconframeaurawatch.duration = 0
				button.iconframeaurawatch:Hide()
			end

			NeuronButton:SetTimer(button.iconframecooldown, start, duration, enable, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
		end
	end
end


function NeuronButton:MACRO_UpdateCooldown(button, update)
	local spell, item, show = button.macrospell, button.macroitem, button.macroshow

	if (button.actionID) then
		NeuronButton:ACTION_SetCooldown(button, button.actionID)
	elseif (show and #show>0) then
		if(GetItemInfo(show) or ItemCache[show]) then
			NeuronButton:MACRO_SetItemCooldown(button, show)
		else
			NeuronButton:MACRO_SetSpellCooldown(button, show)
		end

	elseif (spell and #spell>0) then
		NeuronButton:MACRO_SetSpellCooldown(button, spell)
	elseif (item and #item>0) then
		NeuronButton:MACRO_SetItemCooldown(button, item)
	else
		NeuronButton:SetTimer(button.iconframecooldown, 0, 0, 0, button.cdText, button.cdcolor1, button.cdcolor2, button.cdAlpha)
	end
end

function NeuronButton:MACRO_UpdateTimers(button, ...)
	NeuronButton:MACRO_UpdateCooldown(button)

	for k in pairs(unitAuras) do
		NeuronButton:MACRO_UpdateAuraWatch(button, k, button.macrospell)
	end
end


function NeuronButton:MACRO_UpdateTexture(button, force)
	local hasAction = NeuronButton:MACRO_HasAction(button)

	if (not button:GetSkinned()) then
		if (hasAction or force) then
			button:SetNormalTexture(button.hasAction or "")
			button:GetNormalTexture():SetVertexColor(1,1,1,1)
		else
			button:SetNormalTexture(button.noAction or "")
			button:GetNormalTexture():SetVertexColor(1,1,1,0.5)
		end
	end
end


function NeuronButton:MACRO_UpdateAll(button, updateTexture)
	NeuronButton:MACRO_UpdateData(button)
	NeuronButton:MACRO_UpdateButton(button)
	NeuronButton:MACRO_UpdateIcon(button)
	NeuronButton:MACRO_UpdateState(button)
	NeuronButton:MACRO_UpdateTimers(button)

	if (updateTexture) then
		NeuronButton:MACRO_UpdateTexture(button)
	end
end


--local garrisonAbility = GetSpellInfo(161691):lower()
function NeuronButton:MACRO_UpdateUsableSpell(button, spell)
	local isUsable, notEnoughMana, alt_Name
	local spellName = spell:lower()

	if (sIndex[spellName]) and (sIndex[spellName].spellID ~= sIndex[spellName].spellID_Alt) and sIndex[spellName].spellID_Alt then
		alt_Name = GetSpellInfo(sIndex[spellName].spellID_Alt):lower()
		isUsable, notEnoughMana = IsUsableSpell(alt_Name)
		spellName = alt_Name
	else
		isUsable, notEnoughMana = IsUsableSpell(spellName)
	end

	if (spellName == GetSpellInfo(161691):lower()) then
	end

	if (notEnoughMana) then
		button.iconframeicon:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3])
		--button.iconframerange:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3], 0.5)
		--button.iconframerange:Show()
	elseif (isUsable) then
		if (button.rangeInd and IsSpellInRange(spellName, button.unit) == 0) then
			button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
			--button.iconframerange:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3], 0.5)
			--button.iconframerange:Show()
		elseif sIndex[spellName] and (button.rangeInd and IsSpellInRange(sIndex[spellName].index,"spell", button.unit) == 0) then
			button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
		else
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
			--button.iconframerange:Hide()
		end

	else
		if (sIndex[(spell):lower()]) then
			button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
			--button.iconframerange:SetVertexColor(0.4, 0.4, 0.4, 0.5)
			--button.iconframerange:Show()
		else
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
			--button.iconframerange:Hide()
		end
	end
end


function NeuronButton:MACRO_UpdateUsableItem(button, item)
	local isUsable, notEnoughMana = IsUsableItem(item)-- or PlayerHasToy(ItemCache[item])
	--local isToy = tIndex[item]
	if tIndex[item:lower()] then isUsable = true end

	if (notEnoughMana and button.manacolor) then
		button.iconframeicon:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3])
	elseif (isUsable) then
		if (button.rangeInd and IsItemInRange(spell, button.unit) == 0) then
			button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
		else
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		end

	else
		button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
	end
end


function NeuronButton:ACTION_UpdateUsable(button, action)
	local actionID = tonumber(action)

	if (actionID) then
		if (actionID == 0) then
			button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
		else
			local isUsable, notEnoughMana = IsUsableAction(actionID)

			if (isUsable) then
				if (IsActionInRange(action, button.unit) == 0) then
					button.iconframeicon:SetVertexColor(button.rangecolor[1], button.rangecolor[2], button.rangecolor[3])
				else
					button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
				end

			elseif (notEnoughMana and button.manacolor) then
				button.iconframeicon:SetVertexColor(button.manacolor[1], button.manacolor[2], button.manacolor[3])
			else
				button.iconframeicon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end

	else
		button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end


function NeuronButton:MACRO_UpdateButton(button, ...)

	if (button.editmode) then

		button.iconframeicon:SetVertexColor(0.2, 0.2, 0.2)

	elseif (button.actionID) then

		NeuronButton:ACTION_UpdateUsable(button, button.actionID)

	elseif (button.macroshow and #button.macroshow>0) then

		if(GetItemInfo(button.macroshow) or ItemCache[button.macroshow]) then
			NeuronButton:MACRO_UpdateUsableItem(button, button.macroshow)
		else
			NeuronButton:MACRO_UpdateUsableSpell(button, button.macroshow)
		end

	elseif (button.macrospell and #button.macrospell>0) then

		NeuronButton:MACRO_UpdateUsableSpell(button, button.macrospell)

	elseif (button.macroitem and #button.macroitem>0) then

		NeuronButton:MACRO_UpdateUsableItem(button, button.macroitem)

	else
		button.iconframeicon:SetVertexColor(1.0, 1.0, 1.0)
	end
end

---TODO:
---We need to figure out what this function did.
---Update: Seems to be important for range indication (i.e. button going red)
function NeuronButton:MACRO_OnUpdate(button, elapsed) --this function uses A TON of resources

	if (button.elapsed > GDB.throttle) then --throttle down this code to ease up on the CPU a bit

		if (button.mac_flash) then

			button.mac_flashing = true

			if (alphaDir == 1) then
				if ((1 - (alphaTimer)) >= 0) then
					button.iconframeflash:Show()
				end
			elseif (alphaDir == 0) then
				if ((alphaTimer) <= 1) then
					button.iconframeflash:Hide()
				end
			end

		elseif (button.mac_flashing) then
			button.iconframeflash:Hide()
			button.mac_flashing = false
		end

		NeuronButton:MACRO_UpdateButton(button)

		if (button.auraQueue and not button.iconframecooldown.active) then
			local unit, spell = (":"):split(button.auraQueue)
			if (unit and spell) then
				button.auraQueue = nil;
				NeuronButton:MACRO_UpdateAuraWatch(button, unit, spell)
			end
		end

		button.elapsed = 0
	end

	button.elapsed = button.elapsed + elapsed

end


function NeuronButton:MACRO_ShowGrid(button)
	if (not InCombatLockdown()) then
		button:Show()
	end

	NeuronButton:MACRO_UpdateState(button)
end


function NeuronButton:MACRO_HideGrid(button)
	if (not InCombatLockdown()) then

		if (not button.showGrid and not NeuronButton:MACRO_HasAction(button) and not NEURON.BarsShown and not NEURON.EditFrameShown) then
			button:Hide()
		end
	end

	NeuronButton:MACRO_UpdateState(button)
end

------------------------------------------------------------------------------
---------------------Event Functions------------------------------------------
------------------------------------------------------------------------------

--I'm not sure why all these are here, they don't seem to be used

function NeuronButton:MACRO_ACTIONBAR_UPDATE_COOLDOWN(button, ...)
	NeuronButton:MACRO_UpdateTimers(button, ...)
end

--pointer
NeuronButton.MACRO_RUNE_POWER_UPDATE = NeuronButton.MACRO_ACTIONBAR_UPDATE_COOLDOWN


function NeuronButton:MACRO_ACTIONBAR_UPDATE_STATE(button, ...)
	NeuronButton:MACRO_UpdateState(button, ...)
end

--pointers
NeuronButton.MACRO_COMPANION_UPDATE = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE
NeuronButton.MACRO_TRADE_SKILL_SHOW = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE
NeuronButton.MACRO_TRADE_SKILL_CLOSE = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE
NeuronButton.MACRO_ARCHAEOLOGY_CLOSED = NeuronButton.MACRO_ACTIONBAR_UPDATE_STATE


function NeuronButton:MACRO_ACTIONBAR_UPDATE_USABLE(button, ...)
	-- TODO
end



function NeuronButton:MACRO_BAG_UPDATE_COOLDOWN(button, ...)

	if (button.macroitem) then
		NeuronButton:MACRO_UpdateState(button, ...)
	end
end


NeuronButton.MACRO_BAG_UPDATE = NeuronButton.MACRO_BAG_UPDATE_COOLDOWN


function NeuronButton:MACRO_UNIT_AURA(button, ...)
	local unit = select(2, ...)

	if (unitAuras[unit]) then
		NeuronButton:MACRO_UpdateAuraWatch(button, unit, button.macrospell)

		if (unit == "player") then
			NeuronButton:MACRO_UpdateData(button, ...)
			NeuronButton:MACRO_UpdateIcon(button, ...)
		end
	end
end


NeuronButton.MACRO_UPDATE_MOUSEOVER_UNIT = NeuronButton.MACRO_UNIT_AURA


function BUTTON:MACRO_UNIT_SPELLCAST_INTERRUPTED(...)

	local unit = select(1, ...)

	if ((unit == "player" or unit == "pet") and spell and self.macrospell) then

		NeuronButton:MACRO_UpdateTimers(self, ...)
	end

end


BUTTON.MACRO_UNIT_SPELLCAST_FAILED = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_PET = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_ENTERED_VEHICLE = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_ENTERING_VEHICLE = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED
BUTTON.MACRO_UNIT_EXITED_VEHICLE = BUTTON.MACRO_UNIT_SPELLCAST_INTERRUPTED


function NeuronButton:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(button, ...)
	local spellID = select(2, ...)

	if (button.spellGlow and button.spellID and spellID == button.spellID) then

		NeuronButton:MACRO_UpdateTimers(button, ...)

		NeuronButton:MACRO_StartGlow(button)
	end
end


function NeuronButton:MACRO_SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(button, ...)
	local spellID = select(2, ...)

	if ((button.overlay or button.spellGlow) and button.spellID and spellID == button.spellID) then

		NeuronButton:MACRO_StopGlow(button)
	end
end


function NeuronButton:MACRO_ACTIVE_TALENT_GROUP_CHANGED(button, ...)

	if(InCombatLockdown()) then
		return
	end

	local spec

	if (button.multiSpec) then
		spec = GetSpecialization()
	else
		spec = 1
	end

	button:Show()

	button:LoadData(spec, button:GetParent():GetAttribute("activestate") or "homestate")
	button:UpdateFlyout()
	button:SetType()
	button:SetGrid()

end


function NeuronButton:MACRO_PLAYER_ENTERING_WORLD(button, ...)

	button:MACRO_Reset()
	NeuronButton:MACRO_UpdateAll(button, true)
	button.binder:ApplyBindings(button)
end

function NeuronButton:MACRO_PET_JOURNAL_LIST_UPDATE(button, ...)
	NeuronButton:MACRO_UpdateAll(button, true)
end


function NeuronButton:MACRO_MODIFIER_STATE_CHANGED(button, ...)
	NeuronButton:MACRO_UpdateAll(button, true)
end


NeuronButton.MACRO_SPELL_UPDATE_USABLE = NeuronButton.MACRO_MODIFIER_STATE_CHANGED


function NeuronButton:MACRO_ACTIONBAR_SLOT_CHANGED(button, ...)
	if (button.data.macro_Watch or button.data.macro_Equip) then
		NeuronButton:MACRO_UpdateIcon(button)
	end
end


function NeuronButton:MACRO_PLAYER_TARGET_CHANGED(button, ...)
	NeuronButton:MACRO_UpdateTimers(button)
end


NeuronButton.MACRO_PLAYER_FOCUS_CHANGED = NeuronButton.MACRO_PLAYER_TARGET_CHANGED

function NeuronButton:MACRO_ITEM_LOCK_CHANGED(button, ...)
end


function NeuronButton:MACRO_ACTIONBAR_SHOWGRID(button, ...)
	NeuronButton:MACRO_ShowGrid(button)
end


function NeuronButton:MACRO_ACTIONBAR_HIDEGRID(button, ...)
	NeuronButton:MACRO_HideGrid(button)
end


function NeuronButton:MACRO_UPDATE_MACROS(button, ...)
	if (NEURON.PEW and not InCombatLockdown() and button.data.macro_Watch) then
		button:MACRO_PlaceBlizzMacro(button.data.macro_Watch)
	end
end


function NeuronButton:MACRO_EQUIPMENT_SETS_CHANGED(button, ...)
	if (NEURON.PEW and not InCombatLockdown() and button.data.macro_Equip) then
		button:MACRO_PlaceBlizzEquipSet(button.data.macro_Equip)
	end
end


function NeuronButton:MACRO_PLAYER_EQUIPMENT_CHANGED(button, ...)
	if (button.data.macro_Equip) then
		NeuronButton:MACRO_UpdateIcon(button)
	end
end


function NeuronButton:MACRO_UPDATE_VEHICLE_ACTIONBAR(button, ...)

	if (button.actionID) then
		NeuronButton:MACRO_UpdateAll(button, true)
	end
end


NeuronButton.MACRO_UPDATE_POSSESS_BAR = NeuronButton.MACRO_UPDATE_VEHICLE_ACTIONBAR
NeuronButton.MACRO_UPDATE_OVERRIDE_ACTIONBAR = NeuronButton.MACRO_UPDATE_VEHICLE_ACTIONBAR
NeuronButton.MACRO_UPDATE_EXTRA_ACTIONBAR = NeuronButton.MACRO_UPDATE_VEHICLE_ACTIONBAR

--for 4.x compatibility
NeuronButton.MACRO_UPDATE_BONUS_ACTIONBAR = NeuronButton.MACRO_UPDATE_VEHICLE_ACTIONBAR


function NeuronButton:MACRO_SPELL_UPDATE_CHARGES(button, ...)

	local spell = button.macrospell
	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spell)

	if (maxCharges and maxCharges > 1) then
		button.count:SetText(charges)
	else
		button.count:SetText("")
	end
end


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

---This strips out the "MACRO_" in front of the event name function, and brokers the event to the right object
function NeuronButton:MACRO_OnEvent(button, eventName, ...)
	local event = "MACRO_".. eventName

	if (NeuronButton[event]) then
		NeuronButton[event](NeuronButton, button, ...)
	end
end


function BUTTON:MACRO_PlaceSpell(action1, action2, spellID)
	local modifier, spell, subName, texture

	if (action1 == 0) then
		-- I am unsure under what conditions (if any) we wouldn't have a spell ID
		if not spellID or spellID == 0 then
			return
		end
	else
		spell,_= GetSpellBookItemName(action1, action2)
		_,spellID = GetSpellBookItemInfo(action1, action2)
	end
	local spellInfoName , subName, icon, castTime, minRange, maxRange= GetSpellInfo(spellID)

	if AlternateSpellNameList[spellID] or not spell then
		self.data.macro_Text = self:AutoWriteMacro(spellInfoName)
		self.data.macro_Auto = spellInfoName..";"
	else
		self.data.macro_Text = self:AutoWriteMacro(spell, subName)
		self.data.macro_Auto = spell..";"..subName
	end

	self.data.macro_Icon = false
	self.data.macro_Name = spellInfoName
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

	if (not self.cursor) then
		self:SetType(true)
	end

	MacroDrag[1] = false

	ClearCursor()
	SetCursor(nil)

end


function BUTTON:MACRO_PlaceItem(action1, action2, hasAction)
	local item, link = GetItemInfo(action2)

	if (IsEquippableItem(item)) then
		self.data.macro_Text = "/equip "..item.."\n/use "..item
	else
		self.data.macro_Text = "/use "..item
	end

	self.data.macro_Icon = false
	self.data.macro_Name = item
	self.data.macro_Auto = false
	self.data.macro_Watch = false
	self.data.macro_Equip = false
	self.data.macro_Note = ""
	self.data.macro_UseNote = false

	if (not self.cursor) then
		self:SetType(true)
	end
	MacroDrag[1] = false
	ClearCursor()
	SetCursor(nil)
end


function BUTTON:MACRO_PlaceBlizzMacro(action1)
	if (action1 == 0) then
		return
	else

		local name, icon, body = GetMacroInfo(action1)

		if (body) then

			self.data.macro_Text = body
			self.data.macro_Name = name
			self.data.macro_Watch = name
			self.data.macro_Icon = icon
		else
			self.data.macro_Text = ""
			self.data.macro_Name = ""
			self.data.macro_Watch = false
			self.data.macro_Icon = false
		end

		self.data.macro_Equip = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function BUTTON:MACRO_PlaceBlizzEquipSet(action1)
	if (action1 == 0) then
		return
	else

		local icon = GetEquipmentSetInfoByName(action1)
		if (icon) then

			self.data.macro_Text = "/equipset "..action1
			self.data.macro_Equip = action1
			self.data.macro_Icon = iIndex[icon] or "INTERFACE\\ICONS\\"..icon:upper()
		else
			self.data.macro_Text = ""
			self.data.macro_Equip = false
			self.data.macro_Icon = false
		end

		self.data.macro_Name = ""
		self.data.macro_Watch = false
		self.data.macro_Auto = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


--Hooks mount journal mount buttons on enter to pull spellid from tooltip--
--Based on discusion thread http://www.wowinterface.com/forums/showthread.php?t=49599&page=2
--More dynamic than the manual list that was originally implemented
local CurrentMountSpellID
local function HookOnEnter(self)
	CurrentMountSpellID = self:GetParent().spellID
end


function NeuronButton:ToggleCollectionsJournal()

	local MountButtonsHookIsSet

	if CollectionsJournal:IsShown() then
		if not MountButtonsHookIsSet then
			for i = 1, 20 do
				local bName = "MountJournalListScrollFrameButton"..i
				local f = _G[bName]
				if f then
					if f.DragButton then
						f.DragButton:HookScript("OnEnter", HookOnEnter)
					end
				end
			end
			MountButtonsHookIsSet = true
		end
	end
end

function BUTTON:MACRO_PlaceMount(action1, action2, hasAction)
	if (action1 == 0) then
		return
	else
		--The Summon Random Mount from the Mount Journal
		if action1 == 268435455 then
			self.data.macro_Text = "#autowrite\n/run C_MountJournal.SummonByID(0);"
			self.data.macro_Auto = "Random Mount;"
			self.data.macro_Icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_MOUNTUP"
			self.data.macro_Name = "Random Mount"
			--Any other mount from the Journal
		else
			local mountName,_, mountIcon = GetSpellInfo(CurrentMountSpellID)
			self.data.macro_Text = "#autowrite\n/cast "..mountName..";"
			self.data.macro_Auto = mountName..";"
			self.data.macro_Icon = mountIcon
			self.data.macro_Name = mountName
		end

		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[1] = false
		CurrentMountSpellID = nil

		ClearCursor()
		SetCursor(nil)
	end
end


function BUTTON:MACRO_PlaceCompanion(action1, action2, hasAction)
	if (action1 == 0) then
		return

	else
		local _, _, spellID = GetCompanionInfo(action2, action1)
		local name = GetSpellInfo(spellID)

		if (name) then
			self.data.macro_Name = name
			self.data.macro_Text = self:AutoWriteMacro(name)
			self.data.macro_Auto = name
		else
			self.data.macro_Name = ""
			self.data.macro_Text = ""
			self.data.macro_Auto = false
		end

		self.data.macro_Icon = false
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function BUTTON:MACRO_PlaceFlyout(action1, action2, hasAction)
	if (action1 == 0) then
		return
	else
		local count = self.bar.objCount
		local columns = self.bar.gdata.columns or count
		local rows = count/columns

		local point = self:GetPosition(UIParent)

		if (columns/rows > 1) then

			if ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			elseif ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			else
				point = "r:l:12"
			end
		else
			if ((point):find("RIGHT")) then
				point = "r:l:12"
			elseif ((point):find("LEFT")) then
				point = "l:r:12"
			elseif ((point):find("BOTTOM")) then
				point = "b:t:1"
			elseif ((point):find("TOP")) then
				point = "t:b:1"
			else
				point = "r:l:12"
			end
		end

		self.data.macro_Text = "/flyout blizz:"..action1..":l:"..point..":c"
		self.data.macro_Icon = false
		self.data.macro_Name = ""
		self.data.macro_Auto = false
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		self:UpdateFlyout(true)

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end


function BUTTON:MACRO_PlaceBattlePet(action1, action2, hasAction)
	local petName, petIcon
	local _ --variable used to discard unwanted return values

	if (action1 == 0) then
		return
	else
		_, _, _, _, _, _, _,petName, petIcon = C_PetJournal.GetPetInfoByPetID(action1)

		self.data.macro_Text = "#autowrite\n/summonpet "..petName
		self.data.macro_Auto = petName..";"
		self.data.macro_Icon = petIcon
		self.data.macro_Name = petName
		self.data.macro_Watch = false
		self.data.macro_Equip = false
		self.data.macro_Note = ""
		self.data.macro_UseNote = false

		if (not self.cursor) then
			self:SetType(true)
		end

		MacroDrag[1] = false

		ClearCursor()
		SetCursor(nil)
	end
end

function BUTTON:MACRO_PlaceMacro()
	self.data.macro_Text = MacroDrag[3]
	self.data.macro_Icon = MacroDrag[4]
	self.data.macro_Name = MacroDrag[5]
	self.data.macro_Auto = MacroDrag[6]
	self.data.macro_Watch = MacroDrag[7]
	self.data.macro_Equip = MacroDrag[8]
	self.data.macro_Note = MacroDrag[9]
	self.data.macro_UseNote = MacroDrag[10]

	if (not self.cursor) then
		self:SetType(true)
	end

	PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)

	wipe(MacroDrag);
	ClearCursor();
	SetCursor(nil);
	self:UpdateFlyout()
	NEURON:ToggleButtonGrid(nil, true)

end


function BUTTON:MACRO_PickUpMacro()
	local pickup

	if (not self.barLock) then
		pickup = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		pickup = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		pickup = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		pickup = true
	end

	if (pickup) then
		local texture, move = self.iconframeicon:GetTexture()

		if (macroCache[1]) then  ---triggers when picking up an existing button with a button in the cursor

			wipe(MacroDrag)

			for k,v in pairs(macroCache) do
				MacroDrag[k] = v
			end

			wipe(macroCache)

			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")


		elseif (NeuronButton:MACRO_HasAction(self)) then
			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")

			MacroDrag[1] = NeuronButton:MACRO_GetDragAction()
			MacroDrag[2] = self
			MacroDrag[3] = self.data.macro_Text
			MacroDrag[4] = self.data.macro_Icon
			MacroDrag[5] = self.data.macro_Name
			MacroDrag[6] = self.data.macro_Auto
			MacroDrag[7] = self.data.macro_Watch
			MacroDrag[8] = self.data.macro_Equip
			MacroDrag[9] = self.data.macro_Note
			MacroDrag[10] = self.data.macro_UseNote
			MacroDrag.texture = texture
			self.data.macro_Text = ""
			self.data.macro_Icon = false
			self.data.macro_Name = ""
			self.data.macro_Auto = false
			self.data.macro_Watch = false
			self.data.macro_Equip = false
			self.data.macro_Note = ""
			self.data.macro_UseNote = false

			self.macrospell = nil
			self.spellID = nil
			self.macroitem = nil
			self.macroshow = nil
			self.macroicon = nil

			self:UpdateFlyout()

			self:SetType(true)

		end

	end
end

---This is the function that fires when a button is receiving a dragged item
function BUTTON:MACRO_OnReceiveDrag(preclick)
	if (InCombatLockdown()) then
		return
	end

	local cursorType, action1, action2, spellID = GetCursorInfo()

	local texture = self.iconframeicon:GetTexture()

	if (NeuronButton:MACRO_HasAction(self)) then
		wipe(macroCache)

		---macroCache holds on to the previos macro's info if you are dropping a new macro on top of an existing macro
		macroCache[1] = NeuronButton:MACRO_GetDragAction()
		macroCache[2] = self
		macroCache[3] = self.data.macro_Text
		macroCache[4] = self.data.macro_Icon
		macroCache[5] = self.data.macro_Name
		macroCache[6] = self.data.macro_Auto
		macroCache[7] = self.data.macro_Watch
		macroCache[8] = self.data.macro_Equip
		macroCache[9] = self.data.macro_Note
		macroCache[10] = self.data.macro_UseNote

		macroCache.texture = texture
	end


	if (MacroDrag[1]) then
		self:MACRO_PlaceMacro()
	elseif (cursorType == "spell") then
		self:MACRO_PlaceSpell(action1, action2, spellID, NeuronButton:MACRO_HasAction(self))

	elseif (cursorType == "item") then
		self:MACRO_PlaceItem(action1, action2, NeuronButton:MACRO_HasAction(self))

	elseif (cursorType == "macro") then
		self:MACRO_PlaceBlizzMacro(action1)
	elseif (cursorType == "equipmentset") then
		self:MACRO_PlaceBlizzEquipSet(action1)

	elseif (cursorType == "mount") then
		self:MACRO_PlaceMount(action1, action2, NeuronButton:MACRO_HasAction(self))

	elseif (cursorType == "flyout") then
		self:MACRO_PlaceFlyout(action1, action2, NeuronButton:MACRO_HasAction(self))

	elseif (cursorType == "battlepet") then
		self:MACRO_PlaceBattlePet(action1, action2, NeuronButton:MACRO_HasAction(self))
	end


	if (StartDrag and macroCache[1]) then
		self:MACRO_PickUpMacro()
		NEURON:ToggleButtonGrid(true)
	end

	NeuronButton:MACRO_UpdateAll(self, true)

	StartDrag = false

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		NEURON.NeuronGUI:UpdateObjectGUI()
	end
end

---this is the function that fires when you begin dragging an item
function BUTTON:MACRO_OnDragStart(button)
	if (InCombatLockdown() or not self.bar or self.vehicle_edit or self.actionID) then
		StartDrag = false
		return
	end

	self.drag = nil

	if (not self.barLock) then
		self.drag = true
	elseif (self.barLockAlt and IsAltKeyDown()) then
		self.drag = true
	elseif (self.barLockCtrl and IsControlKeyDown()) then
		self.drag = true
	elseif (self.barLockShift and IsShiftKeyDown()) then
		self.drag = true
	end

	if (self.drag) then
		StartDrag = self:GetParent():GetAttribute("activestate")

		self.dragbutton = button
		self:MACRO_PickUpMacro()

		if (MacroDrag[1]) then
			--PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
			self.sound = true

			if (MacroDrag[2] ~= self) then
				self.dragbutton = nil
			end

			NEURON:ToggleButtonGrid(true)
		else
			self.dragbutton = nil
		end

		NeuronButton:MACRO_UpdateAll(self)

		self.iconframecooldown.duration = 0
		self.iconframecooldown.timer:SetText("")
		self.iconframecooldown:Hide()

		self.iconframeaurawatch.duration = 0
		self.iconframeaurawatch.timer:SetText("")
		self.iconframeaurawatch:Hide()

		self.macroname:SetText("")
		self.count:SetText("")

		self.macrospell = nil
		self.spellID = nil
		self.actionID = nil
		self.macroitem = nil
		self.macroshow = nil
		self.macroicon = nil

		self.auraQueue = nil

		self.border:Hide()

	else
		StartDrag = false
	end
end


function BUTTON:MACRO_OnDragStop()
	self.drag = nil
end

---This function will be used to check if we should release the cursor
function NeuronButton:OnMouseDown()
	if MacroDrag[1] then
		PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP)
		wipe(MacroDrag)
	end
end

function BUTTON:MACRO_PreClick(button)
	self.cursor = nil

	if (not InCombatLockdown() and MouseIsOver(self)) then
		local cursorType = GetCursorInfo()

		if (cursorType or MacroDrag[1]) then
			self.cursor = true

			StartDrag = self:GetParent():GetAttribute("activestate")

			self:SetType(true, true)

			NEURON:ToggleButtonGrid(true)

			self:MACRO_OnReceiveDrag(true)

		elseif (button == "MiddleButton") then
			self.middleclick = self:GetAttribute("type")

			self:SetAttribute("type", "")

		end
	end

	NEURON.ClickedButton = self
end


function BUTTON:MACRO_PostClick(button)
	if (not InCombatLockdown() and MouseIsOver(self)) then

		if (self.cursor) then
			self:SetType(true)

			self.cursor = nil

		elseif (self.middleclick) then
			self:SetAttribute("type", self.middleclick)

			self.middleclick = nil
		end
	end
	NeuronButton:MACRO_UpdateState(self)
end


function BUTTON:MACRO_SetSpellTooltip(spell)

	if (sIndex[spell]) then

		local spell_id = sIndex[spell].spellID

		if(spell_id) then --double check that the spell_id is valid (for switching specs, other specs abilities won't be valid even though a bar might be bound to one)

			local zoneability_id = ZoneAbilityFrame.SpellButton.currentSpellID

			if spell_id == 161691 and zoneability_id then
				spell_id = zoneability_id
			end


			if (self.UberTooltips) then
				GameTooltip:SetSpellByID(spell_id)
			else
				spell = GetSpellInfo(spell_id)
				GameTooltip:SetText(spell, 1, 1, 1)
			end

			self.UpdateTooltip = macroButton_SetTooltip
		end

	elseif (cIndex[spell]) then

		if (self.UberTooltips and cIndex[spell].creatureType =="MOUNT") then
			GameTooltip:SetHyperlink("spell:"..cIndex[spell].spellID)
		else
			GameTooltip:SetText(cIndex[spell].creatureName, 1, 1, 1)
		end

		self.UpdateTooltip = nil
	end
end


function BUTTON:MACRO_SetItemTooltip(item)
	local name, link = GetItemInfo(item)

	if (tIndex[item:lower()]) then
		if (self.UberTooltips) then
			local itemID = tIndex[item:lower()]
			GameTooltip:ClearLines()
			GameTooltip:SetToyByItemID(itemID)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (link) then
		if (self.UberTooltips) then
			GameTooltip:SetHyperlink(link)
		else
			GameTooltip:SetText(name, 1, 1, 1)
		end

	elseif (ItemCache[item]) then
		if (self.UberTooltips) then
			GameTooltip:SetHyperlink("item:"..ItemCache[item]..":0:0:0:0:0:0:0")
		else
			GameTooltip:SetText(ItemCache[item], 1, 1, 1)
		end
	end
end


function BUTTON:ACTION_SetTooltip(action)
	local actionID = tonumber(action)

	if (actionID) then

		self.UpdateTooltip = nil

		if (HasAction(actionID)) then
			GameTooltip:SetAction(actionID)
		end
	end
end


function BUTTON:MACRO_SetTooltip(edit)
	self.UpdateTooltip = nil

	local spell, item, show = self.macrospell, self.macroitem, self.macroshow

	if (self.actionID) then
		self:ACTION_SetTooltip(self.actionID)

	elseif (show and #show>0) then
		if(GetItemInfo(show) or ItemCache[show]) then
			self:MACRO_SetItemTooltip(show)
		else
			self:MACRO_SetSpellTooltip(show:lower())
		end

	elseif (spell and #spell>0) then
		self:MACRO_SetSpellTooltip(spell:lower())

	elseif (item and #item>0) then
		self:MACRO_SetItemTooltip(item)

	elseif (self:GetAttribute("macroShow")) then
		show = self:GetAttribute("macroShow")

		if(GetItemInfo(show) or ItemCache[show]) then
			self:MACRO_SetItemTooltip(show)
		else
			self:MACRO_SetSpellTooltip(show:lower())
		end

	elseif (self.data.macro_Text and #self.data.macro_Text > 0) then
		local equipset = self.data.macro_Text:match("/equipset%s+(%C+)")

		if (equipset) then
			equipset = equipset:gsub("%pnobtn:2%p ", "")
			GameTooltip:SetEquipmentSet(equipset)
		elseif (self.data.macro_Name and #self.data.macro_Name>0) then
			GameTooltip:SetText(self.data.macro_Name)
		end
	end
end


function BUTTON:MACRO_OnEnter(...)
	if (self.bar) then
		if (self.tooltipsCombat and InCombatLockdown()) then
			return
		end

		if(MacroDrag[1]) then ---puts the icon back to the interact icon when moving abilities around and the mouse enteres the WorldFrame
			SetCursor("Interface\\CURSOR\\QUESTINTERACT.BLP")
		end

		if (self.tooltips) then
			if (self.tooltipsEnhanced) then
				self.UberTooltips = true
				--GameTooltip_SetDefaultAnchor(GameTooltip, self)
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			else
				self.UberTooltips = false
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			end

			self:MACRO_SetTooltip()

			GameTooltip:Show()
		end

		if (self.flyout and self.flyout.arrow) then
			self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX/0.625, self.flyout.arrowY/0.625)
		end

	end
end


function BUTTON:MACRO_OnLeave(...)
	self.UpdateTooltip = nil

	GameTooltip:Hide()

	if (self.flyout and self.flyout.arrow) then
		self.flyout.arrow:SetPoint(self.flyout.arrowPoint, self.flyout.arrowX, self.flyout.arrowY)
	end
end


function NeuronButton:MACRO_OnShow(button, ...)
	button:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
	button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	button:RegisterEvent("ACTIONBAR_UPDATE_STATE")
	button:RegisterEvent("ACTIONBAR_UPDATE_USABLE")

	button:RegisterEvent("SPELL_UPDATE_CHARGES")
	button:RegisterEvent("SPELL_UPDATE_USABLE")

	button:RegisterEvent("RUNE_POWER_UPDATE")

	button:RegisterEvent("TRADE_SKILL_SHOW")
	button:RegisterEvent("TRADE_SKILL_CLOSE")
	button:RegisterEvent("ARCHAEOLOGY_CLOSED")

	button:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

	button:RegisterEvent("MODIFIER_STATE_CHANGED")

	button:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	button:RegisterEvent("UNIT_SPELLCAST_FAILED")
	button:RegisterEvent("UNIT_PET")
	button:RegisterEvent("UNIT_AURA")
	button:RegisterEvent("UNIT_ENTERED_VEHICLE")
	button:RegisterEvent("UNIT_ENTERING_VEHICLE")
	button:RegisterEvent("UNIT_EXITED_VEHICLE")

	button:RegisterEvent("PLAYER_TARGET_CHANGED")
	button:RegisterEvent("PLAYER_FOCUS_CHANGED")
	button:RegisterEvent("PLAYER_REGEN_ENABLED")
	button:RegisterEvent("PLAYER_REGEN_DISABLED")
	button:RegisterEvent("PLAYER_ENTER_COMBAT")
	button:RegisterEvent("PLAYER_LEAVE_COMBAT")
	button:RegisterEvent("PLAYER_CONTROL_LOST")
	button:RegisterEvent("PLAYER_CONTROL_GAINED")
	button:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

	button:RegisterEvent("UNIT_INVENTORY_CHANGED")
	button:RegisterEvent("BAG_UPDATE_COOLDOWN")
	button:RegisterEvent("BAG_UPDATE")
	button:RegisterEvent("COMPANION_UPDATE")
	button:RegisterEvent("PET_STABLE_UPDATE")
	button:RegisterEvent("PET_STABLE_SHOW")

	button:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	button:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	button:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	button:RegisterEvent("UPDATE_POSSESS_BAR")
	button:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	button:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
	button:RegisterEvent("UPDATE_BONUS_ACTIONBAR")

	button:RegisterEvent("PET_JOURNAL_LIST_UPDATE")

end


function BUTTON:MACRO_OnHide(...)
	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED")
	self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
	self:UnregisterEvent("ACTIONBAR_UPDATE_USABLE")

	self:UnregisterEvent("SPELL_UPDATE_CHARGES")
	self:UnregisterEvent("SPELL_UPDATE_USABLE")

	self:UnregisterEvent("RUNE_POWER_UPDATE")

	self:UnregisterEvent("TRADE_SKILL_SHOW")
	self:UnregisterEvent("TRADE_SKILL_CLOSE")
	self:UnregisterEvent("ARCHAEOLOGY_CLOSED")

	self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")

	self:UnregisterEvent("MODIFIER_STATE_CHANGED")

	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_PET")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_ENTERING_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")

	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("PLAYER_ENTER_COMBAT")
	self:UnregisterEvent("PLAYER_LEAVE_COMBAT")
	self:UnregisterEvent("PLAYER_CONTROL_LOST")
	self:UnregisterEvent("PLAYER_CONTROL_GAINED")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")

	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN")
	self:UnregisterEvent("BAG_UPDATE")
	self:UnregisterEvent("COMPANION_UPDATE")
	self:UnregisterEvent("PET_STABLE_UPDATE")
	self:UnregisterEvent("PET_STABLE_SHOW")

	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	self:UnregisterEvent("UPDATE_VEHICLE_ACTIONBAR")
	self:UnregisterEvent("UPDATE_POSSESS_BAR")
	self:UnregisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
	self:UnregisterEvent("UPDATE_EXTRA_ACTIONBAR")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("PET_JOURNAL_LIST_UPDATE")

end


function BUTTON:MACRO_OnAttributeChanged(name, value)

	if (value and self.data) then
		if (name == "activestate") then

			---Part 1 of Druid Prowl overwrite fix
			-----------------------------------------------------
			---breaks out of the loop due to flag set below
			if (NEURON.class == "DRUID" and self.ignoreNextOverrideStance == true and value == "homestate") then
				self.ignoreNextOverrideStance = nil
				NEURON.NeuronBar:SetState(self.bar, "stealth") --have to add this in otherwise the button icons change but still retain the homestate ability actions
				return
			else
				self.ignoreNextOverrideStance = nil
			end
			-----------------------------------------------------
			-----------------------------------------------------

			if (self:GetAttribute("HasActionID")) then
				self.actionID = self:GetAttribute("*action*")
			else

				if (not self.statedata) then
					self.statedata = { homestate = CopyTable(stateData) }
				end

				if (not self.statedata[value]) then
					self.statedata[value] = CopyTable(stateData)
				end

				---Part 2 of Druid Prowl overwrite fix
				---------------------------------------------------
				---druids have an issue where once stance will get immediately overwritten by another. I.E. stealth immediately getting overwritten by homestate if they go immediately into prowl from caster form
				---this conditional sets a flag to ignore the next most stance flag, as that one is most likely in error and should be ignored
				if(NEURON.class == "DRUID" and value == "stealth1") then
					self.ignoreNextOverrideStance = true
				end
				------------------------------------------------------
				------------------------------------------------------


				self.data = self.statedata[value]

				self:MACRO_UpdateParse()

				self:MACRO_Reset()

				self.actionID = false
			end
			--This will remove any old button state data from the saved varabiels/memory
			--for id,data in pairs(self.bar.cdata) do
			for id,data in pairs(self.statedata) do
				if (self.bar.cdata[id:match("%a+")]) or (id == "" and self.bar.cdata["custom"])  then
				elseif not self.bar.cdata[id:match("%a+")] then
					self.statedata[id]= nil
				end
			end

			self.specAction = self:GetAttribute("SpecialAction") --?
			NeuronButton:MACRO_UpdateAll(self, true)
		end

		if (name == "update") then
			NeuronButton:MACRO_UpdateAll(self, true)
		end
	end


end


function BUTTON:MACRO_build()
	local button = CopyTable(stateData)
	return button
end


function BUTTON:MACRO_Reset()
	self.macrospell = nil
	self.spellID = nil
	self.macroitem = nil
	self.macroshow = nil
	self.macroicon = nil
end


function BUTTON:MACRO_UpdateParse()
	self.macroparse = self.data.macro_Text

	if (#self.macroparse > 0) then
		self.macroparse = "\n"..self.macroparse.."\n"
		self.macroparse = (self.macroparse):gsub("(%c+)", " %1")
	else
		self.macroparse = nil
	end
end


function BUTTON:SetSkinned(flyout)
	if (SKIN) then
		local bar = self.bar

		if (bar) then
			local btnData = {
				Normal = self.normaltexture,
				Icon = self.iconframeicon,
				Cooldown = self.iconframecooldown,
				HotKey = self.hotkey,
				Count = self.count,
				Name = self.name,
				Border = self.border,
				AutoCast = false,
			}

			if (flyout) then
				SKIN:Group("Neuron", self.anchor.bar.gdata.name):AddButton(self, btnData)
			else
				SKIN:Group("Neuron", bar.gdata.name):AddButton(self, btnData)
			end

			self.skinned = true

			SKINIndex[self] = true
		end
	end
end


function BUTTON:GetSkinned()
	if (self.__MSQ_NormalTexture) then
		local Skin = self.__MSQ_NormalSkin

		if (Skin) then
			self.hasAction = Skin.Texture or false
			self.noAction = Skin.EmptyTexture or false

			if (self.__MSQ_Shape) then
				self.shape = self.__MSQ_Shape:lower()
			else
				self.shape = "square"
			end
		else
			self.hasAction = false
			self.noAction = false
			self.shape = "square"
		end

		self.shine.shape = self.shape

		return true
	else
		self.hasAction = "Interface\\Buttons\\UI-Quickslot2"
		self.noAction = "Interface\\Buttons\\UI-Quickslot"

		return false
	end
end


function BUTTON:SetData(bar)
	if (bar) then

		self.bar = bar

		self.barLock = bar.cdata.barLock
		self.barLockAlt = bar.cdata.barLockAlt
		self.barLockCtrl = bar.cdata.barLockCtrl
		self.barLockShift = bar.cdata.barLockShift

		self.tooltips = bar.cdata.tooltips
		self.tooltipsEnhanced = bar.cdata.tooltipsEnhanced
		self.tooltipsCombat = bar.cdata.tooltipsCombat

		self.spellGlow = bar.cdata.spellGlow
		self.spellGlowDef = bar.cdata.spellGlowDef
		self.spellGlowAlt = bar.cdata.spellGlowAlt

		self.bindText = bar.cdata.bindText
		self.macroText = bar.cdata.macroText
		self.countText = bar.cdata.countText

		self.cdText = bar.cdata.cdText

		if (bar.cdata.cdAlpha) then
			self.cdAlpha = 0.2
		else
			self.cdAlpha = 1
		end

		self.auraText = bar.cdata.auraText
		self.auraInd = bar.cdata.auraInd

		self.rangeInd = bar.cdata.rangeInd

		self.upClicks = bar.cdata.upClicks
		self.downClicks = bar.cdata.downClicks

		self.showGrid = bar.gdata.showGrid
		self.multiSpec = bar.cdata.multiSpec

		self.bindColor = bar.gdata.bindColor
		self.macroColor = bar.gdata.macroColor
		self.countColor = bar.gdata.countColor

		if (not self.cdcolor1) then
			self.cdcolor1 = { (";"):split(bar.gdata.cdcolor1) }
		else
			self.cdcolor1[1], self.cdcolor1[2], self.cdcolor1[3], self.cdcolor1[4] = (";"):split(bar.gdata.cdcolor1)
		end

		if (not self.cdcolor2) then
			self.cdcolor2 = { (";"):split(bar.gdata.cdcolor2) }
		else
			self.cdcolor2[1], self.cdcolor2[2], self.cdcolor2[3], self.cdcolor2[4] = (";"):split(bar.gdata.cdcolor2)
		end

		if (not self.auracolor1) then
			self.auracolor1 = { (";"):split(bar.gdata.auracolor1) }
		else
			self.auracolor1[1], self.auracolor1[2], self.auracolor1[3], self.auracolor1[4] = (";"):split(bar.gdata.auracolor1)
		end

		if (not self.auracolor2) then
			self.auracolor2 = { (";"):split(bar.gdata.auracolor2) }
		else
			self.auracolor2[1], self.auracolor2[2], self.auracolor2[3], self.auracolor2[4] = (";"):split(bar.gdata.auracolor2)
		end

		if (not self.buffcolor) then
			self.buffcolor = { (";"):split(bar.gdata.buffcolor) }
		else
			self.buffcolor[1], self.buffcolor[2], self.buffcolor[3], self.buffcolor[4] = (";"):split(bar.gdata.buffcolor)
		end

		if (not self.debuffcolor) then
			self.debuffcolor = { (";"):split(bar.gdata.debuffcolor) }
		else
			self.debuffcolor[1], self.debuffcolor[2], self.debuffcolor[3], self.debuffcolor[4] = (";"):split(bar.gdata.debuffcolor)
		end

		if (not self.rangecolor) then
			self.rangecolor = { (";"):split(bar.gdata.rangecolor) }
		else
			self.rangecolor[1], self.rangecolor[2], self.rangecolor[3], self.rangecolor[4] = (";"):split(bar.gdata.rangecolor)
		end

		self:SetFrameStrata(bar.gdata.objectStrata)

		self:SetScale(bar.gdata.scale)
	end

	if (self.bindText) then
		self.hotkey:Show()
		if (self.bindColor) then
			self.hotkey:SetTextColor((";"):split(self.bindColor))
		end
	else
		self.hotkey:Hide()
	end

	if (self.macroText) then
		self.macroname:Show()
		if (self.macroColor) then
			self.macroname:SetTextColor((";"):split(self.macroColor))
		end
	else
		self.macroname:Hide()
	end

	if (self.countText) then
		self.count:Show()
		if (self.countColor) then
			self.count:SetTextColor((";"):split(self.countColor))
		end
	else
		self.count:Hide()
	end

	local down, up = "", ""

	if (self.upClicks) then up = up.."AnyUp" end
	if (self.downClicks) then down = down.."AnyDown" end

	self:RegisterForClicks(down, up)
	self:RegisterForDrag("LeftButton", "RightButton")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if (not self.equipcolor) then
		self.equipcolor = { 0.1, 1, 0.1, 1 }
	else
		self.equipcolor[1], self.equipcolor[2], self.equipcolor[3], self.equipcolor[4] = 0.1, 1, 0.1, 1
	end

	if (not self.manacolor) then
		self.manacolor = { 0.5, 0.5, 1.0, 1 }
	else
		self.manacolor[1], self.manacolor[2], self.manacolor[3], self.manacolor[4] = 0.5, 0.5, 1.0, 1
	end

	self:SetFrameLevel(4)
	self.iconframe:SetFrameLevel(2)
	self.iconframecooldown:SetFrameLevel(3)
	self.iconframeaurawatch:SetFrameLevel(3)

	self:GetSkinned()

	NeuronButton:MACRO_UpdateTimers(self)
end


function BUTTON:SaveData(state)
	local index, spec = self.id, GetSpecialization()




	if (not state) then
		state = self:GetParent():GetAttribute("activestate") or "homestate"
	end

	--Possible fix to keep the home state action from getting overwritten

	if (NeuronObjectEditor and NeuronObjectEditor:IsVisible()) then
		return
	end


	if (index and spec and state) then

		if (not btnGDB[index].config) then
			btnGDB[index].config = CopyTable(configData)
		end

		for key,value in pairs(self.config) do
			btnGDB[index].config[key] = value
		end

		if (not btnGDB[index].keys) then
			btnGDB[index].keys = CopyTable(keyData)
		end

		if (not btnCDB[index].keys) then
			btnCDB[index].keys = CopyTable(keyData)
		end

		if (CDB.perCharBinds) then
			for key,value in pairs(self.keys) do
				btnCDB[index].keys[key] = value
			end
		else
			for key,value in pairs(self.keys) do
				btnGDB[index].keys[key] = value
			end
		end

		if (not btnCDB[index][spec]) then
			btnCDB[index][spec] = { homestate = CopyTable(stateData) }
		end

		if (not btnCDB[index][spec][state]) then
			btnCDB[index][spec][state] = CopyTable(stateData)
		end

		for key,value in pairs(self.data) do
			btnCDB[index][spec][state][key] = value
		end

		self:BuildStateData()

	else
		NEURON:Print("DEBUG: Bad Save Data for "..self:GetName().." ?")
		NEURON:Print(index); NEURON:Print(spec); NEURON:Print(state)
	end
end


function BUTTON:LoadData(spec, state)
	local id = self.id

	self.GDB = btnGDB
	self.CDB = btnCDB

	if (self.GDB and self.CDB) then

		if (not self.GDB[id]) then
			self.GDB[id] = {}
		end

		if (not self.GDB[id].config) then
			self.GDB[id].config = CopyTable(configData)
		end

		if (not self.GDB[id].keys) then
			self.GDB[id].keys = CopyTable(keyData)
		end

		if (not self.CDB[id]) then
			self.CDB[id] = {}
		end

		for i=1,4 do
			if (not self.CDB[id][i]) then
				self.CDB[id][i] = { homestate = CopyTable(stateData) }
			end
		end

		if (not self.CDB[id].keys) then
			self.CDB[id].keys = {}
		end

		-- kill old per character key data
		if (self.CDB[id].keys.hotKeys) then
			self.CDB[id].keys.hotKeys = nil
			self.CDB[id].keys.hotKeyText = nil
			self.CDB[id].keys.hotKeyLock = nil
			self.CDB[id].keys.hotKeyPri = nil
		end

		if (not self.CDB[id].keys[spec]) then
			self.CDB[id].keys[spec] = CopyTable(keyData)
		end

		NEURON:UpdateData(self.CDB[id].keys[spec], keyData)

		if (not self.CDB[id][spec]) then
			self.CDB[id][spec] = { homestate = CopyTable(stateData) }
		end

		if (self.CDB[id][spec].keys) then
			self.CDB[id][spec].keys = nil
		end

		if (not self.CDB[id][spec][state]) then
			self.CDB[id][spec][state] = CopyTable(stateData)
		end

		NEURON:UpdateData(self.GDB[id].config, configData)
		NEURON:UpdateData(self.GDB[id].keys, keyData)

		for spec,states in pairs(self.CDB[id]) do
			if (spec ~= "keys") then
				for state,data in pairs(states) do
					if (type(data) == "table") then
						NEURON:UpdateData(data, stateData)
					end
				end
			end
		end

		self.config = self.GDB[id].config

		if (CDB.perCharBinds) then
			self.keys = self.CDB[id].keys
		else
			self.keys = self.GDB[id].keys
		end

		self.specdata = self.CDB[id]

		self.statedata = self.specdata[spec]

		self.data = self.statedata[state]

		self:BuildStateData()
	end
end


function BUTTON:BuildStateData()
	for state, data in pairs(self.statedata) do
		self:SetAttribute(state.."-macro_Text", data.macro_Text)
		self:SetAttribute(state.."-actionID", data.actionID)
	end
end


function BUTTON:Reset()
	self:SetAttribute("unit", nil)
	self:SetAttribute("useparent-unit", nil)
	self:SetAttribute("type", nil)
	self:SetAttribute("type1", nil)
	self:SetAttribute("type2", nil)
	self:SetAttribute("*action*", nil)
	self:SetAttribute("*macrotext*", nil)
	self:SetAttribute("*action1", nil)
	self:SetAttribute("*macrotext2", nil)

	self:UnregisterEvent("ITEM_LOCK_CHANGED")
	self:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")
	self:UnregisterEvent("ACTIONBAR_SHOWGRID")
	self:UnregisterEvent("ACTIONBAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_SHOWGRID")
	self:UnregisterEvent("PET_BAR_HIDEGRID")
	self:UnregisterEvent("PET_BAR_UPDATE")
	self:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("UNIT_FLAGS")
	self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	self:UnregisterEvent("UPDATE_MACROS")
	self:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
	self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")

	self:MACRO_Reset()
end


function BUTTON:SetGrid(show, hide)
	if (not InCombatLockdown()) then

		self:SetAttribute("isshown", self.showGrid)
		self:SetAttribute("showgrid", show)

		if (show or self.showGrid) then
			self:Show()
		elseif (not (self:IsMouseOver() and self:IsVisible()) and not NeuronButton:MACRO_HasAction(self)) then
			self:Hide()
		end
	end
end

function BUTTON:SetAux()
	self:SetSkinned()
	self:UpdateFlyout(true)
end


function BUTTON:LoadAux()

	self:CreateEditFrame(self.objTIndex)
	self:CreateBindFrame(self.objTIndex)

end


function BUTTON:SetDefaults(config, keys)
	if (config) then
		for k,v in pairs(config) do
			self.config[k] = v
		end
	end

	if (keys) then
		for k,v in pairs(keys) do
			self.keys[k] = v
		end
	end
end


function BUTTON:GetDefaults()
	return nil, keyDefaults[self.id]
end


function BUTTON:SetType(save, kill, init)
	local state = self:GetParent():GetAttribute("activestate")

	self:Reset()

	if (kill) then

		self:SetScript("OnEvent", function() end)
		self:SetScript("OnUpdate", function() end)
		self:SetScript("OnAttributeChanged", function() end)

	else
		SecureHandler_OnLoad(self)

		self:RegisterEvent("ITEM_LOCK_CHANGED")
		self:RegisterEvent("ACTIONBAR_SHOWGRID")
		self:RegisterEvent("ACTIONBAR_HIDEGRID")
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		self:RegisterEvent("UPDATE_MACROS")
		self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
		self:RegisterEvent("EQUIPMENT_SETS_CHANGED")

		self:MACRO_UpdateParse()

		self:SetAttribute("type", "macro")
		self:SetAttribute("*macrotext*", self.macroparse)

		self:SetScript("OnEvent", function(self, event, ...) NeuronButton:MACRO_OnEvent(self, event, ...) end)
		self:SetScript("PreClick", BUTTON.MACRO_PreClick)
		self:SetScript("PostClick", BUTTON.MACRO_PostClick)
		self:SetScript("OnReceiveDrag", BUTTON.MACRO_OnReceiveDrag)
		self:SetScript("OnDragStart", BUTTON.MACRO_OnDragStart)
		self:SetScript("OnDragStop", BUTTON.MACRO_OnDragStop)
		self:SetScript("OnUpdate", function(self, elapsed) NeuronButton:MACRO_OnUpdate(self, elapsed) end)--this function uses A LOT of CPU resources
		self:SetScript("OnShow", function(self, ...) NeuronButton:MACRO_OnShow(self, ...) end)
		self:SetScript("OnHide", BUTTON.MACRO_OnHide)
		self:SetScript("OnAttributeChanged", BUTTON.MACRO_OnAttributeChanged)

		self:HookScript("OnEnter", BUTTON.MACRO_OnEnter)
		self:HookScript("OnLeave", BUTTON.MACRO_OnLeave)

		self:WrapScript(self, "OnShow", [[
						for i=1,select('#',(":"):split(self:GetAttribute("hotkeys"))) do
							self:SetBindingClick(self:GetAttribute("hotkeypri"), select(i,(":"):split(self:GetAttribute("hotkeys"))), self:GetName())
						end
						]])

		self:WrapScript(self, "OnHide", [[
						if (not self:GetParent():GetAttribute("concealed")) then
							for key in gmatch(self:GetAttribute("hotkeys"), "[^:]+") do
								self:ClearBinding(key)
							end
						end
						]])

		--new action ID's for vehicle 133-138
		--new action ID's for possess 133-138
		--new action ID's for override 157-162

		self:SetAttribute("overrideID_Offset", 156)
		self:SetAttribute("vehicleID_Offset", 132)

		self:SetAttribute("_childupdate", [=[

				if (message) then

					local msg = (":"):split(message)

					if (msg:find("vehicle")) then

						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))

						end

						self:SetAttribute("SpecialAction", "vehicle")
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif (msg:find("possess")) then
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))

						end

						self:SetAttribute("SpecialAction", "possess")
						self:SetAttribute("HasActionID", true)
						self:Show()

					elseif (msg:find("override")) then
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "action")
							self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("overrideID_Offset"))
							self:SetAttribute("HasActionID", true)

						end

						self:SetAttribute("SpecialAction", "override")

						self:SetAttribute("HasActionID", true)

						self:Show()

					else
						if (not self:GetAttribute(msg.."-actionID")) then

							self:SetAttribute("type", "macro")
							self:SetAttribute("*macrotext*", self:GetAttribute(msg.."-macro_Text"))

							if ((self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or (self:GetAttribute("showgrid"))) then
								self:Show()
							elseif (not self:GetAttribute("isshown")) then
								self:Hide()
							end

							self:SetAttribute("HasActionID", false)
						else
							self:SetAttribute("HasActionID", true)
						end

						self:SetAttribute("SpecialAction", nil)
					end

					self:SetAttribute("useparent-unit", nil)
					self:SetAttribute("activestate", msg)

				end

			]=])

		if (not init) then
			NeuronButton:MACRO_UpdateAll(self, true)
		end

		NeuronButton:MACRO_OnShow(self)

	end

	if (save) then
		self:SaveData(state)
	end
end


function BUTTON:SetFauxState(state)
	if (state)  then

		local msg = (":"):split(state)

		if (msg:find("vehicle")) then
			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
				self:SetAttribute("HasActionID", true)

			end

			self:Show()
		elseif (msg:find("possess")) then
			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("vehicleID_Offset"))
				self:SetAttribute("HasActionID", true)

			end

			self:Show()

		elseif (msg:find("override")) then
			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "action")
				self:SetAttribute("*action*", self:GetAttribute("barPos")+self:GetAttribute("overrideID_Offset"))
				self:SetAttribute("HasActionID", true)

			end

			self:Show()

		else
			if (not self:GetAttribute(msg.."-actionID")) then

				self:SetAttribute("type", "macro")

				self:SetAttribute("*macrotext*", self:GetAttribute(msg.."-macro_Text"))

				if ((self:GetAttribute("*macrotext*") and #self:GetAttribute("*macrotext*") > 0) or (self:GetAttribute("showgrid"))) then
					self:Show()
				elseif (not self:GetAttribute("isshown")) then
					self:Hide()
				end

				self:SetAttribute("HasActionID", false)
			else
				self:SetAttribute("HasActionID", true)
			end
		end
		self:SetAttribute("activestate", msg)
	end
end


--this will generate a spell macro
--spell: name of spell to use
--subname: subname of spell to use (optional)
--return: macro text
function BUTTON:AutoWriteMacro(spell, subName)
	local modifier, modKey = " ", nil
	local bar = Neuron.CurrentBar or self.bar

	if (bar.cdata.mouseOverCast and NeuronCDB.mouseOverMod ~= "NONE" ) then
		modKey = NeuronCDB.mouseOverMod; modifier = modifier.."[@mouseover,mod:"..modKey.."]"
	elseif (bar.cdata.mouseOverCast and NeuronCDB.mouseOverMod == "NONE" ) then
		modifier = modifier.."[@mouseover,exists]"
	end

	if (bar.cdata.selfCast and GetModifiedClick("SELFCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("SELFCAST"); modifier = modifier.."[@player,mod:"..modKey.."]"
	end

	if (bar.cdata.focusCast and GetModifiedClick("FOCUSCAST") ~= "NONE" ) then
		modKey = GetModifiedClick("FOCUSCAST"); modifier = modifier.."[@focus,exists,mod:"..modKey.."]"
	end

	if (bar.cdata.rightClickTarget) then
		modKey = ""; modifier = modifier.."[@player"..modKey..",btn:2]"
	end

	if (modifier ~= " " ) then --(modKey) then
		modifier = modifier.."[] "
	end

	if (subName and #subName > 0) then
		return "#autowrite\n/cast"..modifier..spell.."("..subName..")"
	else
		return "#autowrite\n/cast"..modifier..spell.."()"
	end
end


--This will update the modifier value in a macro when a bar is set twith a target condiional
--@spell:  this is hte macro text to be updated
--return: updated macro text
function BUTTON:AutoUpdateMacro(macro)
	if (GetModifiedClick("SELFCAST") ~= "NONE" ) then
		macro = macro:gsub("%[@player,mod:%u+%]", "[@player,mod:"..GetModifiedClick("SELFCAST").."]")
	else
		macro = macro:gsub("%[@player,mod:%u+%]", "")
	end

	if (GetModifiedClick("FOCUSCAST") ~= "NONE" ) then
		macro = macro:gsub("%[@focus,mod:%u+%]", "[@focus,exists,mod:"..GetModifiedClick("FOCUSCAST").."]")
	else
		macro = macro:gsub("%[@focus,mod:%u+%]", "")
	end

	if (NeuronCDB.mouseOverMod ~= "NONE" ) then
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,mod:"..NeuronCDB.mouseOverMod .."]")
		macro = macro:gsub("%[@mouseover,exists]", "[@mouseover,mod:"..NeuronCDB.mouseOverMod .."]")
	else
		macro = macro:gsub("%[@mouseover,mod:%u+%]", "[@mouseover,exists]")
	end

	--macro = info.macro_Text:gsub("%[.*%]", "")
	return macro
end


function BUTTON:GetPosition(oFrame)
	local relFrame, point

	if (oFrame) then
		relFrame = oFrame
	else
		relFrame = self:GetParent()
	end

	local s = self:GetScale()
	local w, h = relFrame:GetWidth()/s, relFrame:GetHeight()/s
	local x, y = self:GetCenter()
	local vert = (y>h/1.5) and "TOP" or (y>h/3) and "CENTER" or "BOTTOM"
	local horz = (x>w/1.5) and "RIGHT" or (x>w/3) and "CENTER" or "LEFT"

	if (vert == "CENTER") then
		point = horz
	elseif (horz == "CENTER") then
		point = vert
	else
		point = vert..horz
	end

	if (vert:find("CENTER")) then y = y - h/2 end
	if (horz:find("CENTER")) then x = x - w/2 end
	if (point:find("RIGHT")) then x = x - w end
	if (point:find("TOP")) then y = y - h end

	return point, x, y
end

--callback(arg and arg, Group, SkinID, Gloss, Backdrop, Colors, Fonts)

function NEURON:SKINCallback(group,...)
	if (group) then
		for btn in pairs(SKINIndex) do
			if (btn.bar and btn.bar.gdata.name == group) then
				btn:GetSkinned()
			end
		end
	end
end



function NeuronButton.ButtonProfileUpdate()
	GDB, CDB = NeuronGDB, NeuronCDB

	btnGDB = GDB.buttons

	btnCDB = CDB.buttons
end


--- This will itterate through a set of buttons. For any buttons that have the #autowrite flag in its macro, that
-- macro will then be updated to via AutoWriteMacro to include selected target macro option, or via AutoUpdateMacro
-- to update a current target macro's toggle mofifier.
-- @param global(boolean): if true will go though all buttons, else it will just update the button set for the current bar
function BUTTON:UpdateMacroCastTargets(global_update)
	local button_list = {}

	if global_update then
		local button_count =(#NeuronCDB.buttons)
		for index = 1, button_count, 1 do
			tinsert(button_list, _G["NeuronActionButton"..index])
		end
	else
		local bar = Neuron.CurrentBar
		for index in gmatch(bar.gdata.objectList, "[^;]+") do
			tinsert(button_list, _G["NeuronActionButton"..index])
		end
	end

	for index, button in pairs(button_list) do
		local cur_button = button.specdata
		local macro_update = false

		for i = 1,2 do
			for state, info in pairs(cur_button[i]) do
				if info.macro_Text and info.macro_Text:find("#autowrite\n/cast") then
					local spell, subName = "", ""

					spell = info.macro_Text:gsub("%[.*%]", "")
					spell, subName = spell:match("#autowrite\n/cast%s*(.+)%((.*)%)")

					if spell then
						if global_update then
							info.macro_Text = NEURON.BUTTON:AutoUpdateMacro(info.macro_Text)
						else
							info.macro_Text = NEURON.BUTTON:AutoWriteMacro(spell, subName)
						end

					end
					macro_update = true
				end
			end
		end

		if macro_update then
			button:UpdateFlyout()
			button:BuildStateData()
			button:SetType()
		end
	end
end