#! /bin/bash

SPARK_WORKLOAD=$1

if [ $# -le 0 ]; then
    echo -e "Workload argument must be stated\n$0 <workload>"
    exit 1
fi

service ssh start

if [ $SPARK_WORKLOAD = "master" ]; then
    echo "Starting HDFS ${SPARK_WORKLOAD} "
    if [ ! -d /opt/hadoop/data/nameNode/cluster ]; then
        echo "Formatting NameNode..."
        hdfs namenode -format
    else
        echo "NameNode already formatted. Skipping Formatting..."
    fi
    hdfs --daemon start namenode
    hdfs --daemon start secondarynamenode
    yarn --daemon start resourcemanager

    # create required directories, but may fail so do it in a loop
    while ! hdfs dfs -mkdir -p /spark-logs;
    do
        echo "Failed creating /spark-logs hdfs dir"
    done
    echo "Created /spark-logs hdfs dir"
    hdfs dfs -mkdir -p /opt/spark/data
    echo "Created /opt/spark/data hdfs dir"


    # copy the data to the data HDFS directory
    hdfs dfs -copyFromLocal /opt/spark/data/* /opt/spark/data
    hdfs dfs -ls /opt/spark/data
elif [ $SPARK_WORKLOAD = "worker" ]; then
    echo "Starting HDFS DataNode & YARN Node Manager "
    hdfs --daemon start datanode
    yarn --daemon start nodemanager
elif [ "$SPARK_WORKLOAD" == "history" ]; then

  while ! hdfs dfs -test -d /spark-logs;
  do
    echo "spark-logs doesn't exist yet... retrying"
    sleep 1;
  done
  echo "Exit loop"

  # start the spark history server
  start-history-server.sh
elif [ "$SPARK_WORKLOAD" == "notebook" ]; then
    jupyter lab --ip=0.0.0.0 --no-browser --NotebookApp.token='' --notebook-dir=/home/jupyter --port=8888 --allow-root
fi

tail -f /dev/null
