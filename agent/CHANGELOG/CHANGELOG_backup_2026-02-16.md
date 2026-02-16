# Changelog — my_dotfiles

记录本仓库与 dotfiles 备份相关的修改，便于后续管理。

---

## 2026-02-16 备份方式调整与 backup 命令

### 概要

- 备份目标统一为 **Config**（`~/Documents/my_dotfiles/Config/`），与 README 一致。
- 新增 **rsync 排除列表**，避免同步大体积/缓存/敏感目录，便于管理和版本控制。
- 新增 **backup 命令**（zsh 函数），封装 rsync，默认试运行，支持 `backup --run` 执行真实同步。
- **rsync 命令** 同步记录于下方，便于复制或脚本化。

---

### 1. 新增 rsync 排除列表

| 项目 | 说明 |
|------|------|
| 文件 | `rsync-exclude-config.txt`（仓库根目录） |
| 用途 | `rsync --exclude-from=本文件` 时排除大体积应用、缓存、node_modules、.git 等 |
| 同步方向 | `~/.config/` → `~/Documents/my_dotfiles/Config/` |

排除类别概览：

- 大体积/应用数据：`QQ/`、`discord/`、`chromium/`、`music-you/`、`cef_user_data/`、`obsidian/` 等
- 缓存与运行时：`*Cache*/`、`*Session Storage/`、`*Local Storage/`、`*leveldb/`、`*logs/` 等
- 可重建：`node_modules/`、`.git/`、`*.lock`
- 会话/临时：`ibus/bus/`、`session/` 等

---

### 2. rsync 命令（同步记录）

备份 **~/.config** 到 **Config** 时使用的完整命令（与 backup 函数行为一致）：

```bash
rsync -aHOxzvi --delete \
  --exclude-from="$HOME/Documents/my_dotfiles/rsync-exclude-config.txt" \
  ~/.config/ \
  ~/Documents/my_dotfiles/Config/
```

- **-a** 归档；**-H** 硬链接；**-O** 不跨文件系统保留目录；**-x** 不跨文件系统；**-z** 压缩；**-v** 详细；**-i** 列出变更。
- **--delete**：目标与源保持一致（被排除的目录在目标中会被删除；若不想删除目标多余内容，可去掉 `--delete`）。
- 仅试运行（不写目标）时，在命令中加上 **-n**，例如：  
  `rsync -n -aHOxzvi --delete --exclude-from=... ~/.config/ ~/Documents/my_dotfiles/Config/`

---

### 3. Zsh：backup 命令与 .zshrc

| 项目 | 说明 |
|------|------|
| 新增文件 | `~/.config/zsh/zshrc.d/backup.zsh` |
| 修改文件 | `~/.config/zsh/.zshrc`（末尾增加 source 与注释） |

**backup.zsh**

- 定义 **backup** 函数，封装上述 rsync 逻辑。
- 路径与排除列表通过变量配置（`BACKUP_SRC`、`BACKUP_DST`、`BACKUP_EXCLUDE_FILE`），便于修改和扩展。
- 文件内注释说明用途、依赖、用法与扩展方式。

**用法**

- `backup` 或 `backup --dry`：试运行（rsync -n），不写入目标。
- `backup --run`：执行真实同步（带 --delete）。
- `backup -h` / `backup --help`：简短帮助。

**.zshrc 末尾新增**

- 若存在 `${ZDOTDIR}/zshrc.d/backup.zsh` 则 source，并附一行注释说明 backup 命令及 `backup --run` 用于执行同步。

---

### 4. 修改项汇总

| # | 位置 | 类型 | 说明 |
|---|------|------|------|
| 1 | my_dotfiles/rsync-exclude-config.txt | 新建 | rsync 排除列表 |
| 2 | my_dotfiles/CHANGELOG/CHANGELOG_backup_2026-02-16.md | 新建 | 本 changelog，含 rsync 命令与操作记录 |
| 3 | ~/.config/zsh/zshrc.d/backup.zsh | 新建 | backup 函数及注释 |
| 4 | ~/.config/zsh/.zshrc | 修改 | 末尾 source backup.zsh 与注释 |

---

**后续**：若调整排除规则，可编辑 `rsync-exclude-config.txt`；若更改路径或 rsync 选项，可改 `backup.zsh` 中变量与 `_backup_rsync_opts`，并可将变更继续记录在 `CHANGELOG/` 目录下同名或新日期文件中。
