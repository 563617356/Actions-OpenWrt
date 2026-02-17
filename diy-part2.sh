#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# 修改京东云一代 5G 信号 EEPROM 偏移量 (从默认 0x0 修正为 0x8000)
# 这一步是解决 6dBm 的关键
sed -i 's/mediatek,mtd-eeprom = <&factory 0x0>/mediatek,mtd-eeprom = <&factory 0x8000>/g' target/linux/ramips/dts/mt7621_jdcloud_re-sp-01b.dts
