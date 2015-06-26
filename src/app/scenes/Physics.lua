module("Physics", package.seeall)

_contactBegin = {}
_contactEnd = {}
_onPresolve = {}
_onPostSolve = {}

function clearAllContantsEventCache()
	_contactBegin = {}
	_contactEnd = {}
	_onPresolve = {}
	_onPostSolve = {}
end

function pushContactBegin(nodeA, nodeB)
	local pairs_node = {nodeA, nodeB}
	table.insert(_contactBegin, pairs_node)
end

function pushContactEnd(nodeA, nodeB)
	local pairs_node = {nodeA, nodeB}
	table.insert(_contactEnd, pairs_node)
end

function pushPresolveEvent(nodeA, nodeB, solve)
	local pairs_node = {nodeA, nodeB, solve}
	table.insert(_contactEnd, pairs_node)
end

function pushPostSolveEvent(nodeA, nodeB, solve)
	local pairs_node = {nodeA, nodeB, solve}
	table.insert(_contactEnd, pairs_node)
end

function step(scene, dt)
	local world = scene:getPhysicsWorld()
	world:step(dt)
end

function initPhysicsWorld(scene, g)
	local world = scene:getPhysicsWorld()
	world:setGravity(g)
	world:setAutoStep(false)

    world:setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
    --end
end

function setVelocityForNode(node, vx, vy)
	local body = node:getPhysicsBody()
	body:setVelocity(cc.p(vx, vy))
end

function createDynamicBodyForNode(node, s, tag)
	local body = cc.PhysicsBody:createBox(s, cc.PhysicsMaterial(0.0, 0.0, 0.0))
	
	if tag ~= nil then
		body:setTag(tag)
	end

	body:setDynamic(true)
	body:setVelocity(cc.p(0, 0))

	body:setContactTestBitmask(1)
	body:setCollisionBitmask(1)
	--body:setAngularVelocityLimit(0)
	body:setRotationEnable(false)


	node:setPhysicsBody(body)
end

function createStaticPhysicsForNode(node, s, tag)
	local body = cc.PhysicsBody:createBox(s, cc.PhysicsMaterial(0.0, 0.0, 0.0))

	--屏蔽到所有的碰撞
	body:setContactTestBitmask(1)
	body:setCollisionBitmask(1)

	if tag then
		body:setTag(tag)
	end

	body:setDynamic(false)
	node:setPhysicsBody(body)

	return node
end

function createStaticPhysicsNode(s, tag)
	local node = display.newNode()
	local body = cc.PhysicsBody:createBox(s, cc.PhysicsMaterial(0.0, 0.0, 0.0))

	--屏蔽到所有的碰撞
	body:setContactTestBitmask(0)
	body:setCollisionBitmask(0)

	if tag then
		body:setTag(tag)
	end

	body:setDynamic(false)
	node:setPhysicsBody(body)

	return node
end

function registerPhysicsContacts(scene)
	local eventDispathcher = cc.Director:getInstance():getEventDispatcher()

	--begin
	local contactListener = cc.EventListenerPhysicsContact:create()
	local function onContactBegin(contact)
		
		local bodyA = contact:getShapeA():getBody() 
		local bodyB = contact:getShapeB():getBody()
		
		local sp1 = bodyA:getNode();
	    local sp2 = bodyB:getNode();
		
		if sp1 == nil or sp2 == nil then
			return
		end

		--pushContactBegin(sp1, sp2)
		sp1:retain()
		sp2:retain()
		
		if sp1.onContactBegin then
			sp1:onContactBegin(sp2)
		end

		if sp2.onContactBegin then
			sp2:onContactBegin(sp1)
		end

		sp1:release()
		sp2:release()
	end

    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    eventDispathcher:addEventListenerWithSceneGraphPriority(contactListener, scene) 
    --end

    --PreSolve
    local function onPresolve(contact, solve)
		local sp1 = contact:getShapeA():getBody():getNode();
	    local sp2 = contact:getShapeB():getBody():getNode();
		
		if sp1 == nil or sp2 == nil then
			return
		end

		--pushPresolveEvent(sp1, sp2, solve)
		sp1:retain()
		sp2:retain()

		if sp1.onPresolve then
			sp1:onPresolve(sp2, solve)
		end

		if sp2.onPresolve then
			sp2:onPresolve(sp1, solve)
		end
		sp1:release()
		sp2:release()
	end

    contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onPresolve, cc.Handler.EVENT_PHYSICS_CONTACT_PRESOLVE)
    eventDispathcher:addEventListenerWithSceneGraphPriority(contactListener, scene) 
    --end

    --PostSolve
	local function onPostSolve(contact, solve)
		local sp1 = contact:getShapeA():getBody():getNode();
	    local sp2 = contact:getShapeB():getBody():getNode();
		
		if sp1 == nil or sp2 == nil then
			return
		end

		--pushPostSolveEvent(sp1, sp2, solve)
		sp1:retain()
		sp2:retain()

		if sp1.onPostSolve then
			sp1:onPostSolve(sp2)
		end

		if sp2.onPostSolve then
			sp2:onPostSolve(sp1)
		end
		sp1:release()
		sp2:release()
	end
    contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onPostSolve, cc.Handler.EVENT_PHYSICS_CONTACT_POSTSOLVE)
    eventDispathcher:addEventListenerWithSceneGraphPriority(contactListener, scene) 
    --end

    --endContast
	local function onContactEnd(contact)
		local sp1 = contact:getShapeA():getBody():getNode();
	    local sp2 = contact:getShapeB():getBody():getNode();
		
		if sp1 == nil or sp2 == nil then
			return
		end

		--pushContactEnd(sp1, sp2)
		sp1:retain()
		sp2:retain()

		if sp1.onContactEnd then
			sp1:onContactEnd(sp2)
		end

		if sp2.onContactEnd then
			sp2:onContactEnd(sp1)
		end
		sp1:release()
		sp2:release()
	end

    contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactEnd, cc.Handler.EVENT_PHYSICS_CONTACT_SEPERATE)
    eventDispathcher:addEventListenerWithSceneGraphPriority(contactListener, scene)
end

function broadCastContantsEvent()
	local nodeA, nodeB, solve

	for i = 1, #_contactBegin do 
		nodeA = _contactBegin[i][1]
		
		nodeB = _contactBegin[i][2]
		
		nodeA:retain()
		nodeB:retain()

		if nodeA.onContactBegin then
			nodeA:onContactBegin(nodeB)
		end

		if nodeB.onContactBegin then
			nodeB:onContactBegin(nodeA)
		end

		nodeA:release()
		nodeB:release()
	end

	for i = 1, #_onPresolve do 
		nodeA = _onPresolve[i][1]
		nodeB = _onPresolve[i][2]
		solve = _onPresolve[i][3]

		nodeA:retain()
		nodeB:retain()

		if nodeA.onPresolve then
			nodeA:onPresolve(nodeB, solve)
		end

		if nodeB.onPresolve then
			nodeB:onPresolve(nodeA, solve)
		end
		nodeA:release()
		nodeB:release()
	end

	for i = 1, #_onPostSolve do 
		nodeA = _onPostSolve[i][1]
		nodeB = _onPostSolve[i][2]
		solve = _onPostSolve[i][3]

		nodeA:retain()
		nodeB:retain()

		if nodeA.onPostSolve then
			nodeA:onPostSolve(nodeB, solve)
		end

		if nodeB.onPostSolve then
			nodeB:onPostSolve(nodeA, solve)
		end
		nodeA:release()
		nodeB:release()
	end

	for i = 1, #_contactEnd do 
		nodeA = _contactEnd[i][1]
		nodeB = _contactEnd[i][2]

		nodeA:retain()
		nodeB:retain()

		if nodeA.onContactEnd then
			nodeA:onContactEnd(nodeB)
		end

		if nodeB.onContactEnd then
			nodeB:onContactEnd(nodeA)
		end
		nodeA:release()
		nodeB:release()
	end

	clearAllContantsEventCache()
end

