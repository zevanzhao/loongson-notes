# 微信中无法使用输入法

此问题有两种解法

##  解法1：正确配置输入法
配置方案，请参考 [fcitx5输入法配置](./fcitx5的使用.md)。只要正确配置了输入法，微信中就可以正常使用能够输入法。

## 解法2： 配置微信启动脚本

修改`/usr/share/applications/wechat.desktop` 文件，将其中的

`Exec=/usr/bin/wechat %U`

修改为

`Exec=env XMODIFIERS=@im=fcitx GTK_IM_MODULE=fcitx QT_IM_MODULE=fcitx /usr/bin/wechat %U`

即可。


