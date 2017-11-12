--------------------------------------
-- 다국어 전역 변수
--------------------------------------
L = TRADELEVEL_L;

--------------------------------------
-- 단축키 변수
--------------------------------------
BINDING_HEADER_TRADELEVEL = L["Trade Level"];
BINDING_NAME_TRADELEVEL_TOGGLE = L["Show/Hide"];

local spellName;
local spellId;

--------------------------------------
-- 애드온 로드 시
--------------------------------------
function TradeLevel_OnLoad(self)
    self:RegisterEvent("UNIT_SPELLCAST_START");
    self:RegisterEvent("UNIT_SPELLCAST_STOP");
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
end

--------------------------------------
-- 이벤트 발생 시
--------------------------------------
function TradeLevel_OnEvent(self, event, ...)
    --print(event);
    spellName = select(2, ...);
    spellId = select(5, ...);
    --print(spellName.."("..spellId..")");

    if (spellId == 3564 or spellId == 131476) then -- 채광, 낚시
        if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START") then
            TradeLevel_Show();
        elseif (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP") then
            TradeLevel_Hide();
        end
    end
end

------------------------------------
-- 애드온 보이기
------------------------------------
function TradeLevel_Show()
    local sName, sRank, sTexture, sCastTime, sMinRange, sMaxRange, sId = GetSpellInfo(spellId);

    -- 버튼 설정하기
    local button = TradeLevelSpellButton;
    button:SetAttribute("type", "spell");
    button:SetAttribute("spell", sName);
    button:SetAttribute("id", sId);
    button:SetNormalTexture(sTexture);

    -- 기술 이름 설정하기
    TradeLevelTitleText:SetText(sName);

    -- 기술 레벨 설정하기
    local prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions();
    local professions = {prof1, prof2, archaeology, fishing, cooking, firstAid};

    if (#professions > 0) then
        local pIndex = -1;
        for i = 1, #professions do
            local pName, pTexture, pLevel, pMaxLevel = GetProfessionInfo(professions[i]);
            if (pName == spellName) then
                --print("pName: "..pName);
                pIndex = professions[i];
            end
        end

        if (pIndex > -1) then
            local pName, pTexture, pLevel, pMaxLevel = GetProfessionInfo(pIndex);
            --pLevel = 7556;
            --pMaxLevel = 3980;
            TradeLevelCurrentText:SetText(pLevel);
            TradeLevelMaxText:SetText("/"..pMaxLevel);
            if (pMaxLevel >= 1000) then
                TradeLevelFrame:SetWidth(140);
            end
        end
    end

    ShowUIPanel(TradeLevelFrame);
end

function TradeLevel_Hide()
    HideUIPanel(TradeLevelFrame);
end

--------------------------------------
-- "보이기/숨기기" 단축키 눌렀을 때
--------------------------------------
function TradeLevel_ToggleKey_OnPress()
    if (TradeLevelFrame:IsVisible()) then
        TradeLevel_Hide();
    else
        ShowUIPanel(TradeLevelFrame);
    end
end

--------------------------------------
-- "닫기"" 버튼 클릭 시
--------------------------------------
function TradeLevelCloseButton_OnClick()
    TradeLevel_Hide();
end