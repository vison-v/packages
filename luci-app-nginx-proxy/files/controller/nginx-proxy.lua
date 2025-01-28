module("luci.controller.nginx-proxy", package.seeall)

function index()
    -- 主配置页面
    entry({"admin", "services", "nginx-proxy"}, cbi("nginx-proxy"), _("Nginx Reverse Proxy"), 60)

    -- 日志页面
    entry({"admin", "services", "nginx-proxy", "log"}, call("action_log"), _("View Logs"), 70)
    entry({"admin", "services", "nginx-proxy", "log", "clear"}, call("action_clear_log"), nil)

    -- SSL配置页面
    entry({"admin", "services", "nginx-proxy", "ssl"}, cbi("nginx-proxy-ssl"), _("SSL Configuration"), 80)

    -- ACME配置页面
    entry({"admin", "services", "nginx-proxy", "acme"}, cbi("nginx-proxy-acme"), _("ACME Configuration"), 90)
end

-- 日志页面处理函数
function action_log()
    local log_file = "/var/log/nginx-proxy.log"
    local max_lines = 100  -- 最多显示100行日志

    -- 读取日志文件内容
    local log_content = ""
    local file = io.open(log_file, "r")
    if file then
        local lines = {}
        for line in file:lines() do
            table.insert(lines, line)
        end
        file:close()

        -- 只显示最后100行
        if #lines > max_lines then
            lines = {table.unpack(lines, #lines - max_lines + 1, #lines)}
        end
        log_content = table.concat(lines, "\n")
    else
        log_content = _("Log file not found or is empty.")
    end

    -- 渲染日志页面
    luci.template.render("nginx-proxy/log", {log_content=log_content})
end

-- 日志清除处理函数
function action_clear_log()
    local log_file = "/var/log/nginx-proxy.log"

    -- 清空日志文件
    local file = io.open(log_file, "w")
    if file then
        file:write("")
        file:close()
    end

    -- 重定向回日志页面
    luci.http.redirect(luci.dispatcher.build_url("admin/services/nginx-proxy/log"))
end
