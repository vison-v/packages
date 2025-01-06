#
#!/bin/bash
# © 2022 GitHub, Inc.
#====================================================================
# Copyright (c) 2022 Ing
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/wjz304/openwrt-packages
# File name: upgrade.sh
# Description: OpenWrt packages update script
#====================================================================
# 启用扩展通配符  
# shopt -s extglob  
# 设置脚本在遇到错误时不退出  
# set +e  
# 清理之前的 git 缓存  
# git rm -r --cache * >/dev/null 2>&1  
# 删除当前目录下的所有子目录  
# rm -rf `find ./* -maxdepth 0 -type d >/dev/null 2>&1  

# 默认分支为 openwrt  
BRANCH=${1:-openwrt}  

# 克隆 Git 仓库的函数  
function git_clone() {  
    git clone --depth 1 "$1" "$2"  
    if [ "$?" != 0 ]; then  
        echo "克隆出错: $1"  
        pid="$(ps -q $$)"  
        kill $pid  
    else  
        rm -rf "$2/.svn*" "$2/.git*"  
    fi  
}

# 稀疏克隆 Git 仓库的函数  
function git_sparse_clone() {  
    trap 'rm -rf "$tmpdir"' EXIT  
    branch="$1"   
    curl="$2"   
    shift 2  
    rootdir="$PWD"  
    tmpdir="$(mktemp -d)" || exit 1  
    if [ ${#branch} -lt 10 ]; then  
        git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"  
        cd "$tmpdir"  
    else  
        git clone --filter=blob:none --sparse "$curl" "$tmpdir"  
        cd "$tmpdir"  
        git checkout $branch  
    fi  
    if [ "$?" != 0 ]; then  
        echo "克隆出错: $curl"  
        exit 1  
    fi  
    git sparse-checkout init --cone  
    git sparse-checkout set "$@"  
    mv -n "$@" "$rootdir/" || true  
    rm -rf "$rootdir/$(basename "$curl" .git)/.svn*" "$rootdir/$(basename "$curl" .git)/.git*"   
    cd "$rootdir"  
}

# 移动文件夹的函数  
function mvdir() {  
    mv -n `find $1/* -maxdepth 0 -type d` ./  
    rm -rf $1  
}  

# 克隆需要的 Git 仓库  
git_clone https://github.com/xiaorouji/openwrt-passwall passwall && mv -n passwall/luci-app-passwall ./; rm -rf passwall  # luci-app-passwall  
git_clone https://github.com/xiaorouji/openwrt-passwall2 passwall2 && mv -n passwall2/luci-app-passwall2 ./; rm -rf passwall2  # luci-app-passwall2  
git clone https://github.com/kenzok8/small && rm -rf small/{luci-app-passwall,luci-app-passwall2} && mvdir small  # 翻越长城app及依赖  

# 稀疏克隆其他软件包  
git_sparse_clone main "https://github.com/gdy666/luci-app-lucky" luci-app-lucky lucky  

# 更新 lede 分支  
if [ "${BRANCH}" == "lede" ]; then  
    git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-wechatpush luci-theme-argon luci-app-argon-config  
    
    git_sparse_clone master "https://github.com/vison-v/lede" config scripts  
    #git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-quickstart quickstart luci-app-eqosplus \
    #luci-app-oaf open-app-filter oaf luci-app-wrtbwmon wrtbwmon \
    #luci-app-control-timewol luci-app-control-webrestriction luci-app-control-weburl  

# 更新 openwrt 分支  
elif [ "${BRANCH}" == "openwrt" ]; then  
    git_sparse_clone master https://github.com/immortalwrt/immortalwrt package/emortal/default-settings  
    # 如需更多软件包，可取消注释以下行  
    # git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-wechatpush \
    # luci-app-zerotier luci-app-unblockneteasemusic luci-theme-argon luci-app-argon-config luci-app-watchcat \
    # luci-app-autoreboot luci-app-usb-printer luci-app-vlmcsd luci-app-socat luci-app-arpbind luci-app-cifs-mount \
    # vlmcsd UnblockNeteaseMusic-Go UnblockNeteaseMusic \
    # git_sparse_clone master https://github.com/immortalwrt/luci applications/luci-app-smartdns  
    # git_sparse_clone master https://github.com/immortalwrt/packages net/smartdns  

# 更新 immortalwrt 分支  
elif [ "${BRANCH}" == "immortalwrt" ]; then  
    echo "暂无"  
fi  

# 处理语言文件  
for e in luci-app-*/po/*; do  
    [ ! -d "$e" ] && continue  
    [ -d "${e/zh-cn/zh_Hans}" ] && continue  
    cp -rf "$e" "${e/zh-cn/zh_Hans}"  
done  

for e in luci-app-*/po/*; do  
    [ ! -d "$e" ] && continue  
    [ -d "${e/zh_Hans/zh-cn}" ] && continue  
    cp -rf "$e" "${e/zh_Hans/zh-cn}"  
done

# 清理工作目录  
rm -rf ./*/.svn*  
rm -rf ./*/.git*  
find ./ -path '*/po/*' -type d ! -name 'zh-cn' ! -name 'zh_Hans' -exec rm -rf {} +  

# 脚本结束  
exit 0
