# Security Policy

## 信任模型

本工具运行在本机，通过 AppleScript 控制 iTerm2，读取本地文件。不发起网络请求，不存储凭证。

主要风险面：
- **Todo 文件路径**：配置指向的 Markdown 文件由本机读取，不外传
- **脚本执行**：`morning-sessions.sh` 由 forge-engine 触发，执行权限等同当前用户

## 报告漏洞

通过 [GitHub Security Advisory](https://github.com/ambercxx/hello-work/security/advisories/new) 私下报告。

响应承诺：7 天内确认，30 天内修复（严重问题优先）。
