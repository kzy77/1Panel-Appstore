#!/bin/bash

# APIPark 初始化脚本
# 确保数据目录具有正确的权限

echo "正在初始化 APIPark 数据目录权限..."

# 创建必要的数据目录
mkdir -p ./data/apipark
mkdir -p ./data/mysql
mkdir -p ./data/redis
mkdir -p ./data/influxdb
mkdir -p ./data/loki
mkdir -p ./data/grafana

# 设置 Grafana 目录权限 (用户 ID: 472)
chown -R 472:472 ./data/grafana
chmod -R 755 ./data/grafana

# 设置 MySQL 目录权限 (用户 ID: 999)
chown -R 999:999 ./data/mysql

# 设置 InfluxDB 目录权限
chown -R 1000:1000 ./data/influxdb

# 设置 Redis 目录权限 (用户 ID: 999)
chown -R 999:999 ./data/redis

# 设置 Loki 目录权限 (root)
chown -R 0:0 ./data/loki

echo "数据目录权限设置完成！"