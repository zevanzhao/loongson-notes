# fcitx5输入法的使用

我在使用了龙芯3A6000M处理器的笔记本电脑上，安装了Debian testing操作系统。

由于该笔记本使用7A2000作为桥片和显卡，显示性能非常糟糕，难以流畅运行gnome/kde等桌面环境，我决定使用mate作为桌面环境。

我习惯使用fcitx5输入法，需要设置fcitx5输入法。

## 安装输入法
```bash
apt install fcitx5 fcitx5-chinese-addons fcitx5-frontend-all fcitx5-pinyin
```

## 配置输入法
需要配置三个部分：

1. 运行 im-config， 选择fcitx为输入法
2. 设置fcitx自动启动
 ```bash
 cp /usr/share/applications/org.fcitx.Fcitx5.desktop ~/.config/autostart/
 ``` 
3.  修改`~/.xprofile`文件，设置环境变量，添加以下三行：
```text
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
```
不需要额外的操作了。
