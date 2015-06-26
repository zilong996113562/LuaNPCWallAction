local GameProp = class("GameProp", function ()
	return display.newNode()
end)

--初始化,然后传入type, new出不同类型的转杯
function GameProp:ctor(type_prop)
	self.typeProp = type_prop
	
	--资源,名称
	local name = "pickup-type"..type_prop..".png"
	local sprite = display.newSprite(name):addTo(self)
	--end

	-- 表示的，你这个透明，可以影响你的child节点
	self:setCascadeOpacityEnabled(true)

	--FadeIn
	self:setOpacity(0)
	transition.fadeIn(self, {time = 0.6})
	Physics.createStaticPhysicsForNode(self, cc.size(32, 32), 5)
end

--获取装备信息
function GameProp:getPropInfo()
	return self.typeProp
end

return GameProp


