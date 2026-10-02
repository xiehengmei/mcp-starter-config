#!/usr/bin/env bash
# 把 MCP 服务器注册进客户端。默认 Claude Code。
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$PWD}"
set -a; [ -f .env ] && . ./.env; set +a

CLIENT="${1:-claude-code}"

case "$CLIENT" in
  claude-code)
    command -v claude >/dev/null 2>&1 || { echo "未找到 claude CLI"; exit 1; }

    # 零 key 类
    claude mcp add --scope user context7          -- npx -y @upstash/context7-mcp
    claude mcp add --scope user playwright         -- npx -y @playwright/mcp@latest
    claude mcp add --scope user chrome-devtools    -- npx -y chrome-devtools-mcp@latest
    claude mcp add --scope user memory             -- npx -y @modelcontextprotocol/server-memory
    claude mcp add --scope user sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
    claude mcp add --scope user filesystem         -- npx -y @modelcontextprotocol/server-filesystem "$PROJECT_DIR"
    claude mcp add --scope user git                -- uvx mcp-server-git --repository "$PROJECT_DIR"
    claude mcp add --scope user fetch              -- uvx mcp-server-fetch
    claude mcp add --scope user time               -- uvx mcp-server-time
    claude mcp add --scope user serena            -- serena start-mcp-server --context=ide

    # 需要 key 类（-e 传环境变量名，实际值从 shell 取）
    [ -n "${BRAVE_API_KEY:-}" ]     && claude mcp add --scope user -e BRAVE_API_KEY brave-search -- npx -y @brave/brave-search-mcp-server --transport stdio
    [ -n "${FIRECRAWL_API_KEY:-}" ] && claude mcp add --scope user -e FIRECRAWL_API_KEY firecrawl -- npx -y firecrawl-mcp

    # GitHub：本地 Docker + PAT，只开读，避免 agent 误写
    if [ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
      claude mcp add --scope user -e GITHUB_PERSONAL_ACCESS_TOKEN github -- \
        docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN -e GITHUB_READ_ONLY=1 \
        ghcr.io/github/github-mcp-server
    fi

    claude mcp list
    ;;

  codex)
    command -v codex >/dev/null 2>&1 || { echo "未找到 codex CLI"; exit 1; }
    codex mcp add playwright -- npx "@playwright/mcp@latest"
    codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest
    codex mcp add memory -- npx -y @modelcontextprotocol/server-memory
    codex mcp add fetch -- uvx mcp-server-fetch
    echo "其余服务器请编辑 ~/.codex/config.toml 的 [mcp_servers.*]"
    ;;

  vscode)
    command -v code >/dev/null 2>&1 || { echo "未找到 code CLI"; exit 1; }
    code --add-mcp '{"name":"playwright","command":"npx","args":["-y","@playwright/mcp@latest"]}'
    code --add-mcp '{"name":"chrome-devtools","command":"npx","args":["-y","chrome-devtools-mcp@latest"]}'
    code --add-mcp '{"name":"memory","command":"npx","args":["-y","@modelcontextprotocol/server-memory"]}'
    code --add-mcp '{"name":"fetch","command":"uvx","args":["mcp-server-fetch"]}'
    echo "其余请编辑 .vscode/mcp.json（注意 VS Code 用 servers 键，不是 mcpServers）"
    ;;

  *)
    echo "用法: bash configure.sh [claude-code|codex|vscode]"
    echo "其他客户端（Cursor / Windsurf / Cline / opencode / Claude Desktop）请直接编辑 mcp.json，见 README 表格"
    exit 1
    ;;
esac
