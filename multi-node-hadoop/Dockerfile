FROM ubuntu:jammy
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get install -y --no-install-recommends \
    curl \
    sudo \
    openssh-server \
    pdsh \
    nano \
    python3.12 \
    openjdk-11-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

EXPOSE 22

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

RUN service ssh start

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV SPARK_VERSION=3.5.5
ENV HADOOP_HOME=${HADOOP_HOME:-/opt/hadoop}
ENV SPARK_HOME=${SPARK_HOME:-/opt/spark}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p {SPARK_HOME}

COPY --from=downloads hadoop-3.4.1.tar.gz ${HADOOP_HOME}/hadoop-3.4.1.tar.gz
COPY --from=downloads spark-3.5.5-bin-hadoop3-scala2.13.tgz ${SPARK_HOME}/spark-3.5.5-bin-hadoop3-scala2.13.tgz
RUN tar -xf ${HADOOP_HOME}/hadoop-3.4.1.tar.gz --strip-components=1 -C ${HADOOP_HOME}
RUN tar -xf ${SPARK_HOME}/spark-3.5.5-bin-hadoop3-scala2.13.tgz --strip-components=1 -C ${SPARK_HOME}

RUN rm ${HADOOP_HOME}/hadoop-3.4.1.tar.gz ${SPARK_HOME}/spark-3.5.5-bin-hadoop3-scala2.13.tgz


WORKDIR ${SPARK_HOME}

# COPY requirements.txt .
# RUN apt-get install python3-pip
# RUN pip3 install -r requirements.txt

COPY set-hadoop-env.sh /etc/profile.d/set-hadoop-env.sh

ENV PATH=${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:$PATH

# Setup Spark related environment variables
ENV SPARK_MASTER="spark://spark-yarn-master:7077"
ENV SPARK_MASTER_HOST=spark-yarn-master
ENV SPARK_MASTER_PORT=7077
ENV PYSPARK_PYTHON=python3
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop

# Add Hadoop native library path to the dynamic link library path
ENV LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}"

# Set user for HDFS and Yarn (for production probably not smart to put root)
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"

RUN echo export JAVA_HOME=${JAVA_HOME} >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh && \
    echo export PDSH_RCMD_TYPE=ssh >> ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

COPY etc/hadoop/core-site.xml ${HADOOP_CONF_DIR}/core-site.xml
COPY etc/hadoop/hdfs-site.xml ${HADOOP_CONF_DIR}/hdfs-site.xml
COPY etc/hadoop/yarn-site.xml ${HADOOP_CONF_DIR}/yarn-site.xml
COPY etc/hadoop/mapred-site.xml ${HADOOP_CONF_DIR}/mapred-site.xml
COPY conf/spark-env.sh ${SPARK_HOME}/conf/spark-env.sh
COPY conf/spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf

ENV PYTHONPATH=${SPARK_HOME}/python:$PYTHONPATH

RUN chmod u+x ${SPARK_HOME}/conf/spark-env.sh

EXPOSE 7077 8080

COPY entrypoint.sh entrypoint.sh

RUN chmod u+x entrypoint.sh
