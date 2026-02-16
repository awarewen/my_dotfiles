#!/usr/bin/env bash

# DNS 测试脚本 - 测试不同 DNS 服务器对 1688.com 的解析速度

DOMAIN="www.1688.com"

# 定义要测试的 DNS 服务器（名称:IP）
declare -A DNS_SERVERS=(
    ["阿里DNS"]="223.5.5.5"
    ["腾讯DNS"]="119.29.29.29"
    ["114DNS"]="114.114.114.114"
    ["百度DNS"]="180.76.76.76"
    ["Cloudflare"]="1.1.1.1"
    ["Google"]="8.8.8.8"
    ["运营商默认"]=""  # 空值表示使用系统默认
)

echo "=========================================="
echo "DNS 服务器速度测试 - $DOMAIN"
echo "=========================================="
echo ""

# 测试函数
test_dns() {
    local dns_name="$1"
    local dns_ip="$2"
    local domain="$3"
    
    if [ -z "$dns_ip" ]; then
        # 使用系统默认 DNS
        echo "测试: $dns_name (系统默认)"
        result=$(dig +short +time=2 +tries=1 @"$dns_ip" "$domain" 2>/dev/null || dig +short +time=2 +tries=1 "$domain" 2>/dev/null)
    else
        echo "测试: $dns_name ($dns_ip)"
        result=$(dig +short +time=2 +tries=1 @"$dns_ip" "$domain" 2>/dev/null)
    fi
    
    if [ -z "$result" ]; then
        echo "  ❌ 解析失败或超时"
        echo ""
        return 1
    fi
    
    # 显示解析的 IP
    echo "  ✅ 解析结果: $result"
    
    # 测试解析速度（多次测试取平均）
    local total_time=0
    local success_count=0
    
    for i in {1..5}; do
        if [ -z "$dns_ip" ]; then
            time_output=$(dig +noall +stats +time=2 +tries=1 "$domain" 2>/dev/null | grep "Query time:" | awk '{print $4}')
        else
            time_output=$(dig +noall +stats +time=2 +tries=1 @"$dns_ip" "$domain" 2>/dev/null | grep "Query time:" | awk '{print $4}')
        fi
        
        if [ -n "$time_output" ] && [ "$time_output" != "0" ]; then
            total_time=$((total_time + time_output))
            success_count=$((success_count + 1))
        fi
    done
    
    if [ $success_count -gt 0 ]; then
        local avg_time=$((total_time / success_count))
        echo "  ⏱️  平均查询时间: ${avg_time}ms (成功 $success_count/5 次)"
    else
        echo "  ⚠️  无法测量查询时间"
    fi
    
    echo ""
}

# 遍历测试所有 DNS
for dns_name in "${!DNS_SERVERS[@]}"; do
    dns_ip="${DNS_SERVERS[$dns_name]}"
    test_dns "$dns_name" "$dns_ip" "$DOMAIN"
done

echo "=========================================="
echo "测试完成！"
echo ""
echo "推荐配置："
echo "1. 访问国内网站（如 1688.com）：优先使用 阿里DNS (223.5.5.5) 或 腾讯DNS (119.29.29.29)"
echo "2. 访问国外网站：使用 Cloudflare (1.1.1.1) 或 Google (8.8.8.8)"
echo "3. 混合使用：主 DNS 用国内，备用 DNS 用国外"
echo "=========================================="
