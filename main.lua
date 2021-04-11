WGM = LibStub("AceAddon-3.0"):NewAddon("WGM", "AceConsole-3.0", "AceEvent-3.0")

local defaults = {char = {deposits = {}, history = {}}}

function WGM:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WGMDb", defaults)

    WGM:RegisterChatCommand('wgm', 'HandleChatCommand');
end

function WGM:HandleChatCommand(input)

    -- local slotId, textureName = GetInventorySlotInfo("HEADSLOT")
    -- print(slotId)
    -- local alertStatus = GetInventoryAlertStatus(slotId);
    -- print(alertStatus);

    -- local mainHandLink = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
    -- local a, b, c, d, e, f, itemType = GetItemInfo(mainHandLink)
    -- print(a);
    -- print(b);
    -- print(c);
    -- DEFAULT_CHAT_FRAME:AddMessage(itemType)

    local stuffExtracted = WGM:ExtractStuff();
    local weaponEnch = GetWeaponEnchantInfo();
    print(weaponEnch);

    local bags = WGM:GetBags()
    local bagItems = WGM:GetBagItems()

    local exportString = '['..UnitName('player')..','..GetLocale()..'];'

    exportString = exportString .. '['

    for i = 1, #stuffExtracted do
        if i > 1 then exportString = exportString .. '#' end

        exportString = exportString .. stuffExtracted[i].slotName .. ','

        if stuffExtracted[i].link == nil == false then
            exportString = exportString .. stuffExtracted[i].link
        end
    end

    exportString = exportString .. '];'

    WGM:DisplayExportString(exportString)
end

function WGM:ExtractStuff()
    local slotNames = { "HeadSlot", "NeckSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot", 
                        "WaistSlot", "LegsSlot", "FeetSlot", "WristSlot", "HandsSlot",
                        "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
                        "BackSlot", "MainHandSlot", "SecondaryHandSlot" }
    local stuffItems = { };

    for slotCount = 1, 17 do
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

function WGM:GetBags()
    local bags = {}

    for container = -1, 12 do
        bags[#bags + 1] = {
            container = container,
            bagName = GetBagName(container)
        }
    end

    return bags;
end

function WGM:GetBagItems()
    local bagItems = {}

    for container = -1, 12 do
        local numSlots = GetContainerNumSlots(container)

        for slot = 1, numSlots do
            local texture, count, locked, quality, readable, lootable, link,
                  isFiltered, hasNoValue, itemID =
                GetContainerItemInfo(container, slot)

            if itemID then
                bagItems[#bagItems + 1] =
                    {
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

function WGM:DisplayExportString(exportString)

    local encoded = WGM:encode(exportString);

    CgbFrame:Show();
    CgbFrameScroll:Show()
    CgbFrameScrollText:Show()
    CgbFrameScrollText:SetText(encoded)
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
