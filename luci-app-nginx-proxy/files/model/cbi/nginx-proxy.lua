local uci = require "luci.model.uci".cursor()
local nginx_conf = "/etc/nginx/nginx.conf"

-- 生成Nginx配置的函数
local function generate_nginx_config()
    local config = ""
    uci:foreach("nginx-proxy", "proxy", function(s)
        config = config .. "server {\n"
        config = config .. "    listen " .. s.listen .. ";\n"
        config = config .. "    server_name " .. s.server_name .. ";\n"
        if s.ssl_enabled == "1" then
            config = config .. "    listen " .. s.ssl_listen .. " ssl;\n"
            config = config .. "    ssl_certificate " .. s.ssl_certificate .. ";\n"
            config = config .. "    ssl_certificate_key " .. s.ssl_certificate_key .. ";\n"
        end
        config = config .. "    location / {\n"
        config = config .. "        proxy_pass " .. s.proxy_pass .. ";\n"
        config = config .. "        proxy_set_header Host $host;\n"
        config = config .. "        proxy_set_header X-Real-IP $remote_addr;\n"
        config = config .. "        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n"
        config = config .. "        proxy_set_header X-Forwarded-Proto $scheme;\n"
        config = config .. "    }\n"
        config = config .. "}\n"
    end)
    return config
end

-- 将生成的配置写入Nginx配置文件
local function write_nginx_config(config)
    local file = io.open(nginx_conf, "w")
    if file then
        file:write(config)
        file:close()
        return true
    else
        return false, _("Failed to open Nginx configuration file.")
    end
end

-- 重启Nginx服务
local function restart_nginx()
    local result = os.execute("/etc/init.d/nginx restart")
    if result == 0 then
        return true
    else
        return false, _("Failed to restart Nginx.")
    end
end

-- CBI模型
m = Map("nginx-proxy", _("Nginx Reverse Proxy Configuration"))

s = m:section(TypedSection, "proxy", _("Proxy Settings"))
s.addremove = true
s.anonymous = true

s:option(Value, "server_name", _("Server Name")).optional = false
s:option(Value, "listen", _("Listen Port")).optional = false
s:option(Value, "proxy_pass", _("Proxy Pass URL")).optional = false

-- SSL配置
ssl = s:option(Flag, "ssl_enabled", _("Enable SSL"))
ssl.optional = false

ssl_listen = s:option(Value, "ssl_listen", _("SSL Listen Port"))
ssl_listen.optional = false
ssl_listen:depends("ssl_enabled", "1")

ssl_certificate = s:option(Value, "ssl_certificate", _("SSL Certificate Path"))
ssl_certificate.optional = false
ssl_certificate:depends("ssl_enabled", "1")

ssl_certificate_key = s:option(Value, "ssl_certificate_key", _("SSL Certificate Key Path"))
ssl_certificate_key.optional = false
ssl_certificate_key:depends("ssl_enabled", "1")

-- 保存配置时自动生成Nginx配置文件并重启服务
function m.on_commit(self)
    local config = generate_nginx_config()
    local success, err = write_nginx_config(config)
    if not success then
        luci.http.redirect(luci.dispatcher.build_url("admin/services/nginx-proxy"))
        return
    end

    local success, err = restart_nginx()
    if not success then
        luci.http.redirect(luci.dispatcher.build_url("admin/services/nginx-proxy"))
        return
    end
end

return m
