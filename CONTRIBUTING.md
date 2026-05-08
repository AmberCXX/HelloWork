# Contributing

## 本地开发

```bash
git clone <repo-url> hello-work
cd hello-work
bash install.sh
```

验证安装：

```bash
bash ~/scripts/morning-sessions.sh
```

## 修改脚本

脚本通过符号链接安装，直接编辑 `scripts/` 下的源文件即生效，无需重新安装。

## 测试

目前无自动化测试。手动验证：
1. `bash scripts/morning-sessions.sh` — 确认 iTerm2 打开正确数量的 tab
2. 在已有 tab 的情况下再次运行 — 确认不重复开
3. todo 文件为空时 — 确认打开「工作台」fallback tab

## 安全问题

请通过 [GitHub Security Advisory](https://github.com/ambercxx/hello-work/security/advisories/new) 报告，不要开 public issue。7 天内回复。
