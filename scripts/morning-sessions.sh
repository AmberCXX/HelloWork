#!/bin/bash
set -euo pipefail

HELLO_WORK_CONFIG="${HELLO_WORK_CONFIG:-$HOME/.config/hello-work/config.sh}"
# shellcheck source=/dev/null
[ -f "$HELLO_WORK_CONFIG" ] && source "$HELLO_WORK_CONFIG"

TODO_FILE="${HELLO_WORK_TODO_FILE:-$HOME/.config/hello-work/todos.md}"
STARTUP_SCRIPT="${HELLO_WORK_STARTUP_SCRIPT:-$HOME/scripts/session-startup.sh}"

get_todos() {
    python3 - "$TODO_FILE" << 'PYEOF'
import sys, re

with open(sys.argv[1]) as f:
    content = f.read()

todos = []
sections = re.findall(r'## (进行中|待启动)(.*?)(?=^##|\Z)', content, re.MULTILINE | re.DOTALL)
for _, body in sections:
    for line in body.strip().split('\n'):
        m = re.match(r'^- (.+)', line.strip())
        if m:
            text = re.split(r'[（(，,；;]', m.group(1))[0].strip()
            if text:
                todos.append(text[:25])

for t in todos:
    print(t)
PYEOF
}

get_open_sessions() {
    osascript << 'ASEOF' 2>/dev/null
tell application "iTerm2"
    set names to {}
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                set end of names to name of s
            end repeat
        end repeat
    end repeat
    return names
end tell
ASEOF
}

# Escape for AppleScript double-quoted string context
as_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

session_exists() {
    grep -qxF "$1" <<< "$2"
}

open_tab() {
    local name="$1" is_first="$2"
    local safe_name
    safe_name=$(as_escape "$name")

    local create_cmd
    if [ "$is_first" = "true" ]; then
        create_cmd="create window with default profile"
    else
        create_cmd="tell current window to create tab with default profile"
    fi

    osascript << EOF
tell application "iTerm2"
    activate
    $create_cmd
    tell current session of current window
        set name to "$safe_name"
        write text "bash '$safe_startup' '$safe_name'"
    end tell
end tell
EOF
}

if [ ! -f "$TODO_FILE" ]; then
    printf 'todo 文件不存在: %s\n请设置 HELLO_WORK_TODO_FILE 或在 %s/.config/hello-work/config.sh 中配置\n' "$TODO_FILE" "$HOME"
    exit 1
fi

todos=$(get_todos)
# Pre-process once; session_exists does a simple grep in the loop
open_sessions=$(get_open_sessions | tr ',' '\n' | sed 's/^ //;s/ $//')
# Hoist: STARTUP_SCRIPT is constant, no need to re-escape per call
safe_startup=$(as_escape "$STARTUP_SCRIPT")

if [ -z "$todos" ]; then
    session_exists "工作台" "$open_sessions" || open_tab "工作台" "true"
    exit 0
fi

first_opened=false
while IFS= read -r todo; do
    [ -z "$todo" ] && continue
    if session_exists "$todo" "$open_sessions"; then
        printf '跳过（已存在）：%s\n' "$todo"
        continue
    fi
    if [ "$first_opened" = "false" ]; then
        open_tab "$todo" "true"
        first_opened=true
    else
        open_tab "$todo" "false"
    fi
    sleep 0.3
done <<< "$todos"
