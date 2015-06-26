----------------------------------------------------------------------------------------------------
-- AnimManager
-- 
-- @author Justin
----------------------------------------------------------------------------------------------------

module("AnimManager", package.seeall)

--动画播放的开关，如果屏幕小于800*480，则不播放任何动画以节省资源
local closeAnim = false
if display.width < 480 and display.height < 800 then
	closeAnim = true
end

-- 播放容器，要播放的动画，坐标X，坐标Y，播放完成回调函数，播放前等待的时间
function play(container, animData, x, y, callbackFunc, delaySeconds)
	if closeAnim then -- 动画已关闭
		return
	end
	local x = x or 0
	local y = y or 0
	local delaySeconds = delaySeconds or 0
	local callbackFunc = callbackFunc or nil
	local removeAfterPlay = false --播放完成时清除显示对象
	
	if not container or not animData then
		return
	end

	local plist, png, animName, startIndex, frameCount, speed = unpack(animData)

	display.addSpriteFrames(plist, png)
	local frames = display.newFrames(animName, startIndex, frameCount)
	local sprite = display.newSprite(frames[1]):addTo(container):pos(x, y)
	local animation = display.newAnimation(frames, speed)

	return transition.playAnimationOnce(sprite, animation, removeAfterPlay, callbackFunc, delaySeconds)
end

-- 播放容器，动画数据，坐标，动画播放总时间，每一次重复前的延时
function playForever(container, animData, x, y, stopSeconds, delaySeconds)
	if closeAnim then -- 动画已关闭
		return
	end
	if not container or not animData then
		return
	end

	local x = x or 0
	local y = y or 0
	local delaySeconds = delaySeconds or 0
	local stopSeconds = stopSeconds or 0

	local plist, png, animName, startIndex, frameCount, speed = unpack(animData)

	display.addSpriteFrames(plist, png)
	local frames = display.newFrames(animName, startIndex, frameCount)
	local sprite = display.newSprite(frames[1]):addTo(container):pos(x, y)
	local animation = display.newAnimation(frames, speed)

	transition.playAnimationForever(sprite, animation, delaySeconds)

	if stopSeconds > 0 then
		sprite:performWithDelay(function()
        	AnimManager.stop(container, sprite)
    	end, stopSeconds)
	end
	return sprite
end

function stop(container, sprite)
	if not container or not sprite then
		return
	end
    transition.stopTarget(sprite)
    container:removeChild(sprite)
end
















