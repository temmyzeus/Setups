FROM ubuntu:jammy

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    sudo \
    openssh-server \
    pdsh \
    nano \
    openjdk-11-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

COPY set-hadoop-env.sh /etc/profile.d/set-hadoop-env.sh

WORKDIR /opt/hadoop

COPY --from=downloads hadoop-3.4.1.tar.gz .

RUN tar -xf hadoop-3.4.1.tar.gz --strip-components=1

RUN rm hadoop-3.4.1.tar.gz

RUN echo export JAVA_HOME=${JAVA_HOME} >> etc/hadoop/hadoop-env.sh && \
    echo export HDFS_NAMENODE_USER=root >> etc/hadoop/hadoop-env.sh && \
    echo export HDFS_DATANODE_USER=root >> etc/hadoop/hadoop-env.sh && \
    echo export HDFS_SECONDARYNAMENODE_USER=root >> etc/hadoop/hadoop-env.sh && \
    echo export YARN_RESOURCEMANAGER_USER=root >> etc/hadoop/hadoop-env.sh && \
    echo export YARN_NODEMANAGER_USER=root >> etc/hadoop/hadoop-env.sh && \
    echo export PDSH_RCMD_TYPE=ssh >> etc/hadoop/hadoop-env.sh

EXPOSE 22

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

COPY etc/hadoop/core-site.xml etc/hadoop/core-site.xml
COPY etc/hadoop/hdfs-site.xml etc/hadoop/hdfs-site.xml
COPY etc/hadoop/yarn-site.xml etc/hadoop/yarn-site.xml
COPY etc/hadoop/mapred-site.xml etc/hadoop/mapred-site.xml

COPY entrypoint.sh entrypoint.sh

RUN chmod u+x entrypoint.sh

ENV PATH=/opt/hadoop/bin:/opt/hadoop/sbin:$PATH

RUN service ssh start
