#!/bin/sh
#read -p "日志采集. [y/n]: " sinstall
#if [ $sinstall == 'y' ]; then
echo "关闭logAgent进程......"
PID=`ps -ef |grep filebeat  |grep -v grep | awk '{print $2}'`
echo $PID
if [ ! "$PID" ];then
   echo "进程不存在"
else
   echo "关闭日志终端PID$PID"
   kill -s 9 $PID
fi

#如果文件夹不存在，创建文件夹
if [ ! -d "filebeat-7.7.0-linux-x86_64" ]; then
	echo "下载和初始化logAgent程序......"
	curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.7.0-linux-x86_64.tar.gz
	echo "解压logAgent......"
	if tar xvf filebeat-7.7.0-linux-x86_64.tar.gz; then
		 
		echo "拷贝初始化配置filebeat.yml......"
		cp filebeat.yml filebeat-7.7.0-linux-x86_64
		
		echo "创建动态配置目录"
		mkdir filebeat-7.7.0-linux-x86_64/inputs.d
		cp filebeat-demo.yml filebeat-7.7.0-linux-x86_64/inputs.d
		inputs.d
	fi
fi
wait
echo "启动logAgent日志终端......"
./filebeat-7.7.0-linux-x86_64/filebeat -c filebeat.yml &

#else 
#exit
#fi