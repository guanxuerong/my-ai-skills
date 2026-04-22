#!/bin/bash
# 飞书 UAT 一键生成脚本（通用版 - 无需 jq）
# 使用前请先配置 APP_ID 和 APP_SECRET

# ========== 配置区域 ==========
APP_ID="你的 App ID"           # 替换为你的 App ID
APP_SECRET="你的 App Secret"   # 替换为你的 App Secret
REDIRECT_URI="http://localhost:8080/callback"
# ==============================

# 兼容 Windows 和 macOS/Linux 的临时目录
TMPDIR="${TMPDIR:-${TEMP:-${TMP:-/tmp}}}"
LOG_FILE="${TMPDIR}/feishu_code_$$.txt"

# 检查配置
if [ "$APP_ID" = "YOUR_APP_ID" ] || [ "$APP_SECRET" = "YOUR_APP_SECRET" ]; then
    echo "❌ 请先配置 APP_ID 和 APP_SECRET"
    echo ""
    echo "编辑脚本，将以下内容替换为你的应用凭证："
    echo "  APP_ID=\"你的App ID\""
    echo "  APP_SECRET=\"你的App Secret\""
    echo ""
    echo "获取方式：https://open.feishu.cn/app/ → 选择应用 → 凭证与基础信息"
    exit 1
fi

# 清理旧的日志文件
rm -f "$LOG_FILE"

# 检查端口是否被占用（兼容 Windows Git Bash）
if command -v lsof &> /dev/null; then
    if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠️  端口 8080 已被占用，正在尝试释放..."
        kill -9 $(lsof -t -i:8080) 2>/dev/null
        sleep 1
    fi
elif command -v netstat &> /dev/null; then
    if netstat -ano | grep ":8080 " | grep LISTENING > /dev/null 2>&1; then
        echo "⚠️  端口 8080 已被占用，请手动关闭占用该端口的程序"
    fi
fi

# 启动本地服务器接收回调（优先用 node，兼容 python3）
if command -v node &> /dev/null; then
node -e "
const http = require('http');
const url = require('url');
const fs = require('fs');
const logFile = process.argv[1];
const server = http.createServer((req, res) => {
  const query = url.parse(req.url, true).query;
  if (query.code) {
    res.writeHead(200, {'Content-Type': 'text/html; charset=utf-8'});
    res.end('<h1>授权成功！</h1><p>可以关闭此窗口</p>');
    fs.writeFileSync(logFile, query.code);
    server.close();
  } else {
    res.writeHead(200);
    res.end();
  }
});
server.listen(8080);
" "$LOG_FILE" &
elif command -v python3 &> /dev/null; then
python3 - "$LOG_FILE" << 'PYTHON_SCRIPT' &
import http.server, socketserver
from urllib.parse import urlparse, parse_qs
import sys
log_file = sys.argv[1]
class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        query = urlparse(self.path).query
        params = parse_qs(query)
        if 'code' in params:
            self.send_response(200)
            self.send_header('Content-type', 'text/html; charset=utf-8')
            self.end_headers()
            self.wfile.write('<h1>授权成功！</h1><p>可以关闭此窗口</p>'.encode('utf-8'))
            with open(log_file, 'w') as f:
                f.write(params['code'][0])
        else:
            self.send_response(200)
            self.end_headers()
    def log_message(self, format, *args): pass
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", 8080), Handler) as httpd:
    httpd.handle_request()
PYTHON_SCRIPT
else
    echo "❌ 需要 node 或 python3 来启动本地回调服务器"
    exit 1
fi

SERVER_PID=$!

# 等待服务器启动
sleep 2

# 生成授权URL
AUTH_URL="https://open.feishu.cn/open-apis/authen/v1/authorize?app_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&scope=docx:document:readonly%20docx:document:create%20docx:document:write_only%20search:docs:read%20wiki:wiki:readonly%20wiki:wiki%20wiki:node:create%20contact:user:search%20contact:user.base:readonly%20docs:document.comment:read%20docs:document.comment:create%20board:whiteboard:node:create%20board:whiteboard:node:read%20board:whiteboard:node:update"

echo "请在浏览器中打开以下URL进行授权："
echo ""
echo "$AUTH_URL"
echo ""

# 尝试自动打开浏览器（兼容 Windows / macOS / Linux）
if command -v start &> /dev/null; then
    start "$AUTH_URL" 2>/dev/null
elif command -v open &> /dev/null; then
    open "$AUTH_URL" 2>/dev/null
elif command -v xdg-open &> /dev/null; then
    xdg-open "$AUTH_URL" 2>/dev/null
fi

# 等待授权码
echo "等待授权..."
for i in {1..60}; do
    if [ -f "$LOG_FILE" ]; then
        CODE=$(cat "$LOG_FILE")
        if [ -n "$CODE" ]; then
            break
        fi
    fi
    sleep 1
done

# 清理
kill $SERVER_PID 2>/dev/null
wait $SERVER_PID 2>/dev/null

if [ -z "$CODE" ]; then
    echo "❌ 未获取到授权码（超时60秒）"
    rm -f "$LOG_FILE"
    exit 1
fi

echo "✅ 获取到授权码"
rm -f "$LOG_FILE"

# 获取 app_access_token（用 node 替代 jq 解析）
APP_TOKEN_RESPONSE=$(curl -s -X POST 'https://open.feishu.cn/open-apis/auth/v3/app_access_token/internal' \
  -H 'Content-Type: application/json' \
  -d "{\"app_id\":\"${APP_ID}\",\"app_secret\":\"${APP_SECRET}\"}")

APP_ACCESS_TOKEN=$(node -e "console.log(JSON.parse(process.argv[1]).app_access_token || '')" "$APP_TOKEN_RESPONSE")

if [ -z "$APP_ACCESS_TOKEN" ] || [ "$APP_ACCESS_TOKEN" = "undefined" ]; then
    echo "❌ 获取 app_access_token 失败，请检查 APP_ID 和 APP_SECRET"
    echo "响应: $APP_TOKEN_RESPONSE"
    exit 1
fi

# 换取 UAT
RESULT=$(curl -s -X POST 'https://open.feishu.cn/open-apis/authen/v1/oidc/access_token' \
  -H "Authorization: Bearer ${APP_ACCESS_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d "{\"grant_type\":\"authorization_code\",\"code\":\"${CODE}\"}")

UAT=$(node -e "const r=JSON.parse(process.argv[1]); console.log((r.data && r.data.access_token) || '')" "$RESULT")
REFRESH_TOKEN=$(node -e "const r=JSON.parse(process.argv[1]); console.log((r.data && r.data.refresh_token) || '')" "$RESULT")

if [ -z "$UAT" ]; then
    echo "❌ 获取 UAT 失败"
    MSG=$(node -e "console.log(JSON.parse(process.argv[1]).message || JSON.stringify(JSON.parse(process.argv[1])))" "$RESULT")
    echo "错误信息: $MSG"
    exit 1
fi

echo ""
echo "✅ UAT 生成成功！"
echo ""
echo "User Access Token (有效期2小时):"
echo "$UAT"
echo ""
echo "Refresh Token (有效期30天):"
echo "$REFRESH_TOKEN"
echo ""
echo "MCP 配置示例:"
echo "X-Lark-MCP-UAT: $UAT"
echo ""
echo "注意: Token 已复制到剪贴板（如果支持）"

# 尝试复制到剪贴板（兼容 Windows / macOS / Linux）
if command -v clip &> /dev/null; then
    echo -n "$UAT" | clip
elif command -v pbcopy &> /dev/null; then
    echo -n "$UAT" | pbcopy
elif command -v xclip &> /dev/null; then
    echo -n "$UAT" | xclip -selection clipboard
fi
