#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 1. 修改默认 IP
sed -i 's/192.168.1.1/192.168.1.1/g' package/base-files/files/bin/config_generate

# 2. 修改主机名为 JDCloud-One
sed -i 's/OpenWrt/JDCloud-One/g' package/base-files/files/bin/config_generate

# 3. 【核心修复】修正 5G 信号 EEPROM 偏移量
# 解决闭源驱动下无法读取校准数据导致 5G 信号极弱（6dBm）的问题
DTS_FILE="target/linux/ramips/dts/mt7621_jdcloud_re-sp-01b.dts"
if [ -f "$DTS_FILE" ]; then
    # 先删除可能存在的错误定义，防止重复插入
    sed -i '/mediatek,mtd-eeprom = <&factory 0x0>/d' $DTS_FILE
    sed -i '/mediatek,mtd-eeprom = <&factory 0x8000>/d' $DTS_FILE
    # 在 mt7615 节点下精准插入京东云原厂 5G 偏移量 0x8000
    sed -i '/mt7615@0,0 {/a \\t\t\tmediatek,mtd-eeprom = <&factory 0x8000>;' $DTS_FILE
    echo "DTS EEPROM Offset Fixed!"
fi

# 4. 【关键步骤】物理删除开源驱动源码
# 解决你之前 lsmod 出现的 mt7615e 抢占问题，确保系统只能加载闭源驱动模块
rm -rf package/kernel/mt76

# 5. 解锁无线功率限制 (设置为美国区域 US)
# 绕过较严的国内功率限制，解锁芯片硬件余量
sed -i 's/option country .*/option country '\''US'\''/g' package/network/config/wifi-scripts/files/lib/wifi/mac80211.sh 2>/dev/null || true

# 6. 强制开启闭源驱动初始化 (针对 mtwifi 插件优化)
if [ -f "package/network/config/wifi-scripts/files/lib/wifi/mtwifi.sh" ]; then
    sed -i 's/option disabled 1/option disabled 0/g' package/network/config/wifi-scripts/files/lib/wifi/mtwifi.sh
fi
