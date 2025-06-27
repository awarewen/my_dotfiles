#!/usr/bin/env bash
set -euo pipefail

###############################################
# 配置常量
###############################################
readonly GEO_DIR="/usr/local/share/dae"
readonly GEO_FILES=(
    "${GEO_DIR}/geoip.dat"
    "${GEO_DIR}/geosite.dat"
)
readonly URL_PREFIX_GITHUB="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download"
readonly URL_PREFIX_CDN="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release"

###############################################
# Log
###############################################
log() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] ${message}" >&2
}

log_error() {
    log "ERROR: $1"
}

log_success() {
    log "SUCCESS: $1"
}

###############################################
# 创建临时文件
###############################################
create_temp_file() {
    local target="$1"
    local dir_path
    local tmp_file

    dir_path=$(dirname "$target")

    # 确保目录存在
    mkdir -p "${dir_path}" || {
        log_error "Failed to create directory: ${dir_path}"
        return 1
    }

    # 创建临时文件
    tmp_file=$(mktemp -p "${dir_path}" "geo_XXXXXX.dat" 2>/dev/null)
    if [[ -z "${tmp_file}" || ! -f "${tmp_file}" ]]; then
        log_error "Failed to create temp file for ${target##*/}"
        return 1
    fi
    
    echo "${tmp_file}"
}

###############################################
# 下载文件到临时位置
###############################################
download_to_temp() {
    local url="$1"
    local tmp_file="$2"
    
    curl -fsSL \
        --connect-timeout 30 \
        --retry 3 \
        --max-time 300 \
        -o "${tmp_file}" \
        "${url}" || {
        log_error "Download failed for ${url}"
        return 1
    }
    
    # 验证下载内容非空
    if [ ! -s "${tmp_file}" ]; then
        log_error "Downloaded file is empty: ${url}"
        return 1
    fi
}

###############################################
# 安全替换目标文件
###############################################
safe_replace_target() {
    local tmp_file="$1"
    local target_file="$2"
    
    # 原子性覆盖
    if mv -f "${tmp_file}" "${target_file}"; then
        # 设置安全权限
        chmod 644 "${target_file}"
        log_success "Updated ${target_file##*/}"
        return 0
    else
        log_error "Failed to overwrite ${target_file##*/}"
        return 1
    fi
}

###############################################
# 处理单个文件下载
###############################################
process_geo_file() {
    local target_file="$1"
    local base_url="$2"
    local file_name
    local tmp_file
    local status=0

    file_name=$(basename "${target_file}")
    log "Processing ${file_name}..."

    # 获取临时文件路径
    tmp_file=$(create_temp_file "${target_file}") || {
        log_error "Temp file creation failed for ${file_name}"
        return 1
    }

    # 下载文件
    if ! download_to_temp "${base_url}/${file_name}" "${tmp_file}"; then
        status=1
    fi
    
    # 替换目标文件（仅在下载成功时尝试）
    if [[ ${status} -eq 0 ]]; then
        if ! safe_replace_target "${tmp_file}" "${target_file}"; then
            status=1
        fi
    fi
    
    # 清理临时文件（如果存在）
    if [[ -n "${tmp_file}" && -f "${tmp_file}" ]]; then
        # 仅在替换失败时删除临时文件（成功时文件已被移动）
        if [[ ${status} -ne 0 ]]; then
            rm -f "${tmp_file}"
            log "Cleaned up temporary file"
        fi
    fi
    
    return ${status}
}

###############################################
# 选择下载源
###############################################
select_download_source() {
    if pgrep -x dae >/dev/null 2>&1; then
        echo "${URL_PREFIX_GITHUB}"
        log "Using GitHub source"
    else
        echo "${URL_PREFIX_CDN}"
        log "Using CDN source"
    fi
}

###############################################
# 主函数
###############################################
main() {
    local base_url
    local success_count=0
    local failure_count=0
    
    # 选择下载源
    base_url=$(select_download_source)
    
    log "Starting geo data update with URL: ${base_url}"
    
    # 处理所有文件
    for target_file in "${GEO_FILES[@]}"; do
        if process_geo_file "${target_file}" "${base_url}"; then
            success_count=$((success_count+1))
        else
            failure_count=$((failure_count+1))
        fi
    done
    
    # 汇总结果
    log "Update completed. Success: ${success_count}, Failed: ${failure_count}"
    
    # 如果有失败则返回非0状态码
    [ "${failure_count}" -gt 0 ] && return 1
    return 0
}

# 执行主函数
main

# systemctl restart dae
