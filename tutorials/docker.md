# docker的使用
1. 安装docker程序

```bash
sudo apt install docker.io 
```
记得将用户加入docker组里
```bash
sudo gpasswd -a $USER docker
```
2. 配置docker使用的代理服务器

修改文件或者创建文件`/etc/systemd/system/docker.service.d/http-proxy.conf`，根据你的代理服务器地址，添加配置如下：
```conf
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
```
配置代理服务器，才能访问docker官方registry。否则需设置国内就可以访问的registry

3. 配置拉取docker镜像的registry镜像

修改文件`/etc/docker/daemon.json`，添加如下内容：
```json
{
  "registry-mirrors" : [
    "https://lcr.loongnix.cn"
  ],
  "debug": true,
  "experimental": false
}
```
此处，添加了龙芯提供的docker镜像。

**注意**: [龙芯的docker镜像网站分为新世界和旧世界版本](https://bbs.loongarch.org/d/415-openeuler-dockererror-while-loading-shared-libraries/3)

我使用新世界操作系统，所以用了`lcr.loongninx.cn`的镜像。旧世界用户用`cr.loongnix.cn`

这里是 [龙芯容器镜像仓库](https://www.loongnix.cn/zh/cloud/container-registry/)的介绍。


4. 在龙架构下，使用latx或者qemu跨架构运行docker镜像

可以参考这个[网页](https://bbs.loongarch.org/d/139-loongarchdockerx86)

**注意**： 跨架构运行docker,使用的latx需要是静态编译的。否则，需要挂载latx所依赖的所有库文件。
