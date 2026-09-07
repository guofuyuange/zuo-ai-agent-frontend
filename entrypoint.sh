#!/bin/sh
set -e

# 使用 envsubst 替换 nginx.conf 中的环境变量
# 如果设置了 BACKEND_URL 环境变量，则替换到配置中
if [ -n "$BACKEND_URL" ]; then
    echo "配置后端地址: $BACKEND_URL"
    envsubst '${BACKEND_URL}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
else
    echo "使用默认后端地址: backend:9090"
    cp /etc/nginx/conf.d/default.conf.template /etc/nginx/conf.d/default.conf
fi

# 启动 Nginx
exec nginx -g 'daemon off;'