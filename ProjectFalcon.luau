-- Envy v1: standalone entry point. Run this file to cache this exact version.
local source = [====[
-- Falcon
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/corapsez-ctrl/quantumware/main/bedwars.luau"))()
-- Right Shift toggles the menu.

local cloneref = cloneref or function(v)
	return v
end

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local Lighting = cloneref(game:GetService("Lighting"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local TweenService = cloneref(game:GetService("TweenService"))
local VirtualInput
pcall(function()
	VirtualInput = cloneref(game:GetService("VirtualInputManager"))
end)

local HttpService=cloneref(game:GetService("HttpService"))
local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local dbg = (type(debug) == "table" and debug) or {}

local function parentGui()
	local ok, hui = pcall(function()
		return gethui()
	end)
	if ok and typeof(hui) == "Instance" then
		return hui
	end
	local pg = lp and (lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui"))
	if pg then
		return pg
	end
	if lp then
		local waited = lp:WaitForChild("PlayerGui", 5)
		if waited then
			return waited
		end
	end
	if syn and syn.protect_gui then
		local ok2, core = pcall(function()
			return game:GetService("CoreGui")
		end)
		if ok2 then
			return core
		end
	end
end

local function notify(text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Falcon",
			Text = text,
			Duration = 5,
		})
	end)
	print("[Falcon] " .. text)
end

local Life = { active=true, connections={}, resources={}, cleanups={}, jobId=game.JobId, placeId=game.PlaceId }
do
	local env = type(getgenv)=="function" and getgenv() or _G
	local previous=env.EnvyV1Runtime or env.QuantumwareRuntime
	if type(previous)=="table" and type(previous.Destroy)=="function" then pcall(previous.Destroy) end
	env.QuantumwareRuntime=nil
	Life.environment=env
	env.EnvyV1Runtime=Life
end
function Life.connect(signal,callback)
	local connection=signal:Connect(function(...)
		if Life.active then return callback(...) end
	end)
	table.insert(Life.connections,connection)
	return connection
end
Life.connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function() cam = workspace.CurrentCamera end)

local bootLabel
pcall(function()
	local host
	local ok, hui = pcall(gethui)
	if ok and typeof(hui) == "Instance" then
		host = hui
	end
	if not host and lp then
		host = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
	end
	if not host then
		host = game:GetService("CoreGui")
	end
	local g = Instance.new("ScreenGui")
	g.Name = "EnvyV1Boot"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.DisplayOrder = 999999
	g.Parent = host
	local t = Instance.new("TextLabel")
	t.Name = "Text"
	t.BackgroundColor3 = Color3.new(0, 0, 0)
	t.BackgroundTransparency = 0.15
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 14
	t.Size = UDim2.fromOffset(260, 28)
	t.Position = UDim2.new(0, 16, 1, -48)
	t.Text = "Project Falcon loading"
	t.Parent = g
	bootLabel = g
end)

local function boot()
pcall(function()
	RunService:UnbindFromRenderStep("QW_Sign")
	RunService:UnbindFromRenderStep("QW_Avatar")
	local oldSign = workspace:FindFirstChild("QW_Sign")
	if oldSign then
		oldSign:Destroy()
	end
end)
pcall(function()
	Life.connect(RunService.Heartbeat, function()
		local oldSign = workspace:FindFirstChild("QW_Sign")
		if oldSign then
			oldSign:Destroy()
		end
	end)
end)
local function click(btn)
	btn = btn or 0
	pcall(function()
		if btn == 0 and mouse1click then
			mouse1click()
		elseif btn == 1 and mouse2click then
			mouse2click()
		elseif VirtualInput then
			local p = UserInputService:GetMouseLocation()
			VirtualInput:SendMouseButtonEvent(p.X, p.Y, btn, true, game, 0)
			VirtualInput:SendMouseButtonEvent(p.X, p.Y, btn, false, game, 0)
		end
	end)
end

local function char()
	return lp.Character
end

local function root()
	local c = char()
	return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart)
end

local function hum()
	local c = char()
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function teamOf(player)
	if player then
		local t = player:GetAttribute("Team")
		if t ~= nil then
			return tostring(t)
		end
		if player.Team then
			return player.Team.Name
		end
	end
end

local function enemy(player)
	return player and player ~= lp and teamOf(player) ~= teamOf(lp)
end

local TEAM_COLORS = {
	Red = Color3.fromRGB(255, 88, 88),
	Blue = Color3.fromRGB(80, 160, 255),
	Green = Color3.fromRGB(90, 220, 120),
	Yellow = Color3.fromRGB(255, 220, 80),
	Orange = Color3.fromRGB(255, 160, 60),
	Pink = Color3.fromRGB(255, 130, 200),
	Cyan = Color3.fromRGB(70, 230, 230),
	White = Color3.fromRGB(240, 240, 245),
	Purple = Color3.fromRGB(170, 120, 255),
}

local function colorOf(player)
	local t = teamOf(player)
	return (t and TEAM_COLORS[t]) or Color3.fromRGB(255, 90, 90)
end

local BW
local function kitOf(player)
	for _, owner in ipairs({ player, player.Character }) do
		for _, k in ipairs({ "PlayingAsKit", "PlayingAsKits" }) do
			local v = owner:GetAttribute(k)
			if type(v) == "string" then
				return v ~= "none" and v or ""
			end
		end
	end
	if player == lp and BW and BW.store then
		local ok, state = pcall(function() return BW.store:getState() end)
		local id = ok and type(state) == "table" and type(state.Bedwars) == "table" and state.Bedwars.kit
		if type(id) == "string" then return id ~= "none" and id or "" end
	end
	return ""
end

local kitMetadata, kitMetadataAt = nil, -math.huge
local function kitName(id)
	if id == "" then return "" end
	if not kitMetadata and os.clock() - kitMetadataAt >= 2 then
		kitMetadataAt = os.clock()
		local ok, result = pcall(function()
			return require(ReplicatedStorage.TS.games.bedwars.kit["bedwars-kit-meta"]).BedwarsKitMeta
		end)
		if ok and type(result) == "table" then kitMetadata = result end
	end
	local meta = kitMetadata and kitMetadata[id]
	if type(meta) == "table" and type(meta.name) == "string" then return meta.name end
	-- Known public names while the game metadata is still loading. Never title-case an internal ID.
	return ({ angel = "Lumen", wind_walker = "Zephyr" })[id] or ""
end

local function kitImage(id)
	kitName(id) -- Loads the same metadata used for the display name.
	local meta=kitMetadata and kitMetadata[id]
	local image=meta and (meta.renderImage or meta.image or meta.icon)
	if type(image)=="number" then return "rbxassetid://" .. tostring(image) end
	return type(image)=="string" and image or ""
end

local Modules
BW = {
	ready = false,
	knit = nil,
	client = nil,
	store = nil,
	sword = nil,
	attack = nil,
	sprint = nil,
	breaker = nil,
	knockback = nil,
	query = nil,
	itemMeta = nil,
}

local function dumpRemote(fn)
	if type(dbg.getconstants) ~= "function" then
		return
	end
	local ok, consts = pcall(dbg.getconstants, fn)
	if not ok or type(consts) ~= "table" then
		return
	end
	for i, v in ipairs(consts) do
		if v == "Client" then
			return consts[i + 1]
		end
	end
	for _, v in ipairs(consts) do
		if type(v) == "string" and (string.find(v, "Sword", 1, true) or string.find(v, "attack", 1, true) or string.find(v, "swing", 1, true)) then
			return v
		end
	end
end

local hookRankRemotes, hookSwing, hookFall

local function hookKnit()
	local started = os.clock()
	while Life.active and os.clock() - started < 20 do
		local knit
		pcall(function()
			local setup = require(lp.PlayerScripts.TS.knit).setup
			if type(dbg.getupvalue) == "function" then
				knit = dbg.getupvalue(setup, 9)
			end
		end)
		if not knit then
			pcall(function()
				knit = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"].knit.src.Knit.KnitClient)
			end)
		end
		if knit then
			pcall(function()
				if type(dbg.getupvalue) == "function" and knit.Start and not dbg.getupvalue(knit.Start, 1) then
					repeat
						task.wait()
					until not Life.active or dbg.getupvalue(knit.Start, 1) or os.clock() - started > 20
				end
			end)
			BW.knit = knit
			BW.sword = knit.Controllers and knit.Controllers.SwordController
			BW.sprint = knit.Controllers and knit.Controllers.SprintController
			BW.breaker = knit.Controllers and knit.Controllers.BlockBreakController
			BW.blockController = knit.Controllers and knit.Controllers.BlockController
			BW.placer = knit.Controllers and knit.Controllers.BlockPlacementController
			BW.emote = knit.Controllers and (knit.Controllers.EmoteController or knit.Controllers.EmotesController)
			pcall(function()
				BW.client = require(ReplicatedStorage.TS.remotes).default.Client
			end)
			pcall(function()
				local entity=require(ReplicatedStorage.TS.entity.entities["inventory-entity"]).InventoryEntity
				local proto=type(dbg.getproto)=="function" and dbg.getproto(entity.equipItem,4)
					or type(dbg.getprotos)=="function" and dbg.getprotos(entity.equipItem)[4]
				if proto then BW.equipRemote=dumpRemote(proto) end
			end)
			pcall(function()
				BW.store = require(lp.PlayerScripts.TS.ui.store).ClientStore
			end)
			pcall(function()
				BW.knockback = require(ReplicatedStorage.TS.damage["knockback-util"]).KnockbackUtil
			end)
			pcall(function()
				BW.query = require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["game-core"].out).GameQueryUtil
			end)
			pcall(function()
				local getItemMeta = require(ReplicatedStorage.TS.item["item-meta"]).getItemMeta
				BW.getItemMeta = getItemMeta
				if type(dbg.getupvalue) == "function" then
					BW.itemMeta = dbg.getupvalue(getItemMeta, 1)
				end
			end)
			task.defer(function()
				pcall(hookFall)
			end)
			if BW.sword and BW.sword.sendServerRequest then
				BW.attack = dumpRemote(BW.sword.sendServerRequest)
			end
			if BW.breaker then
				for _, fn in pairs(BW.breaker) do
					if type(fn) == "function" then
						local name = dumpRemote(fn)
						if name and not BW.breakRemote then
							BW.breakRemote = name
						end
					end
				end
				if BW.breaker.blockBreaker then
					for _, fn in pairs(BW.breaker.blockBreaker) do
						if type(fn) == "function" and not BW.breakRemote then
							BW.breakRemote = dumpRemote(fn)
						end
					end
				end
			end
			BW.ready = BW.sword ~= nil or BW.client ~= nil
			pcall(function()
				if BW.sword and type(hookSwing) == "function" then
					hookSwing()
				end
			end)
			if hookRankRemotes then
				pcall(hookRankRemotes)
			end
			if BW.ready then return true end
		end
		task.wait(0.25)
	end
	return false
end

task.spawn(function()
	local ok = hookKnit()
	if not Life.active then return end
	notify(ok and "Bedwars hooks ready" or "Hooks missing - still running fallbacks")
end)

local function handTool()
	if BW.sword and type(BW.sword.getHandItem) == "function" then
		local ok, item = pcall(function()
			return BW.sword:getHandItem()
		end)
		if ok and item then
			return item.tool or item
		end
	end
	if BW.store then
		local ok, state = pcall(function()
			return BW.store:getState()
		end)
		if ok and state and state.Inventory and state.Inventory.observedInventory then
			local hand = state.Inventory.observedInventory.inventory.hand
			if hand then
				return hand.tool
			end
		end
	end
	local c = char()
	return c and c:FindFirstChildOfClass("Tool")
end

local function healthOf(model)
	if not model then
		return 0
	end
	local h = model:GetAttribute("Health")
	if type(h) == "number" then
		return h
	end
	local human = model:FindFirstChildOfClass("Humanoid")
	return human and human.Health or 0
end

local function nearest(range)
	local me = root()
	if not me then
		return
	end
	local best, bestRoot, bestDist
	local tagged = {}
	pcall(function()
		tagged = CollectionService:GetTagged("inventory-entity")
	end)
	if #tagged == 0 then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				table.insert(tagged, p.Character)
			end
		end
	end
	for _, model in ipairs(tagged) do
		local plr = Players:GetPlayerFromCharacter(model)
		local r = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
		if plr and enemy(plr) and r and healthOf(model) > 0 then
			local d = (r.Position - me.Position).Magnitude
			if d <= range and (not bestDist or d < bestDist) then
				best, bestRoot, bestDist = plr, r, d
			end
		end
	end
	return best, bestRoot, bestDist
end

local function look(world)
	if cam then
		cam.CFrame = CFrame.lookAt(cam.CFrame.Position, world)
	end
end

local function inventory()
	if not BW.store then
		return
	end
	local ok, state = pcall(function()
		return BW.store:getState()
	end)
	if ok and state and state.Inventory and state.Inventory.observedInventory then
		return state.Inventory.observedInventory.inventory
	end
end

local function metaOf(itemType)
	if not itemType then return end
	if type(BW.itemMeta) == "table" and BW.itemMeta[itemType] then return BW.itemMeta[itemType] end
	if type(BW.getItemMeta) == "function" then
		local ok, meta = pcall(BW.getItemMeta, itemType)
		if ok and type(meta) == "table" then return meta end
	end
end

local function isSword(item)
	if not item then
		return false
	end
	local meta = metaOf(item.itemType)
	if meta and meta.sword then
		return true
	end
	local n = string.lower(tostring(item.itemType or "") .. tostring(item.tool and item.tool.Name or ""))
	return string.find(n, "sword", 1, true) or string.find(n, "scythe", 1, true) or string.find(n, "dagger", 1, true) or string.find(n, "spear", 1, true)
end

local function equipSlot(slot)
	if not BW.store or slot == nil then
		return
	end
	pcall(function()
		BW.store:dispatch({
			type = "InventorySelectHotbarSlot",
			slot = slot,
		})
	end)
end

local function equipSword()
	local inv = inventory()
	if inv and inv.items then
		if isSword(inv.hand) then
			return inv.hand.tool
		end
		for slot, item in pairs(inv.items) do
			if isSword(item) then
				equipSlot(slot)
				return item.tool
			end
		end
	end
	return handTool()
end

local function breakerKind(item)
	if not item then return end
	local id,tool
	if typeof(item)=="Instance" then
		id=item:GetAttribute("itemType") or item:GetAttribute("ItemType") or item.Name
	elseif type(item)=="string" then id=item
	elseif type(item)=="table" then
		id=item.itemType or item.Name
		tool=item.tool
	end
	if not id or id=="" then id=tool and tool.Name end
	local name = string.lower(tostring(id or "")):gsub("[%s_%-]", "")
	if string.find(name, "pickaxe", 1, true) then return "stone" end
	if string.find(name, "shear", 1, true) then return "wool" end
	if string.find(name, "axe", 1, true) then return "wood" end
end

local function breakerDamage(item,kind)
	local toolKind=breakerKind(item)
	if not toolKind or (kind=="wood" and toolKind~="wood") then return 0 end
	local meta=metaOf(item.itemType)
	local damage=meta and meta.breakBlock and meta.breakBlock[kind]
	if type(damage)=="number" and damage>0 then return damage end
	-- Wool can still be mined with an axe or pickaxe when shears are absent.
	if toolKind==kind or (kind=="wool" and (toolKind=="wood" or toolKind=="stone")) then return 1 end
	return 0
end

local function holdingBreaker()
	local inv = inventory()
	local function classify(tool)
		if not tool then return end
		for _,item in pairs(inv and inv.items or {}) do
			if item.tool==tool then return breakerKind(item) end
		end
		return breakerKind(tool)
	end
	local model=char()
	local ref=model and model:FindFirstChild("HandInvItem")
	if ref and ref:IsA("ObjectValue") then
		if ref.Value then return classify(ref.Value),true end
		return nil,false
	end
	local equipped=model and type(model.FindFirstChildOfClass)=="function" and model:FindFirstChildOfClass("Tool")
	if equipped then return classify(equipped),true end
	local reported=handTool()
	return classify(reported) or breakerKind(inv and inv.hand),reported~=nil or (inv and inv.hand~=nil) or false
end

local miningEquip={at=-math.huge}
local function equipBreaker(kind)
	local inv=inventory()
	if not inv or not inv.items then return nil,false,"Inventory unavailable" end
	local hotbar=inv.hotbar
	if not hotbar and BW.store then
		local ok,state=pcall(function() return BW.store:getState() end)
		if ok then hotbar=state.Inventory and state.Inventory.observedInventory and state.Inventory.observedInventory.hotbar end
	end
	local best,bestDamage,bestSlot=nil,0,nil
	local function consider(item,slot)
		if type(item)~="table" or not breakerKind(item) then return end
		if kind=="wood" and breakerKind(item)~="wood" then return end
		local damage=breakerDamage(item,kind)
		if damage>bestDamage or (damage>0 and damage==bestDamage and breakerKind(item)==kind and breakerKind(best)~=kind) then best,bestDamage,bestSlot=item,damage,slot
		elseif best and item.itemType==best.itemType and slot~=nil then bestSlot=slot end
	end
	for _,item in pairs(inv.items) do consider(item) end
	for slot,entry in pairs(hotbar or {}) do consider(entry.item or entry,slot) end
	if not best then return nil,false,kind=="wood" and "No axe in inventory" or "No suitable mining tool in inventory" end
	local model=char()
	local ref=model and model:FindFirstChild("HandInvItem")
	local hasRef=ref and ref:IsA("ObjectValue")
	local live=hasRef and ref.Value
	local ready
	if hasRef then ready=live and (live==best.tool or live.Name==best.itemType)
	else ready=inv.hand and inv.hand.itemType==best.itemType end
	local wanted=best.tool or best.itemType
	if miningEquip.character~=model or miningEquip.item~=wanted then
		miningEquip.pending=nil
		miningEquip.at=-math.huge
		miningEquip.character=model
	end
	if ready then miningEquip.pending=nil;miningEquip.item=wanted;return wanted,true end
	if miningEquip.item~=wanted or os.clock()-miningEquip.at>=0.25 then
		if not miningEquip.pending or os.clock()-miningEquip.at>=2 then
			miningEquip.item,miningEquip.at=wanted,os.clock()
			if bestSlot~=nil then equipSlot(hotbar[0]~=nil and bestSlot or bestSlot-1) end
			if best.tool and BW.client and BW.equipRemote then
				local token={}
				miningEquip.pending=token
				local function done(result)
					if miningEquip.pending~=token then return end
					miningEquip.pending=nil
					if result~=false and Life.active and char()==model and best.tool.Parent and ref and ref.Parent then ref.Value=best.tool end
				end
				local ok,promise=pcall(function() return BW.client:Get(BW.equipRemote):CallServerAsync({hand=best.tool}) end)
				if ok and type(promise)=="table" and type(promise.andThen)=="function" then
					local chain=promise:andThen(done)
					if chain and type(chain.catch)=="function" then chain:catch(function() if miningEquip.pending==token then miningEquip.pending=nil end end) end
				elseif ok then done(promise) else miningEquip.pending=nil end
			end
		end
	end
	return wanted,false,bestSlot==nil and not BW.equipRemote and "Put the mining tool in your hotbar; equip adapter unavailable" or "Waiting for " .. best.itemType
end

local oldCanSee
local function setWalls(on)
	if not BW.sword or type(BW.sword.canSee) ~= "function" then
		return
	end
	if on and not oldCanSee then
		oldCanSee = BW.sword.canSee
		BW.sword.canSee = function()
			return true
		end
	elseif not on and oldCanSee then
		BW.sword.canSee = oldCanSee
		oldCanSee = nil
	end
end

local function setMissBypass(on)
	if not BW.sword or type(BW.sword.attackEntity) ~= "function" then
		return
	end
	pcall(function()
		dbg.setconstant(BW.sword.attackEntity, 58, on and "damage" or "multiHitCheckDurationSec")
	end)
end

local function lineOfSight(targetRoot)
	local me = root()
	if not me or not cam or not targetRoot then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = { char() }
	if targetRoot.Parent then
		table.insert(ignore, targetRoot.Parent)
	end
	params.FilterDescendantsInstances = ignore
	local delta = targetRoot.Position - cam.CFrame.Position
	return workspace:Raycast(cam.CFrame.Position, delta, params) == nil
end

local function inFov(targetRoot, degrees)
	if not cam or not targetRoot then
		return false
	end
	local delta = targetRoot.Position - cam.CFrame.Position
	if delta.Magnitude < 0.1 then
		return true
	end
	return cam.CFrame.LookVector:Dot(delta.Unit) >= math.cos(math.rad((degrees or 80) / 2))
end

local function pick(range, o)
	o = o or {}
	local me = root()
	if not me or healthOf(me.Parent) <= 0 then
		return
	end
	local best, bestRoot, bestScore, bestDist
	for _, plr in ipairs(Players:GetPlayers()) do
		local model = plr.Character
		local r = model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
		local hp = model and healthOf(model) or 0
		if plr ~= lp and r and r:IsA("BasePart") and model:IsDescendantOf(workspace) and not model:FindFirstChildOfClass("ForceField") and hp > 0 and (o.teams or enemy(plr)) then
			local d = (r.Position - me.Position).Magnitude
			local ok = d <= range
			if ok and o.screen then
				local point,onScreen
				if cam then point,onScreen=cam:WorldToViewportPoint(r.Position) end
				ok=onScreen==true and point.Z>0
			elseif ok and o.fov and o.fov < 360 then
				ok = inFov(r, o.fov)
			end
			if ok and o.visible then
				ok = lineOfSight(r)
			end
			if ok then
				local score = d
				if o.sort == "Health" then
					score = hp
				elseif o.sort == "Angle" and cam then
					local offset = r.Position - cam.CFrame.Position
					score = offset.Magnitude > 0.001 and -cam.CFrame.LookVector:Dot(offset.Unit) or -1
				end
				if not bestScore or score < bestScore or (score == bestScore and d < bestDist) then
					best, bestRoot, bestScore, bestDist = plr, r, score, d
				end
			end
		end
	end
	return best, bestRoot, bestDist
end

local attackRemote
local attackState = { targets = setmetatable({}, { __mode = "k" }), busy = false }
local function sendAttack(target, targetRoot, mode, cfg)
	cfg = cfg or {}
	local nuker=Modules and Modules.Nuker
	if cfg.switch~=false and nuker and nuker.enabled and nuker.miningTarget and nuker.miningTarget.Parent then
		return false,"Nuker is using the mining tool"
	end
	local me = root()
	local model = target and target.Character
	if not me or not model or not targetRoot or not targetRoot:IsA("BasePart")
		or not targetRoot:IsDescendantOf(model) or not model:IsDescendantOf(workspace)
		or healthOf(me.Parent) <= 0 or healthOf(model) <= 0
		or model:FindFirstChildOfClass("ForceField") then
		return false
	end
	if cfg.range and (targetRoot.Position - me.Position).Magnitude > cfg.range then
		return false
	end
	if cfg.visible and not lineOfSight(targetRoot) then
		return false, "Target is behind cover"
	end
	if (targetRoot.Position - me.Position).Magnitude < 0.001 then
		return false
	end
	if attackState.busy or UserInputService:GetFocusedTextBox() then return false, "Waiting for input or attack request" end
	local weapon
	if cfg.switch == false then weapon = handTool() else weapon = equipSword() end
	if typeof(weapon) ~= "Instance" or not isSword({ tool = weapon, itemType = weapon.Name }) then
		return false, "Equip a sword or enable Auto switch"
	end
	local now = os.clock()
	local cooldown = math.max(0.05, tonumber(cfg.cooldown) or 0.12)
	local weaponMeta = metaOf(weapon.Name)
	if cfg.respect ~= false and weaponMeta and type(weaponMeta.sword) == "table" then
		local weaponDelay = weaponMeta.sword.attackSpeed
		if type(weaponDelay) == "number" and weaponDelay > 0 and weaponDelay <= 2 then
			cooldown = math.max(cooldown, weaponDelay)
		end
	end
	local last = attackState.targets[model]
	if last and now - last < cooldown then return false, string.format("Weapon cooldown: %d ms", math.ceil((cooldown - (now-last))*1000)) end
	mode = mode or "walls"
	local aim = CFrame.lookAt(me.Position, targetRoot.Position)
	local delta = targetRoot.Position - me.Position
	local selfPos = me.Position + aim.LookVector * math.max(delta.Magnitude - 14.2, 0)
	local camPos = cam and cam.CFrame.Position or me.Position
	if mode == "walls" then
		camPos = targetRoot.Position - aim.LookVector * 2.5
	end
	local cursor = mode == "walls" and aim.LookVector or CFrame.lookAt(camPos, targetRoot.Position).LookVector
	local serverNow = workspace:GetServerTimeNow()
	local previous = BW.sword and BW.sword.lastSwingServerTime
	local swingDelta = type(previous) == "number" and math.clamp(serverNow - previous, 0, 2) or cooldown
	local payload = {
		weapon = weapon,
		chargedAttack = { chargeRatio = 0 },
		lastSwingServerTimeDelta = swingDelta,
		entityInstance = target.Character,
		validate = {
			raycast = {
				cameraPosition = { value = camPos },
				cursorDirection = { value = cursor },
			},
			targetPosition = { value = targetRoot.Position },
			selfPosition = { value = selfPos },
		},
	}
	local sent = false
	attackState.busy = true
	if BW.client and BW.attack then
		if not attackRemote then
			pcall(function()
				attackRemote = BW.client:Get(BW.attack)
			end)
		end
		if attackRemote then
			local ok, result = pcall(function()
				return attackRemote:SendToServer(payload)
			end)
			sent = ok and result ~= false
			if not ok then attackRemote = nil end
		end
	end
	if not sent and BW.sword and type(BW.sword.sendServerRequest) == "function" then
		local ok, result = pcall(function()
			return BW.sword:sendServerRequest(payload)
		end)
		sent = ok and result ~= false
	end
	if not sent and BW.sword and type(BW.sword.attackEntity) == "function" then
		local ok, result = pcall(function()
			return BW.sword:attackEntity({
				getInstance = function()
					return target.Character
				end,
			})
		end)
		sent = ok and result ~= false
	end
	attackState.busy = false
	if sent then attackState.targets[model] = now end
	if sent and cfg.swing then
		if mode == "silent" and Life.playLocalSwordSwing then
			pcall(Life.playLocalSwordSwing)
		elseif BW.sword and type(BW.sword.playSwordEffect) == "function" then
			pcall(BW.sword.playSwordEffect, BW.sword)
		end
	end
	return sent, sent and "Attack submitted; awaiting server damage" or "Attack adapter failed; see F9"
end

local function snap3(pos)
	return Vector3.new(math.round(pos.X / 3), math.round(pos.Y / 3), math.round(pos.Z / 3))
end

local function breakKind(part)
	-- Bed covers and frame parts inherit the bed's tool requirement.
	local ancestor = part
	while ancestor and ancestor ~= workspace do
		if string.lower(ancestor.Name) == "bed" then return "wood" end
		ancestor = ancestor.Parent
	end
	local meta = metaOf(part:GetAttribute("BlockType") or part:GetAttribute("blockType") or part.Name)
	if meta and meta.block and meta.block.breakType then return meta.block.breakType end
	local n = string.lower(part.Name .. tostring(part:GetAttribute("BlockType") or part:GetAttribute("blockType") or ""))
	if string.find(n, "wool", 1, true) then
		return "wool"
	end
	if string.find(n, "wood", 1, true) or string.find(n, "log", 1, true) or string.find(n, "bed", 1, true) then
		return "wood"
	end
	return "stone"
end

local mineBlock
local setMiningTarget
local miningReady
local resetMining
local miningLock={}
local miningRoute={}
do
	local highlight
	setMiningTarget=function(part)
		local mod=Modules and Modules.Nuker
		if mod then mod.miningTarget=part end
		if not part then
			table.clear(miningLock)
			if highlight then highlight.Enabled=false;highlight.Adornee=nil end
			return
		end
		if not highlight then
			highlight=Instance.new("Highlight")
			highlight.Name="QW_MiningTarget"
			highlight.FillColor=Color3.fromRGB(0,255,80)
			highlight.OutlineColor=Color3.fromRGB(0,255,80)
			highlight.FillTransparency=0.65
			highlight.OutlineTransparency=0
			highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent=workspace
		end
		if highlight.Adornee~=part then highlight.Adornee=part end
		if not highlight.Enabled then highlight.Enabled=true end
	end
	table.insert(Life.cleanups,function() if highlight then highlight:Destroy();highlight=nil end end)
	local remote, nextLoad, pending, sentAt, switchedTool, switchedAt
	local retryAt=0
	local failures=0
	local function retryDelay()
		failures+=1
		return math.min(1,0.28*failures)
	end
	resetMining=function()
		pending,remote,nextLoad,sentAt,switchedTool,switchedAt=nil,nil,nil,nil,nil,nil
		retryAt=0
		failures=0
		miningEquip.pending,miningEquip.item,miningEquip.character=nil,nil,nil
		miningEquip.at=-math.huge
		setMiningTarget(nil)
		table.clear(miningRoute)
		local mod=Modules and Modules.Nuker
		if mod then mod.planAt=nil end
	end
	miningReady=function()
		local now=os.clock()
		if pending then
			local gone=not pending.part.Parent
			if not gone and pending.store then
				local ok,current=pcall(function() return pending.store:getBlockAt(pending.cell) end)
				gone=ok and current~=pending.part
			end
			if gone then
				if miningRoute.done then miningRoute.done[pending.part]=true end
				if highlight and highlight.Adornee==pending.part then setMiningTarget(nil) end
				pending=nil
				return now>=retryAt
			end
			if now-(sentAt or now)<3 then return false end
			pending=nil
			remote=nil
			retryAt=now+1
			local mod=Modules and Modules.Nuker
			if mod then mod.status="Block request timed out; retrying after cooldown" end
		end
		return now>=retryAt
	end
	local function damageRemote()
		if remote then return remote end
		if nextLoad and os.clock()<nextLoad then return end
		nextLoad=os.clock()+3
		local ok,client=pcall(function()
			return require(ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["block-engine"].out.shared.remotes).BlockEngineRemotes.Client
		end)
		if ok and client then
			local found,result=pcall(function() return client:Get("DamageBlock") end)
			if found and result and type(result.CallServerAsync)=="function" then remote=result end
		end
		return remote
	end
	mineBlock=function(part,autoTool,hitPosition,normal,toolKind,blockCell)
		local mod=Modules and Modules.Nuker
		if not part or not part:IsA("BasePart") or not part.Parent or not root() then return false end
		if part:GetAttribute("NoBreak")==true then setMiningTarget(nil);return false end
		setMiningTarget(part)
		if not miningReady() then return false end
		local client=damageRemote()
		if not client then
			setMiningTarget(nil)
			retryAt=os.clock()+3
			if mod then mod.status="Block-engine DamageBlock remote unavailable" end
			return false
		end
		if autoTool then
			local wanted,ready,reason=equipBreaker(toolKind or breakKind(part))
			if not wanted then
				setMiningTarget(nil)
				retryAt=os.clock()+0.5
				if mod then mod.status=reason end
				return false
			end
			if wanted and not ready then
				if wanted~=switchedTool or not switchedAt then switchedTool,switchedAt=wanted,os.clock() end
				if mod then mod.status=os.clock()-switchedAt>1 and "Retrying mining tool switch; waiting for equipment confirmation" or "Equipping mining tool" end
				return false
			end
			if ready then switchedTool,switchedAt=wanted,nil end
		end
		local position=hitPosition or part.Position
		-- Position refs are block cells, not world-space multiples of three.
		local grid=blockCell or snap3(part.Position)
		local controller=BW.blockController
		if not blockCell and controller and type(controller.getBlockPosition)=="function" then
			local ok,value=pcall(controller.getBlockPosition,controller,part.Position)
			if ok and typeof(value)=="Vector3" then grid=value end
		end
		if controller and type(controller.isBlockBreakable)=="function" then
			local ok,allowed=pcall(controller.isBlockBreakable,controller,{blockPosition=grid},lp)
			if ok and not allowed then
				setMiningTarget(nil)
				retryAt=os.clock()+1
				if mod then mod.status="Client block controller reports this cell unbreakable" end
				return false
			end
		end
		local request={part=part,cell=grid,cost=miningRoute.costs and miningRoute.costs[part]}
		if miningRoute.store and miningRoute.steps and miningRoute.steps[miningRoute.index]
			and miningRoute.steps[miningRoute.index].part==part then request.store=miningRoute.store end
		pending,sentAt=request,os.clock()
		retryAt=sentAt+0.28
		if mod then
			mod.mineSent=(mod.mineSent or 0)+1
			mod.status="Damage request #" .. mod.mineSent .. " for " .. part.Name .. "; waiting for server"
		end
		local ok,promise=pcall(function()
			return client:CallServerAsync({
				blockRef={blockPosition=grid},
				hitPosition=position,
				hitNormal=normal or Vector3.yAxis,
			})
		end)
		if not ok then
			pending,remote=nil,nil
			retryAt=os.clock()+1
			if mod then mod.status="Block request failed: " .. tostring(promise) end
			return false
		end
		local function finished(result)
			if pending~=request then return end
			pending=nil
			if result=="damaged" and request.cost then
				request.cost.remaining=math.max(1,request.cost.remaining-request.cost.damage)
			end
			if result=="cancelled" or result==false then
				retryAt=math.max(retryAt,os.clock()+retryDelay())
			elseif result~=nil then failures=0 end
			if result=="destroyed" and miningRoute.done then
				miningRoute.done[part]=true
				local last=miningRoute.steps[#miningRoute.steps]
				if last and last.part==part then table.clear(miningRoute) end
			end
			if result=="destroyed" and highlight and highlight.Adornee==part then setMiningTarget(nil) end
			if mod then
				if result==false or result=="cancelled" then
					mod.status="Server rejected block damage: " .. tostring(result)
				elseif result==nil then
					mod.status="Server returned no damage confirmation"
				else
					mod.mineConfirmed=(mod.mineConfirmed or 0)+1
					mod.status="Server reply: " .. tostring(result) .. " | " .. mod.mineConfirmed .. "/" .. mod.mineSent .. " confirmed requests"
				end
			end
		end
		if type(promise)=="table" and type(promise.andThen)=="function" then
			local chained=promise:andThen(finished)
			if chained and type(chained.catch)=="function" then
				chained:catch(function(err)
					if pending~=request then return end
					pending=nil
					retryAt=os.clock()+1
					if mod then mod.status="Block damage error: " .. tostring(err) end
				end)
			end
		else finished(promise) end
		return true
	end
end

local function collectRemotes(fn, into, seen)
	if type(fn) ~= "function" or type(dbg.getconstants) ~= "function" or seen[fn] then
		return
	end
	seen[fn] = true
	local ok, consts = pcall(dbg.getconstants, fn)
	if ok and type(consts) == "table" then
		for i, v in ipairs(consts) do
			if v == "Client" and type(consts[i + 1]) == "string" then
				into[consts[i + 1]] = true
			end
		end
	end
	if type(dbg.getprotos) == "function" then
		local ok2, protos = pcall(dbg.getprotos, fn)
		if ok2 and type(protos) == "table" then
			for _, p in pairs(protos) do
				collectRemotes(p, into, seen)
			end
		end
	end
end

function hookFall()
	if BW.fallHooked or not (BW.client and BW.knit and BW.knit.Controllers) then
		return
	end
	local fall = BW.knit.Controllers.FallDamageController
	if not fall then
		return
	end
	BW.fallHooked = true
	local names, seen = {}, {}
	for _, fn in pairs(fall) do
		collectRemotes(fn, names, seen)
	end
	for name in pairs(names) do
		pcall(function()
			local remote = BW.client:Get(name)
			if remote and type(remote.SendToServer) == "function" then
				local old = remote.SendToServer
				remote.SendToServer = function(self, ...)
					if Life.active and BW.nofall then
						return
					end
					return old(self, ...)
				end
			end
		end)
	end
	if not BW.namecall and type(hookmetamethod) == "function" and type(getnamecallmethod) == "function" then
		BW.namecall = true
		local old
		old = hookmetamethod(game, "__namecall", function(self, ...)
			if BW.nofall then
				local method = getnamecallmethod()
				if method == "FireServer" or method == "fireServer" then
					local ok, n = pcall(function()
						return self.Name
					end)
					if ok and type(n) == "string" and string.find(string.lower(n), "fall", 1, true) then
						return
					end
				end
			end
			return old(self, ...)
		end)
	end
end

local function clearFall()
	local fall = BW.knit and BW.knit.Controllers and BW.knit.Controllers.FallDamageController
	if not fall then
		return
	end
	local nowTick, nowClock = tick(), os.clock()
	local nowServer = workspace:GetServerTimeNow()
	for key, value in pairs(fall) do
		if type(value) == "number" then
			local name = string.lower(tostring(key))
			if string.find(name, "ground", 1, true) or string.find(name, "fall", 1, true) or string.find(name, "land", 1, true) or string.find(name, "time", 1, true) then
				if value > 1e8 then
					fall[key] = nowTick
				elseif value > 1e5 then
					fall[key] = nowServer
				else
					fall[key] = nowClock
				end
			end
		end
	end
end

local beds
do
	local fallback,scanAt={},0
	beds=function()
		local list,seen={},{}
		local function add(inst)
			if not inst or not inst.Parent or seen[inst] then return end
			local owner=inst:GetAttribute("Team") or inst:GetAttribute("TeamId")
			if owner~=nil and tostring(owner)==tostring(teamOf(lp)) then return end
			if inst:GetAttribute("Alive")==false or inst:GetAttribute("Broken")==true then return end
			local cover=inst:FindFirstChild("Covers")
			if owner==nil and cover and cover:IsA("BasePart") and lp.Team and cover.BrickColor==lp.Team.TeamColor then return end
			seen[inst]=true
			table.insert(list,inst)
		end
		for _,tag in ipairs({"bed","Bed"}) do
			for _,inst in ipairs(CollectionService:GetTagged(tag)) do add(inst) end
		end
		if #list==0 then
			if os.clock()-scanAt>5 then
				scanAt=os.clock()
				table.clear(fallback)
				local map=workspace:FindFirstChild("Map") or workspace:FindFirstChild("map")
				if map then
					for _,inst in ipairs(map:GetDescendants()) do
						if inst.Name:lower()=="bed" and (inst:IsA("Model") or inst:IsA("BasePart")) then
							local parent=inst.Parent
							if not parent or parent.Name:lower()~="bed" then table.insert(fallback,inst) end
						end
					end
				end
			end
			for _,inst in ipairs(fallback) do add(inst) end
		end
		return list
	end
end

local function posOf(inst)
	if inst:IsA("Model") then
		return inst:GetPivot().Position
	end
	if inst:IsA("BasePart") then
		return inst.Position
	end
	local p = inst:FindFirstChildWhichIsA("BasePart", true)
	return p and p.Position
end

local function firePrompt(prompt)
	pcall(function()
		if fireproximityprompt then
			fireproximityprompt(prompt)
		else
			prompt:InputHoldBegin()
			task.delay(prompt.HoldDuration or 0, function()
				if prompt.Parent then
					prompt:InputHoldEnd()
				end
			end)
		end
	end)
end

local promptCache, promptAt = {}, 0
local function prompts(needles, range)
	local me = root()
	if not me then
		return
	end
	if os.clock() - promptAt > 1.5 then
		promptAt = os.clock()
		promptCache = {}
		for _, inst in ipairs(workspace:GetDescendants()) do
			if inst:IsA("ProximityPrompt") then
				table.insert(promptCache, inst)
			end
		end
	end
	for _, inst in ipairs(promptCache) do
		if inst.Parent then
			local part = inst.Parent:IsA("BasePart") and inst.Parent or inst.Parent:FindFirstChildWhichIsA("BasePart")
			if part and (part.Position - me.Position).Magnitude <= range then
				local s = string.lower(inst.ActionText .. inst.ObjectText .. inst.Parent.Name)
				for _, n in ipairs(needles) do
					if string.find(s, n, 1, true) then
						firePrompt(inst)
						break
					end
				end
			end
		end
	end
end

local flyVel, flyAtt
local function stopFly()
	if flyVel then
		flyVel:Destroy()
		flyVel = nil
	end
	if flyAtt then
		flyAtt:Destroy()
		flyAtt = nil
	end
	local h = hum()
	if h then
		h.PlatformStand = false
	end
end

local function fly(speed)
	local r, h = root(), hum()
	if not r or not h or not cam then
		return
	end
	if not flyVel or not flyVel.Parent then
		flyAtt = Instance.new("Attachment")
		flyAtt.Parent = r
		flyVel = Instance.new("LinearVelocity")
		flyVel.Attachment0 = flyAtt
		flyVel.MaxForce = math.huge
		flyVel.RelativeTo = Enum.ActuatorRelativeTo.World
		flyVel.Parent = r
	end
	h.PlatformStand = true
	local m = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		m = m + cam.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		m = m - cam.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		m = m + cam.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		m = m - cam.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		m = m + Vector3.yAxis
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		m = m - Vector3.yAxis
	end
	local v = m.Magnitude > 0 and m.Unit * speed or Vector3.zero
	flyVel.VectorVelocity = v
	r.AssemblyLinearVelocity = v
end

Modules = {}
local Cats = {}
local function cat(n)
	Cats[n] = { name = n, modules = {} }
end
cat("Combat")
cat("Blatant")
cat("Kits")
cat("Render")
cat("World")
cat("Larping")
cat("False Ban")
cat("Settings")

local Config = {activeProfile="default",autosave=true,autoExecute=true,startupAura="Silent Aura",restoring=false,revision=0}

local function opt(mod, name, kind, value, extra)
	mod.options[name] = {
		name = name,
		kind = kind,
		value = value,
		min = extra and extra.min or 0,
		max = extra and extra.max or 100,
		step = extra and extra.step or 1,
		list = extra and extra.list,
		suffix = extra and extra.suffix or "",
		order = #mod.order + 1,
	}
	table.insert(mod.order, name)
end

local function get(mod, name)
	return mod.options[name] and mod.options[name].value
end

local refreshHud
local pushToast
local function setOn(mod, state, silent)
	if not Life.active or (Life.destroying and state) then return end
	if mod.action then if state then mod.action() end;return end
	if mod.settingsOnly then return end
	local pendingChanged = false
	if Config.pending and not Config.restoring and Config.pending[mod.name] then
		Config.pending[mod.name] = nil
		pendingChanged = true
	end
	-- A user's aura choice also cancels the other aura's queued startup state.
	-- It may still be disabled locally while waiting for profile restoration.
	if state and (mod.name == "Killaura" or mod.name == "Silent Aura") then
		local other = Modules[mod.name == "Killaura" and "Silent Aura" or "Killaura"]
		if other then setOn(other, false, silent) end
	end
	if mod.enabled == state then
		if pendingChanged and Config.changed then Config.changed() end
		return
	end
	mod.enabled = state
	if mod.worker then pcall(task.cancel, mod.worker); mod.worker = nil end
	mod.running = false
	mod.acc, mod.iv, mod.warned = 0, nil, false
	if mod.paint then
		pcall(mod.paint)
	end
	if not state then
		for _, c in ipairs(mod.conns) do
			pcall(function()
				if typeof(c) == "RBXScriptConnection" then
					c:Disconnect()
				elseif typeof(c) == "Instance" then
					c:Destroy()
				elseif type(c) == "table" and c.Disconnect then
					c.Disconnect()
				end
			end)
		end
		table.clear(mod.conns)
	end
	if mod.toggle then
		local ok, err = pcall(mod.toggle, state, mod)
		if not ok then
			mod.enabled = false
			for _, connection in ipairs(mod.conns) do pcall(function() connection:Disconnect() end) end
			table.clear(mod.conns)
			pcall(mod.toggle, false, mod)
			mod.status = "Initialization failed: " .. tostring(err)
			if mod.paint then pcall(mod.paint) end
			warn("[Falcon] " .. mod.name .. " toggle: " .. tostring(err))
			notify(mod.name .. " failed to initialize. See F9 for details.")
		end
	end
	if pushToast and not silent and not Life.destroying then
		local ok, err = pcall(pushToast, mod.name, mod.enabled)
		if not ok then warn("[Falcon] Notification: " .. tostring(err)); notify(mod.name .. (mod.enabled and " enabled" or " disabled")) end
	end
	if refreshHud then refreshHud() end
	if Config.pending and not Config.restoring then Config.pending[mod.name]=nil end
	if Config.changed then Config.changed() end
end

local function add(category, name, tip, setup, toggle, tick, interval)
	local mod = {
		name = name,
		tip = tip,
		enabled = false,
		options = {},
		order = {},
		conns = {},
		toggle = toggle,
		tick = tick,
		interval = interval or 0.06,
		acc = 0,
	}
	if setup then
		setup(mod)
	end
	opt(mod, "Bind", "bind", nil)
	Modules[name] = mod
	table.insert(Cats[category].modules, mod)
	return mod
end

local espFolder = Instance.new("Folder")
espFolder.Name = "QWWorld"
espFolder.Parent = workspace
table.insert(Life.resources,espFolder)
local pEsp, bEsp = {}, {}

local function hl(adornee, color)
	local h = Instance.new("Highlight")
	h.Adornee = adornee
	h.FillTransparency = 0.65
	h.OutlineTransparency = 0
	h.FillColor = color
	h.OutlineColor = color
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.Parent = adornee
	return h
end

local function bill(adornee)
	local g = Instance.new("BillboardGui")
	g.AlwaysOnTop = true
	g.Size = UDim2.fromOffset(170, 40)
	g.StudsOffset = Vector3.new(0, 2.7, 0)
	g.Adornee = adornee
	g.Parent = adornee
	local t = Instance.new("TextLabel")
	t.Name = "T"
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 13
	t.TextStrokeTransparency = 0.35
	t.Parent = g
	return g
end

local function wipe(map)
	for k, v in pairs(map) do
		if v.h then
			v.h:Destroy()
		end
		if v.b then
			v.b:Destroy()
		end
		map[k] = nil
	end
end


local shader, tex, jumpWas, savedSpeed, swingOrig
local menuOpen = false
local M1 = Enum.UserInputType.MouseButton1
local M2 = Enum.UserInputType.MouseButton2

local function held(btn)
	return UserInputService:IsMouseButtonPressed(btn) and not UserInputService:GetFocusedTextBox() and not menuOpen
end

local function handKind()
	local inv = inventory()
	local hand = inv and inv.hand
	if not hand then
		local model=char()
		local ref=model and model:FindFirstChild("HandInvItem")
		local tool=ref and ref:IsA("ObjectValue") and ref.Value or handTool()
		if typeof(tool)=="Instance" then hand={itemType=tool.Name,tool=tool} end
	end
	if not hand then return "" end
	local meta = metaOf(hand.itemType)
	if isSword(hand) then
		return "sword"
	end
	if meta and meta.block then
		return "block"
	end
	local n = string.lower(tostring(hand.itemType or ""))
	for _, k in ipairs({ "bow", "crossbow", "fireball", "snowball", "arrow", "tnt" }) do
		if string.find(n, k, 1, true) then
			return "projectile"
		end
	end
	return n
end

local function blockPlacer()
	return BW.placer and BW.placer.blockPlacer
end

local function placeGrid(grid)
	local placer = blockPlacer()
	if not placer or not grid then
		return false
	end
	return pcall(placer.placeBlock, placer, grid)
end

local function mouseGrid()
	local placer = blockPlacer()
	if not placer then
		return
	end
	local ok, info = pcall(function()
		return placer.clientManager:getBlockSelector():getMouseInfo(0)
	end)
	if ok and info and info.placementPosition == info.placementPosition then
		return info.placementPosition
	end
end

local function refreshBypass()
	local on = false
	for _, n in ipairs({ "Killaura", "Reach", "Silent Aura" }) do
		if Modules[n] and Modules[n].enabled then
			on = true
		end
	end
	setMissBypass(on)
end

local function onSwing()
	if attackState.busy or (Modules.Killaura and Modules.Killaura.enabled)
		or (Modules["Silent Aura"] and Modules["Silent Aura"].enabled) then return end
	local me = root()
	if not me then
		return
	end
	local rc = Modules.Reach
	if rc and rc.enabled then
		local range = get(rc, "Range")
		local mouse = lp:GetMouse()
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char() }
		local hit = workspace:Raycast(mouse.UnitRay.Origin, mouse.UnitRay.Direction * (range + 14), params)
		local model = hit and hit.Instance and hit.Instance:FindFirstAncestorOfClass("Model")
		local plr = model and Players:GetPlayerFromCharacter(model)
		local r = model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
		if plr and enemy(plr) and r then
			local d = (r.Position - me.Position).Magnitude
			local moving = me.AssemblyLinearVelocity.Magnitude > 3
			if d > 13 and d <= range and (moving or not get(rc, "Only moving")) then
				sendAttack(plr, r, "reach", { switch = false, range = math.min(20, range), visible = true })
			end
		end
	end
end

hookSwing = function()
	if swingOrig then return end
	if not BW.sword or type(BW.sword.swingSwordAtMouse) ~= "function" then
		return
	end
	if not swingOrig then
		swingOrig = BW.sword.swingSwordAtMouse
	end
	Life.swingHook = function(...)
		local result = swingOrig(...)
		if Life.active then onSwing() end
		return result
	end
	BW.sword.swingSwordAtMouse=Life.swingHook
end

local function flyStep(speed, vspeed)
	local r, h = root(), hum()
	if not r or not h or not cam then
		return
	end
	if not flyVel or not flyVel.Parent then
		flyAtt = Instance.new("Attachment")
		flyAtt.Parent = r
		flyVel = Instance.new("LinearVelocity")
		flyVel.Attachment0 = flyAtt
		flyVel.MaxForce = math.huge
		flyVel.RelativeTo = Enum.ActuatorRelativeTo.World
		flyVel.Parent = r
	end
	if UserInputService:GetFocusedTextBox() then
		flyVel.VectorVelocity = Vector3.zero
		return
	end
	local look = cam.CFrame.LookVector
	local right = cam.CFrame.RightVector
	local flat = Vector3.new(look.X, 0, look.Z)
	local side = Vector3.new(right.X, 0, right.Z)
	local m = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		m = m + flat
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		m = m - flat
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		m = m + side
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		m = m - side
	end
	local v = m.Magnitude > 0 and m.Unit * speed or Vector3.zero
	local y = 0
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		y = vspeed
	elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		y = -vspeed
	end
	flyVel.VectorVelocity = Vector3.new(v.X, y, v.Z)
end

local function mineWith(part,autoTool,position,normal,toolKind,cell)
	return mineBlock(part,autoTool,position,normal,toolKind,cell)
end

local function planBedRoute(bed,origin,range,currentRoute,autoTool)
	local done=currentRoute and currentRoute.done or {}
	local costs=currentRoute and currentRoute.costs or {}
	local controller=BW.blockController
	local store
	if controller and type(controller.getStore)=="function" then pcall(function() store=controller:getStore() end) end
	local parts={}
	if bed:IsA("BasePart") then parts[1]=bed else
		for _,part in ipairs(bed:GetDescendants()) do if part:IsA("BasePart") then table.insert(parts,part) end;if #parts>=8 then break end end
	end
	local bedCells,seenCells={},{}
	local function addCell(cell,part)
		local id=cell.X .. ":" .. cell.Y .. ":" .. cell.Z
		if not seenCells[id] then seenCells[id]=true;table.insert(bedCells,{cell=cell,part=part}) end
	end
	-- Prefer the game's multi-block handler: a bed may occupy multiple cells
	-- even though it is represented by one rendered BasePart.
	for _,part in ipairs(parts) do
		local contained
		if controller and type(controller.getHandlerRegistry)=="function" then
			pcall(function()
				local handler=controller:getHandlerRegistry():getHandler(part.Name)
				if handler then contained=handler:getContainedPositions(part) end
			end)
		end
		local count=0
		if type(contained)=="table" then
			for _,cell in pairs(contained) do
				if typeof(cell)=="Vector3" then addCell(cell,part);count+=1 end
			end
		end
		if count==0 then
			local nx=math.clamp(math.round(part.Size.X/3),1,4)
			local nz=math.clamp(math.round(part.Size.Z/3),1,4)
			for x=1,nx do for z=1,nz do
				local offset=Vector3.new((x-(nx+1)*0.5)*3,0,(z-(nz+1)*0.5)*3)
				local point=part.CFrame and part.CFrame:PointToWorldSpace(offset) or part.Position+offset
				addCell(snap3(point),part)
			end end
		end
	end
	local source="block-store"
	local registered=false
	if store then
		for _,rootCell in ipairs(bedCells) do
			local ok,block=pcall(function() return store:getBlockAt(rootCell.cell) end)
			if ok and typeof(block)=="Instance" and (block==bed or block:IsDescendantOf(bed) or block.Name:lower()=="bed") then registered=true;break end
		end
	end
	if not registered then
		-- Some game versions expose no usable block-store entry for a bed.
		-- Reconstruct nearby occupied cells from real parts so every approach
		-- still gets compared instead of choosing the player's center ray.
		local ok,nearby=pcall(function()
			local params=OverlapParams.new()
			params.FilterType=Enum.RaycastFilterType.Exclude
			local ignore={}
			for _,player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(ignore,player.Character) end end
			params.FilterDescendantsInstances=ignore
			params.MaxParts=512
			return workspace:GetPartBoundsInBox(CFrame.new(posOf(bed)),Vector3.new(51,51,51),params)
		end)
		if ok and type(nearby)=="table" and #nearby<512 then
			local cells={}
			local function key(p) return p.X .. ":" .. p.Y .. ":" .. p.Z end
			for _,part in ipairs(nearby) do
				local name=part.Name:lower()
				local meta=metaOf(part.Name)
				if part:IsA("BasePart") and (meta and meta.block or name:find("wool",1,true) or name:find("stone",1,true)
					or name:find("wood",1,true) or name:find("obsidian",1,true) or name:find("ceramic",1,true)
					or name:find("clay",1,true) or name:find("glass",1,true) or name:find("plank",1,true)) then
					if not done[part] then cells[key(snap3(part.Position))]=part end
				end
			end
			local target=bed:IsA("BasePart") and bed or bed.PrimaryPart or parts[1]
			for _,rootCell in ipairs(bedCells) do cells[key(rootCell.cell)]=target end
			store={getBlockAt=function(_,cell)
				local part=cells[key(cell)]
				return part and part.Parent and part or nil
			end}
			store.refreshRoute=function(_,steps,done,entry)
				local wanted={}
				local low,high
				for _,step in ipairs(steps) do
					if step.cell then
						wanted[key(step.cell)]=true
						local p=step.cell*3
						low=low and Vector3.new(math.min(low.X,p.X),math.min(low.Y,p.Y),math.min(low.Z,p.Z)) or p
						high=high and Vector3.new(math.max(high.X,p.X),math.max(high.Y,p.Y),math.max(high.Z,p.Z)) or p
					end
				end
				if entry and low then
					local cell=snap3(entry)
					wanted[key(cell)]=true
					local p=cell*3
					low=Vector3.new(math.min(low.X,p.X),math.min(low.Y,p.Y),math.min(low.Z,p.Z))
					high=Vector3.new(math.max(high.X,p.X),math.max(high.Y,p.Y),math.max(high.Z,p.Z))
				end
				if not low then return end
				local params=OverlapParams.new()
				params.FilterType=Enum.RaycastFilterType.Exclude
				local ignore={}
				for _,player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(ignore,player.Character) end end
				params.FilterDescendantsInstances=ignore
				params.MaxParts=256
				local found=workspace:GetPartBoundsInBox(CFrame.new((low+high)*0.5),high-low+Vector3.new(3,3,3),params)
				if #found>=256 then return end
				local updated={}
				for _,part in ipairs(found) do
					local id=key(snap3(part.Position))
					if part==bed or part:IsDescendantOf(bed) then
						if target.Parent and not done[target] then
							for _,rootCell in ipairs(bedCells) do
								local bedId=key(rootCell.cell)
								if wanted[bedId] then updated[bedId]=target end
							end
						end
					end
					if wanted[id] and part:IsA("BasePart") and not done[part] then
						local name=part.Name:lower()
						local meta=metaOf(part.Name)
						if part==bed or part:IsDescendantOf(bed) then updated[id]=target
						elseif meta and meta.block or name:find("wool",1,true) or name:find("stone",1,true)
							or name:find("wood",1,true) or name:find("obsidian",1,true) or name:find("ceramic",1,true)
							or name:find("clay",1,true) or name:find("glass",1,true) or name:find("plank",1,true) then updated[id]=part end
					end
				end
				for id in pairs(wanted) do cells[id]=updated[id] end
			end
			source="geometry"
		end
	end
	if store then
		local normals={Vector3.new(1,0,0),Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,0,-1),Vector3.yAxis,-Vector3.yAxis}
		local function key(p) return p.X .. ":" .. p.Y .. ":" .. p.Z end
		local cellCache={}
		local function blockAt(cell)
			local id=key(cell)
			local cached=cellCache[id]
			if cached then return cached.value,cached.ok end
			local ok,value=pcall(function() return store:getBlockAt(cell) end)
			if value and (not value.Parent or done[value]) then value=nil end
			cellCache[id]={value=value,ok=ok}
			return value,ok
		end
		local params=RaycastParams.new()
		params.FilterType=Enum.RaycastFilterType.Exclude
		params.RespectCanCollide=true
		local ignore={}
		for _,player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(ignore,player.Character) end end
		params.FilterDescendantsInstances=ignore
		local function entryClear(point,node)
			if (point-origin).Magnitude<0.1 then return true end
			local hit=workspace:Raycast(origin,point-origin,params)
			-- A ray ending past an exposed face can hit the target itself. That
			-- proves access too; it is not an intervening defense block.
			return not hit or hit.Instance==node.part or hit.Instance:IsDescendantOf(node.part)
		end
		local planningInventory=inventory()
		local tools={}
		local function addTool(item)
			if type(item)=="table" and breakerKind(item) then table.insert(tools,item) end
		end
		if autoTool~=false then
			for _,item in pairs(planningInventory and planningInventory.items or {}) do addTool(item) end
			local hotbar=planningInventory and planningInventory.hotbar
			if not hotbar and BW.store then
				pcall(function() hotbar=BW.store:getState().Inventory.observedInventory.hotbar end)
			end
			for _,entry in pairs(hotbar or {}) do addTool(entry.item or entry) end
		end
		local model=char()
		local ref=model and model:FindFirstChild("HandInvItem")
		local held=ref and ref:IsA("ObjectValue") and ref.Value or handTool()
		if held then addTool({itemType=held.Name,tool=held}) end
		local costCache={}
		local function blockCost(part,cell)
			if costCache[part] then return costCache[part].hits,costCache[part].health end
			if part:GetAttribute("NoBreak")==true then return math.huge,math.huge end
			local meta=metaOf(part.Name)
			local health=part:GetAttribute("Health") or part:GetAttribute("MaxHealth")
			if type(store.getBlockData)=="function" then
				pcall(function()
					local data=store:getBlockData(cell)
					if data then health=data:GetAttribute("1") or data:GetAttribute("Health") or health end
				end)
			end
			if type(health)~="number" or health~=health then health=meta and meta.block and (meta.block.health or meta.block.maxHealth) end
			local kind=breakKind(part)
			local known=type(health)=="number" and health==health and health<math.huge and health>=0
			-- Estimates are explicitly marked when live health/metadata is absent.
			-- Unknown obsidian must not look cheaper than known wool merely because
			-- one route has replicated health and the other does not.
			if not known then health=part.Name:lower():find("obsidian",1,true) and 150 or kind=="wool" and 8 or kind=="wood" and 35 or 60 end
			local previous=costs[part]
			local remaining=health
			if previous and health==previous.observed then remaining=math.min(health,previous.remaining) end
			local damage=0
			for _,item in ipairs(tools) do damage=math.max(damage,breakerDamage(item,kind)) end
			local hits=damage>0 and math.max(1,math.ceil(remaining/damage)) or math.huge
			costs[part]={observed=health,remaining=remaining,damage=damage,estimated=not known}
			costCache[part]={hits=hits,health=remaining}
			return hits,remaining
		end
		local remainingScore,remainingHealth=0,0
		if currentRoute then
			local counted={}
			for _,step in ipairs(currentRoute.steps or {}) do
				local part,ok=step.part,true
				if step.cell then part,ok=blockAt(step.cell) end
				if not ok then remainingScore=math.huge;break end
				if part and part.Parent and not done[part] and part~=bed and not part:IsDescendantOf(bed) and not counted[part] then
					counted[part]=true
					local hits,hp=blockCost(part,step.cell)
					remainingScore+=hits;remainingHealth+=hp
				end
			end
		end
		-- Bounded Dijkstra search from every occupied bed cell through connected
		-- defense blocks. An air cell terminates a route; it never leads us out
		-- to unrelated blocks. Linked nodes reconstruct outside-to-inside hits.
		local heap,best={},{}
		local function before(a,b)
			return a.cost<b.cost or (a.cost==b.cost and a.health<b.health)
		end
		local function push(node)
			local i=#heap+1
			while i>1 do
				local parent=math.floor(i/2)
				if not before(node,heap[parent]) then break end
				heap[i]=heap[parent];i=parent
			end
			heap[i]=node
		end
		local function pop()
			local first,last=heap[1],table.remove(heap)
			if #heap>0 then
				local i=1
				while i*2<=#heap do
					local child=i*2
					if child<#heap and before(heap[child+1],heap[child]) then child+=1 end
					if not before(heap[child],last) then break end
					heap[i]=heap[child];i=child
				end
				heap[i]=last
			end
			return first
		end
		for _,rootCell in ipairs(bedCells) do
			local block,ok=blockAt(rootCell.cell)
			if ok and block and block:IsA("BasePart") and (block==bed or block:IsDescendantOf(bed) or block.Name:lower()=="bed") then
				local node={part=block,cell=rootCell.cell,cost=0,health=0,depth=0}
				best[key(node.cell)..":0"]=node;push(node)
			end
		end
		local winner,visited=nil,0
		while #heap>0 and visited<384 do
			local node=pop()
			if currentRoute and node.cost>=remainingScore then break end
			if winner and node.cost>winner.score then break end
			if best[key(node.cell)..":"..node.depth]==node then
				visited+=1
				for _,normal in ipairs(normals) do
					local cell=node.cell+normal
					local point=cell*3
					if (point-origin).Magnitude<=range then
						local block,ok=blockAt(cell)
						if ok and not block then
							local distance=(point-origin).Magnitude
							if (not winner or node.cost<winner.score or (node.cost==winner.score and
								(node.health<winner.health or (node.health==winner.health and distance<winner.distance)))) and entryClear(point,node) then
								local steps,inner,outside={},node,cell
								while inner do
									local face=outside-inner.cell
									table.insert(steps,{part=inner.part,cell=inner.cell,position=inner.cell*3+face*1.45,normal=face,toolKind=inner.depth==0 and "wood" or nil})
									outside,inner=inner.cell,inner.parent
								end
								winner={bed=bed,steps=steps,index=1,done=done,costs=costs,store=store,entry=point,source=source,bedCellCount=#bedCells,
									health=node.health,score=node.cost,distance=distance}
							end
						elseif ok and block and block:IsA("BasePart") and not seenCells[key(cell)] and node.depth<8 and block:GetAttribute("NoBreak")~=true then
							local name=block.Name:lower()
							local meta=metaOf(block.Name)
							local known=meta and meta.block or name:find("wool",1,true) or name:find("stone",1,true) or name:find("wood",1,true)
								or name:find("obsidian",1,true) or name:find("ceramic",1,true) or name:find("clay",1,true) or name:find("glass",1,true) or name:find("plank",1,true)
							if known then
								local hits,hp=blockCost(block,cell)
								local cost=node.cost+hits
								local id=key(cell)..":"..(node.depth+1)
								local previous=best[id]
								if cost<math.huge and (not currentRoute or cost<remainingScore) and (not winner or cost<=winner.score) and (not previous or cost<previous.cost or (cost==previous.cost and node.health+hp<previous.health)) then
									local nextNode={part=block,cell=cell,cost=cost,health=node.health+hp,depth=node.depth+1,parent=node}
									best[id]=nextNode;push(nextNode)
								end
							end
						end
					end
				end
			end
		end
		if currentRoute then currentRoute.visited=visited;currentRoute.budgetHit=visited>=384 end
		if winner then
			winner.visited=visited;winner.budgetHit=visited>=384
			return winner,remainingScore,remainingHealth
		end
		if currentRoute then return nil,remainingScore,remainingHealth end
	end
	-- Without a usable store, trace a single fixed line into the bed.
	-- Each collected block must actually occlude that line.
	local targetPart=bed:IsA("BasePart") and bed or bed.PrimaryPart or parts[1]
	if not targetPart then return end
	local params=RaycastParams.new()
	params.FilterType=Enum.RaycastFilterType.Exclude
	params.RespectCanCollide=true
	local ignore,route,seen={},{},{}
	for _,player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(ignore,player.Character) end end
	for _=1,16 do
		params.FilterDescendantsInstances=ignore
		local hit=workspace:Raycast(origin,targetPart.Position-origin,params)
		if not hit or hit.Instance==bed or hit.Instance:IsDescendantOf(bed) then
			table.insert(route,{part=targetPart,position=hit and hit.Position or targetPart.Position,normal=hit and hit.Normal or Vector3.yAxis,toolKind="wood"})
			return {bed=bed,steps=route,index=1,done={},entry=origin,source="single-ray"}
		end
		local block=hit.Instance
		if seen[block] or not block:IsA("BasePart") or block:GetAttribute("NoBreak")==true then return end
		local meta=metaOf(block.Name)
		local name=block.Name:lower()
		if not (meta and meta.block or name:find("wool",1,true) or name:find("stone",1,true)
			or name:find("wood",1,true) or name:find("obsidian",1,true) or name:find("ceramic",1,true)
			or name:find("clay",1,true) or name:find("glass",1,true) or name:find("plank",1,true)) then return end
		seen[block]=true
		table.insert(route,{part=block,position=hit.Position,normal=hit.Normal})
		table.insert(ignore,block)
	end
end

local function routeDistance(route,position)
	local distance=math.huge
	local previous=route.entry
	for _,step in ipairs(route.steps) do
		local point=step.position
		local delta=point-previous
		local length=delta:Dot(delta)
		local t=length>0 and math.clamp((position-previous):Dot(delta)/length,0,1) or 0
		distance=math.min(distance,(position-(previous+delta*t)).Magnitude)
		previous=point
	end
	return distance
end

local function breakBedStep(range,defenseFirst,autoTool,limitItems)
	local me=root()
	local mod=Modules.Nuker
	if not me or healthOf(me.Parent)<=0 then resetMining();return end
	local heldKind,hasHeldItem=holdingBreaker()
	-- An empty hand caused by our own switch must be allowed through to the
	-- equip retry code. Returning here would permanently prevent that retry.
	local recoveringEquip=autoTool and miningRoute.bed and not hasHeldItem and miningEquip.item~=nil
	if limitItems and not heldKind and not recoveringEquip then
		mod.status="Hold a pickaxe, axe, or shears"
		setMiningTarget(nil)
		return
	end
	if miningRoute.bed and (not miningRoute.bed.Parent or routeDistance(miningRoute,me.Position)>30) then
		setMiningTarget(nil);table.clear(miningRoute)
	end
	if miningRoute.store and type(miningRoute.store.refreshRoute)=="function" and os.clock()>=(miningRoute.refreshAt or 0) then
		miningRoute.refreshAt=os.clock()+0.25
		pcall(miningRoute.store.refreshRoute,miningRoute.store,miningRoute.steps,miningRoute.done,miningRoute.entry)
	end
	if not miningReady() then return end
	if not miningRoute.bed then
		if os.clock()<(mod.planAt or 0) then return end
		mod.planAt=os.clock()+0.2
		local bestBed,bestDistance
		for _,bed in ipairs(beds()) do
			local position=bed.Parent and posOf(bed)
			if position then
				local distance=(position-me.Position).Magnitude
				if distance<=range and (not bestDistance or distance<bestDistance) then bestBed,bestDistance=bed,distance end
			end
		end
		if not bestBed then setMiningTarget(nil);mod.status="Move within " .. range .. " studs of an enemy bed";return end
		local plan=planBedRoute(bestBed,me.Position+Vector3.new(0,1,0),30,nil,autoTool)
		if not plan then setMiningTarget(nil);mod.status="No breakable route found within planning budget";return end
		for key,value in pairs(plan) do miningRoute[key]=value end
		mod.planAt=nil
		miningRoute.replanAt=os.clock()+0.35
		miningRoute.reason="Selected lowest estimated hit count"
	end
	local routeChanged=false
	local steps=miningRoute.steps
	if miningRoute.store and miningRoute.entry and #steps<16 then
		local cell=snap3(miningRoute.entry)
		local ok,patch=pcall(function() return miningRoute.store:getBlockAt(cell) end)
		if ok and patch and patch.Parent and not miningRoute.done[patch] and patch~=miningRoute.bed and not patch:IsDescendantOf(miningRoute.bed) then
			local normal=steps[1].normal or Vector3.yAxis
			table.insert(steps,1,{part=patch,cell=cell,position=cell*3+normal*1.45,normal=normal})
			miningRoute.entry=cell*3+normal*3
			routeChanged=true
		end
	end
	-- Revisit every route cell, including cleared cells. A new instance in an
	-- old cell is a patch to break, not a reason to abandon the locked route.
	if miningRoute.store then
		local first
		for i,candidate in ipairs(steps) do
			if candidate.cell then
				local ok,current=pcall(function() return miningRoute.store:getBlockAt(candidate.cell) end)
				if ok then
					if current and current.Parent and not miningRoute.done[current] then
						if current~=candidate.part then
							routeChanged=true
							candidate.part=current
							candidate.toolKind=(current==miningRoute.bed or current:IsDescendantOf(miningRoute.bed)) and "wood" or nil
						end
						first=first or i
					elseif not current then
						if not miningRoute.done[candidate.part] then routeChanged=true end
						miningRoute.done[candidate.part]=true
					end
				else first=first or i end
			elseif candidate.part.Parent and not miningRoute.done[candidate.part] then first=first or i end
		end
		miningRoute.index=first or (#steps+1)
	end
	-- Compare remaining work from one fresh snapshot. A patch triggers an
	-- immediate comparison; otherwise the bounded search runs at most ~3 Hz.
	-- Equal-cost alternatives keep the current route regardless of movement.
	if routeChanged or os.clock()>=(miningRoute.replanAt or math.huge) then
		miningRoute.replanAt=os.clock()+0.35
		local candidate,remaining,health=planBedRoute(miningRoute.bed,me.Position+Vector3.new(0,1,0),30,miningRoute,autoTool)
		if remaining then miningRoute.score=remaining;miningRoute.health=health end
		if candidate and remaining and candidate.score<remaining then
			local switches=(miningRoute.switches or 0)+1
			setMiningTarget(nil)
			table.clear(miningRoute)
			for key,value in pairs(candidate) do miningRoute[key]=value end
			miningRoute.switches=switches
			miningRoute.reason=routeChanged and "Patch changed route cost; switched to fewer hits" or "Cheaper remaining route found"
			miningRoute.replanAt=os.clock()+0.35
			steps=miningRoute.steps
		else
			miningRoute.reason=not candidate and "Kept current route; no cheaper accessible route found within budget"
				or routeChanged and "Patch checked; current route still cheapest" or "Current route remains cheapest"
		end
	end
	local step=steps[miningRoute.index]
	while step and (miningRoute.done[step.part] or not step.part.Parent) do
		miningRoute.index+=1
		step=steps[miningRoute.index]
	end
	if not step then setMiningTarget(nil);table.clear(miningRoute);return end
	if step.part:GetAttribute("NoBreak")==true then
		setMiningTarget(nil);table.clear(miningRoute);mod.status="Locked route became unbreakable; replanning";return
	end
	-- Defense clearing is always part of the locked route; old profiles cannot disable it.
	if (step.part.Position-me.Position).Magnitude>30 then setMiningTarget(nil);mod.status="Route locked; move within 30 studs of the current block";return end
	miningLock.part,miningLock.bed,miningLock.position,miningLock.normal,miningLock.toolKind=step.part,miningRoute.bed,step.position,step.normal,step.toolKind
	mineWith(step.part,autoTool,step.position,step.normal,step.toolKind,step.cell)
end

local drawESP
do
	local lastDraw = 0
	local inventoryUtil
	local inventoryTried = false
	local function pretty(value)
		return (tostring(value or ""):gsub("_", " "):gsub("(%a)([%w]*)", function(a,b) return a:upper() .. b end))
	end
	local function escape(value)
		return tostring(value):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
	end
	local function inventoryOf(player)
		if not inventoryTried then
			inventoryTried = true
			pcall(function()
				inventoryUtil = require(ReplicatedStorage.TS.inventory["inventory-util"]).InventoryUtil
			end)
		end
		if inventoryUtil and type(inventoryUtil.getInventory) == "function" then
			local ok, inv = pcall(inventoryUtil.getInventory, player)
			if ok and type(inv) == "table" then return inv end
		end
	end
	local function gear(player, model, entry)
		if entry.gearAt and os.clock() - entry.gearAt < 0.5 then return entry.gear end
		local items, seen = {}, {}
		local function add(value, source, kind)
			if type(value) ~= "string" or value == "" then return end
			local id = value:lower():gsub("%s+", "_")
			-- Mesh pieces such as chestplate_left_shoulder are one equipped chestplate.
			for _, slot in ipairs({ "helmet", "chestplate", "boots" }) do
				local at = id:find(slot, 1, true)
				if at then id = id:sub(1, at + #slot - 1); break end
			end
			local key = kind .. ":" .. id
			if seen[key] then return end
			seen[key] = true
			local meta = metaOf(id)
			table.insert(items, { id = id, source = source, kind = kind, image = meta and meta.image })
		end
		local liveHand
		local handRef=model:FindFirstChild("HandInvItem")
		if handRef and handRef:IsA("ObjectValue") and handRef.Value then
			liveHand=handRef.Value
			add(liveHand:GetAttribute("itemType") or liveHand.Name,liveHand,"hand")
		end
		for i=0,2 do
			local ref=model:FindFirstChild("ArmorInvItem_" .. i)
			if ref and ref:IsA("ObjectValue") and ref.Value then
				local item=ref.Value
				add(item:GetAttribute("itemType") or item.Name,item,"armor")
			end
		end
		local inv = inventoryOf(player)
		if inv then
			for _, item in pairs(inv.armor or {}) do
				if type(item) == "table" then add(item.itemType, item.tool, "armor")
				elseif type(item) == "string" then add(item, nil, "armor") end
			end
			if not liveHand and type(inv.hand) == "table" then add(inv.hand.itemType, inv.hand.tool, "hand") end
		end
		local tool = model:FindFirstChildOfClass("Tool")
		if tool then
			local id = tool:GetAttribute("itemType") or tool:GetAttribute("ItemType") or tool.Name
			local hasHand = false
			for _, item in ipairs(items) do if item.kind == "hand" then hasHand = true end end
			if not hasHand then add(id, tool, "hand") end
		end
		local hasArmor = false
		for _, item in ipairs(items) do if item.kind == "armor" then hasArmor = true end end
		if not hasArmor then
			for _, obj in ipairs(model:GetDescendants()) do
				if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Accessory") then
					local name = obj:GetAttribute("itemType") or obj:GetAttribute("ItemType") or obj.Name
					local lower = tostring(name):lower()
					if lower:find("helmet",1,true) or lower:find("chestplate",1,true) or lower:find("boots",1,true) then
						add(name, obj, "armor")
					end
				end
			end
		end
		table.sort(items,function(a,b)
			local function order(v)
				if v.kind == "hand" then return 1 end
				if v.id:find("helmet",1,true) then return 2 end
				if v.id:find("chestplate",1,true) then return 3 end
				if v.id:find("boots",1,true) then return 4 end
				return 5
			end
			local x,y=order(a),order(b)
			return x == y and a.id < b.id or x < y
		end)
		entry.gear,entry.gearAt=items,os.clock()
		return items
	end
	local function rounded(obj, radius)
		local c=Instance.new("UICorner")
		c.CornerRadius=UDim.new(0,radius)
		c.Parent=obj
	end
	local function text(parent,name,size)
		local label=Instance.new("TextLabel")
		label.Name=name
		label.BackgroundTransparency=1
		label.Font=Enum.Font.GothamMedium
		label.TextSize=size
		label.TextColor3=Color3.new(1,1,1)
		label.TextStrokeTransparency=0.3
		label.RichText=true
		label.Parent=parent
		return label
	end
	local function createTag(head)
		local gui=Instance.new("BillboardGui")
		gui.Name="QW_Nametab"
		gui.Size=UDim2.fromOffset(200,52)
		gui.StudsOffset=Vector3.new(0,2.5,0)
		gui.AlwaysOnTop=true
		gui.Adornee=head
		gui.Parent=head
		local icons=Instance.new("Frame")
		icons.Name="Gear"
		icons.BackgroundTransparency=1
		icons.Parent=gui
		local layout=Instance.new("UIListLayout")
		layout.FillDirection=Enum.FillDirection.Horizontal
		layout.HorizontalAlignment=Enum.HorizontalAlignment.Center
		layout.Padding=UDim.new(0,2)
		layout.SortOrder=Enum.SortOrder.LayoutOrder
		layout.Parent=icons
		local plate=Instance.new("Frame")
		plate.Name="Plate"
		plate.AnchorPoint=Vector2.new(0.5,0)
		plate.BackgroundColor3=Color3.fromRGB(12,14,20)
		plate.BackgroundTransparency=0.42
		plate.BorderSizePixel=0
		plate.ZIndex=1
		plate.Parent=gui
		rounded(plate,5)
		local title=text(gui,"Title",12)
		title.ZIndex=2
		title.TextTruncate=Enum.TextTruncate.AtEnd
		local kit=text(gui,"Kit",10)
		kit.Size=UDim2.new(1,0,0,13)
		kit.TextColor3=Color3.fromRGB(182,188,207)
		kit.ZIndex=2
		local bar=Instance.new("Frame")
		bar.Name="HealthBar"
		bar.BorderSizePixel=0
		bar.Size=UDim2.fromOffset(76,3)
		bar.AnchorPoint=Vector2.new(0.5,0)
		bar.BackgroundColor3=Color3.fromRGB(49,29,37)
		bar.ZIndex=2
		bar.Parent=gui
		rounded(bar,2)
		local fill=Instance.new("Frame")
		fill.Name="Fill"
		fill.ZIndex=3
		fill.BorderSizePixel=0
		fill.Size=UDim2.fromScale(1,1)
		fill.Parent=bar
		rounded(fill,2)
		return gui
	end
	local function addIcon(parent,item,size,index)
		local image=item.image
		if type(image)=="number" then image="rbxassetid://" .. image end
		if type(image)=="string" and image~="" then
			local icon=Instance.new("ImageLabel")
			icon.Size=UDim2.fromOffset(size,size)
			icon.BackgroundTransparency=1
			icon.Image=image
			icon.ScaleType=Enum.ScaleType.Fit
			icon.LayoutOrder=index
			icon.Parent=parent
			return
		end
		if typeof(item.source)=="Instance" then
			local ok,clone=pcall(function() return item.source:Clone() end)
			if ok and clone then
				local model=Instance.new("Model")
				clone.Parent=model
				local count=0
				for _, obj in ipairs(model:GetDescendants()) do
					if obj:IsA("BasePart") then
						count=count+1
						obj.Anchored=true
						obj.CanCollide=false
						obj.CanQuery=false
						obj.CanTouch=false
					elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("Constraint") or obj:IsA("JointInstance") then obj:Destroy() end
				end
				if count>0 then
					local view=Instance.new("ViewportFrame")
					view.Size=UDim2.fromOffset(size,size)
					view.BackgroundTransparency=1
					view.Ambient=Color3.new(1,1,1)
					view.LightColor=Color3.new(1,1,1)
					view.LayoutOrder=index
					model.Parent=view
					local box,extent=model:GetBoundingBox()
					local camera=Instance.new("Camera")
					camera.FieldOfView=35
					local distance=math.max(extent.X,extent.Y,extent.Z,0.3)*2
					camera.CFrame=CFrame.lookAt(box.Position+Vector3.new(distance*0.55,distance*0.3,distance),box.Position)
					camera.Parent=view
					view.CurrentCamera=camera
					view.Parent=parent
					return
				end
				model:Destroy()
			end
		end
		-- A short slot marker is preferable to a fabricated item image.
		local fallback=text(parent,"Slot",9)
		fallback.Size=UDim2.fromOffset(size,size)
		fallback.Text=item.kind=="hand" and "HAND" or item.id:find("helmet",1,true) and "HEAD" or item.id:find("boots",1,true) and "FEET" or "BODY"
		fallback.LayoutOrder=index
	end
	drawESP=function(force)
		if not force and os.clock()-lastDraw<0.1 then return end
		lastDraw=os.clock()
		local mod=Modules.Nametabs
		if not mod or not mod.enabled then wipe(pEsp);return end
		local me=root()
		local seen={}
		for _,player in ipairs(Players:GetPlayers()) do
			local model=player.Character
			local r=model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
			if me and r and r:IsA("BasePart") and player~=lp and healthOf(model)>0
				and (get(mod,"Teammates") or enemy(player)) and (r.Position-me.Position).Magnitude<=get(mod,"Range") then
				seen[player]=true
				local entry=pEsp[player]
				if entry and entry.model~=model then
					if entry.h then entry.h:Destroy() end
					if entry.b then entry.b:Destroy() end
					entry=nil
				end
				entry=entry or {model=model}
				pEsp[player]=entry
				local head=model:FindFirstChild("Head") or r
				if not entry.b or not entry.b.Parent then entry.b=createTag(head) end
				entry.b.Adornee=head
				local col=colorOf(player)
				if get(mod,"Highlight") then
					if not entry.h or not entry.h.Parent then entry.h=hl(model,col) end
					entry.h.Adornee=model
					entry.h.FillColor=col
					entry.h.OutlineColor=col
					entry.h.FillTransparency=0.85
				elseif entry.h then entry.h:Destroy();entry.h=nil end
				local hp=math.max(0,math.floor(healthOf(model)+0.5))
				local h=model:FindFirstChildOfClass("Humanoid")
				local maximum=model:GetAttribute("MaxHealth") or (h and h.MaxHealth) or 100
				if type(maximum)~="number" or maximum<=0 then maximum=100 end
				local ratio=math.clamp(hp/maximum,0,1)
				local color=Color3.fromHSV(ratio/3,0.85,1)
				local name=get(mod,"Names") and escape(player.DisplayName) or ""
				if get(mod,"Health") then
					local shown=get(mod,"Health format")=="Fraction" and string.format("%d/%d",hp,math.floor(maximum)) or tostring(hp)
					name=name .. string.format(' <font color="rgb(%d,%d,%d)">%s</font>',math.floor(color.R*255),math.floor(color.G*255),math.floor(color.B*255),shown)
				end
				if get(mod,"Distance") then name=name .. "  " .. math.floor((r.Position-me.Position).Magnitude) .. "st" end
				entry.b.Title.Text=name
				entry.b.Title.TextSize=get(mod,"Text size")
				entry.b.Title.TextColor3=get(mod,"Team color") and col or Color3.fromRGB(255,210,65)
				local kit=kitName(kitOf(player))
				local hasKit=get(mod,"Kit") and kit~=""
				local hasBar=get(mod,"Health bar")
				entry.b.Kit.Text=hasKit and escape(kit) or ""
				entry.b.Kit.Visible=hasKit
				entry.b.HealthBar.Visible=hasBar
				if entry.healthRatio~=ratio then
					entry.healthRatio=ratio
					TweenService:Create(entry.b.HealthBar.Fill,TweenInfo.new(0.12),{Size=UDim2.fromScale(ratio,1),BackgroundColor3=color}):Play()
				end
				local items=gear(player,model,entry)
				local chosen,signature={},{}
				for _,item in ipairs(items) do
					if (item.kind=="armor" and get(mod,"Armor")) or (item.kind=="hand" and get(mod,"Held item")) then
						table.insert(chosen,item)
						table.insert(signature,item.kind .. item.id .. tostring(item.image))
						if #chosen>=6 then break end
					end
				end
				local iconSize=get(mod,"Icon size")
				local iconRow=#chosen>0 and iconSize+2 or 0
				local titleHeight=name~="" and get(mod,"Text size")+3 or 0
				local detailsTop=iconRow+titleHeight
				local detailsHeight=(hasKit and 13 or 0)+(hasBar and 6 or 0)
				entry.b.Size=UDim2.fromOffset(200,math.max(detailsTop+detailsHeight,1))
				entry.b.Gear.Size=UDim2.new(1,0,0,iconRow)
				entry.b.Gear.Visible=iconRow>0
				entry.b.Title.Position=UDim2.fromOffset(0,iconRow)
				entry.b.Title.Size=UDim2.new(1,0,0,titleHeight)
				entry.b.Title.Visible=titleHeight>0
				entry.b.Kit.Position=UDim2.fromOffset(0,detailsTop)
				entry.b.Plate.Position=UDim2.new(0.5,0,0,detailsTop)
				entry.b.Plate.Size=UDim2.fromOffset(112,detailsHeight)
				entry.b.Plate.Visible=detailsHeight>0 and get(mod,"Background")
				entry.b.HealthBar.Position=UDim2.new(0.5,0,0,detailsTop+(hasKit and 13 or 0)+1)
				local key=table.concat(signature,"|") .. ":" .. get(mod,"Icon size")
				if entry.iconKey~=key then
					entry.iconKey=key
					for _,obj in ipairs(entry.b.Gear:GetChildren()) do if obj:IsA("GuiObject") then obj:Destroy() end end
					for i,item in ipairs(chosen) do addIcon(entry.b.Gear,item,get(mod,"Icon size"),i) end
				end
			end
		end
		for player,entry in pairs(pEsp) do
			if not seen[player] then
				if entry.h then entry.h:Destroy() end
				if entry.b then entry.b:Destroy() end
				pEsp[player]=nil
			end
		end
	end
end

local function noM1Gate(m)
	return get(m, "Click only") and not held(M1)
end

add("Combat", "Reach", "Extends swings you aim yourself, no walls", function(m)
	opt(m, "Range", "slider", 20, { min = 14, max = 20, suffix = " st" })
	opt(m, "Only moving", "toggle", false)
end, function(on)
	refreshBypass()
	if on then
		hookSwing()
	end
end, function()
	if not swingOrig then
		hookSwing()
	end
end, 1)

add("Combat", "Silent Aura", "Closet aura: visible targets in FOV, slower hits", function(m)
	opt(m, "Range", "slider", 20, { min = 8, max = 20, suffix = " st" })
	opt(m, "FOV", "slider", 70, { min = 20, max = 360, step = 10, suffix = "\u{B0}" })
	opt(m, "Delay", "slider", 100, { min = 50, max = 500, step = 10, suffix = "ms" })
	opt(m, "Priority", "list", "Distance", { list = { "Distance", "Health", "Angle" } })
	opt(m, "Auto switch", "toggle", true)
	opt(m, "Swing", "toggle", true)
	opt(m, "Click only", "toggle", false)
	opt(m, "Weapon cooldown", "toggle", true)
end, function(on,m)
	if not on and Life.stopLocalSwordSwing then Life.stopLocalSwordSwing() end
	if on and Modules.Killaura and Modules.Killaura.enabled then setOn(Modules.Killaura,false) end
	if on then setWalls(false) end
	refreshBypass()
end, function(m)
	if noM1Gate(m) or UserInputService:GetFocusedTextBox() then
		m.status = "Waiting for input"
		return
	end
	local t, r = pick(get(m, "Range"), { fov = get(m, "FOV"), visible = true, sort = get(m, "Priority") })
	if t then
		local sent, reason = sendAttack(t, r, "silent", { switch = get(m, "Auto switch"), swing = get(m, "Swing"), range = math.min(20, get(m, "Range")), visible = true, respect = get(m, "Weapon cooldown"), cooldown = get(m, "Delay") / 1000 })
		m.status = reason or (sent and "Attack submitted" or "Target became invalid")
	else
		m.status = "No visible enemy inside range and FOV"
	end
end, function(m)
	return 0.025
end)

-- Projectile assistance stays in a separate scope to avoid exhausting Luau locals.
do
	local owner, original, wrapper, charging
	local pressedByAura, releaseMouse, projectileMeta
	local motion=setmetatable({}, {__mode="k"})
	local function sampleMotion(previous,position,velocity,now)
		local sample={position=position,velocity=velocity,at=now}
		if previous then
			local dt=now-previous.at
			local displacement=position-previous.position
			if dt>=0.04 and dt<=0.3 and displacement.Magnitude<120 then
				local measured=displacement/dt
				-- Position replication also covers movement abilities that leave
				-- AssemblyLinearVelocity stale. Avoid lagging behind speed changes.
				if (measured-velocity).Magnitude>math.max(8,velocity.Magnitude*0.25) then
					sample.velocity=measured
				end
				sample.accelerationY=(sample.velocity.Y-previous.velocity.Y)/dt
			end
		end
		return sample
	end
	local function movementGravity(sample,gravity)
		-- Flight abilities can retain the Freefall state while holding altitude.
		-- Apply falling gravity only when recent vertical motion supports it.
		if sample and sample.accelerationY then
			return sample.accelerationY < -gravity*0.5 and sample.accelerationY > -gravity*1.5 and gravity or 0
		end
		return gravity
	end
	Life.connect(RunService.Heartbeat,function()
		local aim,aura=Modules["Projectile Aimbot"],Modules["Projectile Aura"]
		if not (aim and aim.enabled or aura and aura.enabled) then table.clear(motion);return end
		local now=os.clock()
		for _,player in ipairs(Players:GetPlayers()) do
			local character=player.Character
			local root=character and character:FindFirstChild("HumanoidRootPart")
			if player~=lp and root then
				local previous=motion[root]
				if not previous or now-previous.at>=0.08 then
					motion[root]=sampleMotion(previous,root.Position,root.AssemblyLinearVelocity,now)
				end
			end
		end
	end)
	local function release()
		local usedMouse=pressedByAura
		if pressedByAura then
			pressedByAura=false
			if releaseMouse then pcall(releaseMouse) end
			releaseMouse=nil
		end
		if charging then
			if not usedMouse then pcall(function() charging:Deactivate() end) end
			charging = nil
		end
	end
	local function predictedPoint(target, velocity, t, targetGravity, floorY)
		local point = target + velocity * t - Vector3.new(0, (targetGravity or 0) * t * t * 0.5, 0)
		if floorY then point = Vector3.new(point.X, math.max(point.Y, floorY), point.Z) end
		return point
	end
	local function solve(origin, speed, gravity, target, velocity, maximum, targetGravity, floorY, lead)
		-- Find the earliest positive intercept under constant projectile gravity.
		local function aimAt(t)
			return predictedPoint(target, velocity, t + (lead or 0), targetGravity, floorY) - origin + Vector3.new(0, gravity * t * t * 0.5, 0)
		end
		local function residual(t)
			local aim = aimAt(t)
			return aim:Dot(aim) - speed * speed * t * t
		end
		local low, previous = 0, residual(0)
		for i = 1, 160 do
			local high = maximum * (i / 160) ^ 2
			local value = residual(high)
			if value <= 0 and previous >= 0 then
				for _ = 1, 20 do
					local mid = (low + high) * 0.5
					if residual(mid) > 0 then low = mid else high = mid end
				end
				local t = (low + high) * 0.5
				local required = aimAt(t) / t
				if required.Magnitude > 0.001 then return required.Unit * speed, t end
				return
			end
			low, previous = high, value
		end
	end
	local function clearPath(origin, velocity, gravity, duration, target)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { char() }
		local previous = origin
		params.RespectCanCollide = true
		local segments=math.clamp(math.ceil(duration*velocity.Magnitude/8),16,192)
		for i = 1, segments do
			local t = duration * i / segments
			local point = origin + velocity * t - Vector3.new(0, gravity * t * t * 0.5, 0)
			local hit = workspace:Raycast(previous, point - previous, params)
			if hit then return hit.Instance:IsDescendantOf(target) end
			previous = point
		end
		return true
	end
	local function uninstall()
		release()
		if owner and owner.calculateImportantLaunchValues == wrapper then
			owner.calculateImportantLaunchValues = original
		end
		owner, original, wrapper = nil, nil, nil
	end
	local function install(m)
		local ctrl = BW.knit and BW.knit.Controllers and BW.knit.Controllers.ProjectileController
		if not ctrl or type(ctrl.calculateImportantLaunchValues) ~= "function" then return false end
		if owner == ctrl and ctrl.calculateImportantLaunchValues == wrapper then return true end
		uninstall()
		owner, original = ctrl, ctrl.calculateImportantLaunchValues
		pcall(function()
			projectileMeta = require(ReplicatedStorage.TS.projectile["projectile-meta"]).ProjectileMeta
		end)
		local base = original
		wrapper = function(self, launchData, preview, ...)
			local results = table.pack(base(self, launchData, preview, ...))
			local aura=Modules["Projectile Aura"]
			local aim=Modules["Projectile Aimbot"]
			local m=aura and aura.enabled and aura or aim and aim.enabled and aim
			if not m then return table.unpack(results,1,results.n) end
			local values = results[1]
			m.launchCalls=(m.launchCalls or 0)+1
			m.lastLaunch=os.clock()
			if not m.enabled or UserInputService:GetFocusedTextBox() then
				return table.unpack(results,1,results.n)
			end
			if type(values) ~= "table" or typeof(values.positionFrom) ~= "Vector3"
				or typeof(values.initialVelocity) ~= "Vector3" then
				m.status="Launch data format unsupported; original shot preserved"
				return table.unpack(results, 1, results.n)
			end
			-- Exclude utility projectiles such as teleport pearls.
			local kind = type(launchData) == "table" and tostring(launchData.projectile or launchData.projectileType or ""):lower() or ""
			local info=type(projectileMeta)=="table" and projectileMeta[kind] or nil
			local permitted = kind:find("arrow", 1, true) or kind:find("snowball", 1, true)
				or kind:find("fireball", 1, true)
			if not permitted then
				m.status="Selected projectile is not an arrow, fireball, or snowball"
				return table.unpack(results, 1, results.n)
			end
			-- The curved flight path below determines whether the shot is clear.
			local target, r = pick(get(m, "Range"), { screen = get(m,"Full screen"), fov = get(m, "FOV"), visible = false, sort = "Angle" })
			if not target or not r then
				m.status="No enemy inside projectile range and FOV"
				return table.unpack(results,1,results.n)
			end
			local speed = values.initialVelocity.Magnitude
			if get(m,"Speed override")>0 then speed=get(m,"Speed override") end
			if speed < 1 or speed ~= speed then return table.unpack(results, 1, results.n) end
			local gravity = values.gravitationalAcceleration or (info and info.gravitationalAcceleration)
			if get(m,"Gravity override")>=0 then gravity=get(m,"Gravity override") end
			if typeof(gravity) == "Vector3" then gravity = math.abs(gravity.Y) end
			if type(gravity) ~= "number" then
				m.status = "Gravity unavailable: set Gravity override"
				return table.unpack(results, 1, results.n)
			end
			gravity = math.abs(gravity)
			local sample=motion[r]
			if sample and os.clock()-sample.at>0.3 then sample=nil end
			local targetVelocity = get(m, "Prediction") and (sample and sample.velocity or r.AssemblyLinearVelocity) or Vector3.zero
			local targetGravity, floorY = 0, nil
			local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
			if get(m, "Prediction") and humanoid then
				if humanoid.FloorMaterial ~= Enum.Material.Air then
					targetVelocity = Vector3.new(targetVelocity.X, 0, targetVelocity.Z)
				else
					local state = humanoid:GetState()
					if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
						targetGravity = movementGravity(sample,workspace.Gravity)
					end
				end
			end
			local point = r.Position
			if get(m, "Aim at") == "Head" then
				local head = target.Character:FindFirstChild("Head")
				if head and head:IsA("BasePart") then point = head.Position end
			end
			-- Additional lead is user-controlled; flight time is solved separately.
			local lead = get(m, "Extra lead") / 1000
			if targetGravity > 0 then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {char(), target.Character}
				params.RespectCanCollide = true
				local ground = workspace:Raycast(r.Position, Vector3.new(0,-256,0),params)
				if ground then floorY = ground.Position.Y + humanoid.HipHeight + r.Size.Y * 0.5 + (point.Y-r.Position.Y) end
			end
			local maximum=get(m,"Max flight")
			if info and type(info.lifetimeSec)=="number" then maximum=math.min(maximum,info.lifetimeSec) end
			-- Recalculate previews and released shots from the latest movement.
			local velocity, flight=solve(values.positionFrom,speed,gravity,point,targetVelocity,maximum,targetGravity,floorY,lead)
			if not velocity or not clearPath(values.positionFrom, velocity, gravity, flight, target.Character) then
				m.status = "No clear intercept"
				return table.unpack(results, 1, results.n)
			end
			local adjusted = table.clone(values)
			adjusted.initialVelocity = velocity
			results[1] = adjusted
			if not preview then m.redirects=(m.redirects or 0)+1 end
			m.status = string.format("Launch hook active | %d shot calculations",m.launchCalls)
			return table.unpack(results, 1, results.n)
		end
		ctrl.calculateImportantLaunchValues = wrapper
		m.status = "Launch hook ready"
		return true
	end
	local function predictionSettings(m)
		opt(m, "Range", "slider", 1000, { min = 20, max = 3000, step = 5, suffix = " st" })
		opt(m, "Full screen", "toggle", true)
		opt(m, "FOV", "slider", 360, { min = 10, max = 360, step = 5, suffix = "°" })
		opt(m, "Prediction", "toggle", true)
		opt(m, "Aim at", "list", "Body", { list = { "Body", "Head" } })
		opt(m, "Extra lead", "slider", 0, { min = 0, max = 200, step = 10, suffix = "ms" })
		opt(m, "Max flight", "slider", 10, { min = 0.5, max = 20, step = 0.1, suffix = "s" })
		opt(m, "Speed override", "slider", 0, {min=0,max=400,step=5,suffix=" st/s (0 = auto)"})
		opt(m, "Gravity override", "slider", -1, {min=-1,max=250,step=1,suffix=" (-1 = auto)"})
	end
	local function togglePrediction(on,m)
		if on then
			if not install(m) then notify(m.name .. ": waiting for the projectile controller") end
		else
			release()
			local aura=Modules["Projectile Aura"]
			local aim=Modules["Projectile Aimbot"]
			if not (aura and aura.enabled) and not (aim and aim.enabled) then uninstall() end
		end
	end
	add("Combat","Projectile Aimbot","Predicts your manually fired shots. Does not charge or shoot for you",predictionSettings,togglePrediction,function(m)
		if not install(m) then m.status="Projectile controller unavailable"
		elseif not m.lastLaunch then m.status="Aim assistance ready; fire your equipped projectile manually" end
	end,0.2)
	add("Combat","Projectile Aura","Auto-charges and shoots using the same prediction as Projectile Aimbot",function(m)
		predictionSettings(m)
		opt(m, "Charge", "slider", 500, { min = 100, max = 1500, step = 50, suffix = "ms" })
		opt(m, "Fire delay", "slider", 700, { min = 250, max = 2000, step = 50, suffix = "ms" })
	end, togglePrediction, function(m)
		if not install(m) then m.status = "Projectile controller unavailable"; return end
		if not m.lastLaunch or os.clock()-m.lastLaunch>3 then
			m.status="Hook installed; waiting for a supported shot"
		end
		if menuOpen or UserInputService:GetFocusedTextBox() then m.status="Close menu to auto-fire";return end
		if charging or os.clock()<(m.nextShot or 0) then return end
		if UserInputService:IsMouseButtonPressed(M1) then return end
		if handKind()~="projectile" then m.status="Equip a bow, crossbow, fireball, or snowball";return end
		local t = pick(get(m, "Range"), { screen = get(m,"Full screen"), fov = get(m, "FOV"), visible = true, sort = "Angle" })
		if not t then return end
		local tool = handTool()
		if typeof(tool)~="Instance" then m.status="Equipped projectile instance unavailable";return end
		local character=char()
		local hand=character and character:FindFirstChild("HandInvItem")
		local equipped=tool.Parent==character or (hand and hand:IsA("ObjectValue") and hand.Value==tool)
		if not equipped then m.status="Projectile is not currently equipped";return end
		if tool:IsA("Tool") and not tool.Enabled then m.status="Equipped projectile is on cooldown";return end
		m.nextShot = os.clock() + (get(m, "Charge") + get(m, "Fire delay")) / 1000
		charging = tool
		local ok=false
		if type(mouse1press)=="function" and type(mouse1release)=="function" then
			ok=pcall(mouse1press)
			if ok then pressedByAura=true;releaseMouse=mouse1release end
		end
		if not ok and VirtualInput then
			local pointer=UserInputService:GetMouseLocation()
			ok=pcall(function() VirtualInput:SendMouseButtonEvent(pointer.X,pointer.Y,0,true,game,0) end)
			if ok then
				pressedByAura=true
				releaseMouse=function() VirtualInput:SendMouseButtonEvent(pointer.X,pointer.Y,0,false,game,0) end
			end
		end
		if not ok and tool:IsA("Tool") then ok=pcall(function() tool:Activate() end) end
		if not ok then m.status="Input activation unavailable; fire manually";release();return end
		m.status="Charging equipped projectile"
		task.delay(get(m, "Charge") / 1000, function()
			if charging == tool then release() end
		end)
	end, 0.1)
end

add("Combat", "AutoClicker", "Swings or places blocks while you hold M1", function(m)
	opt(m, "CPS", "slider", 12, { min = 4, max = 20 })
	opt(m, "Place blocks", "toggle", true)
	opt(m, "Randomize", "toggle", true)
end, nil, function(m)
	if not held(M1) then
		return
	end
	if handKind() == "block" then
		if get(m, "Place blocks") then
			task.spawn(placeGrid, mouseGrid())
		end
	elseif BW.sword and BW.sword.swingSwordAtMouse then
		pcall(BW.sword.swingSwordAtMouse, BW.sword)
	else
		click(0)
	end
end, function(m)
	local base = 1 / get(m, "CPS")
	return get(m, "Randomize") and base * (0.85 + math.random() * 0.3) or base
end)

add("Combat", "Sprint", "Always sprints", nil, nil, function()
	if BW.sprint and BW.sprint.startSprinting then
		pcall(BW.sprint.startSprinting, BW.sprint)
	end
end, 0.25)

local auraFacingHumanoid, auraAutoRotate, auraFacingRoot
local function releaseAuraFacing()
	if auraFacingHumanoid and auraFacingHumanoid.Parent then auraFacingHumanoid.AutoRotate = auraAutoRotate end
	if auraFacingRoot and auraFacingRoot.Parent then
		local look = auraFacingRoot.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude > 0.001 then auraFacingRoot.CFrame = CFrame.lookAt(auraFacingRoot.Position, auraFacingRoot.Position + flat) end
	end
	auraFacingHumanoid, auraAutoRotate, auraFacingRoot = nil, nil, nil
end
local function faceAuraTarget(targetRoot, m)
	local r, h = root(), hum()
	if not r or not h or not targetRoot or h.Health <= 0 or h.Sit or h.PlatformStand then releaseAuraFacing(); return end
	local position = r.Position
	local point = Vector3.new(targetRoot.Position.X, position.Y, targetRoot.Position.Z)
	if (point - position).Magnitude < 0.001 then releaseAuraFacing(); return end
	if auraFacingHumanoid ~= h then
		releaseAuraFacing()
		auraFacingHumanoid, auraAutoRotate = h, h.AutoRotate
	end
	auraFacingRoot = r
	h.AutoRotate = false
	local pitch = 0
	local mode = m and get(m, "Pitch mode") or "Flat"
	if mode == "Target" then
		local distance = (point - position).Magnitude
		pitch = math.clamp(math.deg(math.atan2(targetRoot.Position.Y - position.Y, distance)), -60, 60)
	elseif mode == "Custom" then pitch = math.clamp(tonumber(get(m, "Pitch angle")) or 0, -60, 60) end
	r.CFrame = CFrame.lookAt(position, point) * CFrame.Angles(math.rad(pitch), 0, 0)
end

add("Blatant", "Killaura", "Attacks nearby targets with configurable timing and body rotation", function(m)
	opt(m, "Range", "slider", 20, { min = 8, max = 20, suffix = " st" })
	opt(m, "Delay", "slider", 80, { min = 20, max = 400, step = 10, suffix = "ms" })
	opt(m, "FOV", "slider", 360, { min = 30, max = 360, step = 10, suffix = "\u{B0}" })
	opt(m, "Priority", "list", "Distance", { list = { "Distance", "Health", "Angle" } })
	opt(m, "Walls", "toggle", true)
	opt(m, "Multi target", "toggle", false)
	opt(m, "Max targets", "slider", 3, { min = 1, max = 6 })
	opt(m, "Auto switch", "toggle", true)
	opt(m, "Swing", "toggle", true)
	opt(m, "Weapon cooldown", "toggle", true)
	opt(m, "Body rotation", "toggle", true)
	opt(m, "Pitch mode", "list", "Target", { list = { "Target", "Custom", "Flat" } })
	opt(m, "Pitch angle", "slider", -45, { min = -60, max = 60, step = 5, suffix = " deg (- = down)" })
end, function(on, m)
	if not on then releaseAuraFacing() end
	if on and Modules["Silent Aura"] and Modules["Silent Aura"].enabled then setOn(Modules["Silent Aura"],false) end
	setWalls(on and get(m, "Walls"))
	refreshBypass()
	if on then
		hookSwing()
	end
end, function(m)
	if menuOpen or UserInputService:GetFocusedTextBox() then releaseAuraFacing(); return end
	if not get(m, "Body rotation") then releaseAuraFacing() end
	local walls = get(m, "Walls")
	setWalls(walls)
	local delay = get(m, "Delay")
	if Modules.FastHits and Modules.FastHits.enabled then delay = math.min(delay, get(Modules.FastHits, "Delay")) end
	local cfg = { switch = get(m, "Auto switch"), swing = get(m, "Swing"), range = math.min(20, get(m, "Range")), visible = not walls, respect = get(m, "Weapon cooldown"), cooldown = delay / 1000 }
	local mode = walls and "walls" or "silent"
	if get(m, "Multi target") then
		local me = root()
		if not me or healthOf(me.Parent) <= 0 then
			releaseAuraFacing()
			return
		end
		local candidates = {}
		local priority = get(m, "Priority")
		for _, plr in ipairs(Players:GetPlayers()) do
			local model = plr.Character
			local r = model and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
			if r and r:IsA("BasePart") and enemy(plr) and model:IsDescendantOf(workspace)
				and not model:FindFirstChildOfClass("ForceField") and healthOf(model) > 0 then
				local distance = (r.Position - me.Position).Magnitude
				if distance <= cfg.range and inFov(r, get(m, "FOV")) and (walls or lineOfSight(r)) then
					local score = distance
					if priority == "Health" then
						score = healthOf(model)
					elseif priority == "Angle" and cam then
						local offset = r.Position - cam.CFrame.Position
						score = offset.Magnitude > 0.001 and -cam.CFrame.LookVector:Dot(offset.Unit) or -1
					end
					table.insert(candidates, { player = plr, root = r, score = score, distance = distance })
				end
			end
		end
		table.sort(candidates, function(a, b)
			if a.score == b.score then
				return a.distance < b.distance
			end
			return a.score < b.score
		end)
		if get(m, "Body rotation") and candidates[1] then faceAuraTarget(candidates[1].root, m)
		else releaseAuraFacing() end
		for i = 1, math.min(#candidates, get(m, "Max targets") or 3) do
			local target = candidates[i]
			cfg.swing = i == 1 and get(m, "Swing")
			sendAttack(target.player, target.root, mode, cfg)
		end
	else
		local t, r = pick(get(m, "Range"), { fov = get(m, "FOV"), visible = not walls, sort = get(m, "Priority") })
		if t and get(m, "Body rotation") then faceAuraTarget(r, m) else releaseAuraFacing() end
		if t then
			sendAttack(t, r, mode, cfg)
		end
	end
end, function(m)
	local d = get(m, "Delay")
	local fh = Modules.FastHits
	if fh and fh.enabled then
		d = math.min(d, get(fh, "Delay"))
	end
	return math.min(0.025, d / 1000)
end)

add("Blatant", "FastHits", "Overrides Killaura delay with a faster one", function(m)
	opt(m, "Delay", "slider", 35, { min = 10, max = 100, step = 5, suffix = "ms" })
end)

add("Blatant", "Fly", "WASD fly, Space up, Shift down", function(m)
	opt(m, "Speed", "slider", 60, { min = 20, max = 140, step = 2 })
	opt(m, "Vertical", "slider", 45, { min = 10, max = 120, step = 5 })
end, function(on)
	if not on then
		stopFly()
	end
end, function(m)
	flyStep(get(m, "Speed"), get(m, "Vertical"))
end, 0)

add("Blatant", "InfiniteJumps", "Jump again in mid air", function(m)
	opt(m, "Boost", "slider", 50, { min = 30, max = 120, step = 5 })
end, function(on, m)
	if on then
		table.insert(m.conns, Life.connect(UserInputService.JumpRequest, function()
			local r = root()
			if r and not menuOpen then
				r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, get(m, "Boost"), r.AssemblyLinearVelocity.Z)
			end
		end))
	end
end)

add("Blatant", "NoFall", "Cancels fall damage, fall speed stays normal", function(m)
	opt(m, "Reset timer", "toggle", true)
end, function(on)
	BW.nofall = on
	if on then
		pcall(hookFall)
	end
end, function(m)
	if not BW.fallHooked then
		pcall(hookFall)
	end
	if get(m, "Reset timer") then
		clearFall()
	end
end, 0)

add("Blatant", "Speed", "Walk faster", function(m)
	opt(m, "Speed", "slider", 23, { min = 16, max = 40 })
	opt(m, "Mode", "list", "Velocity", { list = { "Velocity", "WalkSpeed" } })
end, function(on)
	local h = hum()
	if not on and h and savedSpeed then
		h.WalkSpeed = savedSpeed
		savedSpeed = nil
	end
end, function(m)
	local h, r = hum(), root()
	if not h or not r then
		return
	end
	local zephyr = Modules["Auto Zephyr"]
	if zephyr and zephyr.enabled and zephyr.appliedHumanoid == h then return end
	if get(m, "Mode") == "WalkSpeed" then
		savedSpeed = savedSpeed or h.WalkSpeed
		h.WalkSpeed = get(m, "Speed")
	elseif h.MoveDirection.Magnitude > 0 then
		local v = h.MoveDirection.Unit * get(m, "Speed")
		r.AssemblyLinearVelocity = Vector3.new(v.X, r.AssemblyLinearVelocity.Y, v.Z)
	end
end, 0)

do
	local speeds = { 28, 32, 36, 40, 45 }
	local owner, baseline, applied
	local function release(m)
		if owner and owner.Parent and owner.WalkSpeed == applied then owner.WalkSpeed = baseline end
		owner, baseline, applied = nil, nil, nil
		m.appliedHumanoid = nil
	end
	local discoveredController, discoveryAt, moduleController = nil, -math.huge, nil
	local discoveredKeys, counterLabels = {}, {}
	local function normalize(value) return tostring(value):lower():gsub("[%s_%-]", "") end
	local function counterKey(key)
		key = normalize(key)
		if key:find("max", 1, true) or key:find("multiplier", 1, true) or key:find("duration", 1, true) or key:find("time", 1, true) then return false end
		return key:find("stack", 1, true) or key:find("feather", 1, true)
	end
	local function count(value)
		if type(value) == "table" then
			value = value.count or value.stackCount or value.stacks or (#value > 0 and #value or nil)
		elseif typeof(value) == "Instance" then
			if value:IsA("IntValue") or value:IsA("NumberValue") then value = value.Value else return end
		end
		local number = tonumber(value)
		if number and number == number and number >= 0 and number < math.huge and number % 1 == 0 then return math.min(number, 5) end
	end
	local function discover(controller)
		local visited = {}
		local function inspect(fn, depth)
			if type(fn) ~= "function" or visited[fn] or depth > 2 then return end
			visited[fn] = true
			if type(dbg.getconstants) == "function" then
				local ok, constants = pcall(dbg.getconstants, fn)
				if ok and type(constants) == "table" then
					for _, value in pairs(constants) do if type(value) == "string" and counterKey(value) then discoveredKeys[value] = true end end
				end
			end
			if type(dbg.getprotos) == "function" then
				local ok, protos = pcall(dbg.getprotos, fn)
				if ok and type(protos) == "table" then for _, fn2 in pairs(protos) do inspect(fn2, depth + 1) end end
			end
		end
		local function methods(object)
			if type(object) ~= "table" then return end
			for _, fn in pairs(object) do inspect(fn, 0) end
		end
		methods(controller)
		if type(controller) == "table" then
			pcall(function() inspect(controller.updateSpeed, 0); inspect(controller.onStart, 0) end)
		end
		local mt = type(controller) == "table" and getmetatable(controller)
		if type(mt) == "table" then methods(mt.__index) end
	end
	local function readFeathers(character, isZephyr)
		local controllers = BW.knit and BW.knit.Controllers
		local controller = controllers and (controllers.WindWalkerController or controllers.ZephyrController)
		local now = os.clock()
		if now - discoveryAt >= 1 or (controller and controller ~= discoveredController) then
			discoveryAt = now
			if not controller and not moduleController then
				pcall(function()
					for _, script in ipairs(lp.PlayerScripts:GetDescendants()) do
						if script:IsA("ModuleScript") and normalize(script.Name) == "windwalkercontroller" then
							local exports = require(script)
							moduleController = exports.WindWalkerController or exports.default
							break
						end
					end
				end)
			end
			discoveredController = controller
			discover(controller or moduleController)
			counterLabels = {}
			local pg = lp:FindFirstChildOfClass("PlayerGui")
			if pg then
				for _, label in ipairs(pg:GetDescendants()) do
					if label:IsA("TextLabel") then
						local parent, path = label, ""
						for _ = 1, 5 do if not parent or parent == pg then break end; path = path .. normalize(parent.Name); parent = parent.Parent end
						if (path:find("windwalker", 1, true) or path:find("zephyr", 1, true)) and counterKey(path) then counterLabels[#counterLabels + 1] = label end
					end
				end
			end
		end
		-- Read counter names from the game's actual controller methods, not a user-entered key.
		for _, object in ipairs({ character, lp }) do
			local attributes = object:GetAttributes()
			for key in pairs(discoveredKeys) do
				local value = count(attributes[key])
				if value ~= nil then return value, "game counter: " .. key end
			end
			for key, raw in pairs(attributes) do
				local name = normalize(key)
				local scoped = name:find("windwalker", 1, true) or name:find("zephyr", 1, true)
				local generic = name == "feathers" or name == "feathercount" or name == "windstacks" or name == "stacks" or name == "stackcount"
				if counterKey(key) and (scoped or (isZephyr and generic)) then
					local value = count(raw)
					if value ~= nil then return value, "replicated counter: " .. key end
				end
			end
		end
		if isZephyr then
			local function stateCount(state, depth, visited)
				if type(state) ~= "table" or depth > 2 or visited[state] then return end
				visited[state] = true
				for key, raw in pairs(state) do
					if counterKey(key) then local value = count(raw); if value ~= nil then return value, tostring(key) end end
				end
				for key, child in pairs(state) do
					if type(child) == "table" and (key == "state" or normalize(key):find("windwalker", 1, true) or normalize(key):find("zephyr", 1, true)) then
						local value, source = stateCount(child, depth + 1, visited)
						if value ~= nil then return value, tostring(key) .. "." .. source end
					end
				end
			end
			local value, source = stateCount(controller, 0, {})
			if value ~= nil then return value, "WindWalkerController." .. source end
			if BW.store then
				local ok, state = pcall(function() return BW.store:getState() end)
				if ok and type(state) == "table" then
					for _, branch in ipairs({ "Kit", "Kits", "Bedwars" }) do
						-- Only kit-specific WindWalker/Zephyr state, not unrelated player's counters.
						local part = state[branch]
						if type(part) == "table" then
							for key, child in pairs(part) do
								local name = normalize(key)
								if name:find("windwalker", 1, true) or name:find("zephyr", 1, true) then
									local n, path = stateCount({ state = child }, 0, {})
									if n == nil and counterKey(key) then n = count(child) end
									if n ~= nil then return n, "kit state: " .. tostring(key) .. (path and "." .. path or "") end
								end
							end
						end
					end
				end
			end
			for _, label in ipairs(counterLabels) do
				local visible, ancestor = label.Parent ~= nil, label
				while ancestor and not ancestor:IsA("PlayerGui") do
					if ancestor:IsA("GuiObject") and not ancestor.Visible then visible = false; break end
					ancestor = ancestor.Parent
				end
				if visible then
					local text = label.Text:gsub("<[^>]->", "")
					local n = text:match("^%s*(%d)%s*/%s*5%s*$") or text:match("^%s*[xX]?(%d)%s*$")
					if n and tonumber(n) <= 5 then return tonumber(n), "game feather HUD" end
				end
			end
		end
	end
	add("Kits", "Auto Zephyr", "Automatically tracks Zephyr feathers and uses 28/32/36/40/45 studs/s at stacks 1–5.", nil, function(on, m)
		if not on then release(m) end
	end, function(m)
		local character, h, r = char(), hum(), root()
		if not character or not h or not r or h.Health <= 0 then release(m); m.status = "Waiting for character"; return end
		local kit = kitOf(lp):lower():gsub("[%s_%-]", "")
		local isZephyr = kit:find("zephyr", 1, true) ~= nil or kit:find("windwalker", 1, true) ~= nil
		if kit ~= "" and not isZephyr then release(m); m.status = "Waiting for Zephyr kit"; return end
		if (Modules.Fly and Modules.Fly.enabled) or h.Sit or h.PlatformStand then release(m); m.status = "Paused during flight or while seated"; return end
		local feathers, source = readFeathers(character, isZephyr)
		if not feathers then release(m); m.status = "Waiting for game feather data (automatic detection)"; return end
		if feathers == 0 then release(m); m.status = "0 feathers | normal speed"; return end
		local speed = speeds[feathers]
		if owner ~= h then
			release(m)
			-- Release the generic Speed module's previous WalkSpeed override first.
			if savedSpeed then h.WalkSpeed = savedSpeed; savedSpeed = nil end
			owner, baseline = h, h.WalkSpeed
		elseif h.WalkSpeed ~= applied then baseline = h.WalkSpeed end
		applied = speed
		m.appliedHumanoid = h
		h.WalkSpeed = speed
		if not menuOpen and not UserInputService:GetFocusedTextBox() and h.MoveDirection.Magnitude > 0.001 then
			local direction = Vector3.new(h.MoveDirection.X, 0, h.MoveDirection.Z)
			if direction.Magnitude > 0.001 then
				local velocity = direction.Unit * speed
				r.AssemblyLinearVelocity = Vector3.new(velocity.X, r.AssemblyLinearVelocity.Y, velocity.Z)
			end
		end
		m.status = feathers .. " feathers | " .. speed .. " studs/s | " .. source
	end, 0)
end

do
	local badges={}
	local function close()
		for anchor,badge in pairs(badges) do badge:Destroy();badges[anchor]=nil end
	end
	table.insert(Life.cleanups,close)
	local function rosterAnchor(label)
		local row=label.Parent
		for _=1,4 do
			if not row or row:IsA("ScreenGui") then break end
			if row:IsA("GuiObject") and row.AbsoluteSize.X<=400 and row.AbsoluteSize.Y<=250 then
				local avatar
				for _,child in ipairs(row:GetDescendants()) do
					if (child:IsA("ImageLabel") or child:IsA("ImageButton")) and child.Name~="QW_KitBadge"
						and child.AbsoluteSize.X>=40 and child.AbsoluteSize.Y>=40 then
						if not avatar or child.AbsoluteSize.X*child.AbsoluteSize.Y>avatar.AbsoluteSize.X*avatar.AbsoluteSize.Y then avatar=child end
					end
				end
				if avatar and row.AbsoluteSize.X>=140 then return row end
			end
			row=row.Parent
		end
	end
	add("Render", "Kit Display", "Kit pictures beside avatars in the game's player roster",nil,function(on)
		if not on then close() end
	end,function(m)
		local playerGui=lp:FindFirstChildOfClass("PlayerGui")
		if not playerGui then close();return end
		local names={}
		for _,player in ipairs(Players:GetPlayers()) do
			names[player.Name:lower()]=player
			local display=player.DisplayName:lower()
			if names[display]==nil then names[display]=player elseif names[display]~=player then names[display]=false end
		end
		local seen,shown={},0
		for _,label in ipairs(playerGui:GetDescendants()) do
			if (label:IsA("TextLabel") or label:IsA("TextButton")) and label.Visible and label.AbsoluteSize.X>0 then
				local text=label.Text:gsub("<[^>]->", ""):match("^%s*(.-)%s*$"):lower()
				local player=names[text]
				if player then
					local anchor=rosterAnchor(label)
					if anchor and not seen[anchor] then
						local image=kitImage(kitOf(player))
						if image~="" then
							seen[anchor]=true
							local badge=badges[anchor]
							if not badge then
								badge=Instance.new("ImageLabel")
								badge.Name="QW_KitBadge"
								badge.AnchorPoint=Vector2.new(1,0)
								badge.Position=UDim2.new(1,0,0,0)
								badge.Size=UDim2.new(0.45,0,1,-18)
								badge.BackgroundColor3=Color3.new(0,0,0)
								badge.BackgroundTransparency=1
								badge.BorderSizePixel=0
								badge.ScaleType=Enum.ScaleType.Fit
								badge.Parent=anchor
								badges[anchor]=badge
							end
							badge.ZIndex=anchor.ZIndex+5
							badge.Image=image
							shown+=1
						end
					end
				end
			end
		end
		for anchor,badge in pairs(badges) do
			if not seen[anchor] then badge:Destroy();badges[anchor]=nil end
		end
		m.status=shown>0 and (shown .. " roster kit icons") or "Waiting for roster and replicated kits"
	end,0.5)
end

do
	local palettes = {
		Dusk = {Color3.fromRGB(255, 175, 145), Color3.fromRGB(103, 106, 180), Color3.fromRGB(242, 177, 198), 0.45},
		Frost = {Color3.fromRGB(183, 222, 255), Color3.fromRGB(86, 140, 209), Color3.fromRGB(204, 233, 255), 0.15},
		Ember = {Color3.fromRGB(255, 195, 123), Color3.fromRGB(134, 69, 110), Color3.fromRGB(255, 170, 131), 0.7},
	}
	local atmosphere, clouds, sky, originalAtmosphere, originalClouds, originalSky
	local applied
	add("Render", "Custom Skies", "Change the local horizon, clouds, and star field", function(m)
		opt(m, "Sky preset", "list", "Dusk", {list = {"Dusk", "Frost", "Ember"}})
	end, function(on)
		if on then
			originalAtmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			originalClouds = workspace.Terrain:FindFirstChildOfClass("Clouds")
			originalSky = Lighting:FindFirstChildOfClass("Sky")
			atmosphere = Instance.new("Atmosphere")
			clouds = Instance.new("Clouds")
			sky = originalSky and originalSky:Clone() or Instance.new("Sky")
			if originalAtmosphere then originalAtmosphere.Parent = nil end
			if originalClouds then originalClouds.Parent = nil end
			if originalSky then originalSky.Parent = nil end
			atmosphere.Parent = Lighting
			clouds.Parent = workspace.Terrain
			sky.Parent = Lighting
		else
			if atmosphere then atmosphere:Destroy() end
			if clouds then clouds:Destroy() end
			if sky then sky:Destroy() end
			if originalAtmosphere then originalAtmosphere.Parent = Lighting end
			if originalClouds then originalClouds.Parent = workspace.Terrain end
			if originalSky then originalSky.Parent = Lighting end
			atmosphere, clouds, sky = nil, nil, nil
			originalAtmosphere, originalClouds, originalSky, applied = nil, nil, nil, nil
		end
	end, function(m)
		local preset = get(m, "Sky preset")
		if preset == applied then return end
		local palette = palettes[preset]
		atmosphere.Color = palette[1]
		atmosphere.Decay = palette[2]
		atmosphere.Density = 0.27
		atmosphere.Haze = 1.8
		atmosphere.Glare = 0.15
		clouds.Color = palette[3]
		clouds.Cover = palette[4]
		clouds.Density = 0.65
		sky.StarCount = preset == "Frost" and 4500 or 2200
		applied = preset
	end)

	local grade
	local tints = {
		Cool = Color3.fromRGB(188, 220, 255),
		Warm = Color3.fromRGB(255, 219, 180),
		Neutral = Color3.new(1, 1, 1),
	}
	add("Render", "Color Grade", "Add a cool, warm, or neutral color grade with adjustable contrast", function(m)
		opt(m, "Tone", "list", "Cool", {list = {"Cool", "Warm", "Neutral"}})
		opt(m, "Strength", "slider", 35, {min = 0, max = 100, suffix = "%"})
	end, function(on)
		if on then
			grade = Instance.new("ColorCorrectionEffect")
			grade.Name = "FalconColorGrade"
			grade.Parent = Lighting
		elseif grade then
			grade:Destroy()
			grade = nil
		end
	end, function(m)
		local strength = get(m, "Strength") / 100
		grade.TintColor = Color3.new(1, 1, 1):Lerp(tints[get(m, "Tone")], strength)
		grade.Contrast = 0.18 * strength
		grade.Saturation = 0.12 * strength
	end)
end

do
	local function isRig(candidate)
		return candidate:IsA("Model") or candidate:IsA("Folder") or candidate:IsA("BasePart")
	end
	function Life.findViewmodel(currentCamera)
		local controllers = BW.knit and BW.knit.Controllers
		local controller = controllers and (controllers.ViewmodelController or controllers.ViewModelController)
		local candidate = controller and (controller.viewmodel or controller.viewModel)
		if typeof(candidate) == "Instance" and isRig(candidate) and candidate:IsDescendantOf(currentCamera) then
			return candidate
		end
		for _, child in ipairs(currentCamera:GetDescendants()) do
			local name = child.Name:lower():gsub("[%s_%-]", "")
			if name == "viewmodel" and isRig(child) then
				return child
			end
		end
	end
end

do
	local started, moved, original, applied
	local function restoreSwing()
		if moved and moved.Parent and moved:GetPivot():FuzzyEq(applied) then moved:PivotTo(original) end
		moved, original, applied = nil, nil, nil
	end
	function Life.playLocalSwordSwing()
		if BW.sword and type(BW.sword.playSwordEffect) == "function" then
			pcall(BW.sword.playSwordEffect, BW.sword)
		end
		if Modules["Hand Motion"].enabled and Life.previewSwordSwing and Life.previewSwordSwing() then return end
		if started then return end
		local camera = workspace.CurrentCamera
		local rig = camera and Life.findViewmodel(camera)
		if not rig or not rig:IsA("Model") then return end
		started = os.clock()
		RunService:BindToRenderStep("FalconAuraSwing", Enum.RenderPriority.Last.Value + 1, function()
			restoreSwing()
			local phase = (os.clock() - started) / 0.24
			if phase >= 1 or workspace.CurrentCamera ~= camera or not rig:IsDescendantOf(camera) then
				RunService:UnbindFromRenderStep("FalconAuraSwing")
				started = nil
				return
			end
			local arc = math.sin(math.pi * phase)
			moved, original = rig, rig:GetPivot()
			local offset = CFrame.new(-0.18 * arc, -0.30 * arc, 0) * CFrame.Angles(-0.66 * arc, 0.34 * arc, -0.58 * arc)
			applied = camera.CFrame * offset * camera.CFrame:ToObjectSpace(original)
			rig:PivotTo(applied)
		end)
	end
	function Life.stopLocalSwordSwing()
		RunService:UnbindFromRenderStep("FalconAuraSwing")
		started = nil
		restoreSwing()
	end
end

do
	local rig, camera, nextLookup, elapsed
	local swingStyle
	local function startSwing(m)
		elapsed = 0
		local style = get(m, "Sword style")
		swingStyle = style ~= "Classic" and handKind() == "sword" and style or "Classic"
	end
	local function swingPose(phase, strength)
		local arc = math.sin(math.pi * phase) ^ 2 * strength
		local sweep = math.sin(2 * math.pi * phase) * arc
		if swingStyle == "Reverse Slash" then
			return CFrame.new(-0.25 * arc, -0.16 * arc, 0) * CFrame.Angles(math.rad(-34) * arc, math.rad(-58) * arc, math.rad(92) * arc)
		elseif swingStyle == "Flourish" then
			return CFrame.new(0.30 * sweep, -0.24 * arc, 0) * CFrame.Angles(math.rad(-50) * arc, math.rad(45) * sweep, math.rad(140) * sweep)
		elseif swingStyle == "Heavy Swing" then
			return CFrame.new(0.18 * sweep, -0.42 * arc, 0.24 * sweep) * CFrame.Angles(math.rad(105) * sweep, math.rad(60) * arc, math.rad(-48) * arc)
		end
		return CFrame.new(0.26 * arc, -0.36 * arc, -0.20 * arc)
			* CFrame.Angles(math.rad(-52) * arc, math.rad(18) * arc, math.rad(-34) * arc)
	end
	local joints = {}
	local held = {}
	local drawnPivot, basePivot
	local function restorePose()
		if drawnPivot and rig and rig.Parent and rig:GetPivot():FuzzyEq(drawnPivot) then
			rig:PivotTo(basePivot)
		end
		drawnPivot, basePivot = nil, nil
		for joint, pose in pairs(joints) do
			if pose.drawn and joint.Parent and joint.Transform:FuzzyEq(pose.drawn) then
				joint.Transform = pose.original
			end
			pose.drawn = nil
		end
	end

	local function trackJoint(joint)
		if joint:IsA("Motor6D") and not joints[joint] then joints[joint] = {} end
	end
	local function useInput(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonR2
	end
	add("Render", "Hand Motion", "Smooth, slow first-person swings and item use", function(m)
		opt(m, "Duration", "slider", 720, {min = 350, max = 1200, step = 10, suffix = " ms"})
		opt(m, "Intensity", "slider", 55, {min = 0, max = 100, suffix = "%"})
		opt(m, "Sword style", "list", "Classic", {list = {"Classic", "Reverse Slash", "Flourish", "Heavy Swing"}})
	end, function(on, m)
		if not on then
			RunService:UnbindFromRenderStep("FalconHandDraw")
			Life.previewSwordSwing = nil
			restorePose()
			table.clear(joints)
			table.clear(held)
			rig, camera, elapsed = nil, nil, nil
			m.status = nil
			return
		end
		m.status = "Waiting for first-person hands"
		Life.previewSwordSwing = function()
			if menuOpen or not rig or not rig.Parent then return false end
			if not elapsed then startSwing(m) end
			return true
		end
		table.insert(m.conns, UserInputService.InputBegan:Connect(function(input)
			-- The game's action bindings can mark item use as processed.
			if menuOpen or UserInputService:GetFocusedTextBox() or not useInput(input) then return end
			held[input] = true
			if not elapsed then startSwing(m) end
		end))
		table.insert(m.conns, UserInputService.InputEnded:Connect(function(input)
			held[input] = nil
		end))
		table.insert(m.conns, UserInputService.WindowFocusReleased:Connect(function()
			table.clear(held)
			elapsed = nil
		end))
		table.insert(m.conns, RunService.PreAnimation:Connect(restorePose))
		table.insert(m.conns, RunService.PreSimulation:Connect(function(dt)
			local currentCamera = workspace.CurrentCamera
			if camera ~= currentCamera or (rig and not rig:IsDescendantOf(camera)) then
				camera, rig, nextLookup = currentCamera, nil, nil
				table.clear(joints)
			end
			if not camera then return end
			local now = os.clock()
			if not nextLookup or now >= nextLookup then
				nextLookup = now + 0.25
				rig = rig or Life.findViewmodel(camera)
				if rig then
					for _, child in ipairs(rig:GetDescendants()) do trackJoint(child) end
					-- Some rigs put the wrist motor next to the named viewmodel part.
					if rig:IsA("BasePart") then
						for _, child in ipairs(rig.Parent:GetChildren()) do trackJoint(child) end
					end
				end
			end
			m.status = rig and "First-person hands detected" or "Waiting for first-person hands"
			if menuOpen or UserInputService:GetFocusedTextBox() then
				table.clear(held)
				elapsed = nil
			end
			if not rig then elapsed = nil; return end

			local duration = get(m, "Duration") / 1000
			local strength = get(m, "Intensity") / 100
			if elapsed then
				elapsed = math.min(elapsed + dt, duration)
			elseif next(held) then
				startSwing(m)
			end
			local phase = elapsed and elapsed / duration or 0
			for joint, pose in pairs(joints) do
				local part0, part1 = joint.Part0, joint.Part1
				if not joint:IsDescendantOf(camera) then
					joints[joint] = nil
				elseif part0 and part1 and part0:IsDescendantOf(camera) and part1:IsDescendantOf(camera)
					and (part0 == rig or part1 == rig or part1:IsDescendantOf(rig)) then
					local current = joint.Transform
					if not elapsed or strength == 0 then
						pose.smooth = current
					else
						local response = 1 - math.exp(-dt / (duration * 0.35))
						pose.smooth = (pose.smooth or current):Lerp(current, response)
						local blend = strength * (1 - math.clamp((phase - 0.72) / 0.28, 0, 1))
						pose.original = current
						pose.drawn = current:Lerp(pose.smooth, blend)
						-- A folder or part can have an animated wrist but no model pivot.
						if not rig:IsA("Model") and (part0 == rig or part0.Parent == rig) then
							pose.drawn *= swingPose(phase, strength)
						end
						joint.Transform = pose.drawn
					end
				end
			end
		end))
		RunService:BindToRenderStep("FalconHandDraw", Enum.RenderPriority.Last.Value + 1, function()
			if not elapsed or not rig or not camera or camera ~= workspace.CurrentCamera or not rig:IsDescendantOf(camera) then return end
			local phase = elapsed / (get(m, "Duration") / 1000)
			if phase >= 1 then elapsed = nil; return end
			if not rig:IsA("Model") then return end
			local strength = get(m, "Intensity") / 100
			if strength == 0 then return end
			local offset = swingPose(phase, strength)
			basePivot = rig:GetPivot()
			drawnPivot = camera.CFrame * offset * camera.CFrame:ToObjectSpace(basePivot)
			rig:PivotTo(drawnPivot)
		end)
	end)
end

do
	local catalog, itemKeys = {}, {}
	local catalogStatus
	local finishes
	local function getFinishes()
		if not finishes then
			finishes = {
				["Falcon Steel"] = {Color3.fromRGB(180, 195, 211), Enum.Material.Metal},
				["Falcon Obsidian"] = {Color3.fromRGB(42, 34, 52), Enum.Material.Slate},
				["Falcon Ember"] = {Color3.fromRGB(255, 109, 51), Enum.Material.Neon},
			}
		end
		return finishes
	end
	local function key(name)
		return name:lower():gsub("[%s%-]+", "_"):gsub("[^%w_]", "")
	end
	local function title(name)
		return (name:gsub("_", " "):gsub("%f[%a]%a", string.upper))
	end
	local function family(item)
		if item:find("pickaxe", 1, true) then return "Pickaxes" end
		if item:find("sword", 1, true) then return "Swords" end
		if item:find("axe", 1, true) then return "Axes" end
	end
	local function register(group, item, asset)
		if not itemKeys[item] or group == "" then return end
		if not (asset:IsA("Model") or asset:IsA("BasePart") or asset:IsA("Tool")) then return end
		if not asset:IsA("BasePart") and not asset:FindFirstChildWhichIsA("BasePart", true) then return end
		local name = title(group)
		if name == "Original" then return end
		catalog[name] = catalog[name] or {}
		catalog[name][item] = catalog[name][item] or asset
	end
	local function indexSkins(m)
		local targets = {"All", "Swords", "Pickaxes", "Axes"}
		local items = {}
		for item in pairs(BW.itemMeta or {}) do
			if type(item) == "string" and family(item) then itemKeys[key(item)] = true end
		end
		for _, tier in ipairs({"wood", "stone", "iron", "diamond", "emerald"}) do
			for _, tool in ipairs({"sword", "pickaxe", "axe"}) do itemKeys[tier .. "_" .. tool] = true end
		end
		for item in pairs(itemKeys) do table.insert(items, item) end
		table.sort(items)
		for _, item in ipairs(items) do table.insert(targets, title(item)) end
		m.options.Item.list = targets
		catalog = {}
		for _, folder in ipairs(ReplicatedStorage:GetDescendants()) do
			if folder:IsA("Folder") or folder:IsA("Model") then
				local folderKey = key(folder.Name):gsub("_", "")
				if folderKey == "itemskins" or folderKey == "weaponskins" or folderKey == "toolskins" then
					for _, group in ipairs(folder:GetChildren()) do
						local groupKey = key(group.Name)
						for _, asset in ipairs(group:GetChildren()) do
							local assetKey = key(asset.Name)
							if itemKeys[groupKey] then
								register(assetKey, groupKey, asset)
							else
								register(groupKey, assetKey, asset)
							end
						end
						for _, item in ipairs(items) do
							local prefix, suffix = item .. "_", "_" .. item
							if groupKey:sub(1, #prefix) == prefix then
								register(groupKey:sub(#prefix + 1), item, group)
							elseif groupKey:sub(-#suffix) == suffix then
								register(groupKey:sub(1, -#suffix - 1), item, group)
							end
						end
					end
				end
			end
		end
		local skins = {}
		for name in pairs(catalog) do table.insert(skins, name) end
		table.sort(skins)
		local count = #skins
		for name in pairs(getFinishes()) do table.insert(skins, name) end
		table.sort(skins)
		table.insert(skins, 1, "Original")
		m.options.Skin.list = skins
		catalogStatus = count .. " game skins found · 3 Falcon finishes"
		m.status = catalogStatus
	end

	local active = {}
	local function remove(slot)
		if not slot then return end
		slot.model:Destroy()
		for part, transparency in pairs(slot.hidden) do
			if part.Parent and part.LocalTransparencyModifier == 1 then
				part.LocalTransparencyModifier = transparency
			end
		end
	end
	local function clear()
		for _, slot in pairs(active) do remove(slot) end
		table.clear(active)
	end
	local function handle(item)
		if item:IsA("BasePart") then return item end
		return item:FindFirstChild("Handle", true) or item:FindFirstChildWhichIsA("BasePart", true)
	end
	local function attach(source, item, camera, finish)
		local grip, assetGrip = handle(item), handle(source)
		if not grip or not grip:IsA("BasePart") or not assetGrip or not assetGrip:IsA("BasePart") then return end
		local model = Instance.new("Model")
		model.Name = "FalconLocalSkin"
		local slot = {model = model, grip = grip, item = item, source = source, finish = finish, hidden = {}, parts = {}}
		local originals = source:GetDescendants()
		if source:IsA("BasePart") then table.insert(originals, source) end
		for _, part in ipairs(originals) do
			if part:IsA("BasePart") and part.Archivable then
				local copy = part:Clone()
				if copy then
					for _, child in ipairs(copy:GetDescendants()) do
						if not (child:IsA("DataModelMesh") or (not finish and (child:IsA("Decal") or child:IsA("SurfaceAppearance")))) then
							child:Destroy()
						end
					end
					if finish then
						copy.Color, copy.Material = finish[1], finish[2]
						copy.MaterialVariant = ""
						if copy:IsA("MeshPart") then copy.TextureID = "" end
						local mesh = copy:FindFirstChildOfClass("SpecialMesh")
						if mesh then
							mesh.TextureId = ""
							mesh.VertexColor = Vector3.new(finish[1].R, finish[1].G, finish[1].B)
						end
					end
					copy.Anchored = true
					copy.CanCollide, copy.CanTouch, copy.CanQuery = false, false, false
					copy.LocalTransparencyModifier = 0
					local offset = assetGrip.CFrame:ToObjectSpace(part.CFrame)
					copy.CFrame = grip.CFrame * offset
					copy.Parent = model
					slot.parts[copy] = offset
				end
			end
		end
		if not next(slot.parts) then model:Destroy(); return end
		local hidden = item:GetDescendants()
		if item:IsA("BasePart") then table.insert(hidden, item) end
		for _, part in ipairs(hidden) do
			if part:IsA("BasePart") then
				slot.hidden[part] = part.LocalTransparencyModifier
				part.LocalTransparencyModifier = 1
			end
		end
		model.Parent = camera
		return slot
	end
	local function display(slotName, item, source, camera, finish)
		source = source or item
		local slot = active[slotName]
		if slot and (slot.item ~= item or slot.source ~= source or slot.finish ~= finish or slot.model.Parent ~= camera or not slot.grip.Parent) then
			remove(slot)
			active[slotName], slot = nil, nil
		end
		if item and not slot then active[slotName] = attach(source, item, camera, finish) end
	end
	local function viewItem(rig, itemName)
		if not rig then return end
		for _, item in ipairs(rig:GetDescendants()) do
			if key(item.Name) == itemName and (item:IsA("Model") or item:IsA("BasePart") or item:IsA("Tool")) then
				return item
			end
		end
	end
	local changer = add("Render", "Skin Changer", "Use locally available skins on your held swords and tools", function(m)
		opt(m, "Item", "list", "All", {list = {"All"}})
		opt(m, "Skin", "list", "Original", {list = {"Original"}})
		opt(m, "Refresh skins", "action", nil)
		m.options["Refresh skins"].callback = function() indexSkins(m) end
	end, function(on, m)
		if not on then
			RunService:UnbindFromRenderStep("FalconLocalSkin")
			clear()
			return
		end
		indexSkins(m)
		RunService:BindToRenderStep("FalconLocalSkin", Enum.RenderPriority.Last.Value + 2, function()
			for _, slot in pairs(active) do
				if slot.grip.Parent then
					for part, offset in pairs(slot.parts) do part.CFrame = slot.grip.CFrame * offset end
					for part in pairs(slot.hidden) do
						if part.Parent and part.LocalTransparencyModifier ~= 1 then
							slot.hidden[part] = part.LocalTransparencyModifier
							part.LocalTransparencyModifier = 1
						end
					end
				end
			end
		end)
	end, function(m)
		local camera, character = workspace.CurrentCamera, char()
		local hand = inventory()
		hand = hand and hand.hand
		local item = hand and key(hand.itemType or "")
		local target, skin = get(m, "Item"), get(m, "Skin")
		if not (camera and character and item and (target == "All" or target == family(item) or key(target) == item)) then
			clear()
			m.status = catalogStatus
			return
		end
		local template = catalog[skin] and catalog[skin][item]
		local finish = getFinishes()[skin]
		if not template and not finish then
			clear()
			m.status = skin == "Original" and catalogStatus or "No " .. skin .. " model for " .. title(item)
			return
		end
		local firstPerson = viewItem(Life.findViewmodel(camera), item)
		local head = character:FindFirstChild("Head")
		local inFirstPerson = (camera.CFrame.Position - camera.Focus.Position).Magnitude < 1.7
			or (head and (camera.CFrame.Position - head.Position).Magnitude < 1.7)
		local ref = character:FindFirstChild("HandInvItem")
		local equipped = ref and ref:IsA("ObjectValue") and ref.Value or hand.tool
		if typeof(equipped) ~= "Instance" or not equipped:IsDescendantOf(character) then
			equipped = character:FindFirstChildOfClass("Tool")
			if equipped and key(equipped.Name) ~= item then equipped = nil end
		end
		if equipped and not (inFirstPerson and firstPerson) then
			display("world", equipped, template, camera, finish)
		else
			display("world", nil, nil, camera)
		end
		display("firstPerson", inFirstPerson and firstPerson or nil, template, camera, finish)
		m.status = next(active) and skin .. " · " .. title(item) or "Waiting for the held item model"
	end, 0.08)
	-- Populate lists before saved options are validated.
	Life.indexItemSkins = function() indexSkins(changer) end
end

do
	local styles = {
		pearl = {option = "Pearls", glyph = "◆", color = Color3.fromRGB(87, 246, 199), items = {"telepearl", "teleport_pearl", "ender_pearl", "pearl"}},
		fireball = {option = "Fireballs", glyph = "✦", color = Color3.fromRGB(255, 152, 85), items = {"fireball"}},
		arrow = {option = "Arrows", glyph = "➤", color = Color3.fromRGB(221, 230, 255), items = {"arrow"}},
	}
	local markers = {}
	local function classify(name)
		name = name:lower():gsub("[^%w]", "")
		if name:find("pearl", 1, true) then return styles.pearl end
		if name:find("fireball", 1, true) then return styles.fireball end
		if name:find("arrow", 1, true) then return styles.arrow end
	end
	local function projectileStyle(object)
		local kind = object:GetAttribute("ProjectileType") or object:GetAttribute("projectileType")
		if type(kind) == "string" then return classify(kind) end
		local style = classify(object.Name)
		if style then return style end
		for _, tag in ipairs(CollectionService:GetTags(object)) do
			style = classify(tag)
			if style then return style end
		end
	end
	local function remove(object, marker)
		marker.gui:Destroy()
		marker.trail:Destroy()
		marker.left:Destroy()
		marker.right:Destroy()
		markers[object] = nil
	end
	local function mark(object)
		if markers[object] or not (object:IsA("BasePart") or object:IsA("Model")) then return end
		local style = projectileStyle(object)
		if not style then return end
		local part = object:IsA("BasePart") and object or object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
		if not part or part:FindFirstChild("FalconProjectileIcon") then return end
		-- Skip held items. Only follow independent, moving world objects.
		local ancestor = part.Parent
		while ancestor and ancestor ~= workspace do
			if ancestor:IsA("Tool") or ancestor:IsA("Camera") or (ancestor:IsA("Model") and ancestor:FindFirstChildOfClass("Humanoid")) then return end
			ancestor = ancestor.Parent
		end
		local gui = Instance.new("BillboardGui")
		gui.Name = "FalconProjectileIcon"
		gui.Adornee = part
		gui.StudsOffsetWorldSpace = Vector3.new(0, 1.4, 0)
		gui.MaxDistance = 220
		gui.Enabled = false
		gui.Parent = part
		local icon = Instance.new("ImageLabel")
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.fromScale(1, 1)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Parent = gui
		for _, item in ipairs(style.items) do
			local meta = metaOf(item)
			local asset = meta and meta.image
			if type(asset) == "number" then asset = "rbxassetid://" .. asset end
			if type(asset) == "string" and asset ~= "" then icon.Image = asset; break end
		end
		local glyph = Instance.new("TextLabel")
		glyph.BackgroundTransparency = 1
		glyph.Size = UDim2.fromScale(1, 1)
		glyph.TextScaled = true
		glyph.Font = Enum.Font.GothamBold
		glyph.TextColor3 = style.color
		glyph.TextStrokeTransparency = 0.25
		glyph.Text = style.glyph
		glyph.Visible = icon.Image == ""
		glyph.Parent = gui
		local left, right = Instance.new("Attachment"), Instance.new("Attachment")
		left.Position, right.Position = Vector3.new(0, -0.12, 0), Vector3.new(0, 0.12, 0)
		left.Parent, right.Parent = part, part
		local trail = Instance.new("Trail")
		trail.Attachment0, trail.Attachment1 = left, right
		trail.Color = ColorSequence.new(style.color)
		trail.Transparency = NumberSequence.new(0.32, 1)
		trail.Lifetime = 0.22
		trail.Enabled = false
		trail.Parent = part
		markers[object] = {style = style, gui = gui, trail = trail, left = left, right = right, part = part, position = part.Position}
	end
	add("Render", "Projectile Icons", "Follow flying pearls, fireballs, and arrows with item icons", function(m)
		for _, option in ipairs({"Pearls", "Fireballs", "Arrows", "Trails"}) do opt(m, option, "toggle", true) end
		opt(m, "Icon size", "slider", 23, {min = 14, max = 36, suffix = " px"})
	end, function(on, m)
		if not on then
			for object, marker in pairs(markers) do remove(object, marker) end
			return
		end
		table.insert(m.conns, workspace.DescendantAdded:Connect(function(object)
			if not (object:IsA("BasePart") or object:IsA("Model")) then return end
			task.defer(function()
				if m.enabled and object:IsDescendantOf(workspace) then mark(object) end
			end)
		end))
		for _, object in ipairs(workspace:GetDescendants()) do mark(object) end
	end, function(m)
		local size = get(m, "Icon size")
		for object, marker in pairs(markers) do
			if not marker.part:IsDescendantOf(workspace) then
				remove(object, marker)
			else
				local position = marker.part.Position
				local moving = (position - marker.position).Magnitude > 0.14
					or marker.part.AssemblyLinearVelocity.Magnitude > 4
				marker.position = position
				local visible = moving and get(m, marker.style.option)
				marker.gui.Size = UDim2.fromOffset(size, size)
				marker.gui.Enabled = visible
				marker.trail.Enabled = visible and get(m, "Trails")
			end
		end
	end, 0.05)
end

add("Render", "Nametabs", "Compact name and health tags with kit, equipped armor, and held-item icons", function(m)
	opt(m, "Range", "slider", 300, { min = 50, max = 1000, step = 50, suffix = " st" })
	opt(m, "Text size", "slider", 12, { min = 9, max = 20 })
	opt(m, "Icon size", "slider", 16, { min = 12, max = 26 })
	opt(m, "Names", "toggle", true)
	opt(m, "Health", "toggle", true)
	opt(m, "Health format", "list", "Number", {list={"Number","Fraction"}})
	opt(m, "Background", "toggle", true)
	opt(m, "Health bar", "toggle", true)
	opt(m, "Kit", "toggle", true)
	opt(m, "Armor", "toggle", true)
	opt(m, "Held item", "toggle", true)
	opt(m, "Team color", "toggle", false)
	opt(m, "Distance", "toggle", false)
	opt(m, "Teammates", "toggle", false)
	opt(m, "Highlight", "toggle", false)
end, function() drawESP(true) end, function() drawESP() end, 0.1)

do
	local function tag(part)
		local gui=Instance.new("BillboardGui")
		gui.Name="QW_BedTag"
		gui.Size=UDim2.fromOffset(150,48)
		gui.StudsOffset=Vector3.new(0,3,0)
		gui.AlwaysOnTop=true
		gui.Adornee=part
		gui.Parent=part
		local backing=Instance.new("Frame")
		backing.Size=UDim2.fromScale(1,1)
		backing.BackgroundColor3=Color3.fromRGB(13,16,23)
		backing.BackgroundTransparency=0.15
		backing.BorderSizePixel=0
		backing.Parent=gui
		local corner=Instance.new("UICorner")
		corner.CornerRadius=UDim.new(0,7)
		corner.Parent=backing
		local edge=Instance.new("UIStroke")
		edge.Color=Color3.fromRGB(84,91,112)
		edge.Transparency=0.5
		edge.Parent=backing
		local title=Instance.new("TextLabel")
		title.Name="Title"
		title.Size=UDim2.new(1,-12,0,21)
		title.Position=UDim2.fromOffset(6,4)
		title.BackgroundTransparency=1
		title.Font=Enum.Font.GothamBold
		title.TextSize=12
		title.Parent=gui
		local distance=title:Clone()
		distance.Name="Distance"
		distance.Position=UDim2.fromOffset(6,23)
		distance.Font=Enum.Font.Gotham
		distance.TextSize=11
		distance.TextColor3=Color3.fromRGB(179,186,205)
		distance.Parent=gui
		return gui
	end
	add("Render","BedESP","Team-colored enemy-bed markers with distance and configurable outlines",function(m)
		opt(m,"Range","slider",600,{min=50,max=1500,step=50,suffix=" st"})
		opt(m,"Distance","toggle",true)
		opt(m,"Team color","toggle",true)
		opt(m,"Highlight","toggle",true)
		opt(m,"Through walls","toggle",true)
		opt(m,"Fill","slider",15,{min=0,max=60,step=5,suffix="%"})
	end,function(on) if not on then wipe(bEsp) end end,function(m)
		local me=root()
		local seen={}
		for _,bed in ipairs(beds()) do
			local p=posOf(bed)
			local part=bed:IsA("BasePart") and bed or bed:FindFirstChildWhichIsA("BasePart",true)
			if me and p and part and (p-me.Position).Magnitude<=get(m,"Range") then
				seen[bed]=true
				local team=bed:GetAttribute("Team") or bed:GetAttribute("TeamId")
				local cover=bed:FindFirstChild("Covers")
				local col=Color3.fromRGB(255,112,128)
				if get(m,"Team color") then
					col=(team and TEAM_COLORS[tostring(team)]) or (cover and cover:IsA("BasePart") and cover.Color) or col
				end
				local e=bEsp[bed] or {}
				bEsp[bed]=e
				if get(m,"Highlight") then
					if not e.h or not e.h.Parent then e.h=hl(bed,col) end
					e.h.FillColor,e.h.OutlineColor=col,col
					e.h.FillTransparency=1-get(m,"Fill")/100
					e.h.DepthMode=get(m,"Through walls") and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
				elseif e.h then e.h:Destroy();e.h=nil end
				if not e.b or not e.b.Parent then e.b=tag(part) end
				e.b.Adornee=part
				e.b.AlwaysOnTop=get(m,"Through walls")
				local title=team and TEAM_COLORS[tostring(team)] and (tostring(team):upper() .. " BED") or "ENEMY BED"
				e.b.Title.Text=title
				e.b.Title.TextColor3=col
				e.b.Distance.Visible=get(m,"Distance")
				e.b.Distance.Text=math.floor((p-me.Position).Magnitude+0.5) .. " studs"
			end
		end
		for bed,e in pairs(bEsp) do
			if not seen[bed] then
				if e.h then e.h:Destroy() end
				if e.b then e.b:Destroy() end
				bEsp[bed]=nil
			end
		end
	end,0.2)
end


add("Render", "TargetInfo", "Shows your closest target", function(m)
	opt(m, "Range", "slider", 24, { min = 8, max = 60, suffix = " st" })
end)

local RANK_LIST = {
	"Bronze 1", "Bronze 2", "Bronze 3", "Bronze 4",
	"Silver 1", "Silver 2", "Silver 3", "Silver 4",
	"Gold 1", "Gold 2", "Gold 3", "Gold 4",
	"Platinum 1", "Platinum 2", "Platinum 3", "Platinum 4",
	"Diamond 1", "Diamond 2", "Diamond 3", "Diamond 4",
	"Emerald 1", "Emerald 2", "Emerald 3", "Emerald 4",
	"Nightmare",
}

local RANK_COLOR = {
	Bronze = Color3.fromRGB(176, 112, 64),
	Silver = Color3.fromRGB(198, 206, 214),
	Gold = Color3.fromRGB(255, 190, 60),
	Platinum = Color3.fromRGB(55, 230, 220),
	Diamond = Color3.fromRGB(70, 150, 255),
	Emerald = Color3.fromRGB(50, 210, 130),
	Nightmare = Color3.fromRGB(186, 92, 255),
}

local RANK_IMAGE = {
	Bronze = "rbxassetid://7904293227",
	Silver = "rbxassetid://7904292748",
	Gold = "rbxassetid://7904293006",
	Platinum = "rbxassetid://7904292835",
	Diamond = "rbxassetid://7904293114",
	Emerald = "rbxassetid://12599231807",
	Nightmare = "rbxassetid://107117112416767",
}

local function tierOf(rank)
	return (string.match(tostring(rank or ""), "^(%a+)") or "Platinum")
end

local function asExecutor()
	if type(setthreadidentity) == "function" then
		pcall(setthreadidentity, 8)
	elseif type(syn) == "table" and type(syn.set_thread_identity) == "function" then
		pcall(syn.set_thread_identity, 8)
	end
end

local rankMeta
local function loadRankMeta()
	if rankMeta then
		return rankMeta
	end
	pcall(function()
		rankMeta = require(ReplicatedStorage.TS.rank["rank-meta"]).RankMeta
	end)
	if type(rankMeta) == "table" then
		for _, div in pairs(rankMeta) do
			if type(div) == "table" and type(div.name) == "string" and type(div.image) == "string" then
				RANK_IMAGE[tierOf(div.name)] = div.image
			end
		end
	end
	return rankMeta
end

local function imageForRank(rank)
	loadRankMeta()
	local want = string.lower(tostring(rank or ""))
	if type(rankMeta) == "table" then
		for _, div in pairs(rankMeta) do
			if type(div) == "table" and type(div.name) == "string" and string.lower(div.name) == want and type(div.image) == "string" then
				return div.image
			end
		end
	end
	return RANK_IMAGE[tierOf(rank)]
end

local function isRankImage(image)
	local id = string.match(tostring(image or ""), "%d+")
	if not id then
		return false
	end
	loadRankMeta()
	for _, asset in pairs(RANK_IMAGE) do
		if string.find(asset, id, 1, true) then
			return true
		end
	end
	if type(rankMeta) == "table" then
		for _, div in pairs(rankMeta) do
			if type(div) == "table" and type(div.image) == "string" and string.find(div.image, id, 1, true) then
				return true
			end
		end
	end
	return false
end

local function rankColor(rank)
	loadRankMeta()
	local want = string.lower(tostring(rank or ""))
	if type(rankMeta) == "table" then
		for _, div in pairs(rankMeta) do
			if type(div) == "table" and type(div.name) == "string" and string.lower(div.name) == want then
				for _, key in ipairs({ "color", "progressColor", "barColor", "backgroundColor" }) do
					if typeof(div[key]) == "Color3" then
						return div[key]
					end
				end
			end
		end
	end
	return RANK_COLOR[tierOf(rank)] or RANK_COLOR.Platinum
end

local function rpParts(m)
	local rank = tostring(get(m, "Rank") or "Nightmare")
	if tierOf(rank) == "Nightmare" then
		local raw = math.clamp(math.floor(tonumber(get(m, "Nightmare RP")) or tonumber(get(m, "RP")) or 0), 0, 1000)
		return rank, raw, 0, string.format("%d RP", raw)
	end
	local shown = math.clamp(math.floor(tonumber(get(m, "RP")) or 0), 0, 100)
	return rank, shown, 100, string.format("%d RP / 100", shown)
end

local function plainText(text)
	text = string.gsub(tostring(text or ""), "<.->", "")
	text = string.gsub(text, "\n", " ")
	return string.match(text, "^%s*(.-)%s*$") or text
end

local function isRpLine(text)
	local plain = plainText(text)
	if plain == "" or #plain > 32 then
		return false
	end
	local lower = string.lower(plain)
	if string.find(lower, "leaderboard", 1, true) or not string.find(lower, "rp", 1, true) then
		return false
	end
	return string.find(plain, "%d") ~= nil
end

local nmTrack, nmEffect, nmFollow, nmAsset, nmLooked, nmMissing, nmKey, nmSent
local function stopNm()
	if nmFollow then
		pcall(function()
			RunService:UnbindFromRenderStep("QW_NMFollow")
		end)
		nmFollow = false
	end
	local h = hum()
	if h then
		for _, track in ipairs(h:GetPlayingAnimationTracks()) do
			if track == nmTrack or string.find(string.lower(tostring(track.Name)), "nightmare", 1, true) then
				pcall(function()
					track:Stop(0.05)
				end)
			end
		end
	end
	if nmTrack then
		pcall(function()
			nmTrack:Stop(0.05)
			nmTrack:Destroy()
		end)
		nmTrack = nil
	end
	if nmEffect then
		nmEffect:Destroy()
		nmEffect = nil
	end
	local c = char()
	if c and c:GetAttribute("PlayingEmote") ~= nil then
		pcall(function()
			c:SetAttribute("PlayingEmote", nil)
		end)
	end
	local ctrl = BW.emote or (BW.knit and BW.knit.Controllers and (BW.knit.Controllers.EmoteController or BW.knit.Controllers.EmotesController))
	local maid = ctrl and ctrl.emoteAudioMaids and ctrl.emoteAudioMaids[lp.UserId]
	if maid and maid.DoCleaning then
		pcall(function()
			maid:DoCleaning()
		end)
	end
end

local function nightmareEmote()
	local emoteMeta = require(ReplicatedStorage.TS.locker.emote["emote-meta"]).EmoteMeta
	local emoteType = require(ReplicatedStorage.TS.locker.emote["emote-type"]).EmoteType
	if emoteType and emoteType.NIGHTMARE and emoteMeta[emoteType.NIGHTMARE] then
		return emoteType.NIGHTMARE, emoteMeta[emoteType.NIGHTMARE]
	end
	for key, meta in pairs(emoteMeta) do
		if key ~= (emoteType and emoteType.NONE) and type(meta) == "table" and type(meta.name) == "string" and string.lower(meta.name) == "nightmare" then
			return key, meta
		end
	end
end

local function findNmAsset()
	if nmLooked then
		return nmAsset
	end
	nmLooked = true
	local best
	for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
		local lname = string.lower(obj.Name)
		if string.find(lname, "nightmare", 1, true) and (obj:IsA("Model") or obj:IsA("Folder")) and obj:FindFirstChildWhichIsA("BasePart", true) then
			best = obj
			if obj.Name == "NightmareEmote" or obj.Name == "Nightmare_1" then
				break
			end
		end
	end
	nmAsset = best
	return best
end

local function attachAura(model, r)
	nmEffect = model:Clone()
	nmEffect.Name = "QW_Nightmare"
	for _, p in ipairs(nmEffect:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.Anchored = true
		elseif p:IsA("ParticleEmitter") or p:IsA("Beam") or p:IsA("Trail") then
			p.Enabled = true
		end
	end
	nmEffect.Parent = workspace
	pcall(function()
		nmEffect:PivotTo(r.CFrame * CFrame.new(0, -2, 0))
	end)
	local outer, middle = nmEffect:FindFirstChild("Outer", true), nmEffect:FindFirstChild("Middle", true)
	if outer and outer:IsA("BasePart") then
		TweenService:Create(outer, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = outer.Orientation + Vector3.new(0, 360, 0),
		}):Play()
	end
	if middle and middle:IsA("BasePart") then
		TweenService:Create(middle, TweenInfo.new(12.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
			Orientation = middle.Orientation + Vector3.new(0, -360, 0),
		}):Play()
	end
	nmFollow = true
	RunService:BindToRenderStep("QW_NMFollow", Enum.RenderPriority.Last.Value, function()
		local rootPart = root()
		if nmEffect and rootPart then
			pcall(function()
				nmEffect:PivotTo(rootPart.CFrame * CFrame.new(0, -2, 0))
			end)
		end
	end)
end

local function sendEmote(key)
	if nmSent or not BW.client or not key then
		return
	end
	local ctrl = BW.emote
	local remoteName
	if ctrl and type(dbg.getconstants) == "function" then
		for _, fn in pairs(ctrl) do
			if type(fn) == "function" then
				local ok, consts = pcall(dbg.getconstants, fn)
				if ok and type(consts) == "table" then
					for i, value in ipairs(consts) do
						if value == "Client" and type(consts[i + 1]) == "string" and string.find(string.lower(consts[i + 1]), "emote", 1, true) then
							remoteName = consts[i + 1]
							break
						end
					end
				end
			end
			if remoteName then
				break
			end
		end
	end
	if not remoteName then
		return
	end
	local ok, remote = pcall(function()
		return BW.client:Get(remoteName)
	end)
	if ok and remote and remote.SendToServer then
		nmSent = true
		pcall(function()
			remote:SendToServer({ emote = key })
		end)
	end
end

local function playNm()
	local c, h = char(), hum()
	if not c or not h then
		return
	end
	if nmTrack and nmTrack.IsPlaying and c:GetAttribute("PlayingEmote") ~= nil then
		return
	end
	local key, meta
	local ok, errKey, errMeta = pcall(nightmareEmote)
	if ok then
		key, meta = errKey, errMeta
	end
	if not meta or key == nil then
		if not nmMissing then
			nmMissing = true
			notify("Nightmare emote is not in this place's emote list")
		end
		return
	end
	stopNm()
	nmKey = key
	c = char()
	h = hum()
	if not c or not h then
		return
	end
	local ctrl = BW.emote or (BW.knit and BW.knit.Controllers and (BW.knit.Controllers.EmoteController or BW.knit.Controllers.EmotesController))
	BW.emote = ctrl
	c:SetAttribute("PlayingEmote", key)
	local playSounds = ctrl and (ctrl.createEmoteBeginAudioPlayers or ctrl.playEmoteBeginSounds)
	if playSounds then
		pcall(playSounds, ctrl, key, lp)
	end
	sendEmote(key)
	local animation = meta.animation
	if not animation and meta.emoteDisplayType then
		pcall(function()
			local display = require(ReplicatedStorage.TS.locker.emote["emote-display-meta"]).EmoteDisplayMeta[meta.emoteDisplayType]
			animation = display and display.animation
		end)
	end
	if animation and animation.type then
		local played = pcall(function()
			local animUtil = require(ReplicatedStorage.TS.animation["animation-util"]).GameAnimationUtil
			nmTrack = h:LoadAnimation(animUtil:getAnimation(animation.type))
			nmTrack.Looped = true
			nmTrack.Priority = Enum.AnimationPriority.Action
			nmTrack:Play(0.15, 1, animation.speed or 1)
		end)
		if not played then
			nmTrack = nil
		end
	end
	task.delay(0.4, function()
		local mod = Modules["Fake NM Emote"]
		if not mod or not mod.enabled or nmEffect then
			return
		end
		local body = char()
		local r = root()
		if not body or not r then
			return
		end
		if body:FindFirstChild("Outer", true) or body:FindFirstChild("NightmareEmote", true) or workspace:FindFirstChild("NightmareEmote") then
			return
		end
		local okAsset, asset = pcall(findNmAsset)
		if okAsset and asset then
			attachAura(asset, r)
		end
	end)
end

local oldUsername, oldDisplay, oldLevel
local statSwapped, statWatch, barSaved, statColor, xpFill = {}, {}, {}, {}, {}
local savedAttr = {}
local statWriting
local realNames = {}
local shownName = ""

local function gamePlayerClass()
	local ok, util = pcall(function()
		return require(ReplicatedStorage.TS.player["player-util"]).GamePlayerUtil
	end)
	if not ok or type(util) ~= "table" or type(util.getGamePlayer) ~= "function" then
		return
	end
	local gp = util.getGamePlayer(lp)
	local mt = gp and getmetatable(gp)
	local class = mt and mt.__index
	if type(class) == "table" and type(class.getUsername) == "function" and type(class.getDisplayName) == "function" then
		return class
	end
end

local function commaNum(n)
	local s = tostring(math.floor(tonumber(n) or 0))
	local k
	repeat
		s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0
	return s
end

local function fakeLevel(m)
	return math.clamp(math.floor(tonumber(get(m, "Level")) or 0), 0, 999)
end

local function fakeStreak(m)
	return math.clamp(math.floor(tonumber(get(m, "Winstreak")) or 0), 0, 999)
end

local LEVEL_BANDS = {
	{ 100, Color3.fromRGB(186, 92, 255) },
	{ 90, Color3.fromRGB(255, 236, 140) },
	{ 80, Color3.fromRGB(255, 214, 64) },
	{ 70, Color3.fromRGB(255, 140, 40) },
	{ 60, Color3.fromRGB(255, 90, 90) },
	{ 50, Color3.fromRGB(255, 170, 40) },
	{ 40, Color3.fromRGB(214, 96, 255) },
	{ 30, Color3.fromRGB(90, 120, 255) },
	{ 20, Color3.fromRGB(70, 200, 255) },
	{ 10, Color3.fromRGB(80, 220, 120) },
	{ 0, Color3.fromRGB(186, 194, 204) },
}

local levelColorFn = nil
local function colorForLevel(level)
	if levelColorFn == nil then
		levelColorFn = false
		local ts = ReplicatedStorage:FindFirstChild("TS")
		if ts then
			for _, inst in ipairs(ts:GetDescendants()) do
				if inst:IsA("ModuleScript") then
					local n = string.lower(inst.Name)
					if n == "player-level-util" or n == "player-level-meta" or n == "level-meta" or n == "level-util" then
						local ok, mod = pcall(require, inst)
						if ok and type(mod) == "table" then
							local util = mod.PlayerLevelUtil or mod
							if type(util) == "table" then
								local fn = util.getLevelColor or util.getColor or util.getLevelBadgeColor
								if type(fn) == "function" then
									levelColorFn = fn
									break
								end
							end
						end
					end
				end
			end
		end
	end
	if type(levelColorFn) == "function" then
		local ok, color = pcall(levelColorFn, level)
		if (not ok or typeof(color) ~= "Color3") then
			ok, color = pcall(levelColorFn, nil, level)
		end
		if ok and typeof(color) == "Color3" then
			return color
		end
	end
	for _, band in ipairs(LEVEL_BANDS) do
		if level >= band[1] then
			return band[2]
		end
	end
	return LEVEL_BANDS[#LEVEL_BANDS][2]
end

local function nameHas(name, word)
	local n = string.lower(tostring(name or ""))
	if word == "level" and (string.find(n, "levelreq", 1, true) or string.find(n, "levelup", 1, true) or string.find(n, "milestone", 1, true)) then
		return false
	end
	if word == "streak" and (string.find(n, "best", 1, true) or string.find(n, "highest", 1, true)) then
		return false
	end
	return string.find(n, word, 1, true) ~= nil
end

local function namedStat(obj, word)
	if nameHas(obj.Name, word) then
		return true
	end
	local parent = obj.Parent
	if parent and nameHas(parent.Name, word) then
		return true
	end
	return false
end

local function levelishText(text)
	local plain = plainText(text)
	if plain == "" or #plain > 16 then
		return false
	end
	return string.match(plain, "^%d[%d,]*$") ~= nil
		or string.match(plain, "^%[%s*%d[%d,]*%s*%]$") ~= nil
		or string.match(plain, "^[Ll][Vv]%.?%s*%d[%d,]*$") ~= nil
		or string.match(plain, "^[Ll]evel%s*:?%s*%d[%d,]*$") ~= nil
end

local function formatLevel(original, level)
	local plain = plainText(original)
	local n = tostring(level)
	if string.match(plain, "^%[") then
		return "[" .. n .. "]"
	end
	if string.match(string.lower(plain), "^lv") then
		return "Lv. " .. n
	end
	if string.match(string.lower(plain), "^level") then
		return "Level " .. n
	end
	return n
end

local function xpNeed(_level)
	return 55000
end

local function playerLevelLine(text)
	local plain = plainText(text)
	if plain == "" or #plain > 40 then
		return false
	end
	return string.match(plain, "^[Pp]layer%s+[Ll]evel%s*:?%s*%d+") ~= nil
		or string.match(plain, "^[Ll]evel%s+%d+$") ~= nil
end

local function formatPlayerLevel(original, level)
	local replaced, count = string.gsub(tostring(original or ""), "([Ll]evel%s*:?%s*)%d+", "%1" .. tostring(level), 1)
	if count > 0 then
		return replaced
	end
	return "Player Level " .. tostring(level)
end

local function isXpLine(text)
	local plain = plainText(text)
	if plain == "" or #plain > 28 or string.find(string.lower(plain), "rp", 1, true) then
		return false
	end
	local _, b = string.match(plain, "^(%d[%d,]*)%s*/%s*(%d[%d,]*)$")
	if not b then
		return false
	end
	local seen = tonumber((b:gsub(",", ""))) or 0
	return seen >= 1000 and seen <= 70000
end

local function levelXp(level, original, obj)
	local plain = plainText(original)
	local a, b = string.match(plain, "^(%d[%d,]*)%s*/%s*(%d[%d,]*)$")
	local cur = tonumber(((a or ""):gsub(",", ""))) or 0
	local seen = tonumber(((b or ""):gsub(",", ""))) or 0
	local need = xpNeed(level)
	local ratio
	if seen == need and obj and type(xpFill[obj]) == "number" then
		ratio = xpFill[obj]
	else
		if seen <= 0 then
			seen = 1
		end
		ratio = math.clamp(cur / seen, 0, 1)
		if obj then
			xpFill[obj] = ratio
		end
	end
	local shown = math.floor(ratio * need + 0.5)
	if shown > need then
		shown = need
	end
	return commaNum(shown) .. " / " .. commaNum(need), ratio
end

local function bindLevelBar(label, ratio)
	if not label or type(ratio) ~= "number" or not label.Parent then
		return
	end
	local best, bestScore
	local node = label.Parent
	for _ = 1, 5 do
		if not node then
			break
		end
		local n = 0
		for _, ch in ipairs(node:GetDescendants()) do
			n = n + 1
			if n > 120 then
				break
			end
			if ch ~= label and not barSaved[ch] and (ch:IsA("Frame") or ch:IsA("ImageLabel") or ch:IsA("ImageButton")) then
				local size = ch.AbsoluteSize
				if size.Y >= 3 and size.Y <= 20 and size.X >= 24 then
					local dy = label.AbsolutePosition.Y - (ch.AbsolutePosition.Y + size.Y * 0.5)
					local dx = math.abs((label.AbsolutePosition.X + label.AbsoluteSize.X * 0.5) - (ch.AbsolutePosition.X + size.X * 0.5))
					if dy >= -6 and dy <= 80 and dx <= 200 then
						local score = dy + dx * 0.25
						if not best or score < bestScore then
							best = ch
							bestScore = score
						end
					end
				end
			end
		end
		if best or node:IsA("SurfaceGui") or node:IsA("BillboardGui") or node:IsA("ScreenGui") then
			break
		end
		node = node.Parent
	end
	if not best then
		return
	end
	local saved = xpFill[best]
	if type(saved) ~= "table" then
		saved = { Size = best.Size }
		xpFill[best] = saved
	end
	saved.ratio = ratio
	local yScale, yOffset = best.Size.Y.Scale, best.Size.Y.Offset
	best.Size = UDim2.new(math.clamp(ratio, 0, 1), 0, yScale, yOffset)
end

local function streakCaption(text)
	local plain = string.lower(plainText(text))
	return plain == "winstreak" or plain == "win streak" or plain == "winstreak:" or plain == "win streak:"
end

local function streakLine(text)
	local plain = string.lower(plainText(text))
	if #plain > 28 or string.find(plain, "highest", 1, true) or string.find(plain, "best", 1, true) then
		return false
	end
	if not (string.find(plain, "winstreak", 1, true) or string.find(plain, "win streak", 1, true)) then
		return false
	end
	return string.find(plain, "%d") ~= nil
end

local function statText(text, m)
	if type(text) ~= "string" or text == "" or #text > 90 then
		return text
	end
	local name = tostring(get(m, "Name") or "")
	local rank, _, _, rpLine = rpParts(m)
	local lb = tonumber((tostring(get(m, "Leaderboard Rank") or "1"):gsub(",", ""))) or 1
	if name ~= "" then
		for _, old in ipairs(realNames) do
			if old ~= "" and old ~= name then
				local a, b = string.find(text, old, 1, true)
				if a then
					text = string.sub(text, 1, a - 1) .. name .. string.sub(text, b + 1)
				end
			end
		end
		if shownName ~= "" and shownName ~= name then
			local a, b = string.find(text, shownName, 1, true)
			if a then
				text = string.sub(text, 1, a - 1) .. name .. string.sub(text, b + 1)
			end
		end
	end
	if name ~= "" and #name >= 3 and #text <= 48 and string.find(text, name, 1, true) then
		local replaced, count = string.gsub(text, "%[%s*%d[%d,]*%s*%]", "[" .. tostring(fakeLevel(m)) .. "]", 1)
		if count > 0 then
			text = replaced
		end
	end
	if string.find(text, "Leaderboard Rank", 1, true) then
		return "Leaderboard Rank: " .. commaNum(lb)
	end
	if isRpLine(text) then
		return rpLine
	end
	local trimmed = string.match(text, "^%s*(.-)%s*$") or text
	if #trimmed <= 18 then
		for _, word in ipairs({ "Nightmare", "Emerald", "Diamond", "Platinum", "Gold", "Silver", "Bronze" }) do
			if string.find(trimmed, word, 1, true) then
				return rank
			end
		end
	end
	return text
end

local mineAnswer = setmetatable({}, { __mode = "k" })

local function nameList()
	local names, seen = {}, {}
	local function push(n)
		if type(n) == "string" and n ~= "" and not seen[n] then
			seen[n] = true
			table.insert(names, n)
		end
	end
	for _, n in ipairs(realNames) do
		push(n)
	end
	push(shownName)
	local mod = Modules["Fake Stats"]
	if mod then
		push(tostring(get(mod, "Name") or ""))
	end
	return names
end

local function textHasName(text, names)
	if type(text) ~= "string" then
		return false
	end
	for _, n in ipairs(names) do
		if string.find(text, n, 1, true) then
			return true
		end
	end
	return false
end

local function cardIsMine(obj)
	local names = nameList()
	local node = obj
	for _ = 1, 8 do
		node = node and node.Parent
		if not node or node:IsA("ScreenGui") or node.Name == "Falcon" then
			return false
		end
		local cached = mineAnswer[node]
		if cached == true then
			return true
		end
		if cached == nil then
			local count, hit = 0, false
			local cap = (node:IsA("SurfaceGui") or node:IsA("BillboardGui")) and 900 or 280
			for _, ch in ipairs(node:GetDescendants()) do
				count = count + 1
				if count > cap then
					break
				end
				if (ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox")) and textHasName(ch.Text, names) then
					hit = true
					break
				end
			end
			if hit or count <= cap then
				mineAnswer[node] = hit
			end
			if hit then
				return true
			end
		end
		if node:IsA("SurfaceGui") or node:IsA("BillboardGui") then
			return false
		end
	end
	return false
end

local function rememberBar(frame)
	if barSaved[frame] == nil then
		local grad = frame:FindFirstChildOfClass("UIGradient")
		local image = frame:IsA("ImageLabel") or frame:IsA("ImageButton")
		barSaved[frame] = {
			Color = image and frame.ImageColor3 or frame.BackgroundColor3,
			Size = frame.Size,
			Transparency = frame.BackgroundTransparency,
			ImageTransparency = image and frame.ImageTransparency or nil,
			Gradient = grad and grad.Color or nil,
		}
	end
end

local function paintFill(frame, ratio, color, hide)
	if not frame or not frame.Parent then
		return
	end
	rememberBar(frame)
	local saved = barSaved[frame]
	local image = frame:IsA("ImageLabel") or frame:IsA("ImageButton")
	local yScale, yOffset = frame.Size.Y.Scale, frame.Size.Y.Offset
	local parent = frame.Parent
	if hide then
		frame.Size = UDim2.new(0, 0, yScale, yOffset)
		frame.BackgroundTransparency = 1
		if image then
			frame.ImageTransparency = 1
		end
		if parent and parent:IsA("GuiObject") then
			local ps = parent.AbsoluteSize
			if ps.Y >= 2 and ps.Y <= 22 and ps.X >= 16 then
				if saved.ParentTransparency == nil then
					saved.ParentTransparency = parent.BackgroundTransparency
					saved.ParentImageTransparency = (parent:IsA("ImageLabel") or parent:IsA("ImageButton")) and parent.ImageTransparency or nil
				end
				parent.BackgroundTransparency = 1
				if saved.ParentImageTransparency ~= nil then
					parent.ImageTransparency = 1
				end
			end
		end
		return
	end
	if saved.ParentTransparency ~= nil and parent then
		parent.BackgroundTransparency = saved.ParentTransparency
		if saved.ParentImageTransparency ~= nil and (parent:IsA("ImageLabel") or parent:IsA("ImageButton")) then
			parent.ImageTransparency = saved.ParentImageTransparency
		end
	end
	frame.Size = UDim2.new(math.clamp(ratio, 0, 1), 0, yScale, yOffset)
	if image then
		frame.ImageColor3 = color
		frame.ImageTransparency = 0
	else
		frame.BackgroundColor3 = color
		frame.BackgroundTransparency = 0
	end
	local grad = frame:FindFirstChildOfClass("UIGradient")
	if grad then
		grad.Color = ColorSequence.new(color, color)
	end
end

local function reapplyBars(m)
	local rank, shown, maxRp = rpParts(m)
	local color = rankColor(rank)
	local hide = maxRp <= 0
	local ratio = maxRp > 0 and (shown / maxRp) or 0
	for frame in pairs(barSaved) do
		if typeof(frame) == "Instance" and frame.Parent then
			paintFill(frame, ratio, color, hide)
		end
	end
	for frame, saved in pairs(xpFill) do
		if typeof(frame) == "Instance" and frame.Parent and type(saved) == "table" and type(saved.ratio) == "number" then
			local yScale, yOffset = frame.Size.Y.Scale, frame.Size.Y.Offset
			frame.Size = UDim2.new(math.clamp(saved.ratio, 0, 1), 0, yScale, yOffset)
		end
	end
end

local function styleRankBlock(anchor, m)
	if not anchor or not anchor.Parent then
		return
	end
	local _, shown, maxRp, rpLine = rpParts(m)
	local color = rankColor(get(m, "Rank"))
	local ratio = maxRp > 0 and (shown / maxRp) or 0
	local node = anchor.Parent
	local block = node
	for _ = 1, 6 do
		if not node or node:IsA("ScreenGui") or node:IsA("SurfaceGui") or node:IsA("BillboardGui") then
			break
		end
		local count, hasRp = 0, false
		for _, ch in ipairs(node:GetDescendants()) do
			count = count + 1
			if count > 140 then
				break
			end
			if (ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox")) and isRpLine(ch.Text) then
				hasRp = true
			end
		end
		if hasRp and count <= 140 then
			block = node
			break
		end
		node = node.Parent
	end
	if not block then
		return
	end
	local hideBar = maxRp <= 0
	if hideBar then
		local wider = block
		for _ = 1, 4 do
			if not wider or not wider.Parent or wider:IsA("SurfaceGui") or wider:IsA("ScreenGui") or wider:IsA("BillboardGui") then
				break
			end
			wider = wider.Parent
			block = wider
		end
	end
	for _, ch in ipairs(block:GetDescendants()) do
		if (ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox")) and isRpLine(ch.Text) and ch.Text ~= rpLine then
			if statSwapped[ch] == nil then
				statSwapped[ch] = ch.Text
			end
			statWriting = ch
			ch.Text = rpLine
			statWriting = nil
		end
	end
	local function nearRp(frame)
		local fy = frame.AbsolutePosition.Y + frame.AbsoluteSize.Y * 0.5
		local ay = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y * 0.5
		if hideBar and math.abs(fy - ay) <= 90 then
			return true
		end
		local parent = frame.Parent
		local grand = parent and parent.Parent
		for _, scope in ipairs({ parent, grand }) do
			if scope then
				for _, other in ipairs(scope:GetDescendants()) do
					if (other:IsA("TextLabel") or other:IsA("TextButton") or other:IsA("TextBox")) and isRpLine(other.Text) then
						local oy = other.AbsolutePosition.Y + other.AbsoluteSize.Y * 0.5
						if math.abs(oy - fy) <= 70 then
							return true
						end
					end
				end
			end
		end
		return false
	end
	for _, ch in ipairs(block:GetDescendants()) do
		if (ch:IsA("Frame") or ch:IsA("ImageLabel") or ch:IsA("ImageButton")) and type(xpFill[ch]) ~= "table" and nearRp(ch) then
			local size = ch.AbsoluteSize
			local parent = ch.Parent
			if size.Y >= 2 and size.Y <= 22 and size.X >= 12 and parent and parent:IsA("GuiObject") then
				local psize = parent.AbsoluteSize
				if hideBar then
					paintFill(ch, 0, color, true)
				else
					local colorSum = ch.BackgroundColor3.R + ch.BackgroundColor3.G + ch.BackgroundColor3.B
					local parentSum = parent.BackgroundColor3.R + parent.BackgroundColor3.G + parent.BackgroundColor3.B
					local brighter = colorSum > parentSum + 0.2
					local shorter = size.X < psize.X - 4
					if psize.Y >= 3 and psize.Y <= 22 and psize.X >= 40 and (brighter or shorter) then
						paintFill(ch, ratio, color, false)
					end
				end
			end
		end
	end
end

local otherNames = {}
local otherStamp = 0
local function otherPlayerText(text)
	if type(text) ~= "string" or text == "" then
		return false
	end
	if os.clock() - otherStamp > 1 then
		table.clear(otherNames)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= lp then
				if #plr.Name >= 3 then
					table.insert(otherNames, plr.Name)
				end
				if #plr.DisplayName >= 3 and plr.DisplayName ~= plr.Name then
					table.insert(otherNames, plr.DisplayName)
				end
			end
		end
		otherStamp = os.clock()
	end
	for _, n in ipairs(otherNames) do
		if string.find(text, n, 1, true) then
			return true
		end
	end
	return false
end

local function mineCard(obj)
	local names = nameList()
	local node = obj.Parent
	for _ = 1, 8 do
		if not node or node:IsA("ScreenGui") or node:IsA("PlayerGui") or node.Name == "Falcon" then
			return false
		end
		local count, foundMine, foundOther = 0, false, false
		for _, ch in ipairs(node:GetDescendants()) do
			count = count + 1
		if count > 900 then
				foundOther = true
				break
			end
			if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
				local text = ch.Text
				if type(text) == "string" and text ~= "" then
					if textHasName(text, names) then
						foundMine = true
					elseif otherPlayerText(text) then
						foundOther = true
						break
					end
				end
			end
		end
		if foundOther then
			return false
		end
		if foundMine then
			return true
		end
		if node:IsA("SurfaceGui") or node:IsA("BillboardGui") then
			return false
		end
		node = node.Parent
	end
	return false
end

local function nearStreakIcon(obj)
	if not levelishText(obj.Text) then
		return false
	end
	local parent = obj.Parent
	if not parent then
		return false
	end
	for _, ch in ipairs(parent:GetChildren()) do
		if ch ~= obj then
			local n = string.lower(ch.Name)
			if string.find(n, "streak", 1, true) or string.find(n, "flame", 1, true) then
				return true
			end
		end
	end
	return false
end

local function streakNumberNear(anchor)
	local function pick(scope)
		if not scope then
			return
		end
		local named, nearest, nearestScore
		for _, ch in ipairs(scope:GetChildren()) do
			if ch ~= anchor and (ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox")) and levelishText(ch.Text) then
				if namedStat(ch, "streak") or nameHas(ch.Name, "streak") or nameHas(ch.Name, "value") or nameHas(ch.Name, "amount") then
					named = ch
					break
				end
				local score = ch.LayoutOrder
				if score < anchor.LayoutOrder then
					score = score + 1000
				end
				if not nearest or score < nearestScore then
					nearest, nearestScore = ch, score
				end
			end
		end
		return named or nearest
	end
	return pick(anchor.Parent) or pick(anchor.Parent and anchor.Parent.Parent)
end

local paintStatObject
local sweeping = false
local function watchStat(obj)
	if statWatch[obj] then
		return
	end
	statWatch[obj] = Life.connect(obj:GetPropertyChangedSignal("Text"), function()
		local mod = Modules["Fake Stats"]
		if mod and mod.enabled and statWriting ~= obj then
			paintStatObject(obj, mod)
		end
	end)
end

local function writeStatText(obj, text)
	if obj.Text ~= text then
		if statSwapped[obj] == nil then
			statSwapped[obj] = obj.Text
		end
		statWriting = obj
		obj.Text = text
		statWriting = nil
	end
	watchStat(obj)
end

local function profileOwned(obj)
	if cardIsMine(obj) or mineCard(obj) then
		return true
	end
	local names = nameList()
	local node = obj.Parent
	for _ = 1, 8 do
		if not node or node:IsA("PlayerGui") or node:IsA("ScreenGui") then
			break
		end
		local count, foundMine, foundOther, levelNear = 0, false, false, false
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			levelNear = playerLevelLine(obj.Text)
		end
		for _, ch in ipairs(node:GetDescendants()) do
			count = count + 1
			if count > 800 then
				break
			end
			if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
				if textHasName(ch.Text, names) then
					foundMine = true
				elseif otherPlayerText(ch.Text) then
					foundOther = true
				end
				if playerLevelLine(ch.Text) then
					levelNear = true
				end
			end
		end
		if foundOther and not foundMine then
			return false
		end
		if foundMine and not foundOther then
			return true
		end
		if not foundOther and levelNear and count <= 800 then
			return true
		end
		if node:IsA("SurfaceGui") or node:IsA("BillboardGui") then
			break
		end
		node = node.Parent
	end
	return false
end

local function globalStat(obj, m, sample)
	if not obj or not m then
		return
	end
	local shown = sample or obj.Text
	local function amount(name)
		local n = tonumber((tostring(get(m, name) or "0"):gsub("[^%d]", ""))) or 0
		if n < 0 then
			n = 0
		end
		return commaNum(math.floor(n))
	end
	local function kindOf(text)
		local plain = string.lower(plainText(text))
		if plain == "" or #plain > 22 then
			return
		end
		if plain == "wins" or plain == "win" then
			return "Wins"
		end
		if plain == "bed breaks" or plain == "bed break" or plain == "bedbreaks" or plain == "beds broken" then
			return "Bed Breaks"
		end
		if plain == "final kills" or plain == "final kill" or plain == "finalkills" then
			return "Final Kills"
		end
		if plain == "honor" or plain == "honour" or plain == "honors" or plain == "honours" then
			return "Honor"
		end
	end
	local function bandOf(node)
		local globalY, queueY
		local n = 0
		for _, ch in ipairs(node:GetDescendants()) do
			n = n + 1
			if n > 700 then
				break
			end
			if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
				local plain = string.lower(plainText(ch.Text))
				local y = ch.AbsolutePosition.Y
				if string.find(plain, "global", 1, true) and (not globalY or y < globalY) then
					globalY = y
				end
				if string.find(plain, "queue", 1, true) and (not queueY or y < queueY) then
					queueY = y
				end
			end
		end
		return globalY, queueY
	end
	local function inTotals(anchor)
		local node = anchor.Parent
		for _ = 1, 10 do
			if not node or node:IsA("ScreenGui") or node:IsA("PlayerGui") then
				break
			end
			local wins, beds, n = false, false, 0
			for _, ch in ipairs(node:GetDescendants()) do
				n = n + 1
				if n > 700 then
					break
				end
				if ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox") then
					local k = kindOf(ch.Text)
					if k == "Wins" then
						wins = true
					elseif k == "Bed Breaks" then
						beds = true
					end
				end
			end
			if wins and beds then
				local globalY, queueY = bandOf(node)
				local y = anchor.AbsolutePosition.Y
				local belowGlobal = (not globalY) or y >= globalY - 6
				local aboveQueue = (not queueY) or y < queueY - 4
				if belowGlobal and aboveQueue then
					return true
				end
			end
			if node:IsA("SurfaceGui") or node:IsA("BillboardGui") then
				break
			end
			node = node.Parent
		end
		return false
	end
	if not inTotals(obj) then
		return
	end
	local function closest(anchor, wantNumber)
		local best, bestScore
		local parent = anchor.Parent
		local scopes = { parent, parent and parent.Parent }
		for _, scope in ipairs(scopes) do
			if scope then
				for _, ch in ipairs(scope:GetChildren()) do
					local candidate = ch
					local ok = false
					if candidate ~= anchor and (candidate:IsA("TextLabel") or candidate:IsA("TextButton") or candidate:IsA("TextBox")) then
						ok = (wantNumber and levelishText(candidate.Text)) or ((not wantNumber) and kindOf(candidate.Text) ~= nil)
					end
					if not ok and candidate ~= anchor and candidate:IsA("GuiObject") then
						for _, sub in ipairs(candidate:GetDescendants()) do
							if sub ~= anchor and (sub:IsA("TextLabel") or sub:IsA("TextButton") or sub:IsA("TextBox")) then
								local subOk = (wantNumber and levelishText(sub.Text)) or ((not wantNumber) and kindOf(sub.Text) ~= nil)
								if subOk then
									candidate = sub
									ok = true
									break
								end
							end
						end
					end
					if ok then
						local ax = anchor.AbsolutePosition.X + anchor.AbsoluteSize.X * 0.5
						local ay = anchor.AbsolutePosition.Y + anchor.AbsoluteSize.Y * 0.5
						local cx = candidate.AbsolutePosition.X + candidate.AbsoluteSize.X * 0.5
						local cy = candidate.AbsolutePosition.Y + candidate.AbsoluteSize.Y * 0.5
						local dx = math.abs(cx - ax)
						local dy = math.abs(cy - ay)
						if dx <= 180 and dy <= 160 then
							local score = dx * 3 + dy
							if not best or score < bestScore then
								best = candidate
								bestScore = score
							end
						end
					end
				end
			end
		end
		return best
	end
	local kind = kindOf(shown)
	if kind then
		local num = closest(obj, true)
		if not num and obj.Parent then
			local best, bestDy
			for _, ch in ipairs(obj.Parent:GetDescendants()) do
				if ch ~= obj and (ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox")) and levelishText(ch.Text) then
					local dx = math.abs((ch.AbsolutePosition.X + ch.AbsoluteSize.X * 0.5) - (obj.AbsolutePosition.X + obj.AbsoluteSize.X * 0.5))
					local dy = ch.AbsolutePosition.Y - obj.AbsolutePosition.Y
					if dx <= 180 and dy >= -30 and dy <= 180 and (not best or dy < bestDy) then
						best = ch
						bestDy = dy
					end
				end
			end
			num = best
		end
		if num then
			writeStatText(num, amount(kind))
		end
		return
	end
	if levelishText(shown) then
		local caption = closest(obj, false)
		local near = caption and kindOf(caption.Text)
		if near then
			return amount(near)
		end
	end
	local raw = tostring(shown or "")
	local head = string.match(raw, "^%s*([%a][%a%s]*)%s*[\n\r]+%s*%d[%d,]*%s*$")
	if head then
		local both = kindOf(head)
		if both then
			return (string.gsub(raw, "%d[%d,]*", amount(both), 1))
		end
	end
end

local function tintLevel(obj, level)
	local color = colorForLevel(level)
	local saved = statColor[obj]
	if not saved then
		saved = {}
		statColor[obj] = saved
	end
	if saved.text == nil then
		saved.text = obj.TextColor3
	end
	if obj.TextColor3 ~= color then
		obj.TextColor3 = color
	end
	local parent = obj.Parent
	if parent and parent:IsA("GuiObject") and nameHas(parent.Name, "level") then
		local size = parent.AbsoluteSize
		if size.X <= 90 and size.Y <= 42 then
			local parentSaved = statColor[parent]
			if not parentSaved then
				parentSaved = {}
				statColor[parent] = parentSaved
			end
			if parentSaved.background == nil then
				parentSaved.background = parent.BackgroundColor3
			end
			if parent.BackgroundColor3 ~= color then
				parent.BackgroundColor3 = color
			end
		end
	end
end

paintStatObject = function(obj, m)
	if statWriting == obj or not obj or not obj.Parent or obj:FindFirstAncestor("Falcon") then
		return
	end
	local isImage = obj:IsA("ImageLabel") or obj:IsA("ImageButton")
	local isText = obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")
	if not isImage and not isText then
		return
	end
	asExecutor()
	if isImage then
		if isRankImage(obj.Image) and cardIsMine(obj) then
			local nextImage = imageForRank(get(m, "Rank"))
			if nextImage and obj.Image ~= nextImage then
				if statSwapped[obj] == nil then
					statSwapped[obj] = obj.Image
				end
				statWriting = obj
				obj.Image = nextImage
				statWriting = nil
			end
		end
		return
	end
	local nextText = statText(obj.Text, m)
	local rank = tostring(get(m, "Rank") or "")
	local rankish = nextText == rank or string.find(nextText, "Leaderboard Rank", 1, true) or isRpLine(nextText)
	if nextText ~= obj.Text and rankish and not cardIsMine(obj) then
		return
	end
	if rankish and (nextText == rank or string.find(obj.Text, "Leaderboard Rank", 1, true) or string.find(nextText, "Leaderboard Rank", 1, true)) then
		styleRankBlock(obj, m)
	end
	local level = fakeLevel(m)
	local streak = fakeStreak(m)
	local touchLevel = false
	local owned = false
	local globalText = globalStat(obj, m)
	if type(globalText) == "string" then
		nextText = globalText
		owned = true
	end
	local candidate = namedStat(obj, "level") or namedStat(obj, "streak") or nearStreakIcon(obj) or streakCaption(obj.Text) or streakLine(obj.Text)
	if candidate and mineCard(obj) then
		owned = true
		if namedStat(obj, "level") and levelishText(obj.Text) then
			nextText = formatLevel(obj.Text, level)
			touchLevel = true
		elseif streakCaption(obj.Text) then
			local num = streakNumberNear(obj)
			if num then
				writeStatText(num, tostring(streak))
			end
		elseif (namedStat(obj, "streak") or nearStreakIcon(obj)) and levelishText(obj.Text) then
			nextText = tostring(streak)
		elseif streakLine(obj.Text) then
			local replaced, count = string.gsub(obj.Text, "%d[%d,]*", tostring(streak), 1)
			if count > 0 then
				nextText = replaced
			end
		end
	end
	local xpRatio
	if playerLevelLine(obj.Text) then
		nextText = formatPlayerLevel(obj.Text, level)
		touchLevel = true
		owned = true
	end
	if isXpLine(obj.Text) then
		local formatted, ratio = levelXp(level, obj.Text, obj)
		nextText = formatted
		xpRatio = ratio
		owned = true
	end
	if nextText ~= obj.Text then
		writeStatText(obj, nextText)
	elseif owned then
		watchStat(obj)
	end
	if touchLevel then
		tintLevel(obj, level)
	end
	if xpRatio ~= nil then
		bindLevelBar(obj, xpRatio)
	end
	local fakeName = tostring(get(m, "Name") or "")
	if not sweeping and fakeName ~= "" and type(nextText) == "string" and string.find(nextText, fakeName, 1, true) and obj.Parent then
		sweeping = true
		local count = 0
		for _, ch in ipairs(obj.Parent:GetDescendants()) do
			count = count + 1
			if count > 50 then
				break
			end
			if ch ~= obj and (ch:IsA("TextLabel") or ch:IsA("TextButton") or ch:IsA("TextBox")) then
				if namedStat(ch, "level") or namedStat(ch, "streak") or nearStreakIcon(ch) or streakCaption(ch.Text) or streakLine(ch.Text) then
					paintStatObject(ch, m)
				end
			end
		end
		sweeping = false
	end
end

local function scanStatRoot(root, m, worldBoards)
	if not root or not (Modules["Fake Stats"] and Modules["Fake Stats"].enabled) then
		return
	end
	asExecutor()
	local clock = os.clock()
	local list = worldBoards and {} or root:GetDescendants()
	if worldBoards then
		for _, obj in ipairs(root:GetDescendants()) do
			if obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
				table.insert(list, obj)
			end
			if os.clock() - clock > 0.003 then
				task.wait()
				clock = os.clock()
				if not (Modules["Fake Stats"] and Modules["Fake Stats"].enabled) then
					return
				end
			end
		end
		local boards = list
		list = {}
		for _, gui in ipairs(boards) do
			table.insert(list, gui)
			for _, obj in ipairs(gui:GetDescendants()) do
				table.insert(list, obj)
			end
		end
	end
	table.clear(mineAnswer)
	for _, obj in ipairs(list) do
		paintStatObject(obj, m)
		if os.clock() - clock > 0.003 then
			task.wait()
			clock = os.clock()
			asExecutor()
			if not (Modules["Fake Stats"] and Modules["Fake Stats"].enabled) then
				return
			end
		end
	end
end

local function hookGamePlayer()
	local class = gamePlayerClass()
	if not class or oldUsername then
		return
	end
	oldUsername, oldDisplay, oldLevel = class.getUsername, class.getDisplayName, class.getLevel
	local function playerOf(self)
		if type(self) ~= "table" or type(self.getPlayer) ~= "function" then
			return
		end
		local ok, player = pcall(self.getPlayer, self)
		if ok then
			return player
		end
	end
	class.getUsername = function(self, ...)
		local mod = Modules["Fake Stats"]
		if mod and mod.enabled and playerOf(self) == lp then
			return tostring(get(mod, "Name") or shownName)
		end
		return oldUsername(self, ...)
	end
	class.getDisplayName = function(self, ...)
		local mod = Modules["Fake Stats"]
		if mod and mod.enabled and playerOf(self) == lp then
			return tostring(get(mod, "Name") or shownName)
		end
		return oldDisplay(self, ...)
	end
	if type(oldLevel) == "function" then
		class.getLevel = function(self, ...)
			local mod = Modules["Fake Stats"]
			if mod and mod.enabled and playerOf(self) == lp then
				return fakeLevel(mod)
			end
			return oldLevel(self, ...)
		end
	end
end

local function unhookGamePlayer()
	local class = gamePlayerClass()
	if class and oldUsername then
		class.getUsername = oldUsername
		class.getDisplayName = oldDisplay
		if type(oldLevel) == "function" then
			class.getLevel = oldLevel
		end
	end
	oldUsername, oldDisplay, oldLevel = nil, nil, nil
end

local RANK_REMOTE = {
	FetchRanks = true,
	RequestProfileData = true,
}

local function divisionIdFor(rankName)
	loadRankMeta()
	local want = string.lower(tostring(rankName or ""))
	if type(rankMeta) ~= "table" then
		return
	end
	for key, div in pairs(rankMeta) do
		if type(div) == "table" and type(div.name) == "string" and string.lower(div.name) == want then
			return key
		end
	end
end

local SKIP_PROFILE = {
	matchHistory = true,
	players = true,
	matches = true,
	queues = true,
	favoriteKitData = true,
}

local function patchProfile(value, force, depth, rankName, rp, lb, fakeName, divId, level, streak)
	if depth > 5 or type(value) ~= "table" or value.andThen or value.expect or value.await then
		return
	end
	local uid = value.userId or value.playerId or value.user_id
	if uid ~= nil and uid ~= lp and tonumber(uid) ~= lp.UserId then
		return
	end
	local mine = force or uid == lp or tonumber(uid) == lp.UserId
	for key, field in pairs(value) do
		if type(key) ~= "number" and not SKIP_PROFILE[key] then
		local lk = string.lower(tostring(key))
		if type(field) == "table" then
			patchProfile(field, mine, depth + 1, rankName, rp, lb, fakeName, divId, level, streak)
		elseif mine then
			if divId ~= nil and (lk == "rankdivision" or lk == "division" or lk == "rankeddivision" or lk == "currentdivision") then
				value[key] = divId
			elseif type(field) == "string" and (lk == "rankname" or lk == "divisionname") then
				value[key] = rankName
			elseif type(field) == "string" and (lk == "displayname" or lk == "username" or lk == "name") then
				if fakeName ~= "" and (field == lp.Name or field == lp.DisplayName or field == shownName or field == realNames[1] or field == realNames[2]) then
					value[key] = fakeName
				end
			elseif type(field) == "number" and (lk == "rp" or lk == "rankpoints" or lk == "rankedrp" or lk == "currentrp" or lk == "rpindivision") then
				value[key] = rp
			elseif type(field) == "number" and (lk == "leaderboardrank" or lk == "leaderboardposition" or lk == "leaderboardplacement" or lk == "rankposition") then
				value[key] = lb
			elseif type(field) == "number" and (lk == "level" or lk == "playerlevel" or lk == "currentlevel" or lk == "accountlevel") then
				value[key] = level
			elseif depth <= 4 and type(field) == "number" and (lk == "winstreak" or lk == "globalwinstreak" or lk == "currentwinstreak" or lk == "activewinstreak") then
				value[key] = streak
			elseif type(field) == "number" and not (value.queueId or value.queueType or value.queue or value.kit) then
				local function statNum(name)
					local mod = Modules["Fake Stats"]
					if not mod then
						return field
					end
					return math.floor(tonumber((tostring(get(mod, name) or "0"):gsub("[^%d]", ""))) or 0)
				end
				if lk == "wins" or lk == "globalwins" or lk == "totalwins" or lk == "wincount" then
					value[key] = statNum("Wins")
				elseif lk == "bedbreaks" or lk == "bedbreak" or lk == "bedsbroken" or lk == "bedsdestroyed" or lk == "destroyedbeds" or lk == "globalbedbreaks" or lk == "totalbedbreaks" then
					value[key] = statNum("Bed Breaks")
				elseif lk == "finalkills" or lk == "finalkill" or lk == "globalfinalkills" or lk == "totalfinalkills" then
					value[key] = statNum("Final Kills")
				elseif lk == "honor" or lk == "honour" or lk == "honors" or lk == "honours" or lk == "globalhonor" or lk == "totalhonor" then
					value[key] = statNum("Honor")
				end
			end
		end
		end
	end
	if type(value[1]) == "table" then
		for _, entry in ipairs(value) do
			patchProfile(entry, force, depth + 1, rankName, rp, lb, fakeName, divId, level, streak)
		end
	end
end

local function rewriteRankResult(value, requested)
	local mod = Modules["Fake Stats"]
	if not mod or not mod.enabled or type(value) ~= "table" or value.andThen then
		return
	end
	local rankName, rp = rpParts(mod)
	local lb = tonumber((tostring(get(mod, "Leaderboard Rank") or "1"):gsub(",", ""))) or 1
	local fakeName = tostring(get(mod, "Name") or "")
	patchProfile(value, requested, 0, rankName, rp, lb, fakeName, divisionIdFor(rankName), fakeLevel(mod), fakeStreak(mod))
end

local function wrapRankCall(fn, remote)
	return function(_, ...)
		local requested = false
		for i = 1, select("#", ...) do
			local arg = select(i, ...)
			if arg == lp or arg == lp.UserId or tostring(arg) == tostring(lp.UserId) then
				requested = true
			elseif type(arg) == "table" and (arg[1] == lp.UserId or arg[1] == lp or arg.userId == lp.UserId or arg.player == lp) then
				requested = true
			end
		end
		local packed = table.pack(fn(remote, ...))
		for i = 1, packed.n do
			local item = packed[i]
			if type(item) == "table" and not item.__qwRanks then
				if type(item.andThen) == "function" and not item.__qwThen then
					local oldThen = item.andThen
					item.andThen = function(promise, callback, ...)
						return oldThen(promise, function(result, ...)
							rewriteRankResult(result, requested)
							if type(callback) == "function" then
								return callback(result, ...)
							end
						end, ...)
					end
					item.__qwThen = true
				end
				if type(item.expect) == "function" and not item.__qwExpect then
					local oldExpect = item.expect
					item.expect = function(promise, ...)
						local result = oldExpect(promise, ...)
						rewriteRankResult(result, requested)
						return result
					end
					item.__qwExpect = true
				end
				if type(item.await) == "function" and not item.__qwAwait then
					local oldAwait = item.await
					item.await = function(promise, ...)
						local result = oldAwait(promise, ...)
						rewriteRankResult(result, requested)
						return result
					end
					item.__qwAwait = true
				end
				if not item.andThen and not item.expect and not item.await then
					rewriteRankResult(item, requested)
				end
			end
		end
		return table.unpack(packed, 1, packed.n)
	end
end

local ranksHooked = false
function hookRankRemotes()
	if ranksHooked then
		return
	end
	local client = BW.client
	if type(client) ~= "table" or type(client.Get) ~= "function" then
		return
	end
	local original = client.Get
	local originalThrow = client.GetOrThrow
	local wrappedRemotes = setmetatable({}, { __mode = "k" })
	local function wrapRemote(id, remote)
		if type(remote) ~= "table" or not RANK_REMOTE[tostring(id)] then
			return remote
		end
		if wrappedRemotes[remote] then
			return wrappedRemotes[remote]
		end
		local cache = {}
		local proxy = setmetatable(cache, {
			__index = function(_, key)
				local value = remote[key]
				if type(value) == "function" and (key == "CallServer" or key == "CallServerAsync" or key == "InvokeServer" or key == "Fire") then
					local wrapped = wrapRankCall(value, remote)
					cache[key] = wrapped
					return wrapped
				end
				if type(value) == "function" then
					local wrapped = function(_, ...)
						return value(remote, ...)
					end
					cache[key] = wrapped
					return wrapped
				end
				cache[key] = value
				return value
			end,
		})
		wrappedRemotes[remote] = proxy
		return proxy
	end
	client.Get = function(self, id, ...)
		return wrapRemote(id, original(self, id, ...))
	end
	if type(originalThrow) == "function" then
		client.GetOrThrow = function(self, id, ...)
			return wrapRemote(id, originalThrow(self, id, ...))
		end
	end
	ranksHooked = true
end
task.defer(function()
	pcall(hookRankRemotes)
end)

local textHooked = false
local function hookTextWrites()
	if textHooked or type(hookmetamethod) ~= "function" then
		return
	end
	local old
	local wrap = type(newcclosure) == "function" and newcclosure or function(fn)
		return fn
	end
	old = hookmetamethod(game, "__newindex", wrap(function(obj, key, value)
		local mod = Modules["Fake Stats"]
		if not mod or not mod.enabled or statWriting == obj or typeof(obj) ~= "Instance" or type(value) ~= "string" then
			return old(obj, key, value)
		end
		local isText = key == "Text" and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox"))
		local isImage = key == "Image" and (obj:IsA("ImageLabel") or obj:IsA("ImageButton"))
		if not isText and not isImage then
			return old(obj, key, value)
		end
		if obj:FindFirstAncestor("Falcon") then
			return old(obj, key, value)
		end
		local replacement = value
		local ok, changed = pcall(function()
			if isText then
				local nextText = statText(value, mod)
				local level = fakeLevel(mod)
				if playerLevelLine(value) then
					nextText = formatPlayerLevel(value, level)
				end
				if isXpLine(value) then
					nextText = (levelXp(level, value, obj))
				end
				local globalText = globalStat(obj, mod, value)
				if type(globalText) == "string" then
					nextText = globalText
				end
				if nextText == value then
					return value
				end
				local rank = tostring(get(mod, "Rank") or "")
				local rankish = nextText == rank or string.find(nextText, "Leaderboard Rank", 1, true) ~= nil or isRpLine(nextText)
				if rankish and not cardIsMine(obj) then
					return value
				end
				if statSwapped[obj] == nil then
					statSwapped[obj] = obj.Text
				end
				return nextText
			end
			if isRankImage(value) and cardIsMine(obj) then
				local nextImage = imageForRank(get(mod, "Rank"))
				if nextImage and nextImage ~= value then
					if statSwapped[obj] == nil then
						statSwapped[obj] = obj.Image
					end
					return nextImage
				end
			end
			return value
		end)
		if ok and type(changed) == "string" then
			replacement = changed
		end
		statWriting = obj
		local result = old(obj, key, replacement)
		statWriting = nil
		return result
	end))
	textHooked = old ~= nil
end

add("Larping", "Fake NM Emote", "Plays the Nightmare emote. Walking or jumping turns it off", nil, function(on)
	if on then
		nmMissing = false
		nmSent = false
		playNm()
	else
		nmKey = nil
		nmSent = false
		stopNm()
	end
end, function()
	local mod = Modules["Fake NM Emote"]
	if not mod or not mod.enabled then
		return
	end
	local h = hum()
	local moving = false
	if h and (h.MoveDirection.Magnitude > 0.05 or h.Jump) then
		moving = true
	end
	if not moving then
		for _, key in ipairs({ Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space }) do
			if UserInputService:IsKeyDown(key) then
				moving = true
				break
			end
		end
	end
	if moving then
		stopNm()
		setOn(mod, false)
	end
end, 0.05)

-- Presentation overrides only; never writes another player's replicated stats.
do
	local originals = setmetatable({}, { __mode = "k" })
	local selected, signature
	local fields = { "Level", "Winstreak", "Wins", "Bed Breaks", "Final Kills", "Honor", "Rank", "RP", "Kills" }
	local function release(obj, record)
		pcall(function()
			if obj[record.property] == record.shown then obj[record.property] = record.value end
		end)
		originals[obj] = nil
	end
	local function restore()
		for obj, record in pairs(originals) do release(obj, record) end
	end
	local function base(obj, property)
		local record = originals[obj]
		if record and obj[property] == record.shown then return record.value end
		return obj[property]
	end
	local function write(obj, property, value, touched)
		touched[obj] = true
		local original = base(obj, property)
		if value == original then
			if originals[obj] then release(obj, originals[obj]) end
			return
		end
		originals[obj] = { property = property, value = original, shown = value }
		if obj[property] ~= value then obj[property] = value end
	end
	local function plain(text)
		return text:gsub("<[^>]->", "")
	end
	local function pattern(name)
		return "%f[%w_]" .. name:gsub("(%W)", "%%%1") .. "%f[^%w_]"
	end
	local function normalize(text)
		return text:lower():gsub("[%s_%-]", "")
	end
	local function isText(obj)
		return obj:IsA("TextLabel") or obj:IsA("TextButton")
	end
	add("False Ban", "Fake Enemy Stats", "Local visual edits to player rows, profiles and nametags. Blank fields stay unchanged.", function(m)
		opt(m, "Target Username", "text", "")
		opt(m, "Replacement Name", "text", "")
		for _, field in ipairs(fields) do opt(m, field, "text", "") end
	end, function()
		restore()
		selected, signature = nil, nil
	end, function(m)
		local query = tostring(get(m, "Target Username") or ""):lower():match("^%s*(.-)%s*$"):gsub("^@", "")
		local players, target = Players:GetPlayers(), nil
		for _, player in ipairs(players) do
			if player ~= lp and (player.Name:lower() == query or tostring(player.UserId) == query) then target = player; break end
		end
		if not target and query ~= "" then
			for _, player in ipairs(players) do
				if player ~= lp and player.DisplayName:lower() == query then
					if target then target = nil; break end -- Ambiguous display names require a username.
					target = player
				end
			end
		end
		local values = {}
		for _, key in ipairs(m.order) do if key ~= "Bind" then values[#values + 1] = tostring(get(m, key) or "") end end
		local nextSignature = HttpService:JSONEncode(values)
		if target ~= selected or signature ~= nextSignature then restore(); selected, signature = target, nextSignature end
		if not target then m.status = query == "" and "Enter a target username or user ID" or "Player not found (use an exact username or user ID)"; return end
		local replacements, invalid = {}, {}
		for _, field in ipairs(fields) do
			local value = tostring(get(m, field) or ""):match("^%s*(.-)%s*$")
			if value ~= "" then
				local number = tonumber(value)
				if field == "Rank" then replacements[field] = value
				elseif number and number == number and number >= 0 and number <= 1000000000 then replacements[field] = tostring(math.floor(number))
				else invalid[#invalid + 1] = field end
			end
		end
		local replacement = tostring(get(m, "Replacement Name") or "")
		local touched, labels, groups, ownership = {}, {}, {}, {}
		local function identity(text)
			text = plain(text)
			-- Prefer usernames; display names may be shared by different players.
			for _, player in ipairs(players) do if text:find(pattern(player.Name)) then return player end end
			local found
			for _, player in ipairs(players) do
				if text:find(pattern(player.DisplayName)) then
					if found and found ~= player then return false end
					found = player
				end
			end
			return found
		end
		local function collect(root, character)
			if not root then return end
			for _, obj in ipairs(root:GetDescendants()) do
				if isText(obj) then
					labels[#labels + 1] = obj
					local who = character and target or identity(base(obj, "Text"))
					ownership[obj] = who
					local parent = obj.Parent
					for _ = 1, 4 do
						if not parent or parent == root then break end
						if who ~= nil then
							local group = groups[parent]
							if not group then groups[parent] = { owner = who }
							elseif group.owner ~= who then group.owner = false end
						end
						parent = parent.Parent
					end
				end
			end
		end
		collect(lp:FindFirstChildOfClass("PlayerGui"), false)
		pcall(function() collect(game:GetService("CoreGui"), false) end)
		collect(target.Character, true)
		-- Include EnvyV1's world nametags, without scanning the entire world.
		collect(espFolder, false)
		for _, entry in pairs(pEsp) do if entry.b then collect(entry.b, false) end end
		local count = 0
		for _, obj in ipairs(labels) do
			local owner = ownership[obj]
			local parent, hint = obj.Parent, normalize(obj.Name)
			for _ = 1, 4 do
				if not parent then break end
				if owner == nil and groups[parent] then owner = groups[parent].owner end
				if owner ~= nil then break end
				parent = parent.Parent
			end
			if owner == target then
				local original = base(obj, "Text")
				local visible = plain(original)
				local named = identity(original) == target
				-- Generic TextLabels often live inside a named stat container.
				if obj.Parent then hint = hint .. " " .. normalize(obj.Parent.Name) end
				if obj.Parent then
					for _, sibling in ipairs(obj.Parent:GetChildren()) do
						if sibling ~= obj and isText(sibling) then
							local caption = normalize(plain(base(sibling, "Text"))):gsub(":$", "")
							for _, field in ipairs(fields) do
								if caption == normalize(field) then hint = hint .. " " .. caption end
							end
						end
					end
				end
				local fieldOnly
				for _, field in ipairs(fields) do
					local key = normalize(field)
					if hint:find(key, 1, true) and (visible:match("^%s*[%d,]+%s*$") or (field == "Rank" and not named)) then fieldOnly = field; break end
				end
				local function transform(segment)
					local updated = segment
					for _, field in ipairs(fields) do
						local value = replacements[field]
						if value then
							local key = field:gsub("%a", function(c) return "[" .. c:lower() .. c:upper() .. "]" end):gsub(" ", "%%s*")
							if field ~= "Rank" then
								updated = updated:gsub("(%f[%a]" .. key .. "%f[^%a]%s*[:=]?%s*)%d[%d,]*", function(prefix) return prefix .. value end)
								if field == "Level" then updated = updated:gsub("%[%s*%d+%s*%]", function() return "[" .. value .. "]" end) end
							end
						end
					end
					if replacement ~= "" then
						-- Replace once per original match; never reprocess the replacement itself.
						local names = { target.Name, target.DisplayName }
						table.sort(names, function(a, b) return #a > #b end)
						local out, cursor = {}, 1
						while cursor <= #updated do
							local first, last
							for _, name in ipairs(names) do
								local a, b = updated:find(pattern(name), cursor)
								if a and (not first or a < first) then first, last = a, b end
							end
							if not first then out[#out + 1] = updated:sub(cursor); break end
							out[#out + 1] = updated:sub(cursor, first - 1)
							out[#out + 1] = obj.RichText and replacement:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;") or replacement
							cursor = last + 1
						end
						updated = table.concat(out)
					end
					return updated
				end
				local updated
				if fieldOnly and replacements[fieldOnly] then
					updated = replacements[fieldOnly]
					if obj.RichText then updated = updated:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;") end
				elseif obj.RichText then
					local parts, cursor = {}, 1
					for a, tag, b in original:gmatch("()(<[^>]->)()") do
						parts[#parts + 1] = transform(original:sub(cursor, a - 1)); parts[#parts + 1] = tag; cursor = b
					end
					parts[#parts + 1] = transform(original:sub(cursor)); updated = table.concat(parts)
				else updated = transform(original) end
				write(obj, "Text", updated, touched)
				if updated ~= original then count = count + 1 end
			end
		end
		local humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
		if humanoid and replacement ~= "" then write(humanoid, "DisplayName", replacement, touched) end
		for obj, record in pairs(originals) do if not touched[obj] then release(obj, record) end end
		m.status = "Target: @" .. target.Name .. " | " .. count .. " labels changed locally" .. (#invalid > 0 and " | Invalid: " .. table.concat(invalid, ", ") or "")
	end, 0.2)
end

add("Larping", "Fake Stats", "Name, level, winstreak, rank, leaderboard place, RP, and global wins, bed breaks, final kills, and honor", function(m)
	opt(m, "Name", "text", lp.DisplayName or lp.Name)
	opt(m, "Level", "slider", 100, { min = 0, max = 999 })
	opt(m, "Winstreak", "slider", 10, { min = 0, max = 999 })
	opt(m, "Rank", "list", "Nightmare", { list = RANK_LIST })
	opt(m, "RP", "slider", 20, { min = 0, max = 100, suffix = " RP" })
	opt(m, "Nightmare RP", "slider", 477, { min = 0, max = 1000, suffix = " RP" })
	opt(m, "Leaderboard Rank", "text", "1")
	opt(m, "Wins", "text", "228")
	opt(m, "Bed Breaks", "text", "240")
	opt(m, "Final Kills", "text", "325")
	opt(m, "Honor", "text", "36")
end, function(on, m)
	if on then
		realNames = {}
		shownName = ""
		if lp.Name ~= "" then
			table.insert(realNames, lp.Name)
		end
		if lp.DisplayName ~= "" and lp.DisplayName ~= lp.Name then
			table.insert(realNames, lp.DisplayName)
		end
		hookGamePlayer()
		pcall(hookRankRemotes)
		pcall(hookTextWrites)
		pcall(function()
			RunService:UnbindFromRenderStep("QW_RankBar")
		end)
		RunService:BindToRenderStep("QW_RankBar", Enum.RenderPriority.Last.Value, function()
			if m.enabled then
				reapplyBars(m)
			end
		end)
		shownName = tostring(get(m, "Name") or "")
		local function watch(root, guisOnly)
			if not root then
				return
			end
			table.insert(m.conns, Life.connect(root.DescendantAdded, function(obj)
				if m.enabled then
					task.defer(paintStatObject, obj, m)
				end
			end))
			task.spawn(scanStatRoot, root, m, guisOnly)
		end
		watch(lp:FindFirstChildOfClass("PlayerGui"), false)
		pcall(function()
			watch(game:GetService("CoreGui"), false)
		end)
		pcall(function()
			if type(gethui) == "function" then
				watch(gethui(), false)
			end
		end)
		watch(lp.Character, false)
		task.spawn(scanStatRoot, workspace, m, true)
		table.insert(m.conns, Life.connect(workspace.DescendantAdded, function(obj)
			if not Life.active or not m.enabled then
				return
			end
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				if obj:FindFirstAncestorWhichIsA("SurfaceGui") or obj:FindFirstAncestorWhichIsA("BillboardGui") then
					task.defer(paintStatObject, obj, m)
				end
			end
		end))
		task.delay(1.2, function()
			if not Life.active or not m.enabled then
				return
			end
			local pg = lp:FindFirstChildOfClass("PlayerGui")
			if pg then
				scanStatRoot(pg, m, false)
			end
			scanStatRoot(workspace, m, true)
		end)
		table.insert(m.conns, Life.connect(lp.CharacterAdded, function(character)
			if m.enabled then
				task.delay(0.4, function()
					if m.enabled then
						scanStatRoot(character, m, false)
					end
				end)
			end
		end))
	else
		unhookGamePlayer()
		asExecutor()
		for _, conn in pairs(statWatch) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		table.clear(statWatch)
		for obj, old in pairs(statSwapped) do
			if typeof(obj) == "Instance" and obj.Parent then
				statWriting = obj
				if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
					obj.Image = old
				elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
					obj.Text = old
				end
			end
		end
		statWriting = nil
		table.clear(statSwapped)
		for obj, saved in pairs(statColor) do
			if typeof(obj) == "Instance" and obj.Parent and type(saved) == "table" then
				if saved.text ~= nil and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
					obj.TextColor3 = saved.text
				end
				if saved.background ~= nil and obj:IsA("GuiObject") then
					obj.BackgroundColor3 = saved.background
				end
			end
		end
		table.clear(statColor)
		for attr, old in pairs(savedAttr) do
			pcall(function()
				lp:SetAttribute(attr, old)
			end)
		end
		table.clear(savedAttr)
		for frame, saved in pairs(barSaved) do
			if typeof(frame) == "Instance" and frame.Parent and type(saved) == "table" then
				frame.Size = saved.Size
				if frame:IsA("ImageLabel") or frame:IsA("ImageButton") then
					frame.ImageColor3 = saved.Color
					if saved.ImageTransparency ~= nil then
						frame.ImageTransparency = saved.ImageTransparency
					end
				else
					frame.BackgroundColor3 = saved.Color
					if saved.Transparency ~= nil then
						frame.BackgroundTransparency = saved.Transparency
					end
				end
				if saved.ParentTransparency ~= nil and frame.Parent:IsA("GuiObject") then
					frame.Parent.BackgroundTransparency = saved.ParentTransparency
					if saved.ParentImageTransparency ~= nil and (frame.Parent:IsA("ImageLabel") or frame.Parent:IsA("ImageButton")) then
						frame.Parent.ImageTransparency = saved.ParentImageTransparency
					end
				end
				local grad = frame:FindFirstChildOfClass("UIGradient")
				if grad and saved.Gradient then
					grad.Color = saved.Gradient
				end
			end
		end
		table.clear(barSaved)
		for frame, saved in pairs(xpFill) do
			if typeof(frame) == "Instance" and frame.Parent and type(saved) == "table" and saved.Size then
				frame.Size = saved.Size
			end
		end
		table.clear(xpFill)
		pcall(function()
			RunService:UnbindFromRenderStep("QW_RankBar")
		end)
		shownName = ""
		pcall(function()
			lp.DisplayName = realNames[2] or realNames[1] or lp.Name
		end)
	end
end, function(m)
	pcall(hookRankRemotes)
	local store = BW.store
	if store and type(store.getState) == "function" then
		if not store.__qwLevel then
			local oldGet = store.getState
			store.getState = function(self, ...)
				local state = oldGet(self, ...)
				local mod = Modules["Fake Stats"]
				if mod and mod.enabled and type(state) == "table" and type(state.Bedwars) == "table" then
					local bed = state.Bedwars
					local need = 55000
					bed.playerLevel = fakeLevel(mod)
					local cur = bed.playerLevelXp or bed.currentLevelXp or bed.xpIntoLevel or bed.levelXp
					local seen = bed.xpRequirement or bed.xpRequired or bed.levelXpRequirement or bed.xpNeeded or bed.xpToNextLevel
					if type(cur) == "number" and type(seen) == "number" and seen >= 1000 and seen <= 70000 then
						local ratio = seen == need and math.clamp(cur / need, 0, 1) or math.clamp(cur / seen, 0, 1)
						local shown = math.floor(ratio * need + 0.5)
						if type(bed.playerLevelXp) == "number" then
							bed.playerLevelXp = shown
						end
						if type(bed.currentLevelXp) == "number" then
							bed.currentLevelXp = shown
						end
						if type(bed.xpIntoLevel) == "number" then
							bed.xpIntoLevel = shown
						end
						if type(bed.levelXp) == "number" then
							bed.levelXp = shown
						end
						if type(bed.xp) == "number" and bed.xp <= 70000 then
							bed.xp = shown
						end
					end
					if type(bed.xpRequirement) == "number" then
						bed.xpRequirement = need
					end
					if type(bed.xpRequired) == "number" then
						bed.xpRequired = need
					end
					if type(bed.levelXpRequirement) == "number" then
						bed.levelXpRequirement = need
					end
					if type(bed.xpNeeded) == "number" then
						bed.xpNeeded = need
					end
					if type(bed.xpToNextLevel) == "number" then
						bed.xpToNextLevel = need
					end
				end
				return state
			end
			store.__qwLevel = true
		end
		pcall(function()
			local state = store:getState()
			local bed = state and state.Bedwars
			if type(bed) == "table" then
				bed.playerLevel = fakeLevel(m)
			end
		end)
	end
	local name = tostring(get(m, "Name") or "")
	if name ~= "" then
		pcall(function()
			lp.DisplayName = name
		end)
		local h = hum()
		if h then
			pcall(function()
				h.DisplayName = name
			end)
		end
	end
	shownName = name
	for _, attr in ipairs({ "Level", "PlayerLevel", "WinStreak", "winStreak" }) do
		local cur = lp:GetAttribute(attr)
		if type(cur) == "number" then
			if savedAttr[attr] == nil then
				savedAttr[attr] = cur
			end
			local want = (attr == "Level" or attr == "PlayerLevel") and fakeLevel(m) or fakeStreak(m)
			if cur ~= want then
				pcall(function()
					lp:SetAttribute(attr, want)
				end)
			end
		end
	end
	for obj in pairs(statWatch) do
		if typeof(obj) == "Instance" and obj.Parent then
			paintStatObject(obj, m)
		end
	end
	reapplyBars(m)
	m.scanAcc = (m.scanAcc or 0) + 0.2
	if m.scanAcc >= 2 then
		m.scanAcc = 0
		local pg = lp:FindFirstChildOfClass("PlayerGui")
		if pg then
			task.spawn(scanStatRoot, pg, m, false)
		end
		task.spawn(scanStatRoot, workspace, m, true)
	end
end, 0.2)

local function installFakeAvatar()
	local visual
	local hiddenDecals = {}
	local hiddenParts = setmetatable({}, { __mode = "k" })
	local pieces = {}
	local appliedKey
	local failedKey
	local failedAt = 0
	local busy
	local following
	local generation = 0

	pcall(function()
		RunService:UnbindFromRenderStep("QW_Sign")
		RunService:UnbindFromRenderStep("QW_Avatar")
	end)
	local oldSign = workspace:FindFirstChild("QW_Sign")
	if oldSign then
		oldSign:Destroy()
	end
	local leftover = workspace:FindFirstChild("QW_Avatars")
	if leftover then
		leftover:Destroy()
	end
	if char() then
		for _, inst in ipairs(char():GetDescendants()) do
			if inst:IsA("BasePart") then
				inst.LocalTransparencyModifier = 0
			end
		end
	end
	local stuck = root()
	if stuck and stuck.AssemblyLinearVelocity.Magnitude > 80 then
		stuck.AssemblyLinearVelocity = Vector3.zero
		stuck.AssemblyAngularVelocity = Vector3.zero
	end

	local function avatarFolder()
		local folder = workspace:FindFirstChild("QW_Avatars")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "QW_Avatars"
			folder.Parent = workspace
			table.insert(Life.resources, folder)
		end
		return folder
	end

	local function lockPart(part)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = true
		pcall(function()
			part.AssemblyLinearVelocity = Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
		end)
	end

	local function isAvatarPart(inst, character)
		local top = inst
		while top.Parent and top.Parent ~= character do top = top.Parent end
		if top.Parent ~= character or top:IsA("Tool") then return false end
		-- Preserve equipped game gear, including armor implemented as accessories.
		local current = inst
		while current and current ~= character do
			local name = tostring(current:GetAttribute("itemType") or current:GetAttribute("ItemType") or current.Name):lower()
			if name:find("helmet", 1, true) or name:find("chestplate", 1, true) or name:find("boots", 1, true) or name:find("armor", 1, true) then return false end
			for i = 0, 2 do
				local ref = character:FindFirstChild("ArmorInvItem_" .. i)
				if ref and ref:IsA("ObjectValue") and ref.Value == current then return false end
			end
			current = current.Parent
		end
		return (top:IsA("BasePart") and top.Name ~= "HumanoidRootPart") or top:IsA("Accessory") or top:IsA("Hat")
	end
	local function hideReal(character)
		for _, inst in ipairs(character:GetDescendants()) do
			if inst:IsA("BasePart") and isAvatarPart(inst, character) then
				if hiddenParts[inst] == nil then hiddenParts[inst] = inst.LocalTransparencyModifier end
				inst.LocalTransparencyModifier = 1
			elseif (inst:IsA("Decal") or inst:IsA("Texture")) and isAvatarPart(inst, character) then
				if hiddenDecals[inst] == nil then
					hiddenDecals[inst] = inst.Transparency
				end
				inst.Transparency = 1
			end
		end
	end

	local function showReal()
		for inst, old in pairs(hiddenParts) do
			if inst.Parent then inst.LocalTransparencyModifier = old end
		end
		table.clear(hiddenParts)
		for inst, old in pairs(hiddenDecals) do
			if typeof(inst) == "Instance" and inst.Parent then
				inst.Transparency = old
			end
		end
		table.clear(hiddenDecals)
	end

	local function targetKey(m)
		local idText = string.match(tostring(get(m, "User Id") or ""), "%d+")
		if idText then
			return "id:" .. idText
		end
		local nameText = string.match(tostring(get(m, "Username") or ""), "^%s*@?(.-)%s*$") or ""
		return "name:" .. string.lower(nameText)
	end

	local function prepare(model)
		table.clear(pieces)
		local handles = {}
		for _, acc in ipairs(model:GetChildren()) do
			if acc:IsA("Accessory") or acc:IsA("Hat") then
				local handle = acc:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					local limb, offset
					for _, weld in ipairs(handle:GetChildren()) do
						if weld:IsA("Weld") or weld:IsA("Motor6D") then
							if weld.Part0 and weld.Part0 ~= handle and not weld.Part0:IsDescendantOf(acc) then
								limb = weld.Part0
								offset = weld.C0 * weld.C1:Inverse()
							elseif weld.Part1 and weld.Part1 ~= handle and not weld.Part1:IsDescendantOf(acc) then
								limb = weld.Part1
								offset = weld.C1 * weld.C0:Inverse()
							end
						end
					end
					if not limb then
						for _, att in ipairs(handle:GetChildren()) do
							if att:IsA("Attachment") then
								local limbAtt
								for _, other in ipairs(model:GetDescendants()) do
									if other:IsA("Attachment") and other.Name == att.Name and other.Parent ~= handle and other.Parent:IsA("BasePart") then
										limbAtt = other
										limb = other.Parent
										break
									end
								end
								if limb and limbAtt then
									offset = limbAtt.CFrame * att.CFrame:Inverse()
									break
								end
							end
						end
					end
					if limb and limb:IsA("BasePart") then
						handles[handle] = true
						table.insert(pieces, { kind = "acc", part = handle, limbName = limb.Name, offset = offset or CFrame.new() })
						for _, extra in ipairs(acc:GetDescendants()) do
							if extra:IsA("BasePart") and extra ~= handle then
								handles[extra] = true
								table.insert(pieces, { kind = "child", part = extra, handle = handle, offset = handle.CFrame:ToObjectSpace(extra.CFrame) })
							end
						end
					end
				end
			end
		end
		for _, inst in ipairs(model:GetDescendants()) do
			if inst:IsA("Script") or inst:IsA("LocalScript") then
				inst:Destroy()
			end
		end
		local actor = model:FindFirstChildOfClass("Humanoid")
		if actor then
			actor.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			actor.RequiresNeck = false
			actor.BreakJointsOnDeath = false
			actor.AutoRotate = false
		end
		for _, inst in ipairs(model:GetDescendants()) do
			if inst:IsA("JointInstance") or inst:IsA("Constraint") or inst:IsA("WeldConstraint") then
				inst:Destroy()
			end
		end
		for _, inst in ipairs(model:GetDescendants()) do
			if inst:IsA("BasePart") then
				lockPart(inst)
				if inst.Name == "HumanoidRootPart" then
					inst.Transparency = 1
				elseif not handles[inst] then
					table.insert(pieces, { kind = "copy", part = inst, name = inst.Name, transparency = inst.Transparency })
				end
			end
		end
	end

	local function stepAvatar()
		local character = char()
		local realRoot = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
		if not character or not visual or not visual.Parent or not realRoot then
			return
		end
		hideReal(character)
		local camera = workspace.CurrentCamera
		local head = character:FindFirstChild("Head")
		local firstPerson = camera and head and (camera.CFrame.Position - head.Position).Magnitude < 1
		local fakeHum = visual:FindFirstChildOfClass("Humanoid")
		if camera and fakeHum and camera.CameraSubject == fakeHum then
			local realHum = character:FindFirstChildOfClass("Humanoid")
			if realHum then
				camera.CameraSubject = realHum
			end
		end
		for _, piece in ipairs(pieces) do
			local part = piece.part
			if part and part.Parent then
				part.LocalTransparencyModifier = firstPerson and 1 or 0
				if piece.kind == "copy" then
					local src = character:FindFirstChild(piece.name)
					if src and src:IsA("BasePart") then
						part.Transparency = piece.transparency
						part.CFrame = src.CFrame
					else
						part.CFrame = realRoot.CFrame
						part.Transparency = 1
					end
				elseif piece.kind == "acc" then
					local src = character:FindFirstChild(piece.limbName) or character:FindFirstChild("Head")
					if src and src:IsA("BasePart") then
						part.CFrame = src.CFrame * piece.offset
					else
						part.CFrame = realRoot.CFrame
					end
				elseif piece.kind == "child" and piece.handle and piece.handle.Parent then
					part.CFrame = piece.handle.CFrame * piece.offset
				end
				lockPart(part)
			end
		end
	end

	local function stopAvatar()
		generation = generation + 1
		following = false
		pcall(function()
			RunService:UnbindFromRenderStep("QW_Avatar")
		end)
		if visual then
			visual:Destroy()
			visual = nil
		end
		table.clear(pieces)
		showReal()
		appliedKey = nil
		busy = false
	end

	local function apply(m)
		if busy or not m.enabled then
			return
		end
		local key = targetKey(m)
		if key == "name:" then
			if visual then stopAvatar() end
			m.status = "Enter a username or user ID"
			return
		end
		if key == appliedKey or (key == failedKey and os.clock() - failedAt < 5) then
			return
		end
		busy = true
		local gen = generation
		task.spawn(function()
			local pendingModel
			local ok, err = xpcall(function()
			local function stale()
				return not Life.active or gen ~= generation or not m.enabled or targetKey(m) ~= key
			end
			local userId = tonumber(string.match(key, "^id:(%d+)$"))
			if string.sub(key, 1, 5) == "name:" then
				local wanted = string.sub(key, 6)
				asExecutor()
				local okId, result = pcall(function()
					return game:GetService("Players"):GetUserIdFromNameAsync(wanted)
				end)
				if okId then
					userId = tonumber(result)
				end
			end
			if stale() or not userId then
				if gen == generation then
					busy = false
					if m.enabled and targetKey(m) == key then
						failedKey = key
						failedAt = os.clock()
						m.status = "Username lookup failed; retrying in 5 seconds"
					end
				end
				return
			end
			asExecutor()
			local okModel, model = pcall(function()
				local desc = Players:GetHumanoidDescriptionFromUserId(userId)
				local realHum = hum()
				assert(realHum, "Waiting for character")
				return Players:CreateHumanoidModelFromDescription(desc, realHum.RigType)
			end)
			if not okModel or not model then
				local realHum = hum()
				local okDesc, desc = pcall(function()
					return game:GetService("Players"):GetHumanoidDescriptionFromUserId(userId)
				end)
				if okDesc and desc and realHum then
					okModel, model = pcall(function()
						return game:GetService("Players"):CreateHumanoidModelFromDescription(desc, realHum.RigType)
					end)
				end
			end
			if not okModel or typeof(model) ~= "Instance" or stale() then
				if typeof(model) == "Instance" then
					model:Destroy()
				end
				if gen == generation then
					busy = false
					if m.enabled and targetKey(m) == key then
						failedKey = key
						failedAt = os.clock()
						m.status = "Avatar load failed; retrying in 5 seconds"
					end
				end
				return
			end
			local accCount = 0
			pendingModel = model
			for _, child in ipairs(model:GetChildren()) do
				if child:IsA("Accessory") or child:IsA("Hat") then
					accCount = accCount + 1
				end
			end
			if accCount == 0 then
				local cloneHum = model:FindFirstChildOfClass("Humanoid")
				local okDesc, desc = pcall(function()
					return game:GetService("Players"):GetHumanoidDescriptionFromUserId(userId)
				end)
				if okDesc and desc and cloneHum then
					pcall(function()
						cloneHum:ApplyDescription(desc)
					end)
				end
			end
			if stale() then
				model:Destroy()
				if gen == generation then
					busy = false
				end
				return
			end
			if visual then
				visual:Destroy()
				visual = nil
			end
			prepare(model)
			model.Name = "QW_Avatar"
			model.Parent = avatarFolder()
			visual = model
			pendingModel = nil
			appliedKey = key
			failedKey = nil
			busy = false
			m.status = "Avatar applied | equipped armor preserved"
			if not following then
				following = true
				RunService:BindToRenderStep("QW_Avatar", Enum.RenderPriority.Last.Value, stepAvatar)
			end
			stepAvatar()
			end, function(message) return tostring(message) end)
			if not ok then
				if pendingModel then pendingModel:Destroy() end
				if gen == generation then
					busy = false
					failedKey, failedAt = key, os.clock()
					m.status = "Avatar error: " .. tostring(err)
				end
				warn("[Falcon] Fake Avatar: " .. tostring(err))
			end
		end)
	end

	add("Larping", "Fake Avatar", "Client-side copy of another player's avatar, including hair", function(m)
		opt(m, "Username", "text", "")
		opt(m, "User Id", "text", "")
	end, function(on, m)
		if on then
			failedKey = nil
			apply(m)
		else
			stopAvatar()
		end
	end, function(m)
		if m.enabled and not visual and not busy then
			apply(m)
		elseif m.enabled and visual and appliedKey ~= targetKey(m) then
			apply(m)
		end
	end, 0.4)
end

installFakeAvatar()

do
	local function clutchBlock()
		local inv = inventory()
		if not inv then return end
		local handMeta = inv.hand and metaOf(inv.hand.itemType)
		if handMeta and handMeta.block and (inv.hand.amount or 1) > 0 then return inv.hand.itemType end
		local hotbar = inv.hotbar
		if not hotbar and BW.store then
			pcall(function() hotbar = BW.store:getState().Inventory.observedInventory.hotbar end)
		end
		for _, entry in pairs(hotbar or {}) do
			if type(entry) == "table" then
				local item = entry.item or entry
				local meta = metaOf(item.itemType)
				if meta and meta.block and (item.amount or 1) > 0 then
					return item.itemType
				end
			end
		end
		return nil
	end

	local directions = {
		Vector3.xAxis, -Vector3.xAxis, Vector3.zAxis, -Vector3.zAxis, -Vector3.yAxis,
	}
	local function findClutchCell(store, position, feet, velocity)
		local best, bestScore
		local gravity = workspace.Gravity
		-- Sample the next three block levels and predict where the feet cross each top face.
		local firstY = math.floor((feet - 1.6) / 3)
		local checked = {}
		local function occupied(cell)
			local cached = checked[cell]
			if cached == nil then
				local part = store:getBlockAt(cell)
				cached = not not part
				checked[cell] = cached
			end
			return cached
		end
		for y = firstY, firstY - 2, -1 do
			local drop = feet - (y * 3 + 1.5)
			local time = 2 * drop / (math.sqrt(velocity.Y ^ 2 + 2 * gravity * drop) - velocity.Y)
			if time > 0.045 and time <= 0.45 then
				local x = position.X + velocity.X * time
				local z = position.Z + velocity.Z * time
				local landing = snap3(Vector3.new(x, 0, z))
				for dx = -1, 1 do
					for dz = -1, 1 do
						local cell = Vector3.new(landing.X + dx, y, landing.Z + dz)
						local distance = (cell * 3 - position).Magnitude
						local missX, missZ = math.abs(cell.X * 3 - x), math.abs(cell.Z * 3 - z)
						local score = time * 10 + missX + missZ + distance * 0.1
						if missX <= 1.75 and missZ <= 1.75 and distance <= 12
							and (not bestScore or score < bestScore) and not occupied(cell) then
							for _, direction in ipairs(directions) do
								if occupied(cell + direction) then
									best, bestScore = cell, score
									break
								end
							end
						end
					end
				end
			end
		end
		return best
	end

	local fallbackPlacer, fallbackStore, retryAdapter
	local function clutchAdapters(material)
		local placer = blockPlacer() or fallbackPlacer
		local controller = BW.blockController
		local ok, store = pcall(function() return controller:getStore() end)
		if not ok then store = nil end
		if (placer and (store or fallbackStore)) or os.clock() < (retryAdapter or 0) then
			return placer, store or fallbackStore
		end
		retryAdapter = os.clock() + 1
		pcall(function()
			local engine = ReplicatedStorage.rbxts_include.node_modules["@easy-games"]["block-engine"].out
			if not store and not fallbackStore then fallbackStore = require(engine).BlockEngine:getStore() end
			if not placer then
				local clientEngine = require(lp.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine
				local class = require(engine.client.placement["block-placer"]).BlockPlacer
				fallbackPlacer = class.new(clientEngine, material)
			end
		end)
		return placer or fallbackPlacer, store or fallbackStore
	end

	local nextPlace = 0
	add("World", "Auto Block Clutch", "Places a supported block beneath your fall when you leave an edge", function(m)
		opt(m, "Fall speed", "slider", 20, {min = 12, max = 50, suffix = " st/s"})
	end, function(on)
		nextPlace, retryAdapter = 0, nil
		if not on and fallbackPlacer then
			pcall(function() fallbackPlacer:disable() end)
			fallbackPlacer = nil
		end
	end, function(m)
		local body, humanoid = root(), hum()
		if not body or not humanoid or humanoid.Health <= 0 or menuOpen then return end
		local velocity = body.AssemblyLinearVelocity
		if humanoid.FloorMaterial ~= Enum.Material.Air or velocity.Y > -get(m, "Fall speed") then
			m.status = "Waiting for a fall"
			return
		end
		local now = os.clock()
		if now < nextPlace then return end

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.RespectCanCollide = true
		local ignore = {}
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character then table.insert(ignore, player.Character) end
		end
		params.FilterDescendantsInstances = ignore
		local feet = body.Position.Y - body.Size.Y / 2 - humanoid.HipHeight
		local probe = math.clamp(-velocity.Y * 0.32, 5, 14)
		local lookahead = math.min(probe / -velocity.Y, 0.18)
		local ahead = Vector3.new(velocity.X * lookahead, 0, velocity.Z * lookahead)
		local ground = workspace:Raycast(body.Position + ahead, Vector3.new(0, feet - body.Position.Y - probe, 0), params)
		if ground then m.status = "Ground below"; return end

		local material = clutchBlock()
		if not material then m.status = "Put building blocks in your hotbar"; return end
		local placer, store = clutchAdapters(material)
		if not placer or not store then m.status = "Waiting for block placement and grid"; return end
		local cell = findClutchCell(store, body.Position, feet, velocity)
		if not cell then m.status = "No reachable support"; return end
		nextPlace = now + 0.10
		local previous = placer.blockType
		placer.blockType = material
		local placed, result = pcall(placer.placeBlock, placer, cell)
		if placer.blockType == material then placer.blockType = previous end
		m.status = placed and result ~= false and "Clutch placement attempted" or "Placement unavailable"
	end, 0.04)
end

add("World", "Nuker", "Fast-breaks bed defense, then the bed", function(m)
	opt(m, "Range", "slider", 25, { min = 10, max = 30, suffix = " st" })
	opt(m, "Auto tool", "toggle", true)
	opt(m, "Limit to items", "toggle", true)
	opt(m, "Copy diagnostics", "action", nil)
	m.options["Copy diagnostics"].callback=function()
		local route={}
		for _,step in ipairs(miningRoute.steps or {}) do
			local cost=miningRoute.costs and miningRoute.costs[step.part]
			table.insert(route,{target=step.part.Name,cell=step.cell and tostring(step.cell) or "fallback",
				cleared=miningRoute.done and miningRoute.done[step.part] or false,
				remainingHealth=cost and cost.remaining or "unknown",estimatedHealth=cost and cost.estimated or false,
				toolDamage=cost and cost.damage or "unknown"})
		end
		local text=HttpService:JSONEncode({build="nuker-20261109-cadence10",status=m.status,
			sent=m.mineSent or 0,confirmed=m.mineConfirmed or 0,route=route,history=m.mineHistory or {}})
		if type(setclipboard)=="function" then setclipboard(text);notify("Nuker diagnostics copied")
		else warn(text);notify("Clipboard unavailable; Nuker diagnostics printed to F9") end
	end
end, function() resetMining() end, function(m)
	local ok,err=pcall(breakBedStep,get(m, "Range"),true,get(m, "Auto tool"),get(m, "Limit to items"))
	if not ok then m.status="Nuker error: " .. tostring(err) end
	if m.status~=m.mineLastStatus then
		m.mineLastStatus=m.status
		m.mineHistory=m.mineHistory or {}
		local model=char()
		local ref=model and model:FindFirstChild("HandInvItem")
		local hand=ref and ref:IsA("ObjectValue") and ref.Value
		local step=miningRoute.steps and miningRoute.steps[miningRoute.index]
		table.insert(m.mineHistory,{at=os.clock(),status=m.status or "",hand=hand and hand.Name or "empty",
			target=step and step.part.Name or "none",routeStep=miningRoute.index or 0,
			cell=step and step.cell and tostring(step.cell) or "fallback",
			routeReason=miningRoute.reason or "none",switches=miningRoute.switches or 0,visited=miningRoute.visited or 0,
			budgetHit=miningRoute.budgetHit or false,source=miningRoute.source or "none",bedCells=miningRoute.bedCellCount or 0,
			health=miningRoute.health and miningRoute.health<math.huge and miningRoute.health or "unknown",
			score=miningRoute.score and miningRoute.score<math.huge and miningRoute.score or "unknown"})
		if #m.mineHistory>60 then table.remove(m.mineHistory,1) end
	end
end, 0.05)

-- Profiles contain data only. Imports never execute the JSON contents.
do
	local SHARED="envy-v1"
	-- Keep this generation stable: each account starts fresh once, then keeps its own saves.
	local ACCOUNT=SHARED .. "/users/" .. tostring(lp.UserId)
	local ROOT=ACCOUNT .. "/reset-1"
	local SETTINGS=ROOT .. "/settings.json"
	local controls
	local function profileName(name)
		if type(name)~="string" then return end
		name=name:match("^%s*(.-)%s*$"):gsub("%.json$","")
		if #name<1 or #name>48 or not name:match("^[%w_-]+$") then return end
		return name
	end
	local function folders()
		if type(writefile)~="function" or type(readfile)~="function" then
			return false,"Executor file APIs unavailable"
		end
		for _,dir in ipairs({SHARED,SHARED .. "/users",ACCOUNT,ROOT,ROOT .. "/configs"}) do
			if type(isfolder)=="function" and isfolder(dir) then
				-- Already present.
			elseif type(makefolder)=="function" then
				local ok,err=pcall(makefolder,dir)
				if not ok then
					local checked,exists=pcall(function() return type(isfolder)=="function" and isfolder(dir) end)
					if not checked or not exists then return false,tostring(err) end
				end
			end
		end
		return true
	end
	local function status(message,loud)
		if controls then controls.status=message end
		if loud then notify(message) end
	end
	local function preferences()
		return {
			format="envy.settings",version=1,
			userId=lp.UserId,resetVersion=1,
			activeProfile=Config.activeProfile,
			autosave=Config.autosave,autoExecute=Config.autoExecute,
			startupAura=Config.startupAura,
			suspended=Config.suspended==true,
		}
	end
	local TICKET=ROOT .. "/teleport.json"
	local function loader(ticketId)
		return "local expectedTicket = " .. (ticketId and string.format("%q",ticketId) or "nil") .. "\n" .. [[
local players=game:GetService("Players")
local player=players.LocalPlayer
while not player do task.wait();player=players.LocalPlayer end
local root="envy-v1/users/" .. tostring(player.UserId) .. "/reset-1/"
local http=game:GetService("HttpService")
local ok,settings,ticket=pcall(function()
	return http:JSONDecode(readfile(root .. "settings.json")),http:JSONDecode(readfile(root .. "teleport.json"))
end)
if not ok or type(settings)~="table" or settings.autoExecute~=true or settings.suspended==true then return end
if type(ticket)~="table" or type(ticket.id)~="string" or type(ticket.expires)~="number"
	or ticket.expires<os.time() or ticket.origin==game.JobId
	or (ticket.destination and ticket.destination~=game.PlaceId)
	or (expectedTicket and ticket.id~=expectedTicket) then return end
local env=type(getgenv)=="function" and getgenv() or _G
local runtime=env.EnvyV1Runtime
if runtime and runtime.active and runtime.jobId==game.JobId then return end
local cached,source=pcall(readfile,"envy-v1/source.luau")
if not cached or type(source)~="string" or source=="" then
	source=game:HttpGet("https://raw.githubusercontent.com/corapsez-ctrl/quantumware/main/bedwars.luau?t=" .. tostring(os.time()))
end
local run,err=loadstring(source)
assert(run,err)
local consumed=pcall(function()
	local current=http:JSONDecode(readfile(root .. "teleport.json"))
	assert(current.id==ticket.id and current.expires>=os.time())
	writefile(root .. "teleport.json","{}")
	assert(readfile(root .. "teleport.json")=="{}")
end)
if not consumed then return end
env.EnvyV1Source=source
run()
]]
	end
	local function clearTeleport()
		Config.queued=false
		pcall(writefile,TICKET,"{}")
	end

	function Config.writePreferences()
		local available,err=folders()
		if not available then return false,err end
		local ok,result=pcall(function()
			local raw=HttpService:JSONEncode(preferences())
			writefile(SETTINGS,raw)
			assert(readfile(SETTINGS)==raw,"Settings write did not persist")
			writefile(SHARED .. "/autoexec.luau",loader())
			-- Refresh an existing autoexec install so it uses the account-specific settings path.
			if type(isfile)=="function" and isfile("autoexec/envy-v1.luau") then
				writefile("autoexec/envy-v1.luau",loader())
			end
			local source=Life.environment.EnvyV1Source
			if type(source)=="string" and source~="" then writefile(SHARED .. "/source.luau",source) end
		end)
		return ok,ok and SETTINGS or tostring(result)
	end
	function Config.snapshot()
		local doc={format="envy.config",version=1,modules={}}
		for name,mod in pairs(Modules) do
			if not mod.settingsOnly and not mod.action then
				local enabled=mod.enabled==true
				if Config.pending and Config.pending[name] then enabled=Config.pending[name].enabled end
				local record={enabled=enabled,options={}}
				for key,o in pairs(mod.options) do
					if o.kind=="bind" then
						record.options[key]=o.value and o.value.Name or false
					elseif o.kind~="action" and (type(o.value)=="string" or type(o.value)=="number" or type(o.value)=="boolean") then
						record.options[key]=o.value
					end
				end
				doc.modules[name]=record
			end
		end
		local silent = doc.modules["Silent Aura"]
		local blatant = doc.modules.Killaura
		doc.auraMode = silent and silent.enabled and "Silent Aura" or blatant and blatant.enabled and "Killaura" or "None"
		return doc
	end
	function Config.save(name,loud)
		name=profileName(name or Config.activeProfile)
		if not name then status("Use a profile name with letters, numbers, - or _",loud);return false end
		local available,err=folders()
		if not available then status(err,loud);return false end
		local path=ROOT .. "/configs/" .. name .. ".json"
		local ok,result=pcall(function()
			local raw=HttpService:JSONEncode(Config.snapshot())
			writefile(path,raw)
			assert(readfile(path)==raw,"Profile write did not persist")
		end)
		if not ok then Config.lastError=tostring(result);status("Save failed: " .. tostring(result),true);return false end
		Config.activeProfile=name
		Config.loadError=nil
		local prefsOk,prefsErr=Config.writePreferences()
		if not prefsOk then Config.lastError=tostring(prefsErr);status("Profile saved; preferences failed: " .. tostring(prefsErr),true);return false end
		Config.lastError=nil
		Config.dirty=false
		Config.lastSave=os.clock()
		Config.loaded=true
		status("Saved " .. path .. " | Aura: " .. Config.snapshot().auraMode .. " | Startup: " .. Config.startupAura,loud)
		return true,path
	end
	function Config.validate(doc)
		if type(doc)~="table" or (doc.format~="envy.config" and doc.format~="quantumware.config") or doc.version~=1 or type(doc.modules)~="table" then
			return nil,"Unsupported config format/version"
		end
		local plan={}
		local skipped={}
		for name,record in pairs(doc.modules) do
			local mod=Modules[name]
			if mod and not mod.settingsOnly and not mod.action then
				if type(record)~="table" or type(record.enabled)~="boolean" or type(record.options)~="table" then return nil,"Invalid module record: " .. name end
				local item={enabled=record.enabled,options={}}
				for key,value in pairs(record.options) do
					local o=mod.options[key]
					if o then
						local valid=false
						if o.kind=="toggle" then valid=type(value)=="boolean"
						elseif o.kind=="slider" then
							valid=type(value)=="number" and value==value and value>=o.min and value<=o.max
						elseif o.kind=="list" then valid=type(value)=="string" and table.find(o.list,value)~=nil
						elseif o.kind=="text" then valid=type(value)=="string" and #value<=512
						elseif o.kind=="bind" then
							valid=value==false
							if type(value)=="string" then
								local ok,code=pcall(function() return Enum.KeyCode[value] end)
								valid=ok and code~=nil and code~=Enum.KeyCode.Unknown and code~=Enum.KeyCode.RightShift
							end
						end
						if valid then item.options[key]=value
						else skipped[#skipped+1]=name .. " / " .. key end
					end
				end
				plan[name]=item
			end
		end
		if doc.auraMode == "Silent Aura" or doc.auraMode == "Killaura" or doc.auraMode == "None" then
			for _, name in ipairs({"Killaura", "Silent Aura"}) do
				if Modules[name] then
					plan[name] = plan[name] or {options={}}
					plan[name].enabled = doc.auraMode == name
				end
			end
		elseif plan.Killaura and plan.Killaura.enabled and plan["Silent Aura"] and plan["Silent Aura"].enabled then
			plan.Killaura.enabled=false
		end
		return plan,#skipped>0 and ("Skipped invalid settings: " .. table.concat(skipped, ", ")) or nil
	end
	local function readProfile(name)
		local available,err=folders()
		if not available then return nil,err end
		local path=ROOT .. "/configs/" .. name .. ".json"
		local ok,raw=pcall(readfile,path)
		if not ok then return nil,"Could not read " .. path end
		if type(raw)~="string" or #raw>524288 then return nil,"Config is empty or too large" end
		local decoded,doc=pcall(HttpService.JSONDecode,HttpService,raw)
		if not decoded then return nil,"Config is not valid JSON" end
		return Config.validate(doc)
	end
	local function applyOptions(plan)
		for name,record in pairs(plan) do
			local mod=Modules[name]
			for key,value in pairs(record.options) do
				local o=mod.options[key]
				if o.kind=="bind" then
					o.value=value~=false and Enum.KeyCode[value] or nil
				else o.value=value end
				if o.paint then pcall(o.paint) end
			end
		end
	end
	function Config.import(name,loud)
		name=profileName(name)
		if not name then status("Invalid profile name",loud);return false end
		local plan,err=readProfile(name)
		if not plan then status(err,loud);return false end
		Config.pending=nil
		Config.restoring=true
		for _,mod in pairs(Modules) do if mod.enabled then setOn(mod,false,true) end end
		applyOptions(plan)
		for modName,record in pairs(plan) do if record.enabled then setOn(Modules[modName],true,true) end end
		Config.restoring=false
		Config.activeProfile=name
		Config.loadError=nil
		controls.options.Profile.value=name
		Config.loaded=true
		Config.dirty=false
		Config.writePreferences()
		if Life.closePanel then Life.closePanel() end
		status("Loaded profile " .. name .. (err and " | " .. err or ""),loud)
		return true
	end
	function Config.changed()
		if Config.restoring or not Life.active or Life.destroying then return end
		if controls then
			local previousSave,previousExecute=Config.autosave,Config.autoExecute
			Config.autosave=get(controls,"Autosave")==true
			Config.autoExecute=get(controls,"Auto execute")==true
			local startupAura=get(controls,"Startup aura")
			if startupAura ~= Config.startupAura then
				Config.startupAura=startupAura
				Config.writePreferences()
			end
			if previousExecute and not Config.autoExecute then clearTeleport() end
			if previousSave~=Config.autosave or previousExecute~=Config.autoExecute then Config.writePreferences() end
		end
		Config.revision=Config.revision+1
		Config.dirty=true
		local revision=Config.revision
		task.delay(0.6,function()
			if not Life.active or Life.destroying or revision~=Config.revision then return end
			if Config.autosave and not Config.loadError then Config.save(Config.activeProfile,false)
			else Config.writePreferences() end
		end)
	end
	function Config.prepare()
		local available=folders()
		if not available then status("File APIs unavailable: settings cannot persist",true);return end
		local ok,raw=pcall(readfile,SETTINGS)
		if ok then
			local decoded,prefs=pcall(HttpService.JSONDecode,HttpService,raw)
			if decoded and type(prefs)=="table" and (prefs.format=="envy.settings" or prefs.format=="quantumware.settings") then
				Config.activeProfile=profileName(prefs.activeProfile) or "default"
				Config.autosave=prefs.autosave~=false
				Config.autoExecute=prefs.autoExecute~=false
				if table.find({"Saved","Silent Aura","Killaura","None"},prefs.startupAura) then Config.startupAura=prefs.startupAura end
			end
		end
		Config.suspended=false
		controls.options.Profile.value=Config.activeProfile
		controls.options.Autosave.value=Config.autosave
		controls.options["Auto execute"].value=Config.autoExecute
		controls.options["Startup aura"].value=Config.startupAura
		local plan,err=readProfile(Config.activeProfile)
		if not ok and not plan then
			-- Seed only this new account namespace. Old shared configs are intentionally ignored.
			Config.activeProfile="default"
			controls.options.Profile.value="default"
			local saved=Config.save("default",false)
			if saved then status("Fresh config created for @" .. lp.Name .. "; future changes save automatically",false) end
			return
		end
		if plan then applyOptions(plan);Config.pending=plan;Config.loadWarning=err;Config.loaded=true
		else
			local path=ROOT .. "/configs/" .. Config.activeProfile .. ".json"
			local exists=false
			if type(isfile)=="function" then local checked,result=pcall(isfile,path);exists=checked and result
			else exists=pcall(readfile,path) end
			Config.loadError=exists and err or nil
			status((exists and "Profile could not load: " or "New profile: ") .. Config.activeProfile .. " (" .. tostring(err) .. ")",exists)
		end
		Config.writePreferences()
	end
	function Config.start()
		if Config.started then return end
		Config.started=true
		local queue=queue_on_teleport or queueonteleport or (type(syn)=="table" and syn.queue_on_teleport)
		Config.queueSupported=type(queue)=="function"
		clearTeleport()
		Life.connect(lp.OnTeleport,function(state,destination)
			if state==Enum.TeleportState.Failed then clearTeleport();return end
			if state~=Enum.TeleportState.Started or Config.queued or not Config.autoExecute then return end
			if Config.autosave and not Config.loadError then Config.save(Config.activeProfile,false) end
			if not Config.writePreferences() then return end
			local ok,id=pcall(function()
				local ticketId=HttpService:GenerateGUID(false)
				local raw=HttpService:JSONEncode({
					id=ticketId,origin=game.JobId,expires=os.time()+120,
					destination=type(destination)=="number" and destination>0 and destination or nil,
				})
				writefile(TICKET,raw)
				assert(readfile(TICKET)==raw,"Teleport handoff did not persist")
				return ticketId
			end)
			if not ok then status("Could not save teleport handoff: " .. tostring(id),true);return end
			Config.queued=true
			if Config.queueSupported then
				local queued,err=pcall(queue,loader(id))
				if not queued then status("Could not queue auto-execute: " .. tostring(err),true) end
			else
				status("Teleport handoff saved for the installed auto-load script",false)
			end
		end)
		task.defer(function()
			if not Life.active then return end
			local plan=Config.pending or {}
			if Config.startupAura ~= "Saved" then
				for _, name in ipairs({"Killaura","Silent Aura"}) do
					if Modules[name] then
						plan[name]=plan[name] or {options={}}
						plan[name].enabled=Config.startupAura==name
					end
				end
			end
			Config.restoring=true
			for name,record in pairs(plan) do
				if not record.enabled then setOn(Modules[name],false,true) end
			end
			for name,record in pairs(plan) do
				if record.enabled then setOn(Modules[name],true,true) end
			end
			Config.pending=nil
			Config.restoring=false
			Config.dirty=false
			status("Restored " .. Config.activeProfile .. " | Aura: " .. Config.snapshot().auraMode .. (Config.loadWarning and " | " .. Config.loadWarning or (Config.queueSupported and " | teleport queue ready" or " | use autoexec.luau for auto-launch")),Config.loadWarning~=nil)
		end)
	end
	controls=add("Settings","Configuration","Autosave, JSON profile sharing, and teleport auto-execution",function(m)
		opt(m,"Autosave","toggle",true)
		opt(m,"Auto execute","toggle",true)
		opt(m,"Startup aura","list","Silent Aura",{list={"Saved","Silent Aura","Killaura","None"}})
		opt(m,"Profile","text","default")
		opt(m,"Save now","action",nil)
		opt(m,"Export JSON","action",nil)
		opt(m,"Import JSON","action",nil)
		opt(m,"Enable auto-load","action",nil)
	end)
	controls.settingsOnly=true
	controls.options["Save now"].callback=function() Config.save(get(controls,"Profile"),true) end
	controls.options["Export JSON"].callback=function() Config.save(get(controls,"Profile"),true) end
	controls.options["Import JSON"].callback=function() Config.import(get(controls,"Profile"),true) end
	controls.options["Enable auto-load"].callback=function()
		Config.autoExecute=true
		controls.options["Auto execute"].value=true
		local ok,err=Config.writePreferences()
		if not ok then status(tostring(err),true);return end
		local installed,result=pcall(function()
			assert(type(isfolder)=="function" and isfolder("autoexec"),"Autoexec folder is not exposed by this executor")
			writefile("autoexec/envy-v1.luau",loader())
			assert(readfile("autoexec/envy-v1.luau")==loader(),"Autoexec installation did not persist")
		end)
		status(installed and "Installed autoexec/envy-v1.luau" or "Loader saved at envy-v1/autoexec.luau. Copy it into your executor's autoexec folder for new sessions.",true)
	end
	local destroy=add("Settings","Self Destruct","Unloads modules, removes the menu/effects, and stops this instance")
	destroy.action=function() if Life.Destroy then Life.Destroy() end end
	function Life.Destroy()
		if Life.destroying or not Life.active then return end
		Life.destroying=true
		if Life.stopLocalSwordSwing then pcall(Life.stopLocalSwordSwing) end
		if Config.started and Config.autosave and not Config.loadError then pcall(Config.save,Config.activeProfile,false) end
		Config.suspended=true
		clearTeleport()
		pcall(Config.writePreferences)
		if Life.closePanel then pcall(Life.closePanel) end
		for _,mod in pairs(Modules) do
			if mod.enabled then
				local ok,err=pcall(setOn,mod,false)
				if not ok then warn("[Falcon] cleanup: " .. tostring(err)) end
			end
		end
		pcall(setWalls,false)
		pcall(setMissBypass,false)
		if BW.sword and BW.sword.swingSwordAtMouse==Life.swingHook and swingOrig then BW.sword.swingSwordAtMouse=swingOrig end
		BW.nofall=false
		pcall(stopFly)
		wipe(pEsp)
		wipe(bEsp)
		for _,name in ipairs({"QW_NMFollow","QW_RankBar","QW_Avatar","QW_Sign"}) do pcall(RunService.UnbindFromRenderStep,RunService,name) end
		Life.active=false
		for _,connection in ipairs(Life.connections) do pcall(function() connection:Disconnect() end) end
		table.clear(Life.connections)
		for _,resource in ipairs(Life.resources) do pcall(function() resource:Destroy() end) end
		table.clear(Life.resources)
		if Life.environment.EnvyV1Runtime==Life then Life.environment.EnvyV1Runtime=nil end
		print("[Falcon] Self destruct complete; saved profile retained")
	end
	if Life.indexItemSkins then pcall(Life.indexItemSkins) end
	Config.prepare()
end

local function glass(inst)
	pcall(function()
		local b = Instance.new("UIBlur")
		b.Size = 18
		b.Parent = inst
	end)
	pcall(function()
		local g = Instance.new("UIGradient")
		g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(218, 218, 218))
		g.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.15),
			NumberSequenceKeypoint.new(1, 0.45),
		})
		g.Rotation = 90
		g.Parent = inst
	end)
end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
end

local function stroke(p, a)
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(255, 255, 255)
	s.Transparency = a or 0.78
	s.Thickness = 1
	s.Parent = p
end

local function buildGui()
pcall(function()
	local function sweep(root)
		if not root then
			return
		end
		for _, child in ipairs(root:GetChildren()) do
			if child:IsA("ScreenGui") and (child.Name == "Falcon" or child.Name == "Envy v1" or child.Name == "EnvyV1Boot" or child.Name == "Quantumware" or child.Name == "QuantumwareBoot") then
				child:Destroy()
			end
		end
	end
	if type(gethui) == "function" then
		sweep(gethui())
	end
	sweep(game:GetService("CoreGui"))
	if lp then
		sweep(lp:FindFirstChildOfClass("PlayerGui"))
	end
	local oldSign = workspace:FindFirstChild("QW_Sign")
	if oldSign then
		oldSign:Destroy()
	end
end)
local screen = Instance.new("ScreenGui")
screen.Name = "Falcon"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 999999
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Enabled = true
table.insert(Life.resources,screen)
pcall(function()
	if syn and syn.protect_gui then
		syn.protect_gui(screen)
	end
end)
local attached = false
pcall(function()
	screen.Parent = parentGui()
	attached = screen.Parent ~= nil
end)
if not attached and lp then
	pcall(function()
		screen.Parent = lp:WaitForChild("PlayerGui", 5)
		attached = screen.Parent ~= nil
	end)
end

local overlay = Instance.new("Frame")
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
overlay.BackgroundTransparency = 0.79
overlay.Visible = true
overlay.ZIndex = 1
overlay.Parent = screen

-- Notifications have a separate layer and explicit sizes, independent of menu visibility.
local notificationScreen = Instance.new("ScreenGui")
notificationScreen.Name = "FalconNotifications"
notificationScreen.ResetOnSpawn = false
notificationScreen.IgnoreGuiInset = true
notificationScreen.DisplayOrder = screen.DisplayOrder + 1
notificationScreen.Enabled = true
notificationScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notificationScreen.Parent = screen.Parent
table.insert(Life.resources, notificationScreen)
local toasts = Instance.new("Frame")
toasts.Name = "Toasts"
toasts.BackgroundTransparency = 1
toasts.AnchorPoint = Vector2.new(1, 1)
toasts.Position = UDim2.new(1, -24, 1, -24)
toasts.Size = UDim2.fromOffset(304, 288)
toasts.Active = false
toasts.Parent = notificationScreen
local toastList = Instance.new("UIListLayout")
toastList.Padding = UDim.new(0, 10)
toastList.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastList.SortOrder = Enum.SortOrder.LayoutOrder
toastList.Parent = toasts
local toastOrder = 0
pushToast = function(name, on)
	if not Life.active then return end
	toastOrder = toastOrder + 1
	local card = Instance.new("Frame")
	card.Name = "ModuleNotification"
	card.Size = UDim2.fromOffset(304, 62)
	card.BackgroundColor3 = Color3.fromRGB(45, 47, 46)
	card.BorderSizePixel = 0
	card.LayoutOrder = toastOrder
	card.Parent = toasts
	corner(card, 12)
	stroke(card, 0.82)
	local accent = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(172, 172, 172)
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromOffset(32, 32)
	icon.Position = UDim2.fromOffset(14, 14)
	icon.BackgroundColor3 = on and Color3.fromRGB(68, 71, 66) or Color3.fromRGB(72, 75, 69)
	icon.BorderSizePixel = 0
	icon.Font = Enum.Font.BuilderSansBold
	icon.TextSize = 16
	icon.TextColor3 = accent
	icon.Text = on and "+" or "-"
	icon.Parent = card
	corner(icon, 9)
	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.fromOffset(232, 22)
	title.Position = UDim2.fromOffset(58, 10)
	title.Font = Enum.Font.BuilderSansBold
	title.TextSize = 13
	title.TextColor3 = Color3.fromRGB(245, 245, 245)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Text = name
	title.Parent = card
	local detail = title:Clone()
	detail.Position = UDim2.fromOffset(58, 31)
	detail.Font = Enum.Font.BuilderSans
	detail.TextSize = 11
	detail.TextColor3 = accent
	detail.Text = on and "Module enabled" or "Module disabled"
	detail.Parent = card
	local cards = {}
	for _, child in ipairs(toasts:GetChildren()) do if child:IsA("Frame") then cards[#cards + 1] = child end end
	table.sort(cards, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
	while #cards > 4 do table.remove(cards, 1):Destroy() end
	task.delay(3.2, function()
		if not Life.active or not card.Parent then return end
		local info = TweenInfo.new(0.2)
		for _, child in ipairs(card:GetDescendants()) do
			if child:IsA("TextLabel") then TweenService:Create(child, info, {TextTransparency = 1, BackgroundTransparency = 1}):Play() end
		end
		TweenService:Create(card, info, {BackgroundTransparency = 1}):Play()
		task.delay(0.22, function() if card.Parent then card:Destroy() end end)
	end)
end

local worldBlur = Instance.new("BlurEffect")
worldBlur.Size = 18
worldBlur.Enabled = true
table.insert(Life.resources,worldBlur)
pcall(function()
	worldBlur.Parent = Lighting
end)

local menu = Instance.new("Frame")
menu.Name = "FalconControl"
menu.AnchorPoint = Vector2.new(0.5, 0.5)
menu.Position = UDim2.fromScale(0.5, 0.5)
menu.Size = UDim2.fromOffset(1120, 720)
menu.BackgroundColor3 = Color3.fromRGB(29, 31, 31)
menu.BackgroundTransparency = 0.29
menu.BorderSizePixel = 0
menu.ClipsDescendants = true
menu.Parent = overlay
corner(menu, 34)
stroke(menu, 0.43)
do
	local rim = Instance.new("UIGradient")
	rim.Rotation = 105
	rim.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(100, 104, 100))
	rim.Parent = menu:FindFirstChildOfClass("UIStroke")
end
do
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 34
	gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(145, 145, 145))
	gradient.Parent = menu
end
local menuScale = Instance.new("UIScale")
menuScale.Parent = menu
local function fitMenu()
	local camera = workspace.CurrentCamera
	local view = camera and camera.ViewportSize or Vector2.new(1280, 800)
	menuScale.Scale = math.clamp(math.min((view.X - 36) / 1120, (view.Y - 36) / 720), 0.1, 1)
end
fitMenu()
Life.connect(screen:GetPropertyChangedSignal("AbsoluteSize"), fitMenu)

local COLS = { "Combat", "Blatant", "Kits", "Render", "World", "Larping", "False Ban", "Settings" }
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 182, 1, -151)
sidebar.Position = UDim2.fromOffset(13, 94)
sidebar.BackgroundColor3 = Color3.fromRGB(41, 43, 42)
sidebar.BorderSizePixel = 0
sidebar.BackgroundTransparency = 0.44
sidebar.Parent = menu
corner(sidebar, 25)
stroke(sidebar, 0.83)
local bar = Instance.new("Frame")
bar.Size = UDim2.new(1, 0, 0, 76)
bar.BackgroundTransparency = 1
bar.BorderSizePixel = 0
bar.Active = true
bar.Parent = menu

local brand = Instance.new("TextLabel")
brand.BackgroundTransparency = 1
brand.Size = UDim2.fromOffset(164, 29)
brand.Position = UDim2.fromOffset(22, 15)
brand.Font = Enum.Font.BuilderSansBold
brand.TextSize = 23
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.TextColor3 = Color3.fromRGB(250, 249, 244)
brand.Text = "Project Falcon"
brand.Parent = bar
do
	local wing = Instance.new("Frame")
	wing.Name = "FalconWing"
	wing.BackgroundTransparency = 1
	wing.Position = UDim2.fromOffset(180, 18)
	wing.Size = UDim2.fromOffset(35, 27)
	wing.Parent = bar
	for index = 1, 4 do
		local feather = Instance.new("Frame")
		feather.AnchorPoint = Vector2.new(0.5, 0.5)
		feather.Position = UDim2.fromOffset(18 - index * 2, 2 + index * 5)
		feather.Size = UDim2.fromOffset(37 - index * 5, 4)
		feather.Rotation = -24
		feather.BackgroundColor3 = Color3.fromRGB(250 - index * 9, 248 - index * 9, 233 - index * 8)
		feather.BorderSizePixel = 0
		feather.Parent = wing
		corner(feather, 2)
	end
	local accent = Instance.new("Frame")
	accent.Name = "BrandAccent"
	accent.BorderSizePixel = 0
	accent.BackgroundColor3 = Color3.fromRGB(242, 238, 221)
	accent.Position = UDim2.fromOffset(22, 53)
	accent.Size = UDim2.fromOffset(191, 2)
	accent.Parent = bar
	local fade = Instance.new("UIGradient")
	fade.Transparency = NumberSequence.new(0, 1)
	fade.Parent = accent
end
local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -44, 0, 1)
headerLine.Position = UDim2.new(0, 22, 1, -1)
headerLine.BorderSizePixel = 0
headerLine.BackgroundColor3 = Color3.fromRGB(85, 87, 83)
headerLine.BackgroundTransparency = 0.48
headerLine.Parent = bar

local search = Instance.new("TextBox")
search.Size = UDim2.fromOffset(422, 38)
search.Position = UDim2.fromOffset(236, 19)
search.BackgroundColor3 = Color3.fromRGB(45, 47, 46)
search.BorderSizePixel = 0
search.Font = Enum.Font.BuilderSans
search.TextSize = 13
search.TextXAlignment = Enum.TextXAlignment.Left
search.PlaceholderText = "Search this category..."
search.PlaceholderColor3 = Color3.fromRGB(186, 188, 183)
search.TextColor3 = Color3.fromRGB(246, 246, 246)
search.Text = ""
search.ClearTextOnFocus = false
search.Parent = bar
search.BackgroundTransparency = 0.55
corner(search, 19)
stroke(search, 0.91)
local searchPadding = Instance.new("UIPadding")
searchPadding.PaddingLeft = UDim.new(0, 14)
searchPadding.PaddingRight = UDim.new(0, 14)
searchPadding.Parent = search
local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.fromOffset(104, 36)
saveButton.Position = UDim2.fromOffset(678, 20)
saveButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
saveButton.BorderSizePixel = 0
saveButton.Font = Enum.Font.BuilderSansBold
saveButton.TextSize = 12
saveButton.TextColor3 = Color3.fromRGB(45, 47, 46)
saveButton.Text = "Save profile"
saveButton.Parent = bar
corner(saveButton, 19)
Life.connect(saveButton.MouseButton1Click, function() Config.save(Config.activeProfile, true) end)

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Size = UDim2.fromOffset(130, 36)
status.Position = UDim2.new(1, -284, 0, 20)
status.Font = Enum.Font.BuilderSansMedium
status.TextSize = 12
status.TextColor3 = Color3.fromRGB(220, 220, 220)
status.Text = "waiting"
status.Parent = bar
local keyHint = Instance.new("TextLabel")
keyHint.Size = UDim2.fromOffset(106, 30)
keyHint.Position = UDim2.new(1, -128, 0, 23)
keyHint.BackgroundColor3 = Color3.fromRGB(64, 67, 63)
keyHint.BorderSizePixel = 0
keyHint.Font = Enum.Font.BuilderSansMedium
keyHint.TextSize = 11
keyHint.TextColor3 = Color3.fromRGB(172, 172, 172)
keyHint.Text = "RIGHT SHIFT"
keyHint.Parent = bar
keyHint.BackgroundTransparency = 0.58
corner(keyHint, 15)

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Size = UDim2.fromOffset(686, 26)
hint.Position = UDim2.new(0, 22, 1, -36)
hint.Font = Enum.Font.BuilderSans
hint.TextSize = 11
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextColor3 = Color3.fromRGB(186, 188, 183)
hint.Text = "Click to toggle    /    Settings to customize    /    Right Shift to hide"
hint.Parent = menu
local profileIndicator = Instance.new("TextLabel")
profileIndicator.BackgroundTransparency = 1
profileIndicator.Size = UDim2.fromOffset(292, 26)
profileIndicator.Position = UDim2.new(1, -314, 1, -36)
profileIndicator.Font = Enum.Font.BuilderSansMedium
profileIndicator.TextSize = 11
profileIndicator.TextXAlignment = Enum.TextXAlignment.Right
profileIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
profileIndicator.TextTruncate = Enum.TextTruncate.AtEnd
profileIndicator.Parent = menu

local array = Instance.new("Frame")
array.BackgroundTransparency = 1
array.AnchorPoint = Vector2.new(1, 0)
array.Position = UDim2.new(1, -16, 0, 16)
array.Size = UDim2.fromOffset(220, 400)
array.Parent = screen
local al = Instance.new("UIListLayout")
al.HorizontalAlignment = Enum.HorizontalAlignment.Right
al.Padding = UDim.new(0, 4)
al.SortOrder = Enum.SortOrder.LayoutOrder
al.Parent = array
do
	local watermark = Instance.new("TextLabel")
	watermark.Name = "Watermark"
	watermark.LayoutOrder = -2
	watermark.Size = UDim2.fromOffset(210, 28)
	watermark.BackgroundTransparency = 1
	watermark.Font = Enum.Font.BuilderSansBold
	watermark.TextSize = 23
	watermark.TextXAlignment = Enum.TextXAlignment.Right
	watermark.TextColor3 = Color3.fromRGB(250, 248, 237)
	watermark.TextStrokeTransparency = 0.66
	watermark.Text = "Project Falcon"
	watermark.Parent = array
	local rule = Instance.new("Frame")
	rule.Name = "WatermarkDivider"
	rule.LayoutOrder = -1
	rule.Size = UDim2.fromOffset(140, 1)
	rule.BackgroundColor3 = Color3.fromRGB(242, 238, 221)
	rule.BorderSizePixel = 0
	rule.Parent = array
	local fade = Instance.new("UIGradient")
	fade.Transparency = NumberSequence.new(1, 0.14)
	fade.Parent = rule
end

local targetHud = Instance.new("Frame")
targetHud.Size = UDim2.fromOffset(230, 62)
targetHud.Position = UDim2.new(0.5, -115, 1, -86)
targetHud.BackgroundColor3 = Color3.fromRGB(44, 46, 45)
targetHud.BackgroundTransparency = 0.25
targetHud.Visible = false
targetHud.Parent = screen
corner(targetHud, 12)
stroke(targetHud, 0.75)
glass(targetHud)
local tt = Instance.new("TextLabel")
tt.BackgroundTransparency = 1
tt.Size = UDim2.new(1, -18, 0, 18)
tt.Position = UDim2.fromOffset(12, 8)
tt.Font = Enum.Font.BuilderSans
tt.TextSize = 12
tt.TextXAlignment = Enum.TextXAlignment.Left
tt.TextColor3 = Color3.fromRGB(188, 188, 188)
tt.Text = "Target"
tt.Parent = targetHud
local tn = Instance.new("TextLabel")
tn.BackgroundTransparency = 1
tn.Size = UDim2.new(1, -18, 0, 24)
tn.Position = UDim2.fromOffset(12, 28)
tn.Font = Enum.Font.BuilderSansBold
tn.TextSize = 16
tn.TextXAlignment = Enum.TextXAlignment.Left
tn.TextColor3 = Color3.fromRGB(249, 249, 249)
tn.Text = "None"
tn.Parent = targetHud

function refreshHud()
	for _, c in ipairs(array:GetChildren()) do
		if c:IsA("TextLabel") and c.Name == "ActiveModule" then
			c:Destroy()
		end
	end
	local names = {}
	for n, m in pairs(Modules) do
		if m.enabled then
			table.insert(names, n)
		end
	end
	hint.Text = string.format("%d enabled    /    Left-click to toggle    /    Right-click to configure    /    Right Shift to hide", #names)
	table.sort(names, function(a, b)
		return #a > #b
	end)
	for i, n in ipairs(names) do
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Name = "ActiveModule"
		l.Size = UDim2.fromOffset(210, 17)
		l.TextStrokeTransparency = 0.66
		l.Font = Enum.Font.BuilderSansMedium
		l.TextSize = 13
		l.TextXAlignment = Enum.TextXAlignment.Right
		l.TextColor3 = Color3.fromRGB(242, 242, 242)
		l.Text = n
		l.LayoutOrder = i
		l.Parent = array
	end
end

local function drag(handle, win)
	local held, o, s
	Life.connect(handle.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			held, o, s = true, i.Position, win.Position
		end
	end)
	Life.connect(UserInputService.InputEnded, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			held = false
		end
	end)
	Life.connect(UserInputService.InputChanged, function(i)
		if held and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - o
			win.Position = UDim2.new(s.X.Scale, s.X.Offset + d.X, s.Y.Scale, s.Y.Offset + d.Y)
		end
	end)
end

local filters = {}
local binding

local TXT = Color3.fromRGB(242, 242, 242)
local DIM = Color3.fromRGB(196, 197, 190)
local ACCENT = Color3.fromRGB(242, 238, 221)

local function label(parent, text, size, color, align)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Active = false
	l.Font = Enum.Font.BuilderSans
	l.TextSize = size or 12
	l.TextColor3 = color or TXT
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.Text = text
	l.Parent = parent
	pcall(function()
		l.Interactable = false
	end)
	return l
end

local function paintSwitch(pill, knob, on)
	pill.BackgroundColor3 = on and ACCENT or Color3.fromRGB(22, 22, 22)
	pill.BackgroundTransparency = 0
	pill.BorderSizePixel = 0
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	knob.BackgroundColor3 = on and Color3.fromRGB(29, 31, 31) or Color3.fromRGB(185, 185, 185)
	knob.BackgroundTransparency = 0
	knob.BorderSizePixel = 0
end

drag(bar, menu)
local settingsBack = Instance.new("Frame")
settingsBack.Size = UDim2.fromOffset(318, 540)
settingsBack.Position = UDim2.fromOffset(780, 110)
settingsBack.BackgroundColor3 = Color3.fromRGB(45, 47, 46)
settingsBack.BorderSizePixel = 0
settingsBack.Parent = menu
settingsBack.BackgroundTransparency = 0.46
corner(settingsBack, 26)
stroke(settingsBack, 0.81)
local emptySettings = label(settingsBack, "Select a module’s … button to open its settings.", 12, DIM)
emptySettings.Size = UDim2.new(1, -32, 1, -32)
emptySettings.Position = UDim2.fromOffset(16, 16)
emptySettings.TextWrapped = true

local panel = Instance.new("ScrollingFrame")
panel.Size = UDim2.fromOffset(316, 538)
panel.Position = UDim2.fromOffset(781, 111)
panel.CanvasSize = UDim2.new()
panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
panel.ScrollBarThickness = 3
panel.ScrollBarImageColor3 = ACCENT
panel.BorderSizePixel = 0
panel.BackgroundColor3 = Color3.fromRGB(45, 47, 46)
panel.Visible = false
panel.ZIndex = 20
panel.Parent = menu
panel.BackgroundTransparency = 0.27
corner(panel, 26)

local panelPad = Instance.new("UIPadding")
panelPad.PaddingTop = UDim.new(0, 10)
panelPad.PaddingBottom = UDim.new(0, 12)
panelPad.PaddingLeft = UDim.new(0, 12)
panelPad.PaddingRight = UDim.new(0, 12)
panelPad.Parent = panel
local panelList = Instance.new("UIListLayout")
panelList.Padding = UDim.new(0, 8)
panelList.SortOrder = Enum.SortOrder.LayoutOrder
panelList.Parent = panel
local panelMod
local moduleState

local function fmt(o)
	local v = o.value
	if type(v) == "number" and o.step < 1 then
		v = string.format("%.2f", v)
	end
	return tostring(v) .. o.suffix
end

local function sliderRow(o, order)
	local hold = Instance.new("Frame")
	hold.BackgroundTransparency = 1
	hold.Size = UDim2.new(1, 0, 0, 30)
	hold.LayoutOrder = order
	hold.Parent = panel
	local name = label(hold, o.name, 12, TXT)
	name.Size = UDim2.new(1, 0, 0, 14)
	local val = label(hold, fmt(o), 12, DIM, Enum.TextXAlignment.Right)
	val.Size = UDim2.new(1, 0, 0, 14)
	local track = Instance.new("TextButton")
	track.AutoButtonColor = false
	track.Text = ""
	track.Size = UDim2.new(1, 0, 0, 6)
	track.Position = UDim2.fromOffset(0, 21)
	track.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	track.BackgroundTransparency = 0.86
	track.Parent = hold
	corner(track, 3)
	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = ACCENT
	fill.BorderSizePixel = 0
	fill.Parent = track
	corner(fill, 3)
	local function paint()
		fill.Size = UDim2.new(math.clamp((o.value - o.min) / math.max(o.max - o.min, 1e-3), 0, 1), 0, 1, 0)
		val.Text = fmt(o)
	end
	local function set(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local v = o.min + (o.max - o.min) * a
		o.value = math.clamp(math.floor(v / o.step + 0.5) * o.step, o.min, o.max)
		Config.changed()
		paint()
	end
	local dragging = false
	Life.connect(track.InputBegan, function(i)
		if i.UserInputType == M1 then
			dragging = true
			set(i.Position.X)
		end
	end)
	table.insert(panelMod.uiConns, Life.connect(UserInputService.InputChanged, function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			set(i.Position.X)
		end
	end))
	table.insert(panelMod.uiConns, Life.connect(UserInputService.InputEnded, function(i)
		if i.UserInputType == M1 then
			dragging = false
		end
	end))
	paint()
end

local function pillRow(o, order)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.BackgroundTransparency = 1
	b.Text = ""
	b.Size = UDim2.new(1, 0, 0, 18)
	b.LayoutOrder = order
	b.Parent = panel
	local name = label(b, o.name, 12, TXT)
	name.Size = UDim2.new(1, -44, 1, 0)
	local pill = Instance.new("Frame")
	pill.Size = UDim2.fromOffset(32, 16)
	pill.Position = UDim2.new(1, -32, 0.5, -8)
	pill.Active = false
	pill.ZIndex = 2
	pill.Parent = b
	corner(pill, 8)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(12, 12)
	knob.Active = false
	knob.ZIndex = 3
	knob.Parent = pill
	corner(knob, 8)
	local function paint()
		paintSwitch(pill, knob, o.value)
	end
	Life.connect(b.MouseButton1Click, function()
		o.value = not o.value
		Config.changed()
		paint()
	end)
	paint()
end

local function choiceRow(o, order, isBind)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.BackgroundTransparency = 1
	b.Text = ""
	b.Size = UDim2.new(1, 0, 0, 22)
	b.LayoutOrder = order
	b.Parent = panel
	local name = label(b, o.name, 12, TXT)
	name.Size = UDim2.new(0.5, 0, 1, 0)
	local chip = Instance.new("TextLabel")
	chip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	chip.BackgroundTransparency = 0.9
	chip.Font = Enum.Font.BuilderSansMedium
	chip.TextSize = 12
	chip.TextColor3 = TXT
	chip.AutomaticSize = Enum.AutomaticSize.X
	chip.Size = UDim2.fromOffset(0, 20)
	chip.AnchorPoint = Vector2.new(1, 0.5)
	chip.Position = UDim2.new(1, 0, 0.5, 0)
	chip.Parent = b
	corner(chip, 6)
	local chipPad = Instance.new("UIPadding")
	chipPad.PaddingLeft = UDim.new(0, 8)
	chipPad.PaddingRight = UDim.new(0, 8)
	chipPad.Parent = chip
	local function paint()
		if isBind then
			chip.Text = binding == o and "press a key" or (o.value and o.value.Name or "None")
		else
			chip.Text = tostring(o.value)
		end
	end
	o.paint = paint
	local function step(dir)
		if isBind then
			binding = o
		else
			local idx = table.find(o.list, o.value) or 1
			o.value = o.list[(idx - 1 + dir) % #o.list + 1]
			Config.changed()
		end
		paint()
	end
	Life.connect(b.MouseButton1Click, function()
		step(1)
	end)
	Life.connect(b.MouseButton2Click, function()
		if isBind then
			o.value = nil
			Config.changed()
			binding = nil
			paint()
		else
			step(-1)
		end
	end)
	paint()
end

local function textRow(o, order)
	local hold = Instance.new("Frame")
	hold.BackgroundTransparency = 1
	hold.Size = UDim2.new(1, 0, 0, 44)
	hold.LayoutOrder = order
	hold.Parent = panel
	local name = label(hold, o.name, 12, TXT)
	name.Size = UDim2.new(1, 0, 0, 14)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 24)
	box.Position = UDim2.fromOffset(0, 18)
	box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	box.BackgroundTransparency = 0.9
	box.Font = Enum.Font.BuilderSans
	box.TextSize = 12
	box.TextColor3 = TXT
	box.PlaceholderColor3 = DIM
	box.PlaceholderText = o.name
	box.Text = tostring(o.value or "")
	box.ClearTextOnFocus = false
	box.Parent = hold
	corner(box, 6)
	Life.connect(box:GetPropertyChangedSignal("Text"), function()
		o.value = box.Text
		Config.changed()
	end)
	Life.connect(box.FocusLost, function()
		o.value = box.Text
		Config.changed()
	end)
end

local function actionRow(o,order)
	local button=Instance.new("TextButton")
	button.AutoButtonColor=false
	button.Size=UDim2.new(1,0,0,32)
	button.BackgroundColor3=Color3.fromRGB(19, 19, 19)
	button.BorderSizePixel=0
	button.Font=Enum.Font.BuilderSansMedium
	button.TextSize=12
	button.TextColor3=TXT
	button.Text=o.name
	button.LayoutOrder=order
	button.Parent=panel
	corner(button,7)
	Life.connect(button.MouseButton1Click,function()
		if type(o.callback)~="function" then return end
		local ok,err=pcall(o.callback)
		if not ok then notify(o.name .. " failed: " .. tostring(err)) end
	end)
end

local function closePanel()
	local previous = panelMod
	if panelMod then
		for _, c in ipairs(panelMod.uiConns or {}) do
			c:Disconnect()
		end
		panelMod.uiConns = {}
	end
	binding = nil
	panelMod = nil
	moduleState = nil
	panel.Visible = false
	if previous and previous.paint then previous.paint() end
end

Life.closePanel=closePanel

local function openPanel(mod, anchor)
	if panelMod == mod then
		closePanel()
		return
	end
	closePanel()
	panelMod = mod
	mod.uiConns = {}
	for _, c in ipairs(panel:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end
	local head = Instance.new("Frame")
	head.BackgroundTransparency = 1
	head.Size = UDim2.new(1, 0, 0, 34)
	head.LayoutOrder = 0
	head.Parent = panel
	local title = label(head, mod.name, 14, Color3.fromRGB(255, 255, 255))
	title.Font = Enum.Font.BuilderSansBold
	title.Size = UDim2.new(1, -24, 0, 16)
	local tip = label(head, mod.tip or "", 11, DIM)
	tip.Size = UDim2.new(1, -4, 0, 14)
	tip.Position = UDim2.fromOffset(0, 18)
	tip.TextTruncate = Enum.TextTruncate.AtEnd
	local x = Instance.new("TextButton")
	x.AutoButtonColor = false
	x.BackgroundTransparency = 1
	x.Size = UDim2.fromOffset(18, 16)
	x.Position = UDim2.new(1, -18, 0, 0)
	x.Font = Enum.Font.BuilderSansBold
	x.TextSize = 13
	x.TextColor3 = DIM
	x.Text = "x"
	x.Parent = head
	Life.connect(x.MouseButton1Click, closePanel)
	local line = Instance.new("Frame")
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BackgroundTransparency = 0.9
	line.BorderSizePixel = 0
	line.Size = UDim2.new(1, 0, 0, 1)
	line.LayoutOrder = 1
	line.Parent = panel
	moduleState = label(panel, mod.status or "Ready", 10, DIM)
	moduleState.Size = UDim2.new(1, 0, 0, 38)
	moduleState.BackgroundColor3=Color3.fromRGB(45, 47, 46)
	moduleState.BackgroundTransparency=0
	moduleState.TextColor3=Color3.fromRGB(230, 230, 230)
	moduleState.TextXAlignment=Enum.TextXAlignment.Center
	corner(moduleState,7)
	moduleState.TextWrapped = true
	moduleState.LayoutOrder = 2
	for i, key in ipairs(mod.order) do
		local o = mod.options[key]
		local order = i + 2
		if o.kind == "slider" then
			sliderRow(o, order)
		elseif o.kind == "toggle" then
			pillRow(o, order)
		elseif o.kind == "list" then
			choiceRow(o, order, false)
		elseif o.kind == "bind" then
			choiceRow(o, order, true)
		elseif o.kind == "text" then
			textRow(o, order)
		elseif o.kind == "action" then
			actionRow(o,order)
		end
	end
	panel.Position = UDim2.fromOffset(781, 111)
	panel.CanvasPosition = Vector2.zero
	panel.Visible = true
	if mod.paint then mod.paint() end
end

local activeCategory = "Combat"
local navButtons, categoryViews = {}, {}
local categoryTitle = label(menu, "Combat", 23, TXT)
categoryTitle.Font = Enum.Font.BuilderSansBold
categoryTitle.Position = UDim2.fromOffset(236, 108)
categoryTitle.Size = UDim2.fromOffset(300, 30)
local categoryDetail = label(menu, "Aim, timing, and projectile controls", 11, DIM)
categoryDetail.Position = UDim2.fromOffset(236, 146)
categoryDetail.Size = UDim2.fromOffset(520, 18)
local categoryTips = {
	Combat = "Aim, timing, and projectile controls",
	Blatant = "Movement and extended combat controls",
	Kits = "Kit-specific movement and ability controls",
	Render = "Sky, color grading, hand motion, and player displays",
	World = "Block and environment tools",
	Larping = "Local appearance and profile customization",
	["False Ban"] = "Local player name and stat appearance",
	Settings = "Saved profiles, JSON sharing, and client controls",
}
local noResults = label(menu, "No modules found. Try another search.", 13, DIM)
noResults.Position = UDim2.fromOffset(236, 220)
noResults.Size = UDim2.fromOffset(520, 32)
noResults.TextXAlignment = Enum.TextXAlignment.Center
noResults.Visible = false
local navLabel = label(menu, "MODULES", 10, DIM)
navLabel.Position = UDim2.fromOffset(32, 107)
navLabel.Size = UDim2.fromOffset(150, 18)
local function applyFilter()
	local q = search.Text:lower()
	local matches = 0
	for name, view in pairs(categoryViews) do
		view.Visible = name == activeCategory
		for _, row in ipairs(view:GetChildren()) do
			if row:IsA("GuiObject") then
				local mod = Modules[row.Name]
				row.Visible = q == "" or row.Name:lower():find(q, 1, true) ~= nil or (mod and mod.tip:lower():find(q, 1, true) ~= nil)
				if name == activeCategory and row.Visible then matches = matches + 1 end
			end
		end
	end
	noResults.Visible = matches == 0
end
local function selectCategory(name)
	activeCategory = name
	categoryTitle.Text = name == "Render" and "Visuals" or name
	categoryDetail.Text = (categoryTips[name] or "") .. "  /  " .. #Cats[name].modules .. " modules"
	search.Text = ""
	for category, button in pairs(navButtons) do
		button.BackgroundTransparency = category == name and 0.46 or 1
		button.TextColor3 = category == name and ACCENT or DIM
		button.ActiveMarker.Visible = category == name
	end
	applyFilter()
end

for index, name in ipairs(COLS) do
	local nav = Instance.new("TextButton")
	nav.Name = name
	nav.AutoButtonColor = false
	nav.Size = UDim2.fromOffset(164, 42)
	nav.Position = UDim2.fromOffset(22, 136 + (index - 1) * 49)
	nav.BackgroundColor3 = Color3.fromRGB(81, 83, 77)
	nav.BackgroundTransparency = 1
	nav.BorderSizePixel = 0
	nav.Font = Enum.Font.BuilderSansMedium
	nav.TextSize = 15
	nav.TextXAlignment = Enum.TextXAlignment.Left
	nav.TextColor3 = DIM
	nav.Text = name == "Render" and "Visuals" or name
	nav.Parent = menu
	corner(nav, 17)
	navButtons[name] = nav
	local navPadding = Instance.new("UIPadding")
	navPadding.PaddingLeft = UDim.new(0, 17)
	navPadding.Parent = nav
	local marker = Instance.new("Frame")
	marker.Name = "ActiveMarker"
	marker.Size = UDim2.fromOffset(3, 18)
	marker.Position = UDim2.fromOffset(0, 12)
	marker.BackgroundColor3 = ACCENT
	marker.BorderSizePixel = 0
	marker.Visible = false
	marker.Parent = nav
	corner(marker, 2)
	Life.connect(nav.MouseButton1Click, function() selectCategory(name) end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name
	scroll.Position = UDim2.fromOffset(236, 190)
	scroll.Size = UDim2.fromOffset(520, 460)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = ACCENT
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = menu
	categoryViews[name] = scroll
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	local padding = Instance.new("UIPadding")
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 4)
	padding.Parent = scroll
	for order, mod in ipairs(Cats[name].modules) do
		local thisMod = mod
		local row = Instance.new("TextButton")
		row.Name = mod.name
		row.Text = ""
		row.AutoButtonColor = false
		row.Size = UDim2.new(1, 0, 0, 84)
		row.LayoutOrder = order
		row.BackgroundColor3 = Color3.fromRGB(48, 50, 48)
		row.BorderSizePixel = 0
		row.Parent = scroll
		row.BackgroundTransparency = 0.42
		corner(row, 23)
		stroke(row, 0.84)
		local moduleIcon = label(row, mod.name:sub(1, 1), 16, ACCENT, Enum.TextXAlignment.Center)
		moduleIcon.Size = UDim2.fromOffset(32, 34)
		moduleIcon.Position = UDim2.fromOffset(14, 16)
				moduleIcon.BackgroundColor3 = Color3.fromRGB(85, 87, 83)
		moduleIcon.Font = Enum.Font.BuilderSansBold
		moduleIcon.BackgroundTransparency = 0.48
		corner(moduleIcon, 13)
		local title = label(row, mod.name, 15, TXT)
		title.Font = Enum.Font.BuilderSansMedium
		title.Position = UDim2.fromOffset(58, 16)
		title.Size = UDim2.new(1, -174, 0, 21)
		local description = label(row, mod.tip or "", 11, DIM)
		description.Position = UDim2.fromOffset(58, 42)
		description.Size = UDim2.new(1, -128, 0, 30)
		description.TextTruncate = Enum.TextTruncate.AtEnd
		description.TextWrapped = true
		local pill = Instance.new("Frame")
		pill.Size = UDim2.fromOffset(32, 16)
		pill.Position = UDim2.new(1, -49, 0, 20)
		pill.Active = false
		pill.Parent = row
		corner(pill, 9)
		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(12, 12)
		knob.Active = false
		knob.Parent = pill
		corner(knob, 9)
		local state = label(row, "OFF", 9, DIM, Enum.TextXAlignment.Right)
		state.Position = UDim2.new(1, -63, 0, 52)
		state.Size = UDim2.fromOffset(46, 16)
		local function paint()
			title.TextColor3 = thisMod.enabled and Color3.fromRGB(247, 247, 247) or TXT
			state.Text = thisMod.action and "UNLOAD" or thisMod.settingsOnly and "OPEN" or thisMod.enabled and "ON" or "OFF"
			state.TextColor3 = thisMod.action and Color3.fromRGB(220, 220, 220) or thisMod.enabled and ACCENT or DIM
			pill.Visible=not thisMod.action and not thisMod.settingsOnly
			paintSwitch(pill, knob, thisMod.enabled)
			local selected = panelMod == thisMod
			row.BackgroundColor3 = selected and Color3.fromRGB(72, 75, 69) or Color3.fromRGB(48, 50, 48)
			local outline = row:FindFirstChildOfClass("UIStroke")
			if outline then
				outline.Color = selected and ACCENT or Color3.fromRGB(255, 255, 255)
				outline.Transparency = selected and 0.47 or 0.84
			end
		end
		thisMod.paint = paint
		paint()
		local hit = Instance.new("TextButton")
		hit.Name = "Hit"
		hit.Text = ""
		hit.AutoButtonColor = false
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.ZIndex = 6
		hit.Parent = row
		Life.connect(hit.MouseEnter, function()
			TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.22 }):Play()
		end)
		Life.connect(hit.MouseLeave, function()
			TweenService:Create(row, TweenInfo.new(0.12), { BackgroundTransparency = 0.42 }):Play()
		end)
		Life.connect(hit.MouseButton1Click, function()
			if thisMod.settingsOnly then openPanel(thisMod,row)
			elseif thisMod.action then thisMod.action()
			else setOn(thisMod,not thisMod.enabled) end
		end)
		Life.connect(hit.MouseButton2Click, function() openPanel(thisMod, row) end)
		local configure = Instance.new("TextButton")
		configure.Name = "Configure"
		configure.Size = UDim2.fromOffset(30, 26)
		configure.Position = UDim2.new(1, -91, 0, 15)
		configure.BackgroundColor3 = Color3.fromRGB(85, 87, 83)
		configure.BorderSizePixel = 0
		configure.Text = "⋯"
		configure.TextColor3 = DIM
		configure.TextSize = 16
		configure.Font = Enum.Font.BuilderSansBold
		configure.ZIndex = 8
		configure.Parent = row
		configure.BackgroundTransparency = 0.45
		corner(configure, 12)
		Life.connect(configure.MouseButton1Click, function() openPanel(thisMod, row) end)
	end
end
Life.connect(search:GetPropertyChangedSignal("Text"), applyFilter)
selectCategory("Combat")
-- Open with an uncluttered settings inspector.

menuOpen = overlay.Visible

Life.connect(UserInputService.InputBegan, function(i, g)
	if i.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end
	if i.KeyCode == Enum.KeyCode.RightShift then
		local show = not overlay.Visible
		overlay.Visible = show
		pcall(function()
			worldBlur.Enabled = show
		end)
		menuOpen = show
		if not show then
			closePanel()
		end
		return
	end
	if binding then
		local o = binding
		binding = nil
		if i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Backspace then
			o.value = nil
			Config.changed()
		elseif i.KeyCode ~= Enum.KeyCode.RightShift and i.KeyCode ~= Enum.KeyCode.Unknown then
			o.value = i.KeyCode
			Config.changed()
		end
		if o.paint then
			o.paint()
		end
		return
	end
	if g then
		return
	end
	for _, m in pairs(Modules) do
		local b = m.options.Bind
		if b and b.value == i.KeyCode then
			setOn(m, not m.enabled)
		end
	end
end)

local function intervalOf(m)
	if type(m.interval) == "function" then
		local ok, v = pcall(m.interval, m)
		return ok and tonumber(v) or 0.1
	end
	return m.interval
end

Life.connect(RunService.Heartbeat, function(dt)
	local saveState = Config.lastError and "SAVE FAILED" or Config.loadError and "LOAD FAILED" or Config.dirty and "UNSAVED" or Config.loaded and "SAVED" or "NEW PROFILE"
	profileIndicator.Text = Config.activeProfile .. "  /  " .. saveState
	profileIndicator.TextColor3 = (Config.lastError or Config.loadError) and Color3.fromRGB(220, 220, 220) or Config.dirty and Color3.fromRGB(195, 195, 195) or ACCENT
	saveButton.Text = Config.dirty and "Save changes" or "Save profile"
	if panelMod and moduleState and moduleState.Parent then
		local message = panelMod.status or (panelMod.enabled and "Enabled" or "Disabled")
		if moduleState.Text ~= message then moduleState.Text = message end
	end
	status.Text = BW.ready and "CONNECTED" or "CONNECTING"
	status.TextColor3 = BW.ready and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(220, 220, 220)
	for _, m in pairs(Modules) do
		if m.enabled and m.tick and not m.running then
			m.iv = m.iv or intervalOf(m)
			m.acc = m.acc + dt
			if m.iv <= 0 or m.acc >= m.iv then
				m.acc = m.iv > 0 and (m.acc % m.iv) or 0
				m.iv = nil
				m.running = true
				m.worker = task.spawn(function()
					local ok, err = pcall(m.tick, m)
					m.running = false
					if not ok then
						if not m.lastTickError then m.beforeTickError = m.status end
						m.lastTickError = "Runtime error: " .. tostring(err)
						m.status = m.lastTickError
						if not m.warned then
							m.warned = true
							warn("[Falcon] " .. m.name .. ": " .. tostring(err))
						end
					elseif m.lastTickError then
						if m.status == m.lastTickError then m.status = m.beforeTickError end
						m.lastTickError, m.beforeTickError, m.warned = nil, nil, false
					end
				end)
			end
		end
	end
	if not Life.active then return end
	local ti = Modules.TargetInfo
	if ti and ti.enabled then
		local t, r = pick(get(ti, "Range"))
		targetHud.Visible = t ~= nil
		if t and r then
			tn.Text = string.format("%s   %dhp", t.DisplayName, math.floor(healthOf(r.Parent) + 0.5))
		end
	else
		targetHud.Visible = false
	end
end)

Life.connect(lp.CharacterAdded, function()
	releaseAuraFacing()
	task.wait(0.25)
	stopFly()
	savedSpeed = nil
end)

refreshHud()
Config.start()
notify("Loaded. Right Shift opens the menu, right-click a module for settings.")
end

buildGui()
if bootLabel then
	bootLabel:Destroy()
	bootLabel = nil
end
end

local okBoot, errBoot = xpcall(boot, function(err)
	return tostring(err)
end)
if not okBoot then
	if type(Life.Destroy)=="function" then
		pcall(Life.Destroy)
	else
		Life.active=false
		for _,c in ipairs(Life.connections) do pcall(function() c:Disconnect() end) end
		for _,obj in ipairs(Life.resources) do pcall(function() obj:Destroy() end) end
		if Life.environment.EnvyV1Runtime==Life then Life.environment.EnvyV1Runtime=nil end
	end
	warn("[Falcon] " .. tostring(errBoot))
	notify(tostring(errBoot))
	pcall(function()
		local t = bootLabel and bootLabel:FindFirstChild("Text")
		if t then
			t.Text = "Falcon error: " .. tostring(errBoot)
			t.TextWrapped = true
			t.Size = UDim2.fromOffset(480, 64)
		end
	end)
end
]====]
local env = type(getgenv) == "function" and getgenv() or _G
env.EnvyV1Source = source
local run, err = loadstring(source)
assert(run, err)
return run()
