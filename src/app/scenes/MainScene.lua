local JoyStick = require "app.scenes.JoyStick"
local GamePlayer = require "app.scenes.GamePlayer"
local GameEnemy = require "app.scenes.GameEnemy"
local FireStick = require "app.scenes.FireStick"
local GameTip = require "app.scenes.GameTip"

local MainScene = class("MainScene", function()
    return display.newPhysicsScene("MainScene")
end)

function MainScene:draw_player()
	self.player = GamePlayer.new(1):addTo(self.gameLayer)
	:pos(display.cx, 120)

	self.player:setZOrder(8000)
end

function MainScene:ctor()
	NPCManager.initNPCMan(self)
	--设置随机种子
	math.randomseed(os.time())

  	Physics.initPhysicsWorld(self, cc.p(0, 0))

	--资源加载进来
	display.addSpriteFrames("gui-ingame-main.plist", "gui-ingame-main.png");
	display.addSpriteFrames("player-evo-01.plist", "player-evo-01.png");
	display.addSpriteFrames("weapons.plist", "weapons.png");
	--end

	--创建一个层,把这个层加入到场景
	self.gameLayer = display.newLayer():addTo(self)

	--加载地图背景
	local map = cc.TMXTiledMap:create("game_map.tmx")
    map:addTo(self.gameLayer)

	--player
	self:draw_player()
	--end

	NPCManager.genEnemy()

	local particle = cc.ParticleSystemQuad:create("pfx-ui-smoke02.plist")
	particle:addTo(self.gameLayer):pos(-120, -120)


	--操作层
	self.optLayer = display.newLayer():addTo(self)

	--创建遥感对象, 加到左下角
	JoyStick.new(self.player):addTo(self.optLayer):pos(120, 120)
	--end

	--创建开火对象
	FireStick.new(self.player):addTo(self.optLayer):pos(display.right - 120, 120)
	--end

	self.player:setNPCSet(NPCManager.getNPCSet())

	Physics.registerPhysicsContacts(self)
	
	--初始化我们的装备模块
	PropsManager.initPropsMan(self)
	--

	--游戏提示
	self.gameTip = GameTip.new():addTo(self.optLayer)
	--end

	--audio.playMusic("mus-d1-02.mp3")
end

function MainScene:showGameTip(desic)
	self.gameTip:showGameTip(desic)
end

function MainScene:onTick(dt)
	Physics.step(self, dt)
end

function MainScene:onEnter()
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (dt)
		self:onTick(dt)
	end)
	self:scheduleUpdate()
end

function MainScene:onExit()
	local eventDispathcher = cc.Director:getInstance():getEventDispatcher()
	eventDispathcher:removeEventListenersForTarget(self)
end

return MainScene
