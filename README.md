# packages
🤖 Lede和OpenWrt 常用插件库
[packages](https://github.com/vison-v/packages)

## 使用
Openwrt:
```
sed -i '$a src-git custou-packages https://github.com/vison-v/packages;openwrt' feeds.conf.default
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```
Lede:
```
sed -i '$a custou-packages https://github.com/vison-v/packages;lede' feeds.conf.default
./scripts/feeds clean
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
```

# 在此 鸣谢各位插件作者 


### default-settings
https://github.com/coolsnowwolf/lede/tree/master/package/lean/default-settings


## 鸣谢
- [sirpdboy's openwrt](https://github.com/sirpdboy)
- [xiaorouji's openwrt](https://github.com/xiaorouji)
- [fw876's helloworld](https://github.com/fw876/helloworld)
- [immortalwrt's openwrt](https://github.com/immortalwrt/packages)
- [有種's openwrt-package](https://github.com/kenzok8/openwrt-packages)
- [kiddin9's openwrt-package](https://github.com/kiddin9/openwrt-packages)
- [Lienol's openwrt-package](https://github.com/Lienol/openwrt-package)
