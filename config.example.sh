#!/bin/bash
# hello-work 配置文件
# 复制到 ~/.config/hello-work/config.sh 并按需修改

# todo 文件路径（Markdown，需含「进行中」和「待启动」两级标题）
# 使用 Claude Code auto-memory 文件时，路径格式为：
#   $HOME/.claude/projects/<project-hash>/memory/project_pending_todos.md
HELLO_WORK_TODO_FILE="$HOME/.config/hello-work/todos.md"

# session 启动后 cd 进入的工作目录
HELLO_WORK_WORK_DIR="$HOME"

# session-startup.sh 安装路径
HELLO_WORK_STARTUP_SCRIPT="$HOME/scripts/session-startup.sh"

# 需要检查 git 冲突的仓库（相对于 HELLO_WORK_WORK_DIR 的路径，空格分隔）
HELLO_WORK_GIT_REPOS=""
# 示例：
# HELLO_WORK_GIT_REPOS="projects/my-app projects/my-lib"
