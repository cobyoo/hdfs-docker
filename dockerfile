FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HADOOP_VERSION=3.4.1
ENV HADOOP_HOME=/opt/hadoop
ENV PATH="$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin"

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        openjdk-21-jdk \
        wget curl gnupg2 openssh-server openssh-client \
        software-properties-common \
        python3 python3-pip python3-dev \
        build-essential lsb-release ca-certificates; \
    rm -rf /var/lib/apt/lists/*; \
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-21-openjdk-*/bin/java 1; \
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java)))); \
    echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile.d/java_home.sh; \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java_home.sh; \
    wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz; \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz; \
    mv hadoop-${HADOOP_VERSION} ${HADOOP_HOME}; \
    rm hadoop-${HADOOP_VERSION}.tar.gz; \
    for user in hadoop hdfs yarn mapred hue; do \
        useradd -U -M -d /opt/hadoop/ --shell /bin/bash "$user"; \
    done; \
    for user in root hdfs yarn mapred hue; do \
        usermod -G hadoop "$user"; \
    done; \
    echo "export JAVA_HOME=\$(dirname \$(dirname \$(readlink -f \$(which java))))" >> "$HADOOP_HOME/etc/hadoop/hadoop-env.sh"; \
    echo "export HDFS_DATANODE_USER=root" >> "$HADOOP_HOME/etc/hadoop/hadoop-env.sh"; \
    echo "export HDFS_NAMENODE_USER=root" >> "$HADOOP_HOME/etc/hadoop/hadoop-env.sh"; \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> "$HADOOP_HOME/etc/hadoop/hadoop-env.sh"; \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> "$HADOOP_HOME/etc/hadoop/yarn-env.sh"; \
    echo "export YARN_NODEMANAGER_USER=root" >> "$HADOOP_HOME/etc/hadoop/yarn-env.sh"; \
    mkdir -p /run/sshd; \
    mkdir -p /root/.ssh; \
    ssh-keygen -t rsa -P '' -f /root/.ssh/id_rsa; \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys; \
    chmod 600 /root/.ssh/authorized_keys

COPY core-site.xml hdfs-site.xml yarn-site.xml mapred-site.xml $HADOOP_HOME/etc/hadoop/
COPY ssh_config /root/.ssh/config
COPY start-all.sh /start-all.sh
RUN chmod +x /start-all.sh

EXPOSE 8088 9870 9864 19888 8042 8888

CMD ["/bin/bash", "/start-all.sh"]