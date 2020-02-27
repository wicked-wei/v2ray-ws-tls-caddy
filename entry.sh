#!/bin/bash

domain="$1"
path="$2"
uuid="$3"
psname="v2ray-ws"

if  [ ! "$uuid" ] ;then
  if [ -f "/root/.v2ray/uuid" ]; then
    uuid=`cat /root/.v2ray/uuid`
  else
    uuid=$(uuidgen)
    echo "使用随机生成的UUID: ${uuid}"
  fi
fi
mkdir -p /root/.v2ray
echo ${uuid} > /root/.v2ray/uuid

mkdir -p /etc/caddy
mkdir -p /etc/v2ray

# config for caddy
cat << EOF > /etc/caddy/Caddyfile
${domain}
{
  log ./caddy.log
  proxy /${path} :4567 {
    websocket
    header_upstream -Origin
  }
  errors {
    404 err.html
  }
}
EOF

# config for v2ray
cat << EOF > /etc/v2ray/config.json
{
  "inbounds": [
    {
      "port": 4567,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/${path}"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}
EOF

cat << EOF > /srv/sebs.js
 {
    "add":"${domain}",
    "aid":"0",
    "host":"",
    "id":"${uuid}",
    "net":"ws",
    "path":"/${path}",
    "port":"443",
    "ps":"${psname}",
    "tls":"tls",
    "type":"none",
    "v":"2"
  }
EOF

cat /srv/clientconfig.json \
  | sed "s/@@domain/${domain}/g" \
  | sed "s/@@path/${path}/g" \
  | sed "s/@@uuid/${uuid}/g" \
  > /root/.v2ray/client.json


nohup /bin/parent caddy -conf="/etc/caddy/Caddyfile"  --log stdout --agree=false &
echo "-----------------客户端配置JSON--------------------" > /root/.v2ray/output.txt
cat /root/.v2ray/client.json >> /root/.v2ray/output.txt
node showconfig.js >> /root/.v2ray/output.txt
cat /root/.v2ray/output.txt
/usr/bin/v2ray -config /etc/v2ray/config.json
