#!/bin/bash

# 端口扫描脚本
# 用法: ./port_scan.sh <IP地址> [端口范围]

IP="$1"
PORT_RANGE="${2:-1-1000}"

if [ -z "$IP" ]; then
    echo "用法: $0 <IP地址> [端口范围]"
    echo "示例: $0 183.13.21.63"
    echo "示例: $0 183.13.21.63 1-1000"
    exit 1
fi

echo "正在扫描 $IP 的端口范围: $PORT_RANGE"
echo "=================================="

# 检查是否安装了nmap
if command -v nmap &> /dev/null; then
    echo "使用 nmap 进行扫描..."
    nmap -p "$PORT_RANGE" "$IP" | grep -E "(open|filtered|closed)" | while read line; do
        if echo "$line" | grep -q "open"; then
            port=$(echo "$line" | awk '{print $1}' | cut -d'/' -f1)
            protocol=$(echo "$line" | awk '{print $1}' | cut -d'/' -f2)
            service=$(echo "$line" | awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}')
            echo "✅ 端口 $port/$protocol 开放 - $service"
        fi
    done
elif command -v nc &> /dev/null; then
    echo "使用 netcat 进行扫描..."
    start_port=$(echo "$PORT_RANGE" | cut -d'-' -f1)
    end_port=$(echo "$PORT_RANGE" | cut -d'-' -f2)
    
    for port in $(seq "$start_port" "$end_port"); do
        if timeout 1 nc -z "$IP" "$port" 2>/dev/null; then
            echo "✅ 端口 $port 开放"
        fi
    done
else
    echo "错误: 需要安装 nmap 或 netcat (nc) 才能进行端口扫描"
    echo "安装命令:"
    echo "  Arch Linux: sudo pacman -S nmap"
    echo "  Ubuntu/Debian: sudo apt install nmap"
    exit 1
fi

echo "=================================="
echo "扫描完成"