WGM = LibStub("AceAddon-3.0"):NewAddon("WGM", "AceConsole-3.0", "AceEvent-3.0")

local tradeSkills = {}
local LH = LibStub("LibHash-1.0")

function WGM:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WGMDb", defaults)
    WGM:RegisterEvent('TRADE_SKILL_SHOW', 'HandleTradeSkillFrame')
    WGM:RegisterEvent('TRADE_SKILL_UPDATE', 'HandleTradeSkillFrame')
    WGM:RegisterChatCommand('wgm', 'HandleChatCommand');
end

function WGM:HandleChatCommand(input)

    local stuffExtracted = WGM:ExtractStuff();
    local exportString =
        '[' .. UnitName('player') .. ',' .. UnitLevel('player') .. ',' ..
            UnitRace('player') .. ',' .. UnitSex('player') .. ',' ..
            UnitClass('player') .. ',' .. GetLocale() .. '];'

    exportString = exportString .. WGM:ExportStuff() .. WGM:ExportTalents() ..
                       WGM:ExportTradeSkill() .. WGM:ExportReputation()

    WGM:DisplayExportString(exportString)
end

function WGM:ExportReputation()
    local exportString = "["
    for i = 1, GetNumFactions() do
        name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild =
            GetFactionInfo(i)
        if isHeader == false then
            exportString =
                exportString .. '' .. name .. ',' .. topValue .. ',' ..
                    earnedValue .. '#'
        end
    end
    exportString = exportString .. "];"
    return exportString
end

function WGM:ExportTradeSkill()

    local exportString = "["
    for key, value in pairs(tradeSkills) do
        exportString = exportString .. value .. '*'
    end
    exportString = exportString .. "];"
    return exportString
end

function WGM:ExportTalents()
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

function WGM:ExportStuff()
    local stuffExtracted = WGM:ExtractStuff();
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

function WGM:HandleTradeSkillFrame()
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

function WGM:ExtractStuff()
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

function WGM:DisplayExportString(exportString)

    local encoded = WGM:encode(exportString);
    local guid = WGM:CreateGuid()
    local sign = LH.hmac(LH.sha256, guid, encoded)
    local cryptedData = WGM:encode(encoded .. guid .. sign)

    CgbFrame:Show();
    CgbFrameScroll:Show()
    CgbFrameScrollText:Show()
    CgbFrameScrollText:SetText(cryptedData)
    CgbFrameScrollText:HighlightText()

    CgbFrameButton:SetScript("OnClick", function(self) CgbFrame:Hide(); end);
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

function WGM:makeencoder(s62, s63, spad)
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

function WGM:encode(str)
    encoder = WGM:makeencoder()
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

function WGM:CreateGuid()
    local random = math.random;
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx';

    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb);
        return string.format('%x', v);
    end);
end
