#!/bin/bash

shopt -s extglob
set +e
git rm -r --cache * >/dev/null 2>&1 &
rm -rf `find./* -maxdepth 0 -type d` >/dev/null 2>&1

function git_clone() {
    git clone --depth 1 $1 $2
    if [ "$?"!= 0 ]; then
        echo "error on $1"
        pid="$( ps -q $$ )"
        kill $pid
    fi
}

function git_sparse_clone() {
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1"; shift
    curl="$1"; shift
    rootdir="$PWD"
    tmpdir="$(mktemp -d)" || exit 1
    if [ ${#branch} -lt 10 ]; then
        git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
        cd "$tmpdir"
    else
        git clone --filter=blob:none --sparse "$curl" "$tmpdir"
        cd "$tmpdir"
        git checkout "$branch"
    fi
    if [ "$?"!= 0 ]; then
        echo "error on $curl"
        exit 1
    fi
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    mv -n $@ "$rootdir/" || true
    cd "$rootdir"
}

function mvdir() {
    mv -n `find $1/* -maxdepth 0 -type d`./
    rm -rf $1
}

git_clone https://github.com/xiaorouji/openwrt-passwall passwall && mv -n passwall/luci-app-passwall./; rm -rf passwall
git_clone https://github.com/xiaorouji/openwrt-passwall2 passwall2 && mv -n passwall2/luci-app-passwall2./; rm -rf passwall2
git clone https://github.com/kenzok8/small && rm -rf small/{luci-app-passwall,luci-app-passwall2} && mvdir small

git_sparse_clone main https://github.com/gdy666/luci-app-lucky luci-app-lucky lucky
# 更新 lede 分支
if [ "${1}" == "lede" ]; then
    git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-wechatpush luci-theme-argon luci-app-argon-config
    git_sparse_clone main https://github.com/kiddin9/kwrt-packages luci-app-quickstart quickstart luci-app-eqosplus luci-app-oaf open-app-filter oaf luci-app-wrtbwmon wrtbwmon luci-app-control-timewol luci-app-control-webrestriction luci-app-control-weburl
# 更新 openwrt 分支
elif [ "${1}" == "openwrt" ]; then
    git_sparse_clone master https://github.com/immortalwrt/immortalwrt package/emortal/default-settings
# 更新 immortalwrt 分支
elif [ "${1}" == "immortalwrt" ]; then
    echo "暂无"
fi
