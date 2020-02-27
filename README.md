# v2ray + websocket + tls

扫描二维码 或者 复制 vmess链接 无需关心复杂的V2ray 配置。

- 自动生成 UUID （调用系统UUID库）
- 使用 Caddy 自动获取数字证书
- 自动生成 安卓 v2rayNG vmess链接
- 自动生成 iOS shadowrocket vmess链接
- 自动生成 iOS 二维码

## 使用方法
### 前置条件
 - 提前安装好docker，https://yeasy.gitbooks.io/docker_practice/install/ubuntu.html 这个链接有安装教程（ubuntu的，其他发行版本也是有的）
 - 做好域名解析，将域名解析到自己服务器的公网IP
 - 服务会占用`80`和`443`端口，确认这两个端口没有跑其他的业务。新服务器一般不需要操心，老服务器通过`lsof -i:80`和`lsof -i:443`查看，提示命令未找到的自行搜索`linux安装lsof`

### 安装服务

- 使用下面的命令安装服务。将命令中的`YOUR_DOMAIN`替换成自己的域名，`YOUR_PATH`替换成自己喜欢的任意字符串（必须是英文字母）。
```
bash <(curl -s https://raw.githubusercontent.com/wicked-wei/v2ray-ws-tls-caddy/master/install.sh) YOUR_DOMAIN YOUR_PATH
```
- 如果想用指定的UUID安装服务，还是用上面的命令，在末尾追加指定UUID。也别忘了替换`YOUR_DOMAIN`和`YOUR_PATH`。例如
```
bash <(curl -s https://raw.githubusercontent.com/wicked-wei/v2ray-ws-tls-caddy/master/install.sh) my.abc.com mypath 0890b53a-e3d4-4726-bd2b-52574e8588c4
```
- 服务安装完会自动显示配置信息。之后如果想再次查看配置信息，用下面的命令：
```
cat $HOME/.v2ray/output.txt
```
- 停止服务
```
sudo docker stop v2ray
```

有问题欢迎提issue， 感谢大家。参考了 caddy docker 和 v2ray 的 dockerfile 以及 @Fr3027 的项目，感谢！
