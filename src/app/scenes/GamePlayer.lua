require "app.scenes.AnimManager"
local WeaponDefault = require "app.scenes.WeaponDefault"

local GamePlayer = class("GamePlayer", function ()
	return display.newNode()
end)

local LINE_VX = 100
local LINE_VY = 100

local UP_DIR = 1
local DOWN_DIR = 2
local LEFT_DIR = 3
local RIGHT_DIR = 4
local RU_DIR = 5
local LU_DIR = 6
local LD_DIR = 7
local RD_DIR = 8

function GamePlayer:setPlayerV(dir)
	local body = self:getPhysicsBody()
	

	if dir == 0 then
		body:setVelocity(cc.p(0, 0))
		return 
	end

	if dir < 1 or dir > 8 then
		body:setVelocity(cc.p(0, 0))
		return 
	end

	local v_set = {
		cc.p(0, LINE_VY), cc.p(0, -LINE_VY), 
		cc.p(-LINE_VX, 0), cc.p(LINE_VX, 0), 

		cc.p(LINE_VX, LINE_VY), cc.p(-LINE_VX, LINE_VY), 
		cc.p(-LINE_VX, -LINE_VY), cc.p(LINE_VX, -LINE_VY),
	}
	body:setVelocity(v_set[dir])
end

function GamePlayer:drawPlayerAnim(dir)
	local playerAnim = nil
	if self.dir == dir then
		return
	end

	self.dir = dir
	--以前有，就的删除
	if self.playerAnim ~= nil then
		self:removeChild(self.playerAnim)
		self.playerAnim = nil
	end

	-- 帧动画 dir
	local dir_frames = {
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 12, 3, 0.2}, --上
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 0, 3, 0.2}, --下
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 18, 3, 0.2}, --左
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 6, 3, 0.2}, --右
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 9, 3, 0.2},
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 15, 3, 0.2}, 		
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 21, 3, 0.2}, 
		{"player-evo-01.plist", "player-evo-01.png", "player01-%04d.png", 3, 3, 0.2}, 

	}

	local playerAnim =  AnimManager.playForever(self, 
    	dir_frames[dir], 
    0, 0)	
    self.playerAnim = playerAnim
end

function GamePlayer:onContactBegin(node)
	local body = node:getPhysicsBody()
	local tag = body:getTag()

	if tag == 1 then --固体
		local self_body = self:getPhysicsBody()
		self_body:setVelocity(cc.p(0, 0))
	elseif tag == 5 then -- 碰到了装备

		-- node就是装备
		--获取装备的信息,加东西
		--end
		--删除装备
		local parent = node:getParent()
		local xpos, ypos = node:getPosition()
		local typeProp = node:getPropInfo()
		local name = "pfx-treasure-spawn-01.plist"
		local particle = cc.ParticleSystemQuad:create(name)
		particle:addTo(parent):pos(xpos, ypos)

		node:removeFromParent()

		--提示我们的装备信息
		PropsManager.showPropTip(typeProp)
		--

		--end
	end


end

function GamePlayer:onPresolve(node, solve)
	local body = node:getPhysicsBody()
	local tag = body:getTag()
	
	local self_body = self:getPhysicsBody()
	self_body:setVelocity(cc.p(0, 0))

end

function GamePlayer:onPostSolve(node, solve)
	local body = node:getPhysicsBody()
	local tag = body:getTag()

	local self_body = self:getPhysicsBody()
	self_body:setVelocity(cc.p(0, 0))

end

function GamePlayer:onContactEnd(node)
	local body = node:getPhysicsBody()
	local tag = body:getTag()

	local self_body = self:getPhysicsBody()
	self_body:setVelocity(cc.p(0, 0))
end

local NORMAL_DIR_VEC = {
	cc.p(0, 100), --上
	cc.p(0, -100), --下
	cc.p(-100, 0), --左
	cc.p(100, 0), --右
	cc.p(100, 100), --右上；
	cc.p(-100, 100), --左上;
	cc.p(-100, -100), --左下
	cc.p(100, -100), --右下
}

function GamePlayer:find_nearest_npc()
	local npc = nil
	local min_npc = nil
	local min_distance

	if self.npcs == nil then
		return nil
	end
	local i
	local min_distance = 65536890
	local s_x, s_y = self:getPosition()

	for i = 1, #self.npcs do 
		npc = self.npcs[i]
		local d_x, d_y = npc:getPosition()
		distance = (d_x - s_x)*(d_x - s_x) + (d_y - s_y)*(d_y * s_y)
		if distance < min_distance then
			min_npc = npc
			min_distance = distance
		end
	end

	return min_npc
end

function GamePlayer:autoFire()
	local parent = self:getParent()
	if parent == nil then
		return
	end

	--查找目标
	local enemy = nil
	local target_pos = nil

	enemy = self:find_nearest_npc()
	if not enemy then --自己好玩开火
		target_pos = NORMAL_DIR_VEC[self.dir]
	else
		local s_x, s_y = self:getPosition()
		local d_x, d_y = enemy:getPosition()
		local dst_pos = cc.p(d_x, d_y) 
		local src_pos = cc.p(s_x, s_y)
		
		target_pos = cc.pSub(dst_pos, src_pos)

		--转向
		local dir = AI.flowTarget(src_pos, dst_pos, 0)
		if dir ~= AI.TYPE_INVALID_DIR then
			self:drawPlayerAnim(dir)
		end
	end
	--end

	if not target_pos then
		return
	end

	local xpos, ypos = self:getPosition()
	local fire = WeaponDefault.new(target_pos)
	fire:addTo(parent):pos(xpos, ypos)

end

--Tick
function GamePlayer:onTick(dt)
	if self.auto_fire and self.auto_fire_dt >= 0.25 then
		self.auto_fire_dt = 0
		self:autoFire()
	else 
		self.auto_fire_dt = self.auto_fire_dt + dt
	end
end
--end

function GamePlayer:startAutoFire()
	self.auto_fire = true
	self.auto_fire_dt = 0.25
end

function GamePlayer:stopAutoFire()
	self.auto_fire = false
	self.auto_fire_dt = 0
end

function GamePlayer:setNPCSet(npcs)
	self.npcs = npcs
end

-- 1, 上 2, 下 3 左 4 右
function GamePlayer:ctor(dir)
	self.dir = nil
	self.auto_Fire = false
	self.auto_fire_dt = 0

	--shadow
	display.newSprite("character-shadow.png"):addTo(self):pos(0, -32)
	--

	self:drawPlayerAnim(dir)

	Physics.createDynamicBodyForNode(self, cc.size(40, 60), 2)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (dt)
		self:onTick(dt)
	end)
	self:scheduleUpdate()

end

return GamePlayer
