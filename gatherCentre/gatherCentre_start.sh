precise_waiting()
{
    $1
    while ps -ef | grep $1 | grep -v 'grep'; do
       sleep 10
       continue
    done
}
PID=`ps -ef |grep logGatherSystem  |grep -v grep | awk '{print $2}'`
echo $PID
if [ ! "$PID" ];then  # 这里判断TOMCAT进程是否存在
   echo "进程不存在"
else
   echo "进程存在 杀死进程PID$PID"
   kill -s 9 $PID
fi

#PID=`ps -ef |grep logstash  |grep -v grep | awk '{print $2}'`
#echo $PID
#if [ ! "$PID" ];then  # 这里判断TOMCAT进程是否存在
#   echo "进程不存在"
#else
#   echo "进程存在 杀死进程PID$PID"
#   kill -s 9 $PID
#fi

#PID=`ps -ef |grep elasticsearch  |grep -v grep | awk '{print $2}'`
#echo $PID
#if [ ! "$PID" ];then  # 这里判断TOMCAT进程是否存在
#   echo "进程不存在"
#else
#   echo "进程存在 杀死进程PID$PID"
#   kill -s 9 $PID
#fi

#PID=`ps -ef |grep kibana  |grep -v grep | awk '{print $2}'`
#echo $PID
#if [ ! "$PID" ];then  # 这里判断TOMCAT进程是否存在
#   echo "进程不存在"
#else
#   echo "进程存在 杀死进程PID$PID"
#   kill -s 9 $PID
#fi

##下载套件##
echo "=======================================ALL IN ONE ====================================="
echo "开始下载套件..."
if [ ! -d "kafka_2.12-2.4.0" ]; then
echo "开始下载kafka套件..."
rm -rf kafka_2.12-2.4.0.tgz
wget https://mirror.bit.edu.cn/apache/kafka/2.4.0/kafka_2.12-2.4.0.tgz
tar -xvf kafka_2.12-2.4.0.tgz
else
echo "kafka套件...OK"
fi

if [ ! -d "logstash-7.10.0" ]; then
echo "开始下载logstash套件..."
rm -rf logstash-7.10.0-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/logstash/logstash-7.10.0-linux-x86_64.tar.gz
tar -xvf logstash-7.10.0-linux-x86_64.tar.gz
else
echo "logstash套件...OK"
fi

if [ ! -d "elasticsearch-7.10.0" ]; then
echo "开始下载elasticsearch套件..."
rm -rf elasticsearch-7.10.0-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.10.0-linux-x86_64.tar.gz
tar -xvf elasticsearch-7.10.0-linux-x86_64.tar.gz
else
echo "elasticsearch套件...OK"
fi

if [ ! -d "kibana-7.10.0-linux-x86_64" ]; then
echo "开始下载kibana套件..."
rm -rf kibana-7.10.0-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.10.0-linux-x86_64.tar.gz
tar -xvf kibana-7.10.0-linux-x86_64.tar.gz
else
echo "kibana套件...OK"
fi

basedir=`cd $(dirname $0); pwd -P`

echo "=======================================请初始化es密码，输入es"
sudo adduser es  
sudo passwd es
sudo chown -R es:es $basedir/elasticsearch-7.10.0

echo "=======================================启动zookeeper..."

read -p "请输入本地IP: " sinstall
if [ ! $sinstall ]; then
echo "必须输入IP，启动退出"
exit
fi

##增加advertised.listeners=PLAINTEXT://$sinstall:9092

reg_str="$sinstall kafka"
if grep -q $reg_str /etc/hosts
then
echo "is exist!"
else
	echo $reg_str >> /etc/hosts
  
fi

cp server.properties $basedir/kafka_2.12-2.4.0/config/ 
insert=advertised.listeners=PLAINTEXT://$sinstall:9092
echo $insert >> $basedir/kafka_2.12-2.4.0/config/server.properties

$basedir/kafka_2.12-2.4.0/bin/zookeeper-server-start.sh kafka_2.12-2.4.0/config/zookeeper.properties & 

sleep 5
echo "=======================================启动kafka..."
$basedir/kafka_2.12-2.4.0/bin/kafka-server-start.sh kafka_2.12-2.4.0/config/server.properties &

sleep 10
echo "=======================================创建kafka topic..."
$basedir/kafka_2.12-2.4.0/bin/kafka-topics.sh --create --zookeeper kafka:2181 --replication-factor 1 --partitions 1 --topic logcentre &
$basedir/kafka_2.12-2.4.0/bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --entity-name logcentre --alter --add-config max.message.bytes=10485760
sleep 10
echo "=======================================启动logstash..."
cp logstash-sample.conf $basedir/logstash-7.10.0/config/ 
$basedir/logstash-7.10.0/bin/logstash -f ./logstash-7.10.0/config/logstash-sample.conf &

sleep 3
echo "=======================================启动elasticsearch..."
sysctl -w vm.max_map_count=262144
cp elasticsearch.yml $basedir/elasticsearch-7.10.0/config/ 
cmd=$basedir"/elasticsearch-7.10.0/bin/elasticsearch &"
su - es  -c $cmd &
#su - es  -c "/home2/logGatherSystem1/gatherCentre/elasticsearch-7.10.0/bin/elasticsearch "
#su - es  -c "/home2/logGatherSystem/gatherCentre/elasticsearch-7.10.0/bin/elasticsearch"
sleep 5
echo "=======================================启动kibana..."
cp kibana.yml $basedir/kibana-7.10.0-linux-x86_64/config/ 
$basedir/kibana-7.10.0-linux-x86_64/bin/kibana --allow-root &
#wait
echo "ALL启动完成"
#bin/kafka-topics.sh --list --zookeeper localhost:2181
