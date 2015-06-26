module("NPCManager", package.seeall)


local GameEnemy = require "app.scenes.GameEnemy"

_game_scene = nil
_NPC_set = {}

function getNPCSet()
	return _NPC_set 
end


function removeFromNPCMan(npc)
	local i 
	for i = 1, #_NPC_set do 
		
		if _NPC_set[i] == npc then
			table.remove(_NPC_set, i)
			return
		end
	end
end

-- 120, 960 - 120
-- 64, 640-64
function genEnemy()
	local parent = _game_scene.gameLayer
	local dir = math.random(8)
	local xpos = math.random(240, 960 - 120)
	local ypos = math.random(120, 640 - 120)

	local name = "pfx-monster-spawn.plist"
	particle = cc.ParticleSystemQuad:create(name)
	particle:addTo(parent):pos(xpos, ypos)

	parent:performWithDelay(function ()
		local enemy = GameEnemy.new(dir)
		enemy:addTo(parent):pos(xpos, ypos)
		enemy:setTarget(_game_scene.player)
		table.insert(_NPC_set, enemy)
	end, 1.6)
	
end

function initNPCMan(scene)
	_game_scene = scene
end





