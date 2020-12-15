PID=`ps -ef |grep logGatherSystem  |grep -v grep | awk '{print $2}'`
echo $PID
if [ ! "$PID" ];then  # 这里判断TOMCAT进程是否存在
   echo "进程不存在"
else
   echo "进程存在 杀死进程PID$PID"
   kill -s 9 $PID
fi

