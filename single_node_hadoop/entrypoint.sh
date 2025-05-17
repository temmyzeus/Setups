#! /bin/bash

service ssh start
hdfs namenode -format
start-dfs.sh
start-yarn.sh
tail -f /dev/null
