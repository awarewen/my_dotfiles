# Keybinds 与相关配置修改记录

供逐项检查所有修改。格式：**文件 → 修改说明**，必要时附修改前后内容。

---

## 1. 透明切换绑定不工作（O 键）

**文件：** `custom/keybinds.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 行号 | 约 72 行 | — |
| 内容 | `bind = , O, execr, $SETP activewindow opaque toggle && $RESET_MAP` | `bind = , O, execr, $DISP setprop active opaque toggle && $RESET_MAP` |

**原因：** Hyprland 0.53.x+ 中 `setprop` 需通过 `dispatch` 调用，且选择器应为 `active` 而非 `activewindow`。

**你可检查：** 进入 WindowAction（Super+W）后按 **O**，当前窗口应在透明/不透明之间切换。

---

## 2. 全屏绑定注释乱码

**文件：** `custom/keybinds.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 行号 | 约 66 行 | — |
| 注释 | `# [hidden] <F> : 全屏窗口切换（保留间隙）yprctl keyword "general:col.active_border rgb(c77eb5) rgb(45475a)"` | `# [hidden] <F> : 全屏窗口切换（保留间隙）` |

**原因：** 注释中混入多余内容，仅做清理。

---

## 3. Resize 子映射中 H 键语法统一

**文件：** `custom/keybinds.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 行号 | 约 183–184 行 | — |
| 第一行 | `binde = , H, execr, $DISP resizeactive 20 0 && $DISP moveactive -20 0` | `binde = , H, execr, $DISP resizeactive, 20 0 && $DISP moveactive -20 0` |
| 第二行 | （已是 `resizeactive, 20 0`） | 未改 |

**原因：** `resizeactive` 通过 dispatch 调用时建议用逗号分隔参数，与同块其他 bind 一致。

**你可检查：** Super+R 进入 resize 后，按 **H** 应向左扩展窗口，行为与之前一致。

---

## 4. 未定义变量 $WLOGOUT

**文件：** `custom/env.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 位置 | `# SCREEN_LOCK` 小节下无 `$WLOGOUT` | 在该小节下新增两行 |
| 新增内容 | — | `$WLOGOUT = wlogout --protocol layer-shell  # 登出/关机菜单 [keybind: WindowAction 内 Super+Q]` |

**原因：** keybinds 中 `bind = $MAIN_MOD, Q, execr, $WLOGOUT` 依赖此变量，未定义时该绑定无效。

**你可检查：** 在 WindowAction（Super+W）下按 **Super+Q**，应弹出 wlogout 菜单（需已安装 wlogout）。

---

## 5. WindowsGroup 中重复的 T 绑定

**文件：** `custom/keybinds.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 行号 | 约 132–133 行 | — |
| 内容 | 两行相同：`bind = , T, togglefloating,` 与 `bind = , T, togglefloating, # [hidden] <T>: 合并窗口入组` | 合并为一行：`bind = , T, togglefloating, # [hidden] <T>: 切换浮动` |

**原因：** 同一 submap 下同一按键重复绑定会触发两次，按一次 T 会“切换→再切换”回到原状态。

**你可检查：** 在 WindowsGroup（Super+G）下按 **T**，应只切换一次浮动状态。

---

## 6. WindowsGroup 注释 H/L 方向写反

**文件：** `custom/keybinds.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 行号 | 约 137–138 行 | — |
| 注释 | `<H>: Right`、`<L>: Left` | `<H>: Left`、`<L>: Right` |

**原因：** H 绑定为 `movefocus l`（左），L 为 `movefocus r`（右），注释与真实方向一致。

---

## 7. WindowsGroup 中 P 键注释错误

**文件：** `custom/keybinds.conf`

| 项目 | 修改前 | 修改后 |
|------|--------|--------|
| 行号 | 约 142 行 | — |
| 注释 | `# [hidden] <J>: Prev` | `# [hidden] <P>: Prev` |

**原因：** 该 bind 是 `bind = , P, cyclenext, prev`，对应按键为 P 而非 J。

---

## 修改项汇总表

| # | 文件 | 类型 | 简要说明 |
|---|------|------|----------|
| 1 | custom/keybinds.conf | 绑定修复 | O 键透明切换改用 `$DISP setprop active opaque toggle` |
| 2 | custom/keybinds.conf | 注释清理 | 全屏 F 键注释去掉乱码 |
| 3 | custom/keybinds.conf | 语法统一 | resize 子映射 H 键 `resizeactive, 20 0` 加逗号 |
| 4 | custom/env.conf | 变量新增 | 定义 `$WLOGOUT` |
| 5 | custom/keybinds.conf | 重复绑定删除 | WindowsGroup 中 T 只保留一条 |
| 6 | custom/keybinds.conf | 注释修正 | WindowsGroup H/L 方向注释 |
| 7 | custom/keybinds.conf | 注释修正 | WindowsGroup P 键注释 J→P |

---

**检查建议：** 修改后执行 `hyprctl reload`，再按上表逐项试用对应按键。若某条不符合预期，可根据行号在文件中定位并回退或再改。
