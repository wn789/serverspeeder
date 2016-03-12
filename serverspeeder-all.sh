#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH


#定义变量
#授权文件自动生成url
APX=http://soft.91yun.org/soft/serverspeeder/apx1.php
#安装包下载地址
INSTALLPACK=http://soft.91yun.org/soft/serverspeeder/91yunserverspeeder.tar.gz
#判断版本支持情况的地址
CHECKSYSTEM=http://soft.91yun.org/soft/serverspeeder/checksystem.php
#bin下载地址
BIN=downloadurl

#先安装lsb_release

yum -y install lsb || {  apt-get update;apt-get install -y lsb; } || { echo "lsb_release没安装成功，程序暂停";exit 1; }
yum -y install curl || { apt-get update;apt-get install -y curl; } || { echo "curl自动安装失败，请自行手动安装curl后再重新开始";exit 1; }


#取操作系统的名称
Get_Dist_Name()
{
    if grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'		
	else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        ver3='x64'
    else
        ver3='x32'
    fi
}


#如果不是centos，ubuntu或者debian，提示出错
if [ "$DISTRO" == "unknow" ]; then
	echo "一键脚本暂时只支持centos，ubuntu和debian的安装，其他系统请选择手动安装http://www.91yun.org/serverspeeder91yun"
	exit 1
fi
Get_Dist_Name
Get_Dist_Name
release=$DISTRO
#发行版本
if [ "$release" == "Debian" ]; then
	ver1str="lsb_release -rs | awk -F '.' '{ print \$1}'"
else
	ver1str="lsb_release -rs | awk -F '.' '{ print \$1\".\"\$2 }'"
fi
ver1=$(eval $ver1str)
#内核版本
ver2=`uname -r`
#锐速版本
ver4=3.10.60.0

echo "================================================="
echo "操作系统：$release "
echo "发行版本：$ver1 "
echo "内核版本：$ver2 "
echo "位数：$ver3 "
echo "锐速版本：$ver4 "
echo "================================================="


#下载支持的bin列表
curl "http://soft.91yun.org/soft/serverspeeder/serverspeederbin.txt" -o serverspeederbin.txt || { echo "文件下载失败，自动退出，可以前往http://www.91yun.org/serverspeeder91yun手动下载安装包";exit 1; }

#release="CLOUD"
#判断发行版本号
cat serverspeederbin.txt | grep -q $release/$ver1 || { echo "暂不支持 $release $ver1";exit 1; }

#判断内核版本
#if [ "$release" = "CentOS" ]; then
#cat serverspeederbin.txt | { grep "$release/$ver1/$ver2";} || { grep "$release/$ver1/[^/]*/$ver3";echo 2; } || awk -F '{ print $3 }' 
#fi
grep -q "$release/$ver1/$ver2" serverspeederbin.txt
if [ $? == 1 ]; then
		#echo "没有找到内核"
	if [ "$release" == "CentOS" ]; then
		ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
		#echo $ver21
		ver22=`echo $ver2 | awk -F '-' '{ print $2 }' | awk -F '.' '{ print $1 }'`
		#echo $ver22
		cat serverspeederbin.txt | grep -q  "$release/$ver1/$ver21-$ver22[^/]*/$ver3/"
		#echo "$release/$ver1/$ver21-$ver22[^/]*/$ver3/"

		if [ $? == 1 ]; then
			echo -e "\r\n"
			echo "锐速暂不支持该内核，程序退出.自动安装判断比较严格，你可以到http://www.91yun.org/serverspeeder91yun手动下载安装文件尝试不同版本"
			exit 1
		fi
		echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功"
		#echo -e "\r\n"
		echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
		cat serverspeederbin.txt | grep  "$release/$ver1/$ver21-$ver22[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
	fi
	
	
	if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		ver21=`echo $ver2 | awk -F '-' '{ print $1 }'`
		ver22=`echo $ver2 | awk -F '-' '{ print $2 }'`
		cat serverspeederbin.txt | grep -q  "$release/$ver1/$ver21-[^/]*/$ver3/"

		if [ $? == 1 ]; then
			echo -e "\r\n"
			echo "锐速暂不支持该内核，程序退出.自动安装判断比较严格，你可以到http://www.91yun.org/serverspeeder91yun手动下载安装文件尝试不同版本"
			exit 1
		fi
		echo "没有完全匹配的内核，请选一个最接近的尝试，不确保一定成功"
		echo -e "您当前的内核为 \033[41;37m $ver2 \033[0m"
		cat serverspeederbin.txt | grep  "$release/$ver1/$ver21-[^/]*/$ver3/"  | awk -F '/' '{ print NR"："$3 }'
	fi	
	
	
	echo "请选择（输入数字序号）："	
	read cver2
	if [ "$cver2" == "" ]; then
		exit 1
	fi
	
	if [ "$release" == "CentOS" ]; then
		cver2str="cat serverspeederbin.txt | grep  \"$release/$ver1/$ver21-$ver22[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }'"
	fi
	if [[ "$release" == "Ubuntu" ]] || [[ "$release" == "Debian" ]]; then
		cver2str="cat serverspeederbin.txt | grep  \"$release/$ver1/$ver21-[^/]*/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$3 }' | awk -F '：' '/"$cver2："/{ print \$2 }'"
	fi	
	ver2=$(eval $cver2str)
	 if [ "$ver2" == "" ]; then
                exit 1
        fi
	
fi
#判断锐速版本
grep -q "$release/$ver1/$ver2/$ver3/$ver4" serverspeederbin.txt
if [ $? == 1 ]; then
	echo -e "\r\n"
	echo -e "我们用的锐速安装文件是\033[41;37m 3.10.60.0  \033[0m，但这个内核没有匹配的，请选择一个接近的锐速版本号尝试，不确保一定可用"
	cat serverspeederbin.txt | grep  "$release/$ver1/$ver2/$ver3/"  | awk -F '/' '{ print NR"："$5 }'
	echo "请选择锐速版本号（输入数字序号）：" 
        read cver4
	if [ "$cver4" == "" ]; then
		exit 1
	fi
     	cver4str="cat serverspeederbin.txt | grep  \"$release/$ver1/$ver2/$ver3/\"  | awk -F '/' '{ print NR\"：\"\$5 }' | awk -F '：' '/"$cver4："/{ print \$2 }'"
        ver4=$(eval $cver4str)
	 if [ "$ver4" == "" ]; then
                exit 1
        fi
fi


BINFILESTR="cat serverspeederbin.txt | grep '$release/$ver1/$ver2/$ver3/$ver4/0' | awk -F '/' '{ print \$7 }'"
BINFILE=$(eval $BINFILESTR)
BIN="http://soft.91yun.org/soft/serverspeeder/bin/$release/$ver1/$ver2/$ver3/$ver4/$BINFILE"
echo $BIN
rm -rf serverspeederbin.txt






#先取外网ip，根据取得ip获得网卡，然后通过网卡获得mac地址。
IP=$(curl ipip.net | awk -F ' ' '{print $2}' | awk -F '：' '{print $2}')
NC="ifconfig | awk -F ' |:' '/$IP/{print a}{a=\$1}'"
NETCARD=$(eval $NC)
MACSTR="LANG=C ifconfig $NETCARD | awk '/HWaddr/{ print \$5 }' "
MAC=$(eval $MACSTR)
if [ "$MAC" = "" ]; then
MACSTR="LANG=C ifconfig $NETCARD | awk '/ether/{ print \$2 }' "
MAC=$(eval $MACSTR)
fi
echo IP=$IP
echo NETCARD=$NETCARD
echo MAC=$MAC

#如果自动取不到就要求手动输入
if [ "$MAC" = "" ]; then
echo "无法自动取得mac地址，请手动输入："
read MAC
echo "手动输入的mac地址是$MAC"
fi


#安装curl

yum -y install curl || { apt-get update;apt-get install -y curl; } || { echo "curl自动安装失败，请自行手动安装curl后再重新开始";exit 1; }


	
#下载安装包
echo "======================================"
echo "开始下载安装包。。。。"
echo "======================================"
wget -N -O 91yunserverspeeder.tar.gz  $INSTALLPACK
tar xfvz 91yunserverspeeder.tar.gz || { echo "下载安装包失败，请检查";exit 1; }

#下载授权文件
echo "======================================"
echo "开始下载授权文件。。。。"
echo "======================================"
curl "$APX?mac=$MAC" -o 91yunserverspeeder/apxfiles/etc/apx-20341231.lic || { echo "下载授权文件失败，请检查";exit 1;}


#取得序列号
echo "======================================"
echo "开始修改配置文件。。。。"
echo "======================================"
SNO=$(curl "$APX?mac=$MAC&sno") || { echo "生成序列号失败，请检查";exit 1; }
echo "序列号：$SNO"
sed -i "s/serial=\"sno\"/serial=\"$SNO\"/g" 91yunserverspeeder/apxfiles/etc/config
rv=$release"_"$ver1"_"$ver2
sed -i "s/Debian_7_3.2.0-4-amd64/$rv/g" 91yunserverspeeder/apxfiles/etc/config

#下载bin文件
echo "======================================"
echo "开始下载bin运行文件。。。。"
echo "======================================"
curl $BIN -o "91yunserverspeeder/apxfiles/bin/acce-3.10.61.0-["$release"_"$ver1"_"$ver2"]" || { echo "下载bin运行文件失败，请检查";exit 1; }

#切换目录执安装文件
cd 91yunserverspeeder
bash install.sh

#禁止修改授权文件
chattr +i /serverspeeder/etc/apx*
#安装完显示状态
bash /serverspeeder/bin/serverSpeeder.sh status