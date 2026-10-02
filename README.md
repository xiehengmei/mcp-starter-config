# MCP Starter Config

精选并**逐一核实**过的 MCP 服务器配置。所有安装命令均取自各仓库的官方 README / `package.json` / `pyproject.toml`，不是二手清单里的转述。

## 为什么不是直接抄 awesome-mcp-servers

`punkpeye/awesome-mcp-servers`（95k star）是最全的索引，但它只是个链接表：里面大量条目已归档、安装命令过时、或需要付费 key。本仓库只收录**当前活跃、命令可复现**的服务器。

一个典型例子：官方 `modelcontextprotocol/servers` 仓库里，Brave Search、GitHub、Puppeteer、Postgres、Slack、Sentry 等参考实现**已被归档**到 `servers-archived`，README 明确说 Brave 应改用官方新服务器 `@brave/brave-search-mcp-server`。照旧清单抄会直接装到废弃包。

---

## 第一梯队：零 key，装完即用

| 服务器 | 仓库 | Star | 安装命令 |
| --- | --- | --- | --- |
| Context7 | `upstash/context7` | 62.5k | `npx -y @upstash/context7-mcp`（或远程 `https://mcp.context7.com/mcp`） |
| Chrome DevTools | `ChromeDevTools/chrome-devtools-mcp` | 52.8k | `npx -y chrome-devtools-mcp@latest` |
| Playwright | `microsoft/playwright-mcp` | 微软官方 | `npx @playwright/mcp@latest` |
| Serena | `oraios/serena` | 29.9k | `uv tool install -p 3.13 serena-agent` → `serena init` |
| Memory | `modelcontextprotocol/servers` | 官方参考 | `npx -y @modelcontextprotocol/server-memory` |
| Sequential Thinking | 同上 | 官方参考 | `npx -y @modelcontextprotocol/server-sequential-thinking` |
| Filesystem | 同上 | 官方参考 | `npx -y @modelcontextprotocol/server-filesystem <目录>` |
| Git | 同上 | 官方参考 | `uvx mcp-server-git --repository <仓库>` |
| Fetch | 同上 | 官方参考 | `uvx mcp-server-fetch` |
| Time | 同上 | 官方参考 | `uvx mcp-server-time` |

> Serena 的 README 明确警告：**不要从 MCP / 插件市场安装**，里面的命令过时且次优。只按官方 Quick Start 装。

## 第二梯队：需要 API key

| 服务器 | 仓库 | Star | 说明 |
| --- | --- | --- | --- |
| GitHub（官方） | `github/github-mcp-server` | 33.3k | 远程 `https://api.githubcopilot.com/mcp/`（支持 OAuth，免建 token）；本地用 Docker `ghcr.io/github/github-mcp-server` + `GITHUB_PERSONAL_ACCESS_TOKEN` |
| Firecrawl | `firecrawl/firecrawl-mcp-server` | 7.5k | **有免 key 的托管端点** `https://mcp.firecrawl.dev/v2/mcp`（scrape/search/parse 可用，限速） |
| Brave Search | `brave/brave-search-mcp-server` | 官方 | 需要 `BRAVE_API_KEY`，2.x 起默认 transport 是 **stdio** |
| Exa | `exa-labs/exa-mcp-server` | 5k | 需要 `EXA_API_KEY` |
| Notion | `makenotion/notion-mcp-server` | 4.6k | 官方，需要 OAuth |

## 值得关注的专项

- `DeusData/codebase-memory-mcp`（45.6k）：单静态二进制、零依赖，把代码库索引成持久知识图谱，158 种语言
- `czlonkowski/n8n-mcp`（23k）：让 agent 帮你搭 n8n 工作流
- `antvis/mcp-server-chart`（4.4k）：25+ 图表生成，做数据分析出图
- `containers/kubernetes-mcp-server`（2.1k）：K8s / OpenShift
- `benborla/mcp-server-mysql`（2.1k）：MySQL 只读访问
- `figma/mcp-server-guide`（2k）：Figma Dev Mode MCP

---

## 安装

```bash
bash install.sh          # 全局装包 + 装浏览器 + 初始化 serena
bash configure.sh        # 写入 MCP 客户端配置
```

`configure.sh` 默认走 Claude Code（`claude mcp add`）。其他客户端见下面。

## 各客户端配置位置

| 客户端 | 配置方式 |
| --- | --- |
| **Claude Code** | `claude mcp add --scope user <name> -- <command>` |
| **Claude Desktop** | 编辑 `claude_desktop_config.json`，用 `mcp.json` 内容 |
| **VS Code** | `.vscode/mcp.json`（用 `servers` 键），或 `code --add-mcp '{...}'` |
| **Cursor** | Settings → MCP → Add new MCP server |
| **Codex** | `~/.codex/config.toml`，`[mcp_servers.name]` 用 TOML |
| **opencode** | `~/.config/opencode/opencode.json`，`mcp` 键，`command` 是数组 |
| **Cline** | `cline_mcp_settings.json`，需要 `"type": "stdio"` 和 `"disabled": false` |

**Windows 注意**：`npx` 要包一层 `cmd /c` —— 把 `"command"` 改成 `"cmd"`，`args` 前面加 `"/c", "npx"`。`uvx` 条目不用改。

## 安全

MCP 服务器把工具直接暴露给模型，而模型会被网页/仓库里的内容影响。几点务实建议：

- **GitHub PAT 用最小 scope**：`repo`、`read:packages`、`read:org`。别给 `admin:org`。
- **GitHub 服务器开 `--read-only`**（`GITHUB_READ_ONLY=1`）可以禁掉所有写操作；`--lockdown-mode` 能过滤无 push 权限作者的内容，降低 prompt injection 面。注意 lockdown **不是授权边界**，它不改变 token 本身的权限。
- **Playwright / Chrome DevTools 明确声明自己不是安全边界**。它们能读你浏览器里的任何东西，包括已登录会话。用 `--isolated` 避免污染真实 profile，别在登录了敏感账号的 profile 上跑。
- **Filesystem 只传你愿意共享的目录**，不要传 `$HOME`。
- Token 别写进配置然后提交进 git。`chmod 600` 配置文件。

## 已核实的事实来源

- 官方参考服务器包名：各 `package.json`（`@modelcontextprotocol/server-memory` `0.6.3`、`server-filesystem` `0.6.3`、`server-sequential-thinking` `0.6.2`）与 `src/time/pyproject.toml`（`mcp-server-time`，Python ≥3.10）
- `src/` 当前只剩 7 个参考服务器：everything / fetch / filesystem / git / memory / sequentialthinking / time
- Serena 启动命令 `serena start-mcp-server`，Claude Code 可用 `serena setup claude-code`
- Brave 2.x 默认 stdio；`BRAVE_API_KEY_FILE` 优先级高于 `BRAVE_API_KEY`
- Firecrawl 托管端点分 `/v2/mcp`（全量）与 `/v2/mcp-search`（固定 8 工具）；keyless 只暴露 3 个工具
- GitHub 远程服务器未指定 toolsets 时默认 `context, repos, issues, pull_requests, users`