module("AI", package.seeall)

TYPE_INVALID_DIR = 0
TYPE_UP_DIR = 1
TYPE_DOWN_DIR = 2
TYPE_LEFT_DIR = 3
TYPE_RIGHT_DIR = 4
TYPE_RU_DIR = 5
TYPE_LU_DIR = 6
TYPE_LD_DIR = 7
TYPE_RD_DIR = 8

function flowTarget(pos, target_pos, min_radis)
	
	local relative_pos = cc.pSub(target_pos, pos)
	local len_distance = cc.pGetLength(relative_pos)

	if len_distance < min_radis then
		return TYPE_INVALID_DIR
	end

	local sin_a = relative_pos.y / len_distance
	sin_a = math.abs(sin_a)

	local alpha_d = math.asin(sin_a)  
	local now_x = relative_pos.x 
	local now_y = relative_pos.y

	if now_x > 0 and now_y >= 0 then -- 第-
		--右边
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return TYPE_RIGHT_DIR
		end
		--右上
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return TYPE_RU_DIR
		end 
		-- 上
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return TYPE_UP_DIR
		end
		--end
	elseif now_x < 0 and now_y >= 0 then --第二
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return TYPE_LEFT_DIR
		end

		--左上
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return TYPE_LU_DIR
		end 

		--上
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return TYPE_UP_DIR
		end
		--end
	elseif now_x < 0 and now_y <= 0 then -- 第三象限
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return TYPE_LEFT_DIR
		end

		--左下
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return TYPE_LD_DIR
		end 

		--下
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return TYPE_DOWN_DIR
		end
		--end
	elseif now_x > 0 and now_y <= 0 then -- 第四象限
		if alpha_d >= 0 and alpha_d <= (math.pi / 8) then
			return TYPE_RIGHT_DIR
		end

		--左下
		if alpha_d > (math.pi / 8) and alpha_d <= (3*math.pi / 8) then
			return TYPE_RD_DIR
		end 

		--下
		if alpha_d > (3*math.pi / 8) and alpha_d <= math.pi / 2 then
			return TYPE_DOWN_DIR
		end
		--end
	end

	return TYPE_INVALID_DIR	
end

