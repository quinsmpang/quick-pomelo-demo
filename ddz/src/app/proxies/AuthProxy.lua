local consts = require('app.consts')
local Player = require('app.models.Player')

local AuthProxy = class('AuthProxy', pm.Proxy)

function AuthProxy:ctor(...)
    AuthProxy.super.ctor(self, ...)
end

function AuthProxy:login()
    local rpc = RPC:ins()
    rpc:setOnConnected(handler(self, function(self, connected)
        printInfo('onConnectedCallback called, connected=%s', tostring(connected))
        if not connected then
            ddz.facade:sendNotification(consts.msgs.ON_DISCONNECT);
            return
        end
        --local filename = cc.FileUtils:getInstance():fullPathForFilename('conf')
        --local config = json.decode(io.readfile(filename))
        if not ddz.state.deviceid then
            ddz.state.deviceid = tostring(os.time() * 10000 + math.random(1, 1000) * 1000 + math.random(1, 1000))
            cc.utils.State.save(ddz.state)
        end
        local authInfo = {socialId=ddz.state.deviceid, socialType=consts.binding.types.DEVICE};
        rpc:request(consts.routes.server.connector.LOGIN, {authInfo=authInfo}, handler(self, self._onLoginResponse))
    end))
    rpc:connectGate('127.0.0.1', 3010)
end

function AuthProxy:_onLoginResponse(msg)
    printInfo('_onLoginResponse called')
    ddz.models.me = Player.new(msg.data.player)
    ddz.facade:sendNotification(consts.msgs.UPDATE, ddz.models.me, 'login')
end

function AuthProxy:test(arg)
    printInfo('args: %s', arg)
    return arg + 1
end

return AuthProxy
