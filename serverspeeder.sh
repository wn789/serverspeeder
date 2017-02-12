#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH


#定义变量
#授权文件自动生成url
APX=http://rs.91yun.pw/apx1.php
#安装包下载地址
INSTALLPACK=https://github.com/91yun/serverspeeder/blob/test/91yunserverspeeder.tar.gz?raw=true
#判断版本支持情况的地址
CHECKSYSTEM=https://raw.githubusercontent.com/91yun/serverspeeder/test/serverspeederbin.txt
#bin下载地址
BIN=downloadurl



#取操作系统的名称
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        release='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        release='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        release='Ubuntu'
        PM='apt'		
	else
        release='unknow'
    fi
    
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        bit='x64'
    else
        bit='x32'
    fi
}

Get_Dist_Name
Get_OS_Bit
kernel=`uname -r`
kernel_result=""

echo -e "\r\n"
echo "===============system info======================="
echo "$release "
echo "$kernel "
echo "$bit "
echo "================================================="
echo -e "\r\n"

#下周支持的内核库
wget $CHECKSYSTEM --no-check-certificate -O serverspeederbin.txt > /dev/null 2>&1 || { echo "download error.please try again later";exit 1; }

#判断是否有完全匹配的内核
grep -q "$release/[^/]*/$kernel/$bit" serverspeederbin.txt
if [ $? -eq 0 ]; then
	#如果完全匹配，则取的内核版本
	kernel_result=$kernel
else
	#如果没有完全匹配的内核，则开始模糊匹配
	echo ">>>This kernel is not supported.Fuzzy matching..."
	echo -e "\r\n"
	#因为centos和ubuntu的版本号不太一样，所以centos匹配2.6.32-504.el6.x86_64到504 ，
	if [ "$release" == "CentOS" ]; then
		kernel1=`echo $kernel | awk -F '-' '{ print $1 }'`
		kernel2=`echo $kernel | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $1 }'`
	elif [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		kernel1=`echo $kernel | awk -F '-' '{ print $1 }'`
		kernel2=`echo $kernel | awk -F '-' '{ print $2 }'`
	else
		echo "this shell only supported CentOS,Ubuntu and Debian"
		exit 1
	fi
	
	grep -q "$release/[^/]*/$kernel1\(-\)\{0,1\}$kernel2[^/]*/$bit" serverspeederbin.txt
	if [ $? -eq 1 ]; then
			echo -e "\r\n"
			echo "serverspeeder not supported this system!!"
			exit 1
	else
		#如果模糊匹配到了，就给玩家选
		echo "There is no exact match for the kernel, please choose one of the closest ones:"
		echo -e "The current kernel of the system is \033[41;37m $kernel \033[0m"
		echo -e "\r\n"
		cat serverspeederbin.txt | grep  "$release/[^/]*/$kernel1\(-\)\{0,1\}$kernel2[^/]*/$bit"  | awk -F '/' '{ print NR"："$3 }'
		echo -e "\r\n"
		echo "Please enter the number of the options："	
		read cver2
		if [ "$cver2" == "" ]; then
			echo "you do not choose any kernel options, the install stopped."
			exit 1
		fi
		echo -e "\r\n"
		cver2str="cat serverspeederbin.txt | grep  \"$release/[^/]*/$kernel1\(-\)\{0,1\}$kernel2[^/]*/$bit\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }' | awk 'NR==1{print \$1}'"
		kernel_result=$(eval $cver2str)			
	fi
fi

if [ "$kernel_result" == "" ]; then
	echo "it can not get kernel ,install stopped"
	exit 1
fi

echo "installing ServerSpeeder,please wait a moment..."


#开始匹配锐速的版本
serverspeederver=3.10.61.0

grep -q "$release/[^/]*/$kernel_result/$bit/$serverspeederver" serverspeederbin.txt
if [ $? == 1 ]; then
	#如果没有匹配到这个版本的锐速，则取第一个
	serverspeederverstr="grep \"$release/[^/]*/$kernel_result/$bit/\" serverspeederbin.txt | awk -F '/' 'NR==1{print \$5}'"
	serverspeederver=$(eval $serverspeederverstr)
fi



BINFILESTR="cat serverspeederbin.txt | grep '$release/[^/]*/$kernel_result/$bit/$serverspeederver/0' | awk -F '/' '{ print \$1\"/\"\$2\"/\"\$3\"/\"\$4\"/\"\$5\"/\"\$7 }'"
BINFILE=$(eval $BINFILESTR)
if [ "$BINFILE" == "" ]; then
	echo "it can not get BINFILE ,install stopped"
	exit 1
fi
BIN="http://rs.91yun.pw/"$BINFILE
rm -rf serverspeederbin.txt





if [ "$1" == "" ]; then
	MACSTR="LANG=C ifconfig eth0 | awk '/HWaddr/{ print \$5 }' "
	MAC=$(eval $MACSTR)
	if [ "$MAC" == "" ]; then
		MACSTR="LANG=C ifconfig eth0 | awk '/ether/{ print \$2 }' "
		MAC=$(eval $MACSTR)
	fi	
	if [ "$MAC" == "" ]; then
		echo "name of netcard is not eth0,please retry after change the name."
		exit 1
	fi
else
	MAC=$1
fi	

#如果自动取不到就退出
if [ "$MAC" = "" ]; then
	echo "can not get MAC,install stopped."
	exit 1
fi

	
#下载安装包
wget -N --no-check-certificate -O 91yunserverspeeder.tar.gz  $INSTALLPACK  > /dev/null 2>&1
tar xfvz 91yunserverspeeder.tar.gz  > /dev/null 2>&1 || { echo "can not download install package.install stopped";exit 1; }

#下载授权文件
wget -N -O apx-20341231.lic "$APX?mac=$MAC"  > /dev/null 2>&1 || { echo "can not download lic file,please check : $APX?mac=$MAC";exit 1;}
mv apx-20341231.lic 91yunserverspeeder/apxfiles/etc/


#取得序列号

wget -N -O serverspeedersn.txt "$APX?mac=$MAC&sno"  > /dev/null 2>&1
SNO=$(cat serverspeedersn.txt)
rm -rf serverspeedersn.txt
sed -i "s/serial=\"sno\"/serial=\"$SNO\"/g" 91yunserverspeeder/apxfiles/etc/config
rv=$release"_"$kernel_result
sed -i "s/acce-3.10.61.0-\[Debian_7_3.2.0-4-amd64\]/acce-$serverspeederver-[$rv]/g" 91yunserverspeeder/apxfiles/etc/config

#下载bin文件
wget -N -O "acce-"$serverspeederver"-["$release"_"$kernel_result"]" $BIN  > /dev/null 2>&1
mv "acce-"$serverspeederver"-["$release"_"$kernel_result"]" 91yunserverspeeder/apxfiles/bin/

#切换目录执安装文件
cd 91yunserverspeeder
bash install.sh  > /dev/null 2>&1

#禁止修改授权文件
chattr +i /serverspeeder/etc/apx*
bash /serverspeeder/bin/serverSpeeder.sh status