local uci = require "luci.model.uci".cursor()

m = Map("nginx-proxy-acme", _("ACME Configuration"))

s = m:section(TypedSection, "acme", _("ACME Settings"))
s.addremove = true
s.anonymous = true

s:option(Value, "domain", _("Domain Name")).optional = false
s:option(Value, "email", _("Email Address")).optional = false
s:option(Value, "cert_path", _("Certificate Path")).optional = false
s:option(Value, "key_path", _("Private Key Path")).optional = false

-- 保存配置时触发ACME证书申请
function m.on_commit(self)
    local domain = uci:get("nginx-proxy-acme", "acme", "domain")
    local email = uci:get("nginx-proxy-acme", "acme", "email")
    local cert_path = uci:get("nginx-proxy-acme", "acme", "cert_path")
    local key_path = uci:get("nginx-proxy-acme", "acme", "key_path")

    if domain and email and cert_path and key_path then
        -- 调用ACME客户端申请证书
        local cmd = string.format("acme.sh --issue --dns dns_cf -d %s --email %s --cert-file %s --key-file %s", domain, email, cert_path, key_path)
        os.execute(cmd)
    end
end

return m
