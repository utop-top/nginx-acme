#!/usr/bin/env bash
set -euo pipefail

# 镜像名和版本
IMAGE_NAME="utoptop/nginx-acme"
IMAGE_TAG="latest"

# 1. 拉取 nginx 源码
if [ ! -d "nginx" ]; then
  git clone https://github.com/nginx/nginx.git
fi
cd nginx
git fetch --all --tags
git checkout release-1.28.0
cd ..

# 2. 拉取 acme 模块
if [ ! -d "nginx-acme" ]; then
  git clone https://github.com/nginx/nginx-acme.git
fi

# 3. 构建镜像
echo "🚀 开始构建镜像 $IMAGE_NAME:$IMAGE_TAG ..."
docker buildx build \
  --platform=linux/arm64 \
  -t "$IMAGE_NAME:$IMAGE_TAG" \
  .

# 4. 推送镜像
echo "📤 推送镜像到 Docker Hub ..."
docker push "$IMAGE_NAME:$IMAGE_TAG"

echo "✅ 构建并推送完成: $IMAGE_NAME:$IMAGE_TAG"

