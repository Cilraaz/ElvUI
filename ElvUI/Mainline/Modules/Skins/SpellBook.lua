local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

local C_SpellBook_GetSpellBookItemInfo = C_SpellBook.GetSpellBookItemInfo

local function clearBackdrop(self)
	self:SetBackdropColor(0, 0, 0, 1)
end

local function HandleSkillButton(button)
	if not button then return end
	button:SetCheckedTexture(E.media.normTex)
	button:GetCheckedTexture():SetColorTexture(1, 1, 1, .25)
	button:SetPushedTexture(E.media.normTex)
	button:GetPushedTexture():SetColorTexture(1, 1, 1, .5)
	button.IconTexture:SetInside()

	if button.cooldown then
		E:RegisterCooldown(button.cooldown)
	end

	S:HandleIcon(button.IconTexture, true)
	button.highlightTexture:SetInside(button.IconTexture.backdrop)

	local nameFrame = _G[button:GetName()..'NameFrame']
	if nameFrame then nameFrame:Hide() end
end

function S:Blizzard_ProfessionsBook()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook) then return end

	local ProfessionsBookFrame = _G.ProfessionsBookFrame
	S:HandleFrame(ProfessionsBookFrame)

	if E.global.general.disableTutorialButtons then
		ProfessionsBookFrameTutorialButton:Kill()
	else
		ProfessionsBookFrameTutorialButton.Ring:Hide()
	end

	--Profession Tab
	for _, button in next, { _G.PrimaryProfession1, _G.PrimaryProfession2, _G.SecondaryProfession1, _G.SecondaryProfession2, _G.SecondaryProfession3 } do
		button.missingHeader:SetTextColor(1, 1, 0)

		--[[ FIX ME 11.0
		if E.private.skins.parchmentRemoverEnable then
			button.missingText:SetTextColor(1, 1, 1)
		else
			button.missingText:SetTextColor(0, 0, 0)
		end
		]]
		button.missingText:SetTextColor(1, 1, 1)

		local a, b, c, _, e = button.statusBar:GetPoint()
		button.statusBar:Point(a, b, c, 0, e)
		button.statusBar.rankText:Point('CENTER')
		S:HandleStatusBar(button.statusBar, {0, .86, 0})

		if a == 'BOTTOMLEFT' then
			button.rank:Point('BOTTOMLEFT', button.statusBar, 'TOPLEFT', 0, 4)
		elseif a == 'TOPLEFT' then
			button.rank:Point('TOPLEFT', button.professionName, 'BOTTOMLEFT', 0, -20)
		end

		if button.unlearn then
			button.unlearn:Point('RIGHT', button.statusBar, 'LEFT', -18, -5)
		end

		if button.icon then
			S:HandleIcon(button.icon)

			button:StripTextures()
			button.professionName:Point('TOPLEFT', 100, -4)

			button:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, true)
			button.backdrop.Center:SetDrawLayer('BORDER', -1)
			button.backdrop:SetOutside(button.icon)
			button.backdrop:SetBackdropColor(0, 0, 0, 1)
			button.backdrop.callbackBackdropColor = clearBackdrop

			button.icon:SetDesaturated(false)
			button.icon:SetAlpha(1)
		end

		HandleSkillButton(button.SpellButton1)
		HandleSkillButton(button.SpellButton2)
	end

	for i = 1, 2 do
		local button = _G['PrimaryProfession'..i]
		S:HandleButton(button, true, nil, true)

		if button.iconTexture then
			S:HandleIcon(button.iconTexture, true)
		end
	end

	-- Some Texture Magic
	hooksecurefunc('FormatProfession', function(frame, id)
		if not (id and frame and frame.icon) then return end

		local texture = select(2, GetProfessionInfo(id))
		if texture then frame.icon:SetTexture(texture) end
	end)

	-- FIX ME 11.0
	hooksecurefunc(_G.ProfessionSpellButtonMixin, 'UpdateButton', function(button)
		local parent = button:GetParent()
		if not parent or not parent.spellOffset then return end

		local activeSpellBank = Enum.SpellBookSpellBank.Player
		local spellIndex = button:GetID() + parent.spellOffset
		local spellBookItemInfo = C_SpellBook_GetSpellBookItemInfo(spellIndex, activeSpellBank)
		if spellBookItemInfo.isPassive then
			button.highlightTexture:SetColorTexture(1, 1, 1, 0)
		else
			button.highlightTexture:SetColorTexture(1, 1, 1, .25)
		end

		if E.private.skins.parchmentRemoverEnable then
			if button.spellString then
				button.spellString:SetTextColor(1, 1, 1)
			end
			if button.subSpellString then
				button.subSpellString:SetTextColor(1, 1, 1)
			end
			if button.SpellName then
				button.SpellName:SetTextColor(1, 1, 1)
			end
			if button.SpellSubName then
				button.SpellSubName:SetTextColor(1, 1, 1)
			end
		end
	end)
end

S:AddCallbackForAddon('Blizzard_ProfessionsBook')
