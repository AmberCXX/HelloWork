# hello-work

每天定时根据 todo 列表自动打开多个命名 iTerm2 工作 session，每个 session 启动时显示服务状态和待办摘要。

## 功能

- 读取 Markdown todo 文件，为「进行中」和「待启动」的每条任务开一个 iTerm2 tab
- 已存在同名 tab 自动跳过，不重复开
- 每个 session 启动时展示：forge-hub 状态、forge-engine 状态、git 冲突检测、待办列表
- 通过 forge-engine 在指定时间自动触发（默认 04:00）

## 依赖

| 依赖 | 必须 | 安装方式 |
|------|------|----------|
| macOS | ✅ | — |
| iTerm2 | ✅ | `brew install --cask iterm2` |
| Claude Code CLI | ✅ | [claude.ai/code](https://claude.ai/code) |
| Python 3 | ✅ | macOS 自带；或 `brew install python3` |
| git | ✅ | `xcode-select --install` |
| forge-hub（`fh` CLI） | 可选 | 用于状态检查；无则跳过 |
| forge-engine | 可选 | 用于定时触发；无则手动运行 |

## 安装

```bash
git clone <repo-url> hello-work
cd hello-work
bash install.sh
```

自定义触发时间（如早上 9 点）：

```bash
bash install.sh --hour 9 --minute 0
```

## 配置

安装后编辑 `~/.config/hello-work/config.sh`：

```bash
# todo 文件路径（见下方「Todo 文件格式」）
HELLO_WORK_TODO_FILE="$HOME/.config/hello-work/todos.md"

# session 启动后进入的工作目录
HELLO_WORK_WORK_DIR="$HOME/projects"

# 检查 git 冲突的仓库（相对于 WORK_DIR，空格分隔）
HELLO_WORK_GIT_REPOS="my-app my-lib"
```

### Todo 文件格式

支持任意路径的 Markdown 文件，需包含以下结构：

```markdown
## 进行中
- 任务 A
- 任务 B（说明文字会被截断，只取括号前的部分）

## 待启动
- 任务 C

## 已完成
- 已完成任务（此节不会出现在 session 列表中）
```

使用 Claude Code auto-memory 文件时，路径格式为：

```
~/.claude/projects/<project-hash>/memory/project_pending_todos.md
```

## 手动运行

```bash
bash ~/scripts/morning-sessions.sh
```

## 工作原理

```
forge-engine (04:00)
    └── 触发 Claude 执行 morning-sessions.sh
            └── 读取 todo 文件
            └── 获取已开 iTerm2 session 列表
            └── 为每条未开的 todo 打开新 tab
                    └── 运行 session-startup.sh
                            └── 显示状态头（forge-hub / git / todo）
                            └── exec claude
```

## License

[MIT](LICENSE) — ambercxx
