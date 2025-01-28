include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-nginx-proxy
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-nginx-proxy
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=Nginx Reverse Proxy Configuration
  DEPENDS:=+luci +nginx +luci-i18n-base-zh-cn +acme
endef

define Package/luci-app-nginx-proxy/description
  A LuCI plugin to configure Nginx reverse proxy with SSL and ACME support.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-nginx-proxy/install
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/nginx-proxy
    $(INSTALL_DIR) $(1)/etc/uci-defaults

    $(INSTALL_DATA) ./files/controller/nginx-proxy.lua $(1)/usr/lib/lua/luci/controller/
    $(INSTALL_DATA) ./files/model/cbi/nginx-proxy.lua $(1)/usr/lib/lua/luci/model/cbi/
    $(INSTALL_DATA) ./files/model/cbi/nginx-proxy-acme.lua $(1)/usr/lib/lua/luci/model/cbi/
    $(INSTALL_DATA) ./files/view/nginx-proxy/log.htm $(1)/usr/lib/lua/luci/view/nginx-proxy/
    $(INSTALL_DATA) ./files/view/nginx-proxy/ssl.htm $(1)/usr/lib/lua/luci/view/nginx-proxy/
endef

$(eval $(call BuildPackage,luci-app-nginx-proxy))
