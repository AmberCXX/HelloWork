#!/bin/bash
# hello-work 安装脚本
# 用法：bash install.sh [--hour H] [--minute M]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_INSTALL_DIR="$HOME/scripts"
CONFIG_DIR="$HOME/.config/hello-work"
ENGINE_DIR="$HOME/.forge-hub/engine-data/engine.d"

HOUR=4
MINUTE=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --hour)   HOUR="$2";   shift 2 ;;
        --minute) MINUTE="$2"; shift 2 ;;
        *) echo "未知参数: $1"; exit 1 ;;
    esac
done

echo "=== hello-work 安装 ==="
echo ""

# 1. 检查依赖
echo "检查依赖..."
missing=()

if ! command -v python3 > /dev/null 2>&1; then
    missing+=("python3（macOS 自带，或通过 Homebrew 安装：brew install python3）")
fi
if ! command -v git > /dev/null 2>&1; then
    missing+=("git（xcode-select --install）")
fi
if ! command -v osascript > /dev/null 2>&1; then
    missing+=("osascript（仅支持 macOS）")
fi
if ! command -v claude > /dev/null 2>&1; then
    missing+=("claude CLI（https://claude.ai/code）")
fi
if ! [ -d "/Applications/iTerm.app" ]; then
    missing+=("iTerm2（brew install --cask iterm2）")
fi

if [ ${#missing[@]} -gt 0 ]; then
    echo "缺少以下依赖，请先安装："
    for dep in "${missing[@]}"; do
        echo "  ✗ $dep"
    done
    exit 1
fi
echo "  ✅ 依赖检查通过"

# 2. 安装脚本到 ~/scripts/
echo ""
echo "安装脚本..."
mkdir -p "$SCRIPTS_INSTALL_DIR"
ln -sf "$REPO_DIR/scripts/morning-sessions.sh" "$SCRIPTS_INSTALL_DIR/morning-sessions.sh"
ln -sf "$REPO_DIR/scripts/session-startup.sh"  "$SCRIPTS_INSTALL_DIR/session-startup.sh"
chmod +x "$REPO_DIR/scripts/morning-sessions.sh" "$REPO_DIR/scripts/session-startup.sh"
echo "  ✅ $SCRIPTS_INSTALL_DIR/morning-sessions.sh"
echo "  ✅ $SCRIPTS_INSTALL_DIR/session-startup.sh"

# 3. 初始化配置文件
echo ""
echo "初始化配置..."
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config.sh" ]; then
    cp "$REPO_DIR/config.example.sh" "$CONFIG_DIR/config.sh"
    echo "  ✅ 配置文件已创建：$CONFIG_DIR/config.sh"
    echo "  ⚠️  请编辑配置文件，至少设置 HELLO_WORK_TODO_FILE"
else
    echo "  ℹ️  配置文件已存在，跳过：$CONFIG_DIR/config.sh"
fi

# 4. 创建 todo 示例文件（如果不存在）
if [ ! -f "$CONFIG_DIR/todos.md" ]; then
    cat > "$CONFIG_DIR/todos.md" << 'EOF'
# 待办事项

## 进行中
<!-- 正在推进的事项 -->

## 待启动
- 示例任务（替换成你的实际待办）

## 已完成
<!-- 已完成事项 -->
EOF
    echo "  ✅ 示例 todo 文件：$CONFIG_DIR/todos.md"
fi

# 5. 安装 forge-engine 任务（可选）
echo ""
if [ -d "$ENGINE_DIR" ]; then
    echo "安装 forge-engine 定时任务..."
    sed \
        -e "s|{{HOUR}}|$HOUR|g" \
        -e "s|{{MINUTE}}|$MINUTE|g" \
        -e "s|{{SCRIPTS_DIR}}|$SCRIPTS_INSTALL_DIR|g" \
        "$REPO_DIR/engine.d/morning-sessions.json.template" \
        > "$ENGINE_DIR/morning-sessions.json"
    echo "  ✅ forge-engine 任务已安装（每天 ${HOUR}:$(printf '%02d' $MINUTE)）"
else
    echo "  ℹ️  未检测到 forge-engine（$ENGINE_DIR 不存在），跳过定时任务安装"
    echo "  如需定时触发，手动复制并填写 engine.d/morning-sessions.json.template"
fi

echo ""
echo "=== 安装完成 ==="
echo ""
echo "后续步骤："
echo "  1. 编辑配置：open $CONFIG_DIR/config.sh"
echo "  2. 手动测试：bash $SCRIPTS_INSTALL_DIR/morning-sessions.sh"
echo "  3. 定时触发：forge-engine 将在每天 ${HOUR}:$(printf '%02d' $MINUTE) 自动启动 sessions"
