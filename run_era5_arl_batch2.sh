#!/bin/bash

# 起止日期
start="2016-01-01"
end="2023-12-31"

current="$start"

while [ "$(date -d "$current" +%s)" -le "$(date -d "$end" +%s)" ]; do
    year=$(date -d "$current" +%Y)
    month=$(date -d "$current" +%m)   # 例如 01, 02, ..., 12
    day=$(date -d "$current" +%d)     # 例如 01, 02, ..., 31
    monthname=$(date -d "$current" +%b)  # Jan, Feb, Mar, ... Dec

    echo "============================================================"
    echo "Processing date: $current  (year=$year month=$month day=$day mon=$monthname)"
    echo "============================================================"

    # 如果 get_era5data4hysplit.sh 在当前目录，用下面这一行
    ./get_era5data4hysplit.sh "$year" "$month" "$day" "$monthname"

    # 如果脚本不在当前目录，就用绝对路径，例如：
    # /home/aaadebiyi/myshell/hysplit/data2arl/get_era5data4hysplit_US.sh "$year" "$month" "$day" "$monthname"

    # 日期 +1 天
    current=$(date -d "$current +1 day" +%F)
done

