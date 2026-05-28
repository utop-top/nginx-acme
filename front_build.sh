#!/bin/bash

# 开启错误检测，任何命令失败都会立刻停止脚本，防止带着错误环境打包镜像
set -e

echo -e "================================================"
echo -e "      🚀 执行构建前初始化 (front_build.sh)      "
echo -e "================================================\n"

# 1. 强制清理旧项目目录 (核心要求)
echo "🧹 [1/3] 正在清理当前目录下的旧缓存..."
# 使用 rm -rf 强制递归删除这两个目录，如果不存在也不会报错
rm -rf nginx nginx-acme
echo "✅ 清理完成。"

# 2. 拉取 Nginx 源码并切换到指定标签
echo -e "\n📦 [2/3] 正在克隆 nginx 官方仓库..."
git clone https://github.com/nginx/nginx.git
cd nginx
echo "🔄 正在切换到 release-1.28.0 分支..."
git checkout release-1.28.0
cd ..

# 3. 拉取 ACME 模块源码
echo -e "\n📦 [3/3] 正在克隆 nginx-acme 模块仓库..."
git clone https://github.com/nginx/nginx-acme.git

echo -e "\n🎉 所有源码与模块准备就绪，可以开始 Docker 构建！\n"