FROM alpine:3.7

ENV NGINX_VERSION=1.15.3
ENV NGINX_RTMP_VERSION=1.2.1
ENV FFMPEG_VERSION=4.0.2
ENV FFMPEG_VERSION_URL="http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2"
ENV BIN="/usr/bin"

WORKDIR /tmp

RUN adduser -h /etc/nginx -D -s /bin/sh nginx \
    && apk --update add pcre libbz2 ca-certificates libressl \
    && apk add \
         freetype-dev \
         gnutls-dev \
         lame-dev \
         libass-dev \
         libogg-dev \
         libtheora-dev \
         libvorbis-dev \
         libvpx-dev \
         libwebp-dev \
         libssh2 \
         opus-dev \
         rtmpdump-dev \
         x264-dev \
         x265-dev \
         yasm-dev \
    && cd /tmp \
    && wget https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_VERSION}.tar.gz \
    && tar zxf v${NGINX_RTMP_VERSION}.tar.gz && rm v${NGINX_RTMP_VERSION}.tar.gz \
    && apk --update add --virtual build_deps build-base zlib-dev pcre-dev libressl-dev bzip2 coreutils gnutls nasm x264 \
    && wget -O - https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar xzf - \
    && cd /tmp/nginx-$NGINX_VERSION && ./configure \
       --prefix=/usr/share/nginx \
       --sbin-path=/usr/sbin/nginx \
       --conf-path=/etc/nginx/nginx.conf \
       --error-log-path=stderr \
       --http-log-path=/dev/stdout \
       --pid-path=/var/run/nginx.pid \
       --lock-path=/var/run/nginx.lock \
       --http-client-body-temp-path=/var/cache/nginx/client_temp \
       --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
       --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
       --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
       --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
       --user=nginx \
       --group=nginx \
       --with-http_addition_module \
       --with-http_auth_request_module \
       --with-http_gunzip_module \
       --with-http_gzip_static_module \
       --with-http_realip_module \
       --with-http_ssl_module \
       --with-http_stub_status_module \
       --with-http_sub_module \
       --with-http_v2_module \
       --with-threads \
       --with-stream \
       --with-stream_ssl_module \
       --without-http_memcached_module \
       --without-mail_pop3_module \
       --without-mail_imap_module \
       --without-mail_smtp_module \
       --with-pcre-jit \
       --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security' \
       --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
       --add-module=/tmp/nginx-rtmp-module-${NGINX_RTMP_VERSION} \
    && make install \
    && cd /tmp && rm -rf nginx-$NGINX_VERSION \
    && mkdir /var/cache/nginx \
    && rm /etc/nginx/*.default \
    && apk add --update nasm yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && apk add --update fdk-aac-dev \
    && cd /tmp/ \
    && wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz \
    && tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz && rm ffmpeg-${FFMPEG_VERSION}.tar.gz \
    && cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
         ./configure \
         --bindir="/usr/bin" \
         --enable-version3 \
         --enable-gpl \
         --enable-nonfree \
         --enable-small \
         --enable-libmp3lame \
         --enable-libx264 \
         --enable-libx265 \
         --enable-libvpx \
         --enable-libtheora \
         --enable-libvorbis \
         --enable-libopus \
         --enable-libfdk-aac \
         --enable-libass \
         --enable-libwebp \
         --enable-librtmp \
         --enable-postproc \
         --enable-avresample \
         --enable-libfreetype \
         --enable-openssl \
         --disable-debug && \
         make -j4 && make install && make distclean \
    && apk del build_deps && rm /var/cache/apk/* \
    && rm -rf /var/cache/* /tmp/*

COPY nginx.conf /etc/nginx/
ADD  conf.d /etc/nginx/conf.d

VOLUME ["/var/cache/nginx"]
EXPOSE 80 443 1935

CMD ["nginx", "-g", "daemon off;"]
