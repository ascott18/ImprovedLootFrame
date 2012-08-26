
-- --------------------------
-- Improved Loot Frame
-- By Cybeloras of Mal'Ganis
-- --------------------------

local LovelyLootLoaded = IsAddOnLoaded("LovelyLoot")
local ISMOP = select(4, GetBuildInfo()) >= 50000


-- Woah, nice coding, blizz.
-- Anchor something positioned at the top of the frame to the center of the frame instead,
-- and make it an anonymous font string so I have to work to find it
local i, t = 1, "Interface\\LootFrame\\UI-LootPanel"
if not LovelyLootLoaded then
	while true do
		local r = select(i, LootFrame:GetRegions())
		if not r then break end
		if r.GetText and r:GetText() == ITEMS then
			r:ClearAllPoints()
			r:SetPoint("TOP", ISMOP and 12 or -12, ISMOP and -5 or -19.5)
		elseif not ISMOP and r.GetTexture and r:GetTexture() == t then
			r:Hide()
		end
		i = i + 1
	end

	if not ISMOP then
		local top = LootFrame:CreateTexture("LootFrameBackdropTop")
		top:SetTexture(t)
		top:SetTexCoord(0, 1, 0, 0.3046875)
		top:SetPoint("TOP")
		top:SetHeight(78)

		local bottom = LootFrame:CreateTexture("LootFrameBackdropBottom")
		bottom:SetTexture(t)
		bottom:SetTexCoord(0, 1, 0.9296875, 1)
		bottom:SetPoint("BOTTOM")
		bottom:SetHeight(18)

		local mid = LootFrame:CreateTexture("LootFrameBackdropMiddle")
		mid:SetTexture(t)
		mid:SetTexCoord(0, 1, 0.3046875, 0.9296875)
		mid:SetPoint("TOP", top, "BOTTOM")
		mid:SetPoint("BOTTOM", bottom, "TOP")
	end
end

local p, r, x, y = "TOP", "BOTTOM", 0, -4
local buttonHeight = LootButton1:GetHeight() + abs(y)
local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS)
if ISMOP then
	baseHeight = baseHeight - 5
end
local old_LootFrame_Show = LootFrame_Show
function LootFrame_Show(self, ...)
	LootFrame:SetHeight(baseHeight + (GetNumLootItems() * buttonHeight))
	local num = GetNumLootItems()
	for i = 1, GetNumLootItems() do
		if i > LOOTFRAME_NUMBUTTONS then
			local button = _G["LootButton"..i]
			if not button then
				button = CreateFrame("Button", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
			end
			LOOTFRAME_NUMBUTTONS = i
		end
		if i > 1 then
			local button = _G["LootButton"..i]
			button:ClearAllPoints()
			button:SetPoint(p, "LootButton"..(i-1), r, x, y)
		end
	end
	
	return old_LootFrame_Show(self, ...)
end

-- the following is inspired by http://us.battle.net/wow/en/forum/topic/2353268564 and is hacktastic
local framesRegistered = {}
local function populateframesRegistered(...)
	wipe(framesRegistered)
	for i = 1, select("#", ...) do
		framesRegistered[i] = select(i, ...)
	end
end

local old_LootButton_OnClick = LootButton_OnClick
function LootButton_OnClick(self, ...)
	populateframesRegistered(GetFramesRegisteredForEvent("ADDON_ACTION_BLOCKED"))
	
	for i, frame in pairs(framesRegistered) do
		frame:UnregisterEvent("ADDON_ACTION_BLOCKED") -- fuck the rice-a-roni! (Blizzard throws a false taint error when attemping to loot the coins from a mob when the coins are the only loot on the mob)
	end
	
	old_LootButton_OnClick(self, ...)
	
	for i, frame in pairs(framesRegistered) do
		frame:RegisterEvent("ADDON_ACTION_BLOCKED")
	end
end