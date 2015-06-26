local FireStick = class("FireStick", function ()
	return display.newNode()
end)

function FireStick:onEventMove(event)
	local x, y

	x = event.x
	y = event.y

    if event.name == "began" then
		self.player:startAutoFire()
        return true
    end

    if event.name == "ended" then
    	self.player:stopAutoFire()
    end
end

function FireStick:setTarget(p)
	self.player = p
end

function FireStick:ctor(p)
	local bk = display.newSprite("#shootbutton.png"):addTo(self)
	bk:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onEventMove))
	bk:setTouchEnabled(true)	

	self.player = p
end

return FireStick

