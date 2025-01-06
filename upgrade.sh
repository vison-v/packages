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
shopt -s extglob
set +e
git rm -r --cache * >/dev/null 2>&1 &
rm -rf `find ./* -maxdepth 0 -type d` >/dev/null 2>&1
BRANCH=${1:-openwrt}

function git_clone() {  
    git clone --depth 1 $1 $2  
    if [ "$?" != 0 ]; then  
        echo "error on $1"  
        pid="$(ps -q $$)"  
        kill $pid  
    fi  
}  

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
        echo "error on $curl"  
        exit 1  
    fi  
    git sparse-checkout init --cone  
    git sparse-checkout set "$@"  
    mv -n "$@" "$rootdir/" || true  
    cd "$rootdir"  
}  

function mvdir() {  
    mv -n `find $1/* -maxdepth 0 -type d` ./  
    rm -rf $1  
}  

git_clone https://github.com/xiaorouji/openwrt-passwall passwall && mv -n passwall/luci-app-passwall ./; rm -rf passwall  ## luci-app-passwall  
git_clone https://github.com/xiaorouji/openwrt-passwall2 passwall2 && mv -n passwall2/luci-app-passwall2 ./; rm -rf passwall2  ## luci-app-passwall2  
git clone https://github.com/kenzok8/small && rm -rf small/{luci-app-passwall,luci-app-passwall2} && mvdir small  ## 翻越长城app及依赖  

git_sparse_clone main https://github.com/kiddin9/luci-app-tcpdump luci-app-tcpdump  
git_sparse_clone main "https://github.com/gdy666/luci-app-lucky" luci-app-lucky lucky  

# 更新lede分支  
if [ "${{ BRANCH }}" == "lede" ]; then  
    git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-wechatpush luci-theme-argon luci-app-argon-config  
    git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-quickstart quickstart luci-app-eqosplus \
    luci-app-oaf open-app-filter oaf luci-app-wrtbwmon wrtbwmon \
    luci-app-control-timewol luci-app-control-webrestriction luci-app-control-weburl  

# 更新openwrt分支  
elif [ "${BRANCH}" == "openwrt" ]; then  
    git_sparse_clone master https://github.com/immortalwrt/immortalwrt package/emortal/default-settings  
    # Uncomment the following lines for additional packages  
    # git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-wechatpush \
    # luci-app-zerotier luci-app-unblockneteasemusic luci-theme-argon luci-app-argon-config luci-app-watchcat \
    # luci-app-autoreboot luci-app-usb-printer luci-app-vlmcsd luci-app-socat luci-app-arpbind luci-app-cifs-mount \
    # vlmcsd UnblockNeteaseMusic-Go UnblockNeteaseMusic \
    # git_sparse_clone master https://github.com/immortalwrt/luci applications/luci-app-smartdns  
    # git_sparse_clone master https://github.com/immortalwrt/packages net/smartdns  

# 更新immortalwrt分支  
elif [ "${{ BRANCH }}" == "immortalwrt" ]; then  
    echo "暂无"  
fi  

# Clean up  
rm -rf ./*/.svn*  
rm -rf ./*/.git*  
find ./ -path '*/po/*' -type d ! -name 'zh-cn' ! -name 'zh_Hans' -exec rm -rf {} +  

# End  
exit 0
