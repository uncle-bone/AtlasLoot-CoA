-- AtlasLoot-CoA BiS browser. WoW 3.3.5a compatible; data is deliberately source-backed.
local AL = LibStub("AceAddon-3.0"):GetAddon("AtlasLoot")
AL.CoABiS = AL.CoABiS or { [1] = {}, [2] = {} }
local function sortedKeys(t)
 local keys = {}; for k in pairs(t or {}) do keys[#keys+1] = k end
 table.sort(keys); return keys
end
local function button(parent, text, width, height, onClick)
 local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
 b:SetSize(width,height); b:SetText(text); b:SetScript("OnClick",onClick); return b
end
function AL:InitializeCoABiS()
 local pane = self.ui.tabs.BiS
 if pane.initialized then return end
 pane.initialized = true
 pane:SetPoint("TOPLEFT",self.ui,"TOPLEFT",24,-70)
 pane:SetSize(1040,510)
 local title=pane:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
 title:SetPoint("TOPLEFT",12,-12);title:SetText("Conquest Reborn - Best in Slot")
 local status=pane:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
 status:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-10)
 status:SetText("Source-backed gear only. Missing lists are not invented.")
 local phase=1;local class;local spec;local page=1
 local phaseButtons={}
 local classButtons={};local specButtons={};local itemButtons={}
 local phaseText=pane:CreateFontString(nil,"OVERLAY","GameFontNormal")
 phaseText:SetPoint("TOPLEFT",12,-75);phaseText:SetText("Phase")
 for p=1,2 do
  local index=p
  local b=button(pane,"Phase "..p,95,25,function()phase=index;class=nil;spec=nil;page=1;pane.refresh()end)
  b:SetPoint("TOPLEFT",12+(p-1)*102,-94);phaseButtons[p]=b
 end
 local classLabel=pane:CreateFontString(nil,"OVERLAY","GameFontNormal")
 classLabel:SetPoint("TOPLEFT",12,-133);classLabel:SetText("Class")
 local specLabel=pane:CreateFontString(nil,"OVERLAY","GameFontNormal")
 specLabel:SetPoint("TOPLEFT",185,-133);specLabel:SetText("Specialization")
 local gearLabel=pane:CreateFontString(nil,"OVERLAY","GameFontNormal")
 gearLabel:SetPoint("TOPLEFT",400,-133);gearLabel:SetText("Recommended items (hover for tooltip)")
 for i=1,14 do
  local index=i
  local b=button(pane,"",162,22,function()local keys=sortedKeys(AL.CoABiS[phase]);class=keys[index];spec=nil;page=1;pane.refresh()end)
  b:SetPoint("TOPLEFT",12,-151-(i-1)*23);classButtons[i]=b
 end
 for i=1,14 do
  local index=i
  local b=button(pane,"",203,22,function()local keys=sortedKeys(AL.CoABiS[phase][class] or {});spec=keys[index];page=1;pane.refresh()end)
  b:SetPoint("TOPLEFT",185,-151-(i-1)*23);specButtons[i]=b
 end
 for i=1,12 do
  local b=CreateFrame("Button",nil,pane)
  b:SetSize(590,25);b:SetPoint("TOPLEFT",400,-151-(i-1)*27)
  local label=b:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  label:SetPoint("LEFT",4,0);label:SetWidth(580);label:SetJustifyH("LEFT")
  b.label=label
  b:SetScript("OnEnter",function(self)
   if self.itemID then GameTooltip:SetOwner(self,"ANCHOR_RIGHT");GameTooltip:SetHyperlink("item:"..self.itemID);GameTooltip:Show() end
  end)
  b:SetScript("OnLeave",function()GameTooltip:Hide()end)
  itemButtons[i]=b
 end
 local pageLabel=pane:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
 pageLabel:SetPoint("BOTTOMRIGHT",-90,8)
 local prev=button(pane,"<",35,22,function()page=math.max(1,page-1);pane.refresh()end)
 prev:SetPoint("BOTTOMRIGHT",-145,4)
 local nextB=button(pane,">",35,22,function()page=page+1;pane.refresh()end)
 nextB:SetPoint("BOTTOMRIGHT",-40,4)
 function pane.refresh()
  local classes=sortedKeys(AL.CoABiS[phase]);class=class or classes[1]
  local specs=sortedKeys(AL.CoABiS[phase][class] or {});spec=spec or specs[1]
  for i,b in ipairs(classButtons) do local v=classes[i];b:SetShown(v~=nil);if v then b:SetText(v) end end
  for i,b in ipairs(specButtons) do local v=specs[i];b:SetShown(v~=nil);if v then b:SetText(v) end end
  local items=(AL.CoABiS[phase][class] or {})[spec] or {}
  local maxPage=math.max(1,math.ceil(#items/12));page=math.min(page,maxPage)
  for i,b in ipairs(itemButtons) do
   local entry=items[(page-1)*12+i]
   b:SetShown(entry~=nil);b.itemID=nil
   if entry then
    local id=tonumber(entry.id)
    b.itemID=id
    b.label:SetText((entry.slot or "Gear").."  |cff00ffcc"..(entry.name or (id and ("Item "..id) or "Unknown")).."|r"..(entry.source and ("  - "..entry.source) or ""))
   end
  end
  pageLabel:SetText(page.." / "..maxPage)
  status:SetText(#classes==0 and "No verified Phase "..phase.." lists installed yet. See UI/CoABiS_Data.lua." or ("Phase "..phase.." | "..(class or "").." - "..(spec or "").." | "..#items.." entries"))
 end
 pane.refresh()
end
function AL:ShowCoABiSTab()
 self:InitializeCoABiS()
 self.ui.tabs.BiS.refresh()
end
