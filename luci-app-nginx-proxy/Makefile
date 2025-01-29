include $(TOPDIR)/rules.mk  

LUCI_TITLE:=Nginx Proxy  
LUCI_DEPENDS:=+nginx +acme  
LUCI_PKGARCH:=all  

PKG_NAME:=luci-app-nginx-proxy  
PKG_VERSION:=1.2.0  
PKG_RELEASE:=1  

include $(INCLUDE_DIR)/package.mk  
include $(INCLUDE_DIR)/luci.mk  

define Package/$(PKG_NAME)  
  SECTION:=luci  
  CATEGORY:=LuCI  
  TITLE:=$(LUCI_TITLE)  
  DEPENDS:=$(LUCI_DEPENDS)  
endef  

define Package/$(PKG_NAME)/description  
  Nginx reverse proxy configuration and management plugin, supports SSL and ACME automatic certificate management.  
endef  

define Build/Compile  
endef  

define Package/$(PKG_NAME)/install  
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller  
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi  
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view  
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n  

	$(INSTALL_DATA) ./src/controller/nginx_proxy.lua $(1)/usr/lib/lua/luci/controller/  
	$(INSTALL_DATA) ./src/model/cbi/nginx_proxy.lua $(1)/usr/lib/lua/luci/model/cbi/  
	$(INSTALL_DATA) ./src/view/nginx_proxy.htm $(1)/usr/lib/lua/luci/view/  
    $(INSTALL_DATA) ./src/view/nginx_proxy_logs.htm $(1)/usr/lib/lua/luci/view/  
	$(INSTALL_DATA) ./src/po/zh-cn.po $(1)/usr/lib/lua/luci/i18n/zh-cn/nginx_proxy.po  
    $(INSTALL_DATA) ./src/po/zh_Hans.po $(1)/usr/lib/lua/luci/i18n/zh_Hans/nginx_proxy.po  
endef  

$(eval $(call BuildPackage,$(PKG_NAME)))
