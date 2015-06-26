require "app.scenes.AnimManager"

local GameEnemy = class("GameEnemy", function ()
	return display.newNode()
end)

function GameEnemy:setPlayerV(dir)
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
		cc.p(0, self.LINE_VY), cc.p(0, -self.LINE_VY), 
		cc.p(-self.LINE_VX, 0), cc.p(self.LINE_VX, 0), 

		cc.p(self.LINE_VX, self.LINE_VY), cc.p(-self.LINE_VX, self.LINE_VY), 
		cc.p(-self.LINE_VX, -self.LINE_VY), cc.p(self.LINE_VX, -self.LINE_VY),
	}
	body:setVelocity(v_set[dir])
end

local RUNNING_DIR_FRAMES = {
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 20, 2, 0.2}, --上
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 1, 2, 0.2}, --下
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 30, 3, 0.2}, --左
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 10, 2, 0.2}, --右
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 15, 3, 0.2}, --右上
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 25, 3, 0.2}, --左上
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 35, 3, 0.2}, --左下
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 5, 3, 0.2}, --右下
}

local ATTACK_DIR_FRAMES = {
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 22, 2, 0.2}, --上攻击
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 3, 2, 0.2}, --下攻击
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 33, 2, 0.2}, --左攻击
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 12, 3, 0.2}, --右攻击
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 18, 2, 0.2}, --右上攻击
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 28, 2, 0.2}, --左上攻击
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 38, 2, 0.2}, --左下攻击
	{"enemy-skeleton-sword.plist", "enemy-skeleton-sword.png", "enemy-skeleton-sword-%04d.png", 8, 2, 0.2} --右下攻击
}

function GameEnemy:drawPlayerAnim(dir, isAttack)
	local playerAnim = nil
	if self.dir == dir and self.isAttack == isAttack then
		return
	end

	self.LINE_VX = math.random(50, 80)
	self.LINE_VY = math.random(50, 80)

	self.dir = dir
	self.isAttack = isAttack
	--以前有，就的删除
	if self.playerAnim ~= nil then
		self:removeChild(self.playerAnim)
		self.playerAnim = nil
	end

	-- 帧动画 dir
	local frames = nil
	if isAttack then
		frames = ATTACK_DIR_FRAMES
	else 
		frames = RUNNING_DIR_FRAMES
	end
	

	local playerAnim =  AnimManager.playForever(self, 
    	frames[dir], 
    0, 0)	
    self.playerAnim = playerAnim

end

function GameEnemy:onContactBegin(node)
	local body = node:getPhysicsBody()
	
	local self_body = self:getPhysicsBody()
	self_body:setVelocity(cc.p(0, 0))
	print("onContactBegin called")
	
	if body:getTag() == 4 then --子弹
		local parent = self:getParent()
		local xpos, ypos = self:getPosition()
			
		--骨头横飞
		local particle = cc.ParticleSystemQuad:create("pfx-enemydie-bones.plist")
		particle:addTo(parent):pos(xpos, ypos)
		--end

		--爆装备
		parent:performWithDelay(function ()
			PropsManager.genProps(xpos, ypos)
		end, 0.6)
		--end

		--产生新的NPC
		NPCManager.removeFromNPCMan(self)
		self:removeFromParent()
		NPCManager.genEnemy()
		--end
	end
end

function GameEnemy:onPresolve(node, solve)
	local body = node:getPhysicsBody()
	if body:getTag() == 1 then --固体
		local self_body = self:getPhysicsBody()
		self_body:setVelocity(cc.p(0, 0))
	end
end

function GameEnemy:onPostSolve(node, solve)
	local body = node:getPhysicsBody()
	if body:getTag() == 1 then --固体
		local self_body = self:getPhysicsBody()
		self_body:setVelocity(cc.p(0, 0))
	end
end

function GameEnemy:onContactEnd(node)
	local body = node:getPhysicsBody()
	if body:getTag() == 1 then --固体
		local self_body = self:getPhysicsBody()
		self_body:setVelocity(cc.p(0, 0))
	end
end

function GameEnemy:onEnterFrame(dt)
	if self.target == nil then
		return
	end
	
	local t_x, t_y = self.target:getPosition()

	local target_pos = cc.p(t_x, t_y) 
	local src_x, src_y = self:getPosition()
	local pos = cc.p(src_x, src_y)

	
	local relative_pos = cc.pSub(target_pos, pos)
	local len_distance = cc.pGetLength(relative_pos)
	-- 敌人太远了
	if len_distance > 160 then
		self:setPlayerV(0)
		return
	end
	--

	self.prev_dt = self.prev_dt + dt


	if self.prev_dt < 0.4 then
		return
	end



	
	if len_distance < 60 then
		local dir = AI.flowTarget(pos, target_pos, 0)
		self:drawPlayerAnim(dir, true)
		self:setPlayerV(0)
		return
	end
	--end
	

	self.prev_dt = 0

	if self.target == nil then
		return
	end
	

	--跟随玩家
	local dir = AI.flowTarget(pos, target_pos, 40)
	if dir ~= AI.TYPE_INVALID_DIR then
		
		self:drawPlayerAnim(dir, false)
		self:setPlayerV(dir)
	end
	--end
end

function GameEnemy:setTarget(player)
	self.target = player
end

-- 1, 上 2, 下 3 左 4 右
function GameEnemy:ctor(dir)
	self.dir = nil
	self.isAttack = false
	
	self:drawPlayerAnim(dir, false)
	self.prev_dt = 0
	Physics.createDynamicBodyForNode(self, cc.size(40, 60), 3)

	-- 注册帧事件
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
    self:scheduleUpdate()
end




return GameEnemy
