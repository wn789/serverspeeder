# serverspeeder锐速一键破解安装版

本破解锐速是是无限带宽版的，破解版锐速的一些代码将逐步开源在github这里。

锐速破解版自动安装过程中有什么问题都可以留言，我尽量解答。

# 特别说明
另外：重要的事情说三遍！！！

锐速不支持Openvz！！！锐速不支持Openvz！！！锐速不支持Openvz！！！

# 锐速破解版安装方法：
    wget -N --no-check-certificate https://raw.githubusercontent.com/wn789/serverspeeder/master/serverspeeder.sh && bash serverspeeder.sh
# 锐速破解版卸载方法：
    chattr -i /serverspeeder/etc/apx* && /serverspeeder/bin/serverSpeeder.sh uninstall -f


锐速破解版功能：
如果内核完全匹配就会自动下载安装。
如果没有完全匹配的内核，会在界面提示可选内核，可以手动选个最接近的尝试
自动下载授权文件
自动修改配置文件
已chattr +i /serverspeeder/etc/apx*禁止修改配置文件，可以不用加hosts了
目前只支持CentOS，ubuntu和debian。
