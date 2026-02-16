# 动画配置修改记录

供逐项检查所有修改。格式：**文件 → 修改说明**，必要时附修改前后内容。

---

## TOP

**修改概要**

| 项目 | 说明 |
|------|------|
| 目的 | 将动画配置独立为 `custom/animations.conf`，并采用优化后的曲线与时长，使动效更丝滑。 |
| 涉及文件 | `custom/animations.conf`（新建）、`hyprland.conf`（新增 source）。 |

**文档生成**

- 由 **Cursor** 根据对话中的动画优化与独立配置结果整理生成。  
- 日期：**2026-02-16**。

---

## 1. 新建动画专用配置

**文件：** `custom/animations.conf`（新建）

**内容：** 完整的 `animations { ... }` 块，包括：

- **曲线：** 新增 `smoothIn`、`smoothOut`，保留原有 expressive/emphasized/menu/stall 等曲线。
- **窗口：** windowsIn/Out、fadeIn/Out、windowsMove、border 使用 smooth 曲线，时长微调（如 border 10→5，workspaces 7→5）。
- **图层：** layersIn/Out、fadeLayersIn/Out 时长与曲线统一。
- **工作区：** workspaces、specialWorkspaceIn/Out 使用 smoothOut/emphasizedAccel，时长略缩短。
- **缩放：** zoomFactor 时长 3→4。

**原因：** 动画单独成文件便于维护与版本对比；优化曲线与时长可提升观感丝滑度。

**你可检查：** 重载配置（`hyprctl reload`）后，开/关窗口、切换工作区、焦点移动时边框与过渡应更顺滑。

---

## 2. 主配置中引入动画文件

**文件：** `hyprland.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 位置 | Custom 段，`source=custom/general.conf` 下一行 | 在 `custom/general.conf` 与 `custom/rules.conf` 之间新增一行 |
| 内容 | — | `source=custom/animations.conf` |

**原因：** 主配置需显式 source 才能加载 `custom/animations.conf`；放在 general 之后、rules 之前，保证覆盖 `hyprland/general.conf` 中的默认 animations。

**你可检查：** 修改后执行 `hyprctl reload`，若存在语法错误会提示；无报错则动画配置已生效。

---

## 修改项汇总表

| # | 文件 | 类型 | 简要说明 |
|---|------|------|----------|
| 1 | custom/animations.conf | 新建 | 独立动画配置，丝滑曲线与时长优化 |
| 2 | hyprland.conf | source 新增 | 在 Custom 段增加 `source=custom/animations.conf` |

---

**检查建议：** 修改后执行 `hyprctl reload`，依次测试：打开/关闭窗口、切换工作区、移动焦点观察边框动画、打开/关闭层（如面板、锁屏）。若需回退，可注释掉 `hyprland.conf` 中该 source 行，并删除或重命名 `custom/animations.conf`。
