#!/bin/sh
# 清理 CRLF（保险）
sed -i 's/\r$//' /etc/xray/config.json.template 2>/dev/null || true
#!/bin/sh
set -e

# 默认 UUID
UUID=${UUID:-c2ce3368-41e4-485c-b159-34cc6ed020ac}
sed "s/\${UUID}/$UUID/g" /etc/xray/config.json.template > /etc/xray/config.json

# 启动 xray
/usr/local/bin/xray-core -config /etc/xray/config.json &

# 启动 nginx
nginx -g 'daemon off;' &

# 启动 cloudflared (使用环境变量)
/usr/local/bin/cloudflared tunnel --no-autoupdate run --token "$TUNNEL_TOKEN" &

# 保持容器前台运行
wait -n
