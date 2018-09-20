# docker-nginx-rtmp
Docker image that built with nginx and nginx-rtmp-module

build
```bash
docker build -f ./Dockerfile -t jamaismagic/docker-nginx-rtmp:latest .
```

run
```bash
docker run -d -p 81:80 -p 1935:1935 \
 -v /Users/jamais/wwk/dev/wwk/github/docker-nginx-rtmp/nginx.conf:/etc/nginx/nginx.conf \
 -v /Users/jamais/wwk/dev/wwk/github/docker-nginx-rtmp/conf.d:/etc/nginx/conf.d \
 -v /Users/jamais/wwk/dev/wwk/github/docker-nginx-rtmp/tmp/hls:/tmp/hls \
 jamaismagic/docker-nginx-rtmp:latest
```

Just for ffmpeg
```bash
docker run -it \
jamaismagic/docker-nginx-rtmp:latest ffmpeg --help
```

update nginx settings
```bash
docker exec <container id> nginx -t

docker exec <container id> nginx -s reload
```

# Thanks to these repositories

[sitkevij/ffmpeg](https://github.com/sitkevij/ffmpeg)

[cybercode/alpine-nginx](https://github.com/cybercode/alpine-nginx)

[alfg/docker-nginx-rtmp](https://github.com/alfg/docker-nginx-rtmp)

[tiangolo/nginx-rtmp-docker](https://github.com/tiangolo/nginx-rtmp-docker/blob/master/Dockerfile)
