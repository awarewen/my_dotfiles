# ZSH_profiles
这是我的个人 `$ZDOTDIR`，如果需要使用请先备份好你的现有相关配置
This is my personal `$ZDOTDIR`, If you want to USE THIS DOT is a good idea to `backup your existing conf-files` first. Emjoy :)

# Directory Path

使用 [ZI](https://github.com/z-shell/zi) 插件管理器
- 安装目录 `${ZI[CONFIG_DIR]}`：
    `$HOME/.local/share/zi`

主要目录结构 [SixArm/zsh-config](https://github.com/SixArm/zsh-config)
- Zsh 以及 ZI、plugin 相关配置目录 `${ZDORDIR}`:
    `$HOME/.config/zsh`

# How to use
请先备份旧配置，再进行迁移！

1. 创建 `$HOME/.zshenv` 文件
- 不建议使用 `XDG_COFNIG_DIR` 的[原因](https://www.reddit.com/r/zsh/comments/qtehjs/comment/hkkpzyi/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)

`$HOME/.zshenv` 用于设置 `ZDOTDIR` 指定在单独的自定义文件夹中管理 Zsh 相关配置

- `$HOME/.zshenv`
```
# `ZDOTDIR` zsh shell config dir
ZDOTDIR="${HOME}/.config/zsh"
source -- "${ZDOTDIR}/.zshenv"

```

2. 将配置拉取到 `$HOME/.config/`
`git clone git@github.com:awarewen/zsh.d.git $HOME/.config/zsh`

3. 重启终端，插件管理器应该开始自动安装插件

# ZI 插件 `zoxide` Jump Histpath 功能 依赖于独立的二进制可执行程序 [zoxide](https://github.com/ajeetdsouza/zoxide)
`yay -S zoxide`

使用方法：
```
cd xxx      # zoxide 会将 cd 进入的目录添加到 Jump Histpath List 中
xi          # 通过直接输入 xi 调用程序模糊搜索
```
