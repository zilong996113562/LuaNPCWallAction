local WeaponDefault = class("WeaponDefault", function ()
	return display.newNode()
end)

function WeaponDefault:onRemoved(dt)
	local s_x, s_y = self:getPosition()
	if s_x >= -64 and s_y <= 960 + 64 and s_y >= -64 and s_y <= 640 + 64 then
		return
	end	
	--删除掉
	self:unscheduleUpdate()

	self:performWithDelay(function ()
		self:removeFromParent()
	end, 0.1)
	--end

	
end

function WeaponDefault:onContactBegin(node)
	local body = node:getPhysicsBody()
	local tag = body:getTag()

	if tag == 3 then --固体
		local parent = self:getParent()
		local xpos, ypos = self:getPosition()
		

		local particle = cc.ParticleSystemQuad:create("pfx-shotimpact-default.plist")
		particle:addTo(parent):pos(xpos, ypos)
		particle:performWithDelay(function ()
			particle:removeFromParent()
		end, 1)
		
		self:removeFromParent()


	end
end

function WeaponDefault:ctor(target_dir)
	local len_distance = cc.pGetLength(target_dir)
	
	if len_distance <= 0 then
		return
	end

	self.speed = 1000
	local vy = self.speed * (target_dir.y / len_distance)
	local vx = self.speed * (target_dir.x / len_distance)

	local sin_a = target_dir.y / len_distance
	sin_a = math.abs(sin_a)

	local alpha_d = math.asin(sin_a)  
	local now_x = target_dir.x 
	local now_y = target_dir.y
	local alpha = alpha_d
	

	if now_x >= 0 and now_y >= 0 then -- 第-
		alpha = alpha_d
	elseif now_x <= 0 and now_y >= 0 then --第二
		alpha = math.pi - alpha_d
	elseif now_x <= 0 and now_y <= 0 then -- 第三象限
		alpha = math.pi + alpha_d
	elseif now_x >= 0 and now_y <= 0 then -- 第四象限
		alpha = 2 * math.pi - alpha_d
	end

	alpha = alpha * 180 / math.pi
	alpha = 360 - alpha

	local weap = display.newSprite("#playershot-default.png"):addTo(self)
	local blend = weap:getBlendFunc()
	blend.src = GL_DST_ALPHA
	blend.dst = GL_ONE_MINUS_SRC_ALPHA
	weap:setBlendFunc(blend)

	Physics.createDynamicBodyForNode(self, cc.size(31, 21), 4)
	Physics.setVelocityForNode(self, vx, vy)	
	self:setRotation(alpha)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (dt)
		self:onRemoved(dt)
	end)
	self:scheduleUpdate()
end

return WeaponDefault

