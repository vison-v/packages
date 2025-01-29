module("luci.controller.nginx_proxy", package.seeall)  

function index()  
    entry({"admin", "services", "nginx_proxy"}, cbi("nginx_proxy"), _("Nginx Reverse Proxy"), 60)  
    entry({"admin", "services", "nginx_proxy", "logs"}, call("render_logs_view"), _("View Logs"), 70)  
end  

function render_logs_view()  
    luci.template.render("nginx_proxy_logs")  
end
