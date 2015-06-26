local GameTip = class("GameTip", function ()
	return display.newNode()
end)

--初始化函数
function GameTip:ctor()
	local w, h
	w = 320
	h = 160
	self.width = w

	local bk = display.newScale9Sprite("battlecard-banner-right.png", 0, 0, cc.size(w, h))
	:addTo(self):pos(-w/2 + 20, -h/2 + 16)

	self.tip = cc.ui.UILabel.newTTFLabel_({
	    text = "Go ！",
	    size = 64,
	    color = ccc3(224, 226, 0),
	    align = cc.ui.TEXT_ALIGN_CENTER -- 文字内部居中对齐
	}):addTo(bk):pos(w/2, h/2)

	self:pos(display.right + self.width, display.top)
	
end

function GameTip:showGameTip(desic)
	self.tip:setString(desic)
	--飞入；
	self:pos(display.right + self.width, display.top)
	local moveIn = cc.MoveTo:create(0.2, cc.p(display.right, display.top))
	--end
	--停留
	local delay = cc.DelayTime:create(0.8) 
	--end

	--飞出
	local moveOut = cc.MoveTo:create(0.2, cc.p(display.right + self.width, display.top))
	
	--创建动作序列
	local seq = transition.sequence({
		moveIn,
		delay,
		moveOut,
		})

	self:runAction(seq)
	--end
end

return GameTip

