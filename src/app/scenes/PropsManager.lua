module("PropsManager", package.seeall)

-- 游戏装备的类
local GameProp = require "app.scenes.GameProp"

_game_scene = nil

-- 120, 960 - 120
-- 64, 640-64
function genProps(xpos, ypos)
	local parent = _game_scene.gameLayer
	
	--可以有装备算法,简单爆装备算法
	local prop_type = math.random(1, 7)
	--end

	--根据概率，产生装备
	local prop = GameProp.new(prop_type)
	prop:addTo(parent):pos(xpos, ypos)
	--end
end

--装备描述以及装备属性
local PROP_TYPE_NAME = {
	"Blood",
	"Gun 1",
	"Gun 2",
	"Gun 3",
	"Coins 1",
	"Coins 2",
	"Coins 3",	
}

function showPropTip(type)
	if PROP_TYPE_NAME[type] then
		_game_scene:showGameTip(PROP_TYPE_NAME[type])
	end
end

--初始化函数
function initPropsMan(scene)
	_game_scene = scene
end





