#
# Builder
#
FROM abiosoft/caddy:builder as builder

ARG version="1.0.3"
ARG plugins="git,cors,realip,expires,cache,cloudflare"

RUN go get -v github.com/abiosoft/parent
RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh

#
# Final stage
#
FROM alpine:3.10
# process wrapper
LABEL maintainer "kchen0x kchen0x@gmail.com"

# V2RAY & KCPTUN
ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}
ENV V2RAY_VERSION v4.19.1 
ENV V2RAY_LOG_DIR /var/log/v2ray
ENV V2RAY_CONFIG_DIR /etc/v2ray/
ENV V2RAY_DOWNLOAD_URL https://github.com/v2ray/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-64.zip
ENV KCPTUN_DOWNLOAD_URL https://github.com/xtaci/kcptun/releases/download/v20200226/kcptun-linux-arm64-20200226.tar.gz

RUN apk upgrade --update \
    && apk add \
        bash \
        tzdata \
        curl \
        wget \
        tar \
    && mkdir -p \ 
        ${V2RAY_LOG_DIR} \
        ${V2RAY_CONFIG_DIR} \
        /tmp/v2ray \
        /tmp/kcptun \
    && curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip ${V2RAY_DOWNLOAD_URL} \
    && pwd \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /usr/bin \
    && mv /tmp/v2ray/v2ctl /usr/bin \
    && mv /tmp/v2ray/vpoint_vmess_freedom.json /etc/v2ray/config.json \
    && chmod +x /usr/bin/v2ray \
    && chmod +x /usr/bin/v2ctl \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && wget --no-check-certificate "${KCPTUN_DOWNLOAD_URL}" -O /tmp/kcptun/kcptun.tar.gz \
    && pwd \
    && mkdir -p /usr/local/kcptun && tar -zxf /tmp/kcptun/kcptun.tar.gz -C /usr/local/kcptun \
    && apk del curl wget\
    && rm -rf /tmp/kcptun /tmp/v2ray /var/cache/apk/*

# ADD entrypoint.sh /entrypoint.sh
WORKDIR /srv
# node
# install node 
RUN apk add --no-cache util-linux
RUN apk add --update nodejs nodejs-npm
COPY package.json /srv/package.json
RUN  npm install
COPY  v2ray.js /srv/v2ray.js

ARG version="1.0.3"
LABEL caddy_version="$version"

# Let's Encrypt Agreement
ENV ACME_AGREE="false"

# Telemetry Stats
ENV ENABLE_TELEMETRY="false"

RUN apk add --no-cache openssh-client git

# install caddy
COPY --from=builder /install/caddy /usr/bin/caddy

# validate install
RUN /usr/bin/caddy -version
RUN /usr/bin/caddy -plugins


VOLUME /root/.caddy /srv
# WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY index.html /srv/index.html
COPY html /srv/html

# COPY package.json /etc/package.json
# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent
ADD docker-entrypoint.sh /docker-entrypoint.sh
EXPOSE 443 80 29900
ENTRYPOINT ["/docker-entrypoint.sh"]
# CMD ["--conf", "/etc/Caddyfile", "--log", "stdout", "--agree=$ACME_AGREE"]
