# homebrew-unsigned-tap

恢复并自动更新所有因 macOS Gatekeeper 限制而被官方禁用的 Homebrew Cask 软件（`fails_gatekeeper_check`），安装时自动解除隔离属性。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/thedavidweng/homebrew-unsigned-tap/main/scripts/migrate.sh)"
```

[English](README.md) · [简体中文](README.zh-CN.md)

运行上方命令即可：
* 自动添加本 Tap：`thedavidweng/unsigned-tap`
* 自动接管已安装的被禁用软件（`darktable`, `makemkv`, `xld`, `chromium`, `alacritty` 等）
* 移除隔离属性，恢复日常 `brew upgrade --cask --greedy` 自动升级

*(可选参数：`--dry-run` 预览、`--yes` 静默执行、`--interactive` 逐个确认)*

---

## 单个软件安装

```bash
brew tap thedavidweng/unsigned-tap
brew install --cask <软件名>

# 或接管已安装的软件：
brew reinstall --cask thedavidweng/unsigned-tap/<软件名>
```

## 为什么需要本仓库 (Why)

官方 Homebrew 禁用了未通过 macOS Gatekeeper 检查的未签名开源软件：

```text
Warning: Not upgrading <cask>, it is disabled because it does not pass the macOS Gatekeeper check!
```

本仓库恢复这些软件的正常安装与升级，并在安装时自动清除隔离限制（`xattr -d com.apple.quarantine`），每晚自动同步上游最新版本。

## 支持的热门软件

`darktable` · `makemkv` · `xld` · `chromium` · `alacritty` · `qbittorrent` · `wine-stable` · `zenmap` · `gstreamer-runtime`

检索所有软件：
```bash
brew search thedavidweng/unsigned-tap/
```

## 安全提示

本仓库在安装时会自动移除隔离属性。软件本身未经 Apple 公证签名，请确认软件来源并自行评估风险。

## 开源协议

[BSD-2-Clause](LICENSE)
