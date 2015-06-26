local JoyStick = class("JoyStick", function ()
	return display.newNode()
end)

-- 第一象限， 右[0, pi / 8)，右上[pi/8, pi*3/8)，上[pi*3 / 8, pi/2]

local UP_DIR = 1
local DOWN_DIR = 2
local LEFT_DIR = 3
local RIGHT_DIR = 4
local RU_DIR = 5
local LU_DIR = 6
local LD_DIR = 7
local RD_DIR = 8

function JoyStick:getNewPosByMaxRadis(maxRadis, x, y)
	
	local now_x, now_y
	local dir = -1 --方向

	now_x = x
	now_y = y

	local len = x*x + y*y -- 两点之间的距离
	len = math.sqrt(len)

	if len < maxRadis then -- 没有超过最大边界；
		now_x = x
		now_y = y
	else
		--
		local sin_a = y / len
		local cos_a = x / len

		now_x = maxRadis * cos_a
		now_y = maxRadis * sin_a
		len = maxRadis
	end


	if now_x == 0 then
		if now_y < 0 then -- 下
			dir = DOWN_DIR
		elseif now_y > 0 then -- 上 
			dir = UP_DIR
		end
		return dir, now_x, now_y
	end

	-- argtan y/x alphad
	
	local tan_value = now_y / now_x
	tan_value = math.abs(tan_value)

	local alpha_d = math.atan(tan_value)  

	
	if now_x > 0 and now_y >= 0 then -- 第-
		--右边
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return RIGHT_DIR, now_x, now_y
		end
		--右上
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return RU_DIR, now_x, now_y
		end 
		-- 上
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return UP_DIR, now_x, now_y
		end
		--end
	elseif now_x < 0 and now_y >= 0 then --第二
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return LEFT_DIR, now_x, now_y
		end

		--左上
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return LU_DIR, now_x, now_y
		end 

		--上
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return UP_DIR, now_x, now_y
		end
		--end
	elseif now_x < 0 and now_y <= 0 then -- 第三象限
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return LEFT_DIR, now_x, now_y
		end

		--左下
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return LD_DIR, now_x, now_y
		end 

		--下
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return DOWN_DIR, now_x, now_y
		end
		--end
	elseif now_x > 0 and now_y <= 0 then -- 第四象限
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return RIGHT_DIR, now_x, now_y
		end

		--左下
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return RD_DIR, now_x, now_y
		end 

		--下
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return DOWN_DIR, now_x, now_y
		end
		--end
	end
	--end
	return dir, now_x, now_y

end

-- event 事件类型
function JoyStick:onEventMove(event)
	--按小的时候的事件
	local x, y
	x = event.x
	y = event.y

	if event.name == "began" then
		--返回一个True,不会向后传递了；
		return true;
	elseif event.name == "moved" then
		-- stick 跟着触摸屏移动
		-- x, y是一个屏幕坐票，转成节点坐标
		local localPoint = self:convertToNodeSpace(cc.p(x, y))
		--不能够超过最大半径
		local dir, now_x, now_y = self:getNewPosByMaxRadis(120, localPoint.x, localPoint.y)
		--end
		if dir ~= -1 then
			self.player:drawPlayerAnim(dir)
			self.player:setPlayerV(dir)
		end

		self.stick:pos(now_x, now_y)
	else
		self.stick:pos(0, 0)
		self.player:setPlayerV(0)
	end
end

function JoyStick:setTarget(p)
	self.player = p
end

--初始化函数
function JoyStick:ctor(player)
	--背景图
	-- 初始化
	self.player = player
	display.newSprite("#pad-left.png"):addTo(self):pos(0, 0)
	--end

	--遥感
	self.stick = display.newSprite("#thumbstick.png"):addTo(self):pos(0, 0)
	--接受触摸消息
	self.stick:setTouchEnabled(true)

	-- 监听一个事件
	self.stick:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onEventMove))
	--
end

return JoyStick
