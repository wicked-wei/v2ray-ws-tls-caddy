# Builder
FROM golang:1.13-alpine as builder

RUN apk add --no-cache git gcc musl-dev

COPY builder.sh /usr/bin/builder.sh

CMD ["/bin/sh", "/usr/bin/builder.sh"]

ARG version="1.0.3"
ARG plugins="git,cors,realip,expires,cache"


RUN go get -v github.com/abiosoft/parent
RUN VERSION=${version} PLUGINS=${plugins} ENABLE_TELEMETRY=false /bin/sh /usr/bin/builder.sh

# Final stage
FROM alpine:3.8

# V2RAY
ARG TZ="Asia/Shanghai"
ENV TZ ${TZ}
ENV V2RAY_VERSION v4.22.1
ENV V2RAY_LOG_DIR /var/log/v2ray
ENV V2RAY_CONFIG_DIR /etc/v2ray/
ENV V2RAY_DOWNLOAD_URL https://github.com/v2ray/v2ray-core/releases/download/${V2RAY_VERSION}/v2ray-linux-64.zip

RUN apk upgrade --update \
    && apk add \
        bash \
        tzdata \
        curl \
    && mkdir -p \
        ${V2RAY_LOG_DIR} \
        ${V2RAY_CONFIG_DIR} \
        /tmp/v2ray \
    && curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip ${V2RAY_DOWNLOAD_URL} \
    && pwd \
    && unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray/ \
    && mv /tmp/v2ray/v2ray /usr/bin \
    && mv /tmp/v2ray/v2ctl /usr/bin \
    && mv /tmp/v2ray/vpoint_vmess_freedom.json /etc/v2ray/config.json \
    && chmod +x /usr/bin/v2ray \
    && chmod +x /usr/bin/v2ctl \
    && apk del curl \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /tmp/v2ray /var/cache/apk/*

WORKDIR /srv

# node
# install node
RUN apk add --no-cache util-linux
RUN apk add --update nodejs nodejs-npm
COPY package.json /srv/package.json
RUN  npm install
COPY showconfig.js /srv/showconfig.js

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
# RUN /usr/bin/caddy -version
# RUN /usr/bin/caddy -plugins

VOLUME /root/.caddy
VOLUME /root/.v2ray

COPY err.html /srv/err.html

# install process wrapper
COPY --from=builder /go/bin/parent /bin/parent
COPY clientconfig.json /srv/clientconfig.json
COPY entry.sh /entry.sh
EXPOSE 443 80

RUN chmod +x /entry.sh

# Startup script
ENTRYPOINT ["/entry.sh"]
