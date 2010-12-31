#
# Copyright (C) 2010 XRouter GROUP
#
# 
#
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lightmultiwan
PKG_VERSION:=1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/lightmultiwan
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ip
  TITLE:=Light-Multi-WAN
  URL:=http://www.xrouter.co.cc
  MAINTAINER:=Xu Guanglin xuguangl@mail2.sysu.edu.cn
endef

define Package/lightmultiwan/description
	Light-Multi-WAN is a light version of Multi-WAN application. It gets rid of daemon and iptables filters which require a lot of router resources.
endef

define Build/Compile
endef

define Package/lightmultiwan/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/lightmultiwan.sh $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/50-lightmultiwan $(1)/etc/hotplug.d/iface/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_BIN) ./files/lightmultiwan $(1)/etc/config/
endef

$(eval $(call BuildPackage,lightmultiwan))
