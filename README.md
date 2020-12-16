# logGatherSystem 

架构：filebeat->kafaka->logstash->elasticsearch->kibana

# 一键部署的日志采集系统，采用shell编写，运行时需要公网畅通
  客户端部署：
  修改filebeat.yml kafa 的远端IP
  --logAgent 采集客户端，这个放到要采集日志文件的服务器。执行sh logAgent_start.sh启动
  服务端部署：
  vi /etc/hosts 增加   你的ip kafka
  --gatherCentre 中控中心，这个放到一个中心服务器，能和采集日志服务器互通。执行sh gatherCentre_start.sh启动

# kibana 作为web管理端查看日志http://IP:5601


