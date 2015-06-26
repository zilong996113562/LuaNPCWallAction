
require("config")
require("cocos.init")
require("framework.init")
require("framework.ui")
require("app.scenes.Physics")
require("app.scenes.AI")
require("app.scenes.NPCManager")
require("app.scenes.PropsManager") --装备模块代码导入

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("MainScene")
end

return MyApp
