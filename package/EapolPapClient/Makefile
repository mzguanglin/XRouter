#
# Copyright (C) 2010 XRouter GROUP
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=EapolPapClient
PKG_VERSION:=0.9
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/EapolPapClient
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libpcap
  TITLE:=802.1x PAP Client
  URL:=http://www.xrouter.co.cc
  SUBMENU:=dial-in/up
  MAINTAINER:=Xu Guanglin xuguangl@mail2.sysu.edu.cn
endef

define Package/EapolPapClient/description
	An 802.1x Authentication Client Work With H3C PAP Protocol
endef

define Build/Compile
endef

define Package/EapolPapClient/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/EapolPapClient $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/EapolPapClient
	$(INSTALL_BIN) ./files/8021xdhcp.script $(1)/usr/share/EapolPapClient/
endef

$(eval $(call BuildPackage,EapolPapClient))
