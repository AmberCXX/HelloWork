#!/bin/bash
set -euo pipefail

HELLO_WORK_CONFIG="${HELLO_WORK_CONFIG:-$HOME/.config/hello-work/config.sh}"
# shellcheck source=/dev/null
[ -f "$HELLO_WORK_CONFIG" ] && source "$HELLO_WORK_CONFIG"

TODO_NAME="${1:-工作台}"
WORK_DIR="${HELLO_WORK_WORK_DIR:-$HOME}"
TODO_FILE="${HELLO_WORK_TODO_FILE:-$HOME/.config/hello-work/todos.md}"
GIT_REPOS="${HELLO_WORK_GIT_REPOS:-}"

printf '\033]0;%s\007' "$TODO_NAME"

# $'\033' produces a literal ESC, so printf '%s' and echo both render color correctly
c_cyan=$'\033[1;36m'; c_green=$'\033[32m'; c_red=$'\033[31m'
c_yellow=$'\033[33m'; c_gray=$'\033[90m'; c_reset=$'\033[0m'
line="${c_cyan}────────────────────────────────────${c_reset}"

printf '\n%s\n' "$line"
printf "  ${c_cyan}📋 %s${c_reset}\n" "$TODO_NAME"
printf "  ${c_gray}%s${c_reset}\n" "$(date '+%Y-%m-%d %H:%M')"
printf '%s\n' "$line"

fh_available=false
command -v fh > /dev/null 2>&1 && fh_available=true || true

if $fh_available; then
    if fh hub status > /dev/null 2>&1; then
        printf "  ${c_green}✅ forge-hub${c_reset}\n"
    else
        printf "  ${c_red}❌ forge-hub 未运行${c_reset}\n"
    fi
    if fh engine list > /dev/null 2>&1; then
        printf "  ${c_green}✅ forge-engine${c_reset}\n"
    else
        printf "  ${c_red}❌ forge-engine 未运行${c_reset}\n"
    fi
else
    printf "  ${c_gray}⚙️  forge-hub / forge-engine — 未安装 fh CLI${c_reset}\n"
fi

printf "  ${c_gray}⚙️  MCP servers — claude 启动后加载${c_reset}\n"

if [ -n "$GIT_REPOS" ]; then
    conflict_found=false
    for repo in $GIT_REPOS; do
        dir="$WORK_DIR/$repo"
        if [ -d "$dir/.git" ]; then
            conflicts=$(git -C "$dir" diff --name-only --diff-filter=U 2>/dev/null)
            if [ -n "$conflicts" ]; then
                printf "  ${c_yellow}⚠️  git 冲突: %s${c_reset}\n" "$(basename "$repo")"
                conflict_found=true
            fi
        fi
    done
    [ "$conflict_found" = false ] && printf "  ${c_green}✅ git 无冲突${c_reset}\n"
fi

if [ -f "$TODO_FILE" ]; then
    printf '\n'
    printf "  ${c_gray}待办：${c_reset}\n"
    python3 - "$TODO_FILE" << 'PYEOF'
import sys, re

with open(sys.argv[1]) as f:
    content = f.read()

sections = re.findall(r'## (进行中|待启动)(.*?)(?=^##|\Z)', content, re.MULTILINE | re.DOTALL)
for _, body in sections:
    for line in body.strip().split('\n'):
        m = re.match(r'^- (.+)', line.strip())
        if m:
            print(f"  \033[90m  • {m.group(1).strip()}\033[0m")
PYEOF
fi

printf '%s\n\n' "$line"

if [ ! -d "$WORK_DIR" ]; then
    printf "${c_red}⚠️  WORK_DIR 不存在: %s${c_reset}\n" "$WORK_DIR" >&2
    exit 1
fi
cd "$WORK_DIR"
exec claude
