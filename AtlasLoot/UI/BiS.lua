-- AtlasLoot-CoA native-style BiS browser for 3.3.5a.
-- Uses the existing three dropdown widgets and the right-hand navigation column.
local AL = LibStub("AceAddon-3.0"):GetAddon("AtlasLoot")
AL.CoABiS = AL.CoABiS or {[1]={},[2]={}}
local slots = {"All Slots","Head","Neck","Shoulder","Back","Chest","Wrist","Hands","Waist","Legs","Feet","Finger","Trinket","Main Hand","Off Hand","Two-Hand","Ranged","Relic"}
local function keys(t)
 local a={} for k in pairs(t or {}) do a[#a+1]=k end table.sort(a) return a
end
local function drop(al, anchor, heading, entries, choose)
 local menu={{{text=heading,isTitle=true}}}
 for _,v in ipairs(entries) do
  local value=v
  table.insert(menu[1],{text=tostring(v),func=function() choose(value) end})
 end
 al:OpenDewdropMenu(anchor,menu)
end
local function normalize(slot)
 local s=string.lower(tostring(slot or ""))
 s=s:gsub(" #%d+", "")
 local aliases={shoulders="shoulder",wrists="wrist",rings="finger",ring="finger",trinkets="trinket",weapons="main hand",cloak="back"}
 return aliases[s] or s
end
function AL:InitializeCoABiS()
 local pane=self.ui.tabs.BiS
 if pane.bisReady then return end
 pane.bisReady=true
 self.db.profile.CoABiSSelection = self.db.profile.CoABiSSelection or {}
 local saved=self.db.profile.CoABiSSelection
 pane.phase=tonumber(saved.phase) or 1
 pane.class=saved.class; pane.spec=saved.spec
 pane.slot=saved.slot or "All Slots"; pane.page=1
 -- The BiS tab owns only the normal left-hand loot area. No full-window overlay.
 pane:ClearAllPoints()
 pane:SetPoint("TOPLEFT",self.ui.tabs.Loot,"TOPLEFT")
 pane:SetSize(770,515)
 pane:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",tile=true,tileSize=16,edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=16,insets={left=4,right=4,top=4,bottom=4}})
 local title=pane:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
 title:SetPoint("TOPLEFT",18,-18);title:SetText("Conquest Reborn - Best in Slot")
 local summary=pane:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
 summary:SetPoint("TOPLEFT",18,-44);summary:SetWidth(715);summary:SetJustifyH("LEFT")
 local header=pane:CreateFontString(nil,"OVERLAY","GameFontNormal")
 header:SetPoint("TOPLEFT",18,-75);header:SetText("Ranked gear candidates (hover for in-game tooltip)")
 local rows={}
 for i=1,30 do
  local b=CreateFrame("Button",nil,pane)
  b:SetSize(342,25)
  local column=math.floor((i-1)/15)
  local line=(i-1)%15
  b:SetPoint("TOPLEFT",18+column*355,-92-line*25)
  local icon=b:CreateTexture(nil,"ARTWORK")
  icon:SetSize(23,23);icon:SetPoint("LEFT",2,0);b.icon=icon
  local label=b:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  label:SetPoint("LEFT",icon,"RIGHT",8,0);label:SetWidth(305);label:SetJustifyH("LEFT");b.label=label
  b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
  b:SetScript("OnEnter",function(btn)
   if btn.itemID then GameTooltip:SetOwner(btn,"ANCHOR_RIGHT");GameTooltip:SetHyperlink("item:"..btn.itemID);GameTooltip:Show() end
  end)
  b:SetScript("OnLeave",function()GameTooltip:Hide()end)
  rows[i]=b
 end
 local pageText=pane:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
 pageText:SetPoint("BOTTOM",0,12)
 local prev=CreateFrame("Button",nil,pane,"UIPanelButtonTemplate")
 prev:SetSize(40,22);prev:SetPoint("RIGHT",pageText,"LEFT",-20,0);prev:SetText("<")
 local nextB=CreateFrame("Button",nil,pane,"UIPanelButtonTemplate")
 nextB:SetSize(40,22);nextB:SetPoint("LEFT",pageText,"RIGHT",20,0);nextB:SetText(">")
 prev:SetScript("OnClick",function()pane.page=math.max(1,pane.page-1);pane.refresh()end)
 nextB:SetScript("OnClick",function()pane.page=pane.page+1;pane.refresh()end)
 -- Right column: slot navigation, replacing the difficulty and boss list while BiS is active.
 local right=CreateFrame("Frame",nil,self.ui)
 right:SetPoint("TOPLEFT",self.ui.difficultyScrollFrame,"TOPLEFT",0,0)
 right:SetSize(265,480);right:SetFrameStrata("HIGH")
 right:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",edgeSize=16,insets={left=4,right=4,top=4,bottom=4}})
 local slotTitle=right:CreateFontString(nil,"OVERLAY","GameFontNormal")
 slotTitle:SetPoint("TOPLEFT",12,-12);slotTitle:SetText("Equipment slots")
 local slotButtons={}
 for i,slot in ipairs(slots) do
  local b=CreateFrame("Button",nil,right)
  b:SetSize(238,22);b:SetPoint("TOPLEFT",12,-30-(i-1)*23)
  local txt=b:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
  txt:SetPoint("LEFT",4,0);txt:SetText(slot);b.txt=txt
  b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
  b:SetScript("OnClick",function()pane.slot=slot;pane.page=1;pane.refresh()end)
  slotButtons[i]=b
 end
 pane.right=right
 local function setDropdowns()
  self.ui.moduelMenuButton:SetText("Phase "..pane.phase)
  self.ui.moduelMenuButton.Lable:SetText("Select Phase")
  self.ui.submenuButton:SetText(pane.class or "Select Class")
  self.ui.submenuButton.Lable:SetText("Select Class")
  self.ui.expansionMenuButton:SetText(pane.spec or "Select Specialization")
  self.ui.expansionMenuButton.Lable:SetText("Select Specialization")
 end
 function pane.refresh()
  local classes=keys(AL.CoABiS[pane.phase]);local valid=false
  for _,v in ipairs(classes) do if v==pane.class then valid=true end end
  if not valid then pane.class=classes[1];pane.spec=nil end
  local specs=keys((AL.CoABiS[pane.phase] or {})[pane.class]);valid=false
  for _,v in ipairs(specs) do if v==pane.spec then valid=true end end
  if not valid then pane.spec=specs[1] end
  local all=(((AL.CoABiS[pane.phase] or {})[pane.class] or {})[pane.spec]) or {}
  local filtered={}
  for _,item in ipairs(all) do
   if pane.slot=="All Slots" or normalize(item.slot)==normalize(pane.slot) then filtered[#filtered+1]=item end
  end
  local maxPage=math.max(1,math.ceil(#filtered/#rows))
  pane.page=math.min(pane.page,maxPage)
  for i,b in ipairs(rows) do
   local item=filtered[(pane.page-1)*#rows+i]
   b.itemID=nil;b:SetShown(item~=nil)
   if item then
    local id=tonumber(item.id);b.itemID=id
    b.icon:SetTexture((id and GetItemIcon(id)) or "Interface\\Icons\\INV_Misc_QuestionMark")
    b.label:SetText("|cffa335ee"..(item.name or (id and "Item "..id or "Unknown")).."|r")
   end
  end
  local saved=self.db.profile.CoABiSSelection
  saved.phase=pane.phase; saved.class=pane.class; saved.spec=pane.spec; saved.slot=pane.slot
  summary:SetText("Phase "..pane.phase.."  |  "..(pane.class or "No class data").." / "..(pane.spec or "No spec data").."  |  "..pane.slot.."  |  "..#filtered.." items")
  pageText:SetText(pane.page.." / "..maxPage)
  for i,b in ipairs(slotButtons) do b.txt:SetText((pane.slot==slots[i] and "|cffffd100> " or "")..slots[i].."|r") end
  setDropdowns()
 end
 pane.openMenus=function()
  self.ui.moduelMenuButton:SetScript("OnClick",function()
   drop(self,self.ui.moduelMenuButton,"Phase",{"Phase 1","Phase 2"},function(v)
    pane.phase=tonumber(string.match(v,"%d+")) or 1;pane.class=nil;pane.spec=nil;pane.page=1;pane.refresh()
   end)
  end)
  self.ui.submenuButton:SetScript("OnClick",function()
   drop(self,self.ui.submenuButton,"Class",keys(AL.CoABiS[pane.phase]),function(v)
    pane.class=v;pane.spec=nil;pane.page=1;pane.refresh()
   end)
  end)
  self.ui.expansionMenuButton:SetScript("OnClick",function()
   drop(self,self.ui.expansionMenuButton,"Specialization",keys(AL.CoABiS[pane.phase][pane.class] or {}),function(v)
    pane.spec=v;pane.page=1;pane.refresh()
   end)
  end)
 end
 pane.refresh()
 right:Hide()
end
function AL:LeaveCoABiS()
 local pane=self.ui and self.ui.tabs and self.ui.tabs.BiS
 if not pane or not pane.bisReady then return end
 pane:Hide();pane.right:Hide()
 self.ui.moduelMenuButton.Lable:SetText("Select Module")
 self.ui.submenuButton.Lable:SetText("Select Category")
 self.ui.expansionMenuButton.Lable:SetText("Select Expansion")
 self.ui.moduelMenuButton:SetScript("OnClick",function()self:ModuleMenuOpen()end)
 self.ui.submenuButton:SetScript("OnClick",function()if self.currentTable and self.ui.menus.collection[self.currentTable] then self:SubMenuOpen(self.ui.menus.collection[self.currentTable]) end end)
 self.ui.expansionMenuButton:SetScript("OnClick",function(btn)self:ExpansionMenuOpen(btn)end)
 self.ui.expansionMenuButton:SetText(self.ui.menus.expansion[GetAccountExpansionLevel()+1][1])
 self.ui.moduelMenuButton:SetText("Select Loot Table")
 self.ui.submenuButton:SetText("Select Category")
 self.ui.difficultyScrollFrame:Show()
 if self.ui.tabs.Loot.TableScrollFrame then self.ui.tabs.Loot.TableScrollFrame:Show() end
end
function AL:ShowCoABiSTab()
 self:InitializeCoABiS()
 self.ui.tabs.currentTab="BiS"
 for _,name in ipairs({"Loot","Map","Search","Wishlist"}) do self.ui.tabs[name]:Hide() end
 self.itemframe:Hide()
 self.ui.difficultyScrollFrame:Hide()
 -- This frame is a child of the main window, NOT the Loot tab.
 -- Hiding Loot alone leaves the old boss list visible above the BiS slots.
 self.ui.tabs.Loot.TableScrollFrame:Hide()
 self.ui.tabs.BiS:Show()
 self.ui.tabs.BiS.right:Show()
 self.ui.tabs.BiS.openMenus()
 self.ui.tabs.BiS.refresh()
end
