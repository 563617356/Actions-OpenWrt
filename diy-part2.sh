#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 1. 修改默认 IP (根据需要修改，这里改为 192.168.1.1)
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 2. 修改主机名为 JDCloud
sed -i 's/OpenWrt/JDCloud-One/g' package/base-files/files/bin/config_generate

# 3. 【核心修复】修正 5G 信号 EEPROM 偏移量
# 解决闭源驱动下 5G 信号只有 6dBm 的问题
DTS_FILE="target/linux/ramips/dts/mt7621_jdcloud_re-sp-01b.dts"
if [ -f "$DTS_FILE" ]; then
    # 先删除可能存在的错误定义，防止重复
    sed -i '/mediatek,mtd-eeprom = <&factory 0x0>/d' $DTS_FILE
    sed -i '/mediatek,mtd-eeprom = <&factory 0x8000>/d' $DTS_FILE
    # 在 mt7615 节点下精准插入正确的偏移量
    sed -i '/mt7615@0,0 {/a \\t\t\tmediatek,mtd-eeprom = <&factory 0x8000>;' $DTS_FILE
    echo "DTS EEPROM Offset Fixed!"
fi

# 4. 解锁无线功率限制 (设置为美国区域 US)
# 这一步能让闭源驱动在初始化时跳过国内较严的功率限制
sed -i 's/option country .*/option country '\''US'\''/g' package/network/config/wifi-scripts/files/lib/wifi/mac80211.sh 2>/dev/null || true

# 5. 修复部分闭源驱动界面显示中文乱码 (可选)
# sed -i 's/default \"UTF-8\"/default \"zh-cn\"/g' feeds/luci/modules/luci-base/luasrc/i18n.lua
