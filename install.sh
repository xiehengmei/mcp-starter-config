#!/usr/bin/env bash
# 全局安装所有 MCP 服务器。跑一次即可。
set -euo pipefail

command -v node >/dev/null 2>&1 || { echo "需要 Node.js >= 18"; exit 1; }
command -v npm  >/dev/null 2>&1 || { echo "需要 npm"; exit 1; }

# uvx 是 Python 系 MCP 服务器（git / fetch / time）的前提
if ! command -v uv >/dev/null 2>&1; then
  echo "未找到 uv，正在安装 ..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "==> 安装 TypeScript 系 MCP 服务器"
npm i -g \
  @modelcontextprotocol/server-memory \
  @modelcontextprotocol/server-filesystem \
  @modelcontextprotocol/server-sequential-thinking \
  @upstash/context7-mcp \
  @playwright/mcp \
  chrome-devtools-mcp \
  firecrawl-mcp

echo "==> 安装 Playwright 浏览器（chrome-devtools 需要 Chrome，playwright 需要 chromium）"
npx -y playwright install chromium

echo "==> 安装 Serena（按官方 Quick Start，不走 MCP 市场）"
uv tool install -p 3.13 serena-agent
serena init

echo
echo "完成。接下来："
echo "  1) 编辑 .env，填入 API key（Context7 / Brave / Firecrawl / GitHub）"
echo "  2) 编辑 mcp.json，把 /path/to/your/project 换成你的项目目录"
echo "  3) bash configure.sh"
