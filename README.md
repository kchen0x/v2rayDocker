# 一键 V2ray websocket + TLS

一键就完事了，复制 vmess 链接 无需关心复杂的 V2ray 配置，websocket + tls 更安全，伪装更好。

* 自动生成 UUID （调用系统 UUID 库）
* 默认使用 caddy 自动获取证书
* 自动生成 安卓 v2rayNG vmess 链接
* 自动生成 iOS shadowrocket vmess 链接
* 自动生成 surgio 使用的配置格式
* 简单的混淆主页

## 使用方法

* 提前安装好 docker

 ```
  curl -fsSL https://get.docker.com -o get-docker.sh  && \
  bash get-docker.sh
 ```

* 解析好域名 确认 你的域名正确解析到了你安装的这台服务器
* 会占用 443 和 80 端口请提前确认没有跑其他的业务 （ lsof -i:80 和 lsof -i:443 能查看）
* 请将下面命令中的 YOURDOMAIN.COM（域名）替换成自己的域名（此 IP 解析的域名）！！！

```
sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy  kchen2991/v2ray_ws:0.9 YOURDOMAIN.COM V2RAY_WS && sleep 3s && sudo docker logs v2ray
```

* 如果你想指定固定 uuid 的话， 0890b53a-e3d4-4726-bd2b-52574e8588c4 这个 uuid 改为你自己的，https://www.uuidgenerator.net/ 这个网站可以生成随机 uuid。
* 如果你想指定 path 的话，将 `one` 换成你需要的 path 路径：

```
sudo docker run -d --rm --name v2ray -p 443:443 -p 80:80 -v $HOME/.caddy:/root/.caddy  kchen2991/v2ray_ws:0.9 YOURDOMAIN.COM V2RAY_WS 0890b53a-e3d4-4726-bd2b-52574e8588c4 one && sleep 3s && sudo docker logs v2ray
```

* 命令执行完会显示链接信息，如果想查看链接信息，执行下面命令即可

```
sudo docker logs v2ray
```

* 想停止这个 docker 和服务

```
sudo docker stop v2ray
```

有问题欢迎提 issue， 感谢大家。参考了 caddy docker 和 v2ray 的 dockerfile 感谢！
