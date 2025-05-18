#! /bin/bash

# service ssh start

WORKLOAD=$1

if [ $# -le 0 ]; then
    echo -e "Workload argument must be stated\n$0 <workload>"
    exit 1
fi

service ssh start

if [ $WORKLOAD = "namenode" ]; then
    echo "Starting HDFS ${WORKLOAD} "
    if [ ! -d /home/namenode_name_dir ]; then
        echo "Formatting NameNode..."
        hdfs namenode -format
    else
        echo "NameNode already formatted. Skipping Formatting..."
    fi
    hdfs namenode
elif [ $WORKLOAD = "resourcemanager" ]; then
    echo "Starting YARN ${WORKLOAD} "
    yarn resourcemanager
elif [ $WORKLOAD = "worker" ]; then
    echo "Starting HDFS DataNode & YARN Node Manager "
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
    tail -f /dev/null
fi
