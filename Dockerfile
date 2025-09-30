# ===== Stage 1: build nginx + ACME dynamic module =====
FROM rust:1.81-bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpcre2-dev libssl-dev zlib1g-dev \
    ca-certificates git make pkg-config clang libclang-dev \
  && rm -rf /var/lib/apt/lists/*

# 你本地已经把源码下载到了这两个目录：
#   ./nginx         -> NGINX 源码（务必是 release-1.28.0）
#   ./nginx-acme    -> 官方 ACME 模块仓库 https://github.com/nginx/nginx-acme
WORKDIR /build
COPY ./nginx       /build/nginx
COPY ./nginx-acme  /build/nginx-acme

WORKDIR /build/nginx
# 用独立 ACME 模块的根目录作为 --add-dynamic-module 的路径
RUN ./auto/configure \
      --with-compat \
      --with-http_ssl_module \
      --add-dynamic-module=../nginx-acme \
 && make -j"$(nproc)" modules

# ===== Stage 2: runtime（用与源码同版本的官方镜像） =====
FROM nginx:1.28.0

# 拷贝动态模块到运行时路径
COPY --from=builder /build/nginx/objs/ngx_http_acme_module.so /usr/lib/nginx/modules/

# 在 nginx.conf 顶部加载模块（绝对路径最稳妥）
RUN sed -i '1iload_module /usr/lib/nginx/modules/ngx_http_acme_module.so;' /etc/nginx/nginx.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
