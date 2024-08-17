
-- --------------------------
-- Improved Loot Frame
-- By Cybeloras of Detheroc/Mal'Ganis
-- --------------------------

local LovelyLootLoaded = C_AddOns.IsAddOnLoaded("LovelyLoot")

-- LOOTFRAME_AUTOLOOT_DELAY = 0.5;
-- LOOTFRAME_AUTOLOOT_RATE = 0.1;

if not LovelyLootLoaded then

	-- Woah, nice coding, blizz.
	-- Anchor something positioned at the top of the frame to the center of the frame instead,
	-- and make it an anonymous font string so I have to work to find it
	local i = 1

	while true do
		local r = select(i, LootFrame:GetRegions())
		if not r then break end
		if r.GetText and r:GetText() == ITEMS then
			r:ClearAllPoints()
			r:SetPoint("TOP", 12, -5)
		end
		i = i + 1
	end
end

if LootButton1 then
	-- Calculate base height of the loot frame
	local p, r, x, y = "TOP", "BOTTOM", 0, -4
	local buttonHeight = LootButton1:GetHeight() + abs(y)
	local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS)
	if not LovelyLootLoaded then
		baseHeight = baseHeight - 5
	end

	LootFrame.OverflowText = LootFrame:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
	local OverflowText = LootFrame.OverflowText

	OverflowText:SetPoint("TOP", LootFrame, "TOP", 0, -26)
	OverflowText:SetPoint("LEFT", LootFrame, "LEFT", 60, 0)
	OverflowText:SetPoint("RIGHT", LootFrame, "RIGHT", -8, 0)
	OverflowText:SetPoint("BOTTOM", LootFrame, "TOP", 0, -65)

	if LovelyLootLoaded then
		OverflowText:SetPoint("LEFT", LootFrame, "RIGHT", 10, 0)
		OverflowText:SetPoint("RIGHT", LootFrame, "RIGHT", -10 + LootFrame:GetWidth(), 0)
	end

	OverflowText:SetSize(1, 1)
	OverflowText:SetJustifyH("LEFT")
	OverflowText:SetJustifyV("TOP")
	OverflowText:SetText("Hit 50-mob limit! Take some, then re-loot for more.")
	OverflowText:Hide()

	local t = {}
	local function CalculateNumMobsLooted()
		wipe(t)

		for i = 1, GetNumLootItems() do
			for n = 1, select("#", GetLootSourceInfo(i)), 2 do
				local GUID, num = select(n, GetLootSourceInfo(i))
				t[GUID] = true
			end
		end

		local n = 0
		for k, v in pairs(t) do
			n = n + 1
		end

		return n
	end

	hooksecurefunc("LootFrame_Show", function(self, ...)
		local maxButtons = floor(UIParent:GetHeight()/LootButton1:GetHeight() * 0.7)
		
		local num = GetNumLootItems()

		if self.AutoLootTable then
			num = #self.AutoLootTable
		end

		self.AutoLootDelay = 0.4 + (num * 0.05)
		
		num = min(num, maxButtons)
		
		LootFrame:SetHeight(baseHeight + (num * buttonHeight))
		for i = 1, num do
			if i > LOOTFRAME_NUMBUTTONS then
				local button = _G["LootButton"..i]
				if not button then
					button = CreateFrame(ItemButtonMixin and "ItemButton" or "Button", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
				end
				LOOTFRAME_NUMBUTTONS = i
			end
			if i > 1 then
				local button = _G["LootButton"..i]
				button:ClearAllPoints()
				button:SetPoint(p, "LootButton"..(i-1), r, x, y)
			end
		end

		if CalculateNumMobsLooted() >= 50 then
			OverflowText:Show()
		else
			OverflowText:Hide()
		end
		
		LootFrame_Update();
	end)
else
	LootFrame.panelMaxHeight = UIParent:GetHeight() * .7
end
