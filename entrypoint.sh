#!/bin/sh
# 运行时再做一次 CRLF 清理（多一层保险）
sed -i 's/\r$//' /etc/xray/config.json 2>/dev/null || true

# 启动 xray（监听 127.0.0.1:10000）
/usr/local/bin/xray-core -config /etc/xray/config.json &

# 以 foreground 模式启动 nginx（exec 保证 PID 1 是 nginx，信号工作正常）
exec nginx -g 'daemon off;'

# 启动 cloudflared（需要你在部署前已 cloudflared tunnel login 并准备好配置）
/usr/local/bin/cloudflared tunnel run --url http://127.0.0.1:12345 &

# wait 保持前台进程
wait -n