# reset-zsh-and-install-starship

Reset a **user-level Zsh environment on Linux** to a near-fresh state, then install **Starship** and write a minimal, clean `.zshrc`.

This script is meant for people who want to:

- remove existing Zsh frameworks such as **Oh My Zsh** and **Zim**
- clear common user-level Zsh config files and completion caches
- keep a minimal but usable Zsh setup
- install **Starship** with its **default theme/config**

It does **not** modify system-level files such as `/etc/zshrc` or `/etc/zprofile`.

## What it does

The script:

1. Checks that you are on **Linux** and that `zsh` is installed.
2. Optionally backs up your current user-level Zsh files.
3. Removes common user-level Zsh config/framework files, including:
   - `~/.zshenv`
   - `~/.zprofile`
   - `~/.zshrc`
   - `~/.zlogin`
   - `~/.zlogout`
   - `~/.zimrc`
   - `~/.p10k.zsh`
   - `~/.zcompdump*`
   - `~/.zcompcache*`
   - `~/.oh-my-zsh/`
   - `~/.zim/`
   - `~/.config/starship.toml`
4. Writes a minimal `.zshrc`.
5. Installs **Starship** to `~/.local/bin` using the official installer.

## Resulting `.zshrc`

After running, the script writes this minimal Zsh config:

```zsh
autoload -Uz compinit
compinit

HISTFILE=$HOME/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY_TIME

## Online install

Run the script directly without downloading it first:

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash
```

This gives you:

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- -y
```

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- --purge-history
```

### Skip backups

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- --no-backup
```

### Fully non-interactive

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- --purge-history --no-backup -y
```

---

## Local usage

If you prefer to inspect the script first:

```bash
chmod +x reset-zsh-and-install-starship.sh
```

Run it:

```bash
./reset-zsh-and-install-starship.sh
```

### Optional flags

Remove Zsh history too:

```bash
./reset-zsh-and-install-starship.sh --purge-history
```

Skip backups:

```bash
./reset-zsh-and-install-starship.sh --no-backup
```

Skip the confirmation prompt:

```bash
./reset-zsh-and-install-starship.sh -y
```

Combine flags:

```bash
./reset-zsh-and-install-starship.sh --purge-history --no-backup -y
```

Show help:

```bash
./reset-zsh-and-install-starship.sh --help
```

## Backups

By default, removed files are moved into:

```text
~/.local/share/zsh-reset-backups/<timestamp>/
```

This lets you restore anything you still need later.

## Notes

- This script is intended for **Linux only**.
- It only resets **user-level** Zsh configuration.
- If your distro loads system-wide Zsh settings from `/etc/zsh*`, those will still apply.
- The script preserves `~/.zsh_history` unless you pass `--purge-history`.
- Starship is installed with its **default configuration**. Since `~/.config/starship.toml` is removed, Starship falls back to its built-in defaults.

## Requirements

- `zsh`
- either `curl` or `wget`
- internet access to download the Starship installer

## Why this script exists

Some Zsh setups become hard to reason about after trying multiple frameworks, themes, and plugins. This script gives you a reproducible way to get back to a clean, minimal setup while still ending up with a modern prompt.

## Disclaimer

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash
```

### 跳过确认

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- -y
```

### 连 Zsh 历史记录一起删除

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- --purge-history
```

### 不做备份

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- --no-backup
```

### 完全非交互执行

```bash
curl -fsSL https://raw.githubusercontent.com/dvpig/zclean-starship/main/reset-zsh-and-install-starship.sh | bash -s -- --purge-history --no-backup -y
```

---

## 本地使用

如果你想先下载并检查脚本内容，再执行：

```bash
chmod +x reset-zsh-and-install-starship.sh
./reset-zsh-and-install-starship.sh
```

### 更多示例

```bash
./reset-zsh-and-install-starship.sh --purge-history
./reset-zsh-and-install-starship.sh --no-backup -y
./reset-zsh-and-install-starship.sh --help
```

---

## 执行完成后

启动一个新的 Zsh 会话：

```bash
exec zsh
```

如果 Zsh 还不是你的默认 shell，可以执行：

```bash
chsh -s "$(command -v zsh)"
```

---

## 说明

- 这个脚本的目标是 **重置用户级 Zsh 环境**，不是整个系统级 shell 环境
- 删除前可以自动备份已有的用户配置文件
- 安装完 Starship 后会自动执行：

```bash
starship preset gruvbox-rainbow -o ~/.config/starship.toml
```

- 生成的 `.zshrc` 是刻意保持精简的最小配置

---

## 注意

该脚本会删除当前用户已有的 Zsh 配置文件和框架。  
如果你使用 `curl | bash` 远程执行，请先自行检查脚本内容。
