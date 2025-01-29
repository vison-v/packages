local uci = require "luci.model.uci".cursor()  
local fs = require "nixio.fs"  
local exec = require "luci.util".exec  

m = Map("nginx_proxy", _("Nginx Reverse Proxy Configuration"))  
m.on_after_save = function(self)  
    generate_nginx_config()  
    local ret = os.execute("/etc/init.d/nginx reload")  
    if ret == 0 then  
        self:form_message(_("Nginx configuration updated and reloaded."))  
    else  
        self:form_message(_("Failed to update Nginx configuration, please check the settings."), "error")  
    end  
end  

s = m:section(TypedSection, "proxy", _("Reverse Proxy Settings"))  
s.addremove = true  
s.anonymous = true  

s:option(Value, "server_name", _("Server Name (e.g., example.com)")).description = _("Enter your domain name or server name")  
s:option(Value, "listen", _("Listen Address (e.g., 80 or [::]:80)")).default = "80" .description = _("Enter the listening port, e.g., 80 for HTTP, 443 for HTTPS, or [::]:80 for IPv6")  
s:option(Value, "proxy_pass", _("Proxy Address (e.g., http://localhost:8080)")).description = _("Enter the backend server address, e.g., http://127.0.0.1:8080")  
s:option(Flag, "ssl_enabled", _("Enable SSL")).default = "0"  

cert_s = m:section(TypedSection, "ssl", _("SSL Certificate Configuration"))  
cert_s.anonymous = true  
cert_s:option(Value, "certificate", _("Certificate Path (e.g., /etc/nginx/ssl/cert.pem)")).description = _("Enter the full path to the SSL certificate file")  
cert_s:option(Value, "key", _("Private Key Path (e.g., /etc/nginx/ssl/key.pem)")).description = _("Enter the full path to the SSL private key file")  

acme_s = m:section(TypedSection, "acme", _("ACME Automatic Certificate Management"))  
acme_s.anonymous = true  
acme_s:option(Flag, "enabled", _("Enable ACME")).default = "0"  
acme_s:option(Value, "email", _("Email Address (for certificate requests)")).description = _("Enter the email address for ACME certificate requests")  
acme_s:option(Button, "run_acme", _("Run ACME")).inputstyle = "apply"  

function acme_s.parse(self, ...)  
    local run_acme = luci.http.formvalue("cbid.nginx_proxy.acme._run_acme")  
    if run_acme and uci:get("nginx_proxy", "acme", "enabled") == "1" then  
        local server_name = uci:get("nginx_proxy", "proxy", "server_name")  
        local email = uci:get("nginx_proxy", "acme", "email")  
        local ret, stdout, stderr = exec(string.format("/usr/bin/acme.sh --issue -d %s -w /www --email %s --force", server_name, email))  
        if ret == 0 then  
            local cert_path = string.format("/etc/nginx/ssl/%s.cer", server_name)  
            local key_path = string.format("/etc/nginx/ssl/%s.key", server_name)  
            fs.copy(string.format("/root/.acme.sh/%s/%s.cer", server_name, server_name), cert_path)  
            fs.copy(string.format("/root/.acme.sh/%s/%s.key", server_name, server_name), key_path)  
            uci:set("nginx_proxy", "ssl", "certificate", cert_path)  
            uci:set("nginx_proxy", "ssl", "key", key_path)  
            uci:save("nginx_proxy")  
            self:form_message(_("ACME certificate request successful. Certificates saved to %s and %s.") :format(cert_path, key_path))  
        else  
            self:form_message(_("ACME certificate request failed: %s") :format(stderr), "error")  
        end  
    end  
    Map.parse(self, ...)  
end  

logs_s = m:section(TypedSection, "logs", _("Log Management"))  
logs_s.anonymous = true  
logs_s:option(Button, "clear_logs", _("Clear Logs")).inputstyle = "apply"  
logs_s:option(DummyValue, "log_path", _("Log Path")).value = "/var/log/nginx/access.log"  

function logs_s.parse(self, ...)  
    local clear = luci.http.formvalue("cbid.nginx_proxy.logs._clear_logs")  
    if clear then  
        local ret = os.execute("echo '' > /var/log/nginx/access.log")  
        if ret == 0 then  
            self:form_message(_("Logs cleared."))  
        else  
            self:form_message(_("Failed to clear logs."), "error")  
        end  
    end  
    Map.parse(self, ...)  
end  


function generate_nginx_config()  
    local config = [[  
http {  
    include       mime.types;  
    default_type  application/octet-stream;  

    server {  
        listen %s;  
        server_name %s;  

        location / {  
            proxy_pass %s;  
            proxy_set_header Host $host;  
            proxy_set_header X-Real-IP $remote_addr;  
        }  
    }  
]]  

    local server_name = uci:get("nginx_proxy", "proxy", "server_name")  
    local proxy_pass = uci:get("nginx_proxy", "proxy", "proxy_pass")  
    local listen = uci:get("nginx_proxy", "proxy", "listen")  
    local ssl_enabled = uci:get("nginx_proxy", "proxy", "ssl_enabled")  

    if ssl_enabled == "1" then  
        local cert = uci:get("nginx_proxy", "ssl", "certificate")  
        local key = uci:get("nginx_proxy", "ssl", "key")  
        config = config .. [[  
        listen 443 ssl;  
        ssl_certificate %s;  
        ssl_certificate_key %s;  
        ]]  
        config = config:format(listen, server_name, proxy_pass, cert, key)  
    else  
        config = config:format(listen, server_name, proxy_pass)  
    end  

    local nginx_conf = "/etc/nginx/nginx.conf"  
    fs.writefile(nginx_conf, config)  
end  

return m
