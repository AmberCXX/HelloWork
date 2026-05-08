# hello-work

每日自动启动多个命名 Claude Code session 的工具。

## 结构

```
scripts/
  morning-sessions.sh   # 主入口：读 todo → 开 iTerm2 tabs
  session-startup.sh    # 每个 tab 内运行：状态检查 → exec claude
engine.d/
  morning-sessions.json.template  # forge-engine 定时任务模板
config.example.sh       # 配置文件模板
install.sh              # 安装脚本
```

## 安装路径（安装后）

| 文件 | 位置 |
|------|------|
| 主脚本（符号链接） | `~/scripts/morning-sessions.sh` |
| 启动脚本（符号链接） | `~/scripts/session-startup.sh` |
| 配置文件 | `~/.config/hello-work/config.sh` |
| forge-engine 任务 | `~/.forge-hub/engine-data/engine.d/morning-sessions.json` |

## 改动注意

- 修改 `scripts/` 下文件直接生效（符号链接）
- 修改触发时间：重新运行 `bash install.sh --hour H --minute M`
- 修改 todo 文件路径：编辑 `~/.config/hello-work/config.sh`
