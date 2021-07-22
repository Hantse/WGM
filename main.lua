EPIC = LibStub("AceAddon-3.0"):NewAddon("EPIC", "AceConsole-3.0", "AceEvent-3.0")

local tradeSkills = {}
local LH = LibStub("LibHash-1.0")

function EPIC:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("EPICDb", defaults)
    EPIC:RegisterEvent('TRADE_SKILL_SHOW', 'HandleTradeSkillFrame')
    EPIC:RegisterEvent('TRADE_SKILL_UPDATE', 'HandleTradeSkillFrame')
    EPIC:RegisterChatCommand('EPIC', 'HandleCharacterCommand')
    EPIC:RegisterChatCommand('EPIC-test', 'HandleTestCommand')
    EPIC:RegisterChatCommand('EPIC-bank', 'HandleBankCommand')
end

-- region handler
function EPIC:HandleCharacterCommand(input)
    
    print(EPIC:GetAddons())
    EPIC:HandleEnchanting()

    local exportString =
        '[' .. UnitName('player') .. ',' .. UnitLevel('player') .. ',' ..
            UnitRace('player') .. ',' .. UnitSex('player') .. ',' ..
            UnitClass('player') .. ',' .. GetLocale() .. '];'

    exportString = exportString .. EPIC:ExportStuff() .. EPIC:ExportTalents() ..
                       EPIC:ExportTradeSkill() .. EPIC:ExportReputation() ..
                       EPIC:ExportAttunement() .. EPIC:ExtractCharacterStats() .. EPIC:GetAddons()

    EPIC:DisplayExportString(exportString)
end

function EPIC:HandleBankCommand()
    local bags = EPIC:GetBags()
    local bagItems = EPIC:GetBagItems()

    local exportString =
        '[' .. UnitName('player') .. ',' .. GetMoney() .. ',' .. GetLocale() ..
            '];'

    exportString = exportString .. '['

    for i = 1, #bags do
        if i > 1 then exportString = exportString .. ',' end

        exportString = exportString .. bags[i].container .. ','

        if bags[i].bagName == nil == false then
            exportString = exportString .. bags[i].bagName
        end
    end

    exportString = exportString .. '];'

    for i = 1, #bagItems do
        exportString = exportString .. '[' .. bagItems[i].container .. ',' ..
                           bagItems[i].slot .. ',' .. bagItems[i].itemID .. ',' ..
                           bagItems[i].count .. '];'
    end

    EPIC:DisplayExportStringWithoutCrypting(exportString)
end
-- end region handler

-- region for character
function EPIC:ExportAttunement()
    local exportString = "["

    if C_QuestLog.IsQuestFlaggedCompleted(7848) then
        exportString = exportString .. "MC#"
    end

    if C_QuestLog.IsQuestFlaggedCompleted(6502) then
        exportString = exportString .. "Onyxia#"
    end

    if C_QuestLog.IsQuestFlaggedCompleted(7761) then
        exportString = exportString .. "BWL#"
    end

    if C_QuestLog.IsQuestFlaggedCompleted(9837) then
        exportString = exportString .. "Karazhan#"
    end

    if C_QuestLog.IsQuestFlaggedCompleted(13431) then
        exportString = exportString .. "Serpentshrine Cavern#"
    end

    if C_QuestLog.IsQuestFlaggedCompleted(10888) then
        exportString = exportString .. "Tempest Keep#"
    end

    if C_QuestLog.IsQuestFlaggedCompleted(10445) then
        exportString = exportString .. "Hyjal#"
    end

    exportString = exportString .. "];"
    return exportString
end

function EPIC:ExportReputation()
    local exportString = "["
    for i = 1, GetNumFactions() do
        name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild =
            GetFactionInfo(i)
        if isHeader == false then
            exportString =
                exportString .. '' .. name .. ',' .. topValue .. ',' ..
                    earnedValue .. ',' .. standingId .. '#'
        end
    end
    exportString = exportString .. "];"
    return exportString
end

function EPIC:ExportTradeSkill()
    local exportString = "["
    for key, value in pairs(tradeSkills) do
        exportString = exportString .. value .. '*'
    end
    exportString = exportString .. "];"
    return exportString
end

function EPIC:ExportTalents()
    local exportString = "[";
    for i = 0, GetNumTalentTabs(), 1 do
        for j = 0, GetNumTalents(i), 1 do
            local nameTalent, icon, tier, column, currRank, maxRank =
                GetTalentInfo(i, j)
            if nameTalent == nil == false and currRank > 0 == true then
                exportString = exportString .. '[' .. i .. ',' .. tier .. ',' ..
                                   column .. ',' .. currRank .. ',' .. maxRank ..
                                   ']#'
            end
        end
    end
    exportString = exportString .. "];"
    return exportString
end

function EPIC:ExportStuff()
    local stuffExtracted = EPIC:ExtractStuff();
    local exportString = "[";
    for i = 1, #stuffExtracted do
        if i > 1 then exportString = exportString .. '#' end

        exportString = exportString .. stuffExtracted[i].slotName .. ','

        if stuffExtracted[i].link == nil == false then
            exportString = exportString .. stuffExtracted[i].link
        end
    end

    exportString = exportString .. "];"
    return exportString;
end

function EPIC:HandleTradeSkillFrame()
    local localised_name, current_skill_level, max_level = GetTradeSkillLine()
    if GetNumTradeSkills() == 0 == false then
        tradeSkills[localised_name] = {}
        local exportedSkill = "[" .. localised_name .. "," ..
                                  current_skill_level .. "," .. max_level .. "@";
        local numSkills = GetNumTradeSkills()
        for i = 0, numSkills, 1 do
            if GetTradeSkillItemLink(i) == nil == false then
                exportedSkill = exportedSkill .. GetTradeSkillItemLink(i) .. '#'
            end
        end
        exportedSkill = exportedSkill .. "]"
        tradeSkills[localised_name] = exportedSkill
    end
    print('Scan done for ' .. localised_name)
end

function EPIC:HandleEnchanting()
    tradeSkills[GetCraftName()] = {}
    local exportedSkill =
        "[" .. GetCraftName() .. "," .. "300" .. "," .. "375" .. "@";

    for i = 1, GetNumCrafts() do
        if GetCraftItemLink(i) == nil == false then
            exportedSkill = exportedSkill .. GetCraftItemLink(i) .. '#'
        end
    end

    exportedSkill = exportedSkill .. "]"
    tradeSkills[GetCraftName()] = exportedSkill

    print('Scan done for ' .. GetCraftName())
end

function EPIC:ExtractStuff()
    local slotNames = {
        "HeadSlot", "NeckSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot",
        "WaistSlot", "LegsSlot", "FeetSlot", "WristSlot", "HandsSlot",
        "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
        "BackSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot"
    }
    local stuffItems = {};

    for slotCount = 1, 18 do
        local itemLink, soltId = GetInventoryItemLink("player",
                                                      GetInventorySlotInfo(
                                                          slotNames[slotCount]))
        stuffItems[#stuffItems + 1] = {
            slotName = slotNames[slotCount],
            link = itemLink
        }
    end

    return stuffItems;
end

function EPIC:ExtractCharacterStats()

    baseStrength, statStrength, posBuffStrength, negBuffStrength = UnitStat(
                                                                       "player",
                                                                       1);
    baseAgility, statAgility, posBuffAgility, negBuffAgility = UnitStat(
                                                                   "player", 2);
    baseStamina, statStamina, posBuffStamina, negBuffStamina = UnitStat(
                                                                   "player", 3);
    baseIntellect, statIntellect, posBuffIntellect, negBuffIntellect = UnitStat(
                                                                           "player",
                                                                           4);
    baseSpirit, statSpirit, posBuffSpirit, negBuffSpirit = UnitStat("player", 5);

    local exportString = '[ArmorPenetration:' .. GetArmorPenetration() ..
                             ',CritChance:' .. GetCritChance() ..
                             ',DodgeChance:' .. GetDodgeChance() ..
                             ',Expertise:' .. GetExpertise() .. ',ManaRegen:' ..
                             GetManaRegen() .. ',ParryChance:' ..
                             GetParryChance() .. ',PhysicalSpellDamage:' ..
                             GetSpellBonusDamage(1) .. ',HolySpellDamage:' ..
                             GetSpellBonusDamage(2) .. ',FireSpellDamage:' ..
                             GetSpellBonusDamage(3) .. ',NatureSpellDamage:' ..
                             GetSpellBonusDamage(4) .. ',FrostSpellDamage:' ..
                             GetSpellBonusDamage(5) .. ',ShadowSpellDamage:' ..
                             GetSpellBonusDamage(6) .. ',ArcaneSpellDamage:' ..
                             GetSpellBonusDamage(7) .. ',PhysicalSpellCrit:' ..
                             GetSpellBonusDamage(1) .. ',HolySpellCrit:' ..
                             GetSpellBonusDamage(2) .. ',FireSpellCrit:' ..
                             GetSpellBonusDamage(3) .. ',NatureSpellCrit:' ..
                             GetSpellBonusDamage(4) .. ',FrostSpellCrit:' ..
                             GetSpellBonusDamage(5) .. ',ShadowSpellCrit:' ..
                             GetSpellBonusDamage(6) .. ',ArcaneSpellCrit:' ..
                             GetSpellBonusDamage(7) .. ',RangerCrit:' ..
                             GetRangedCritChance() .. ',Strength:' ..
                             statStrength .. '#' .. posBuffStrength .. '#' ..
                             negBuffStrength .. ',Agility:' .. statAgility ..
                             '#' .. posBuffAgility .. '#' .. negBuffAgility ..
                             ',Stamina:' .. statStamina .. '#' .. posBuffStamina ..
                             '#' .. negBuffStamina .. ',Intellect:' ..
                             statIntellect .. '#' .. posBuffIntellect .. '#' ..
                             negBuffIntellect .. ',Spirit:' .. statSpirit .. '#' ..
                             posBuffSpirit .. '#' .. negBuffSpirit ..
                             ',BlockChance:' .. GetBlockChance() .. '];';

    return exportString;
end

function EPIC:GetAddons()
    local addons = '[';
    for index = 1, GetNumAddOns() do
        local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(index)
            if enabled == nil == false and enabled then
                addons = addons .. name .. ',';
            end
    end
    addons = addons .. '];';
    return addons;
end
-- end region for character

-- region for bank
function EPIC:GetBags()
    local bags = {}
    for container = -1, 12 do
        bags[#bags + 1] = {
            container = container,
            bagName = GetBagName(container)
        }
    end
    return bags;
end

function EPIC:GetBagItems()
    local bagItems = {}

    for container = -1, 12 do
        local numSlots = GetContainerNumSlots(container)

        for slot = 1, numSlots do
            local texture, count, locked, quality, readable, lootable, link,
                  isFiltered, hasNoValue, itemID =
                GetContainerItemInfo(container, slot)

            if itemID then
                bagItems[#bagItems + 1] = {
                    container = container,
                    slot = slot,
                    itemID = itemID,
                    count = count
                }
            end
        end
    end

    return bagItems
end
-- end region for bank

-- region utils
function EPIC:DisplayExportString(exportString)

    local encoded = EPIC:Encode(exportString);
    local guid = EPIC:CreateGuid()
    local sign = LH.hmac(LH.sha256, guid, encoded)
    local cryptedData = EPIC:Encode(encoded .. guid .. sign)

    EPICFrame:Show();
    EPICFrameScroll:Show()
    EPICFrameScrollText:Show()
    EPICFrameScrollText:SetText(cryptedData)
    EPICFrameScrollText:HighlightText()

    EPICFrameButton:SetScript("OnClick", function(self) EPICFrame:Hide(); end);
end

function EPIC:DisplayExportStringWithoutCrypting(exportString)

    local encoded = EPIC:Encode(exportString);

    EPICFrame:Show();
    EPICFrameScroll:Show()
    EPICFrameScrollText:Show()
    EPICFrameScrollText:SetText(encoded)
    EPICFrameScrollText:HighlightText()

    EPICFrameButton:SetScript("OnClick", function(self) EPICFrame:Hide(); end);
end

local extract = _G.bit32 and _G.bit32.extract
if not extract then
    if _G.bit then
        local shl, shr, band = _G.bit.lshift, _G.bit.rshift, _G.bit.band
        extract = function(v, from, width)
            return band(shr(v, from), shl(1, width) - 1)
        end
    elseif _G._VERSION >= "Lua 5.3" then
        extract = load [[return function( v, from, width )
			return ( v >> from ) & ((1 << width) - 1)
		end]]()
    else
        extract = function(v, from, width)
            local w = 0
            local flag = 2 ^ from
            for i = 0, width - 1 do
                local flag2 = flag + flag
                if v % flag2 >= flag then w = w + 2 ^ i end
                flag = flag2
            end
            return w
        end
    end
end

local char, concat = string.char, table.concat

function EPIC:MakeEncoder(s62, s63, spad)
    local encoder = {}
    for b64code, char in pairs {
        [0] = 'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z',
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
        'h',
        'i',
        'j',
        'k',
        'l',
        'm',
        'n',
        'o',
        'p',
        'q',
        'r',
        's',
        't',
        'u',
        'v',
        'w',
        'x',
        'y',
        'z',
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        s62 or '+',
        s63 or '/',
        spad or '='
    } do encoder[b64code] = char:byte() end
    return encoder
end

function EPIC:Encode(str)
    encoder = EPIC:MakeEncoder()
    local t, k, n = {}, 1, #str
    local lastn = n % 3
    for i = 1, n - lastn, 3 do
        local a, b, c = str:byte(i, i + 2)
        local v = a * 0x10000 + b * 0x100 + c

        t[k] = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)],
                    encoder[extract(v, 6, 6)], encoder[extract(v, 0, 6)])
        k = k + 1
    end
    if lastn == 2 then
        local a, b = str:byte(n - 1, n)
        local v = a * 0x10000 + b * 0x100
        t[k] = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)],
                    encoder[extract(v, 6, 6)], encoder[64])
    elseif lastn == 1 then
        local v = str:byte(n) * 0x10000
        t[k] = char(encoder[extract(v, 18, 6)], encoder[extract(v, 12, 6)],
                    encoder[64], encoder[64])
    end
    return concat(t)
end

function EPIC:CreateGuid()
    local random = math.random;
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx';

    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb);
        return string.format('%x', v);
    end);
end
-- end region utils
