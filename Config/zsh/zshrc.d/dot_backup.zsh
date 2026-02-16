################################################################################
# backup.zsh — 将 ~/.config 同步到 dotfiles 仓库（Config）的封装命令
#
# 功能：
#   - 提供 backup 命令，使用 rsync + 排除列表同步配置，便于扩展和维护
# 依赖：
#   - rsync
#   - 排除列表：$HOME/Documents/my_dotfiles/rsync-exclude-config.txt
# 用法：
#   dot_backup           # 默认仅试运行（rsync -n），不写入目标
#   dot_backup --run     # 真实执行同步（会 --delete）
#   dot_backup --dry     # 仅试运行（与默认相同）
#
# 扩展：
#   - 修改下方 BACKUP_EXCLUDE_FILE / BACKUP_SRC / BACKUP_DST 可改路径
#   - 在 _backup_rsync_opts 中追加 rsync 选项即可扩展行为
################################################################################

# 排除列表与路径（可按需修改）
readonly BACKUP_EXCLUDE_FILE="${HOME}/Documents/my_dotfiles/rsync-exclude-config.txt"
readonly BACKUP_SRC="${HOME}/.config/"
readonly BACKUP_DST="${HOME}/Documents/my_dotfiles/Config/"

# 默认 rsync 选项：归档、硬链接、保留属性、压缩、详细、增量
# 使用 --delete 时目标会与源保持一致（源因排除而未同步的，目标会被删除）
_backup_rsync_opts=(-aHOxzvi --delete)

# 若存在排除列表则加入
[[ -f "$BACKUP_EXCLUDE_FILE" ]] && _backup_rsync_opts+=(--exclude-from="$BACKUP_EXCLUDE_FILE")

function dot_backup() {
  local do_run=0
  case "${1:-}" in
    --run)  do_run=1 ;;
    --dry)  do_run=0 ;;
    -h|--help)
      echo "usage: backup [--run|--dry]"
      echo "  --run  执行同步（会 --delete）"
      echo "  --dry  仅试运行，不写入目标（默认）"
      return 0
      ;;
  esac

  if [[ ! -d "$BACKUP_SRC" ]]; then
    echo "backup: 源目录不存在: $BACKUP_SRC" >&2
    return 1
  fi
  if [[ ! -f "$BACKUP_EXCLUDE_FILE" ]]; then
    echo "backup: 排除列表不存在: $BACKUP_EXCLUDE_FILE" >&2
    return 1
  fi

  if (( do_run )); then
    rsync "${_backup_rsync_opts[@]}" "$BACKUP_SRC" "$BACKUP_DST"
  else
    rsync -n "${_backup_rsync_opts[@]}" "$BACKUP_SRC" "$BACKUP_DST"
  fi
}
