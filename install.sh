#!/bin/bash

domain=$1
path=$2
uuid=$3

sudo docker run -d --name=v2ray --restart=always -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy -v $HOME/.v2ray:/root/.v2ray wickedwei/v2ray_tls $domain $path $uuid
sleep 3s
cat $HOME/.v2ray/output.txt
echo "再次查看配置信息，可用命令：cat $HOME/.v2ray/output.txt"
echo "谢谢！"
