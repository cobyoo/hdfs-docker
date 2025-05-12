#!/bin/bash

/etc/init.d/ssh start

export HADOOP_HOME=/opt/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))

$HADOOP_HOME/bin/hdfs namenode -format

$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver

tail -f /dev/null