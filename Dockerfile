FROM alpine:3.20

# 安装必须软件：unzip 用来解 Xray 包，nginx 做 80 端口反代
RUN apk add --no-cache unzip nginx

# 下载 xray-core 二进制包到临时目录
ADD https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip /tmp/xray.zip

# 解压并准备 xray 二进制
RUN unzip /tmp/xray.zip -d /usr/local/bin/ \
    && mv /usr/local/bin/xray /usr/local/bin/xray-core \
    && chmod +x /usr/local/bin/xray-core \
    && rm -rf /tmp/*

# 静态页面目录
RUN mkdir -p /www

# 把三个文件复制进镜像（注意：这些文件在 Windows 上可能带 CRLF）
COPY config.json.template /etc/xray/config.json.template
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

# 设置执行权限，并在构建时清除 CRLF（去掉 '\r'）
RUN chmod +x /entrypoint.sh \
    && sed -i 's/\r$//' /entrypoint.sh /etc/nginx/nginx.conf \
    && printf '%s\n' "配備が完了しました" > /www/index.html

# 安装 cloudflared
ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 /usr/local/bin/cloudflared
RUN chmod +x /usr/local/bin/cloudflared

EXPOSE 80

# exec 形式启动脚本（脚本会以 exec 启动 nginx，保证信号传递）
CMD ["/entrypoint.sh"]
