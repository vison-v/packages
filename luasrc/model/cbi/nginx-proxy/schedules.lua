local uci = luci.model.uci.cursor()
local sys = require "luci.sys"

m = Map("nginx-proxy", translate("Scheduled Tasks"),
    translate("Manage cron jobs for automatic certificate renewal and log rotation"))

s = m:section(TypedSection, "cron", translate("Cron Jobs"))
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true

time = s:option(Value, "time", translate("Schedule"), 
    translate("Format: minute hour day month week"))
time.placeholder = "0 3 * * *"
time.datatype = "crontime"

command = s:option(Value, "command", translate("Command"))
command.template = "cbi/cbi-value"
command.size = 60
command:value("/usr/libexec/nginx-proxy/renew-certs", translate("Renew Certificates"))
command:value("/usr/libexec/nginx-proxy/rotate-logs", translate("Rotate Logs"))

function m.on_commit(self)
    sys.call("/etc/init.d/cron restart")
end

return m
