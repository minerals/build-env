FROM ubuntu:16.04
MAINTAINER piotr@migo.money

#common
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
      ant \
      bc \
      build-essential \
      byobu \
      curl \
      git \
      g++ \
      jq \
      make \
      man \
      maven \
      libffi-dev \
      libopenblas-dev \
      libssl-dev \
      octave \
      openjdk-8-jdk-headless \
      openssh-server \
      python-setuptools \
      python-dev \
      unzip \
      vim \
      wget; \
    apt-get clean
RUN easy_install py4j

# Pip
RUN cd /tmp/; \
    wget https://bootstrap.pypa.io/get-pip.py; \
    python get-pip.py

# Install particular SBT
RUN cd /usr/local; \
    wget http://dl.bintray.com/sbt/native-packages/sbt/0.13.6/sbt-0.13.6.tgz; \
    tar -xzf sbt-0.13.6.tgz; \
    rm sbt-0.13.6.tgz

# SBT 0.13.6 continues to be a pain in the ass and tries to override memory settings regardless
# of our environment variables. Prevent it from doing so.
RUN sed -i".bak" '/$(get_mem_opts $sbt_mem) /d' /usr/local/sbt/bin/sbt-launch-lib.bash

# Python data science libs
RUN apt-get install -y python-leveldb libleveldb-dev && apt-get clean
RUN pip install jupyter plyvel===0.9
RUN apt-get install -y python-numpy python-scipy python-matplotlib python-pandas python-sympy python-nose && apt-get clean

# Go 1.6
RUN cd /tmp/; \
    curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz; \
    tar -xvf go1.6.linux-amd64.tar.gz; \
    mv go /usr/local/
ENV PATH $PATH:/usr/local/go/bin/
ENV GOPATH /usr/local/go-workspace/

# AWS utilities
RUN pip install \
      awscli \
      boto3 \
      boto \
      futures

# Ansible
RUN pip install ansible==2.1.1

# Install SNAP (needed for graph analysis)
RUN cd /tmp/; \
    wget https://s3.eu-central-1.amazonaws.com/mine-fs/snap-1.2-2.4-centos6.5-x64-py2.6.tar.gz; \
    tar -xzf snap-1.2-2.4-centos6.5-x64-py2.6.tar.gz; \
    cd snap-1.2-2.4-centos6.5-x64-py2.6; \
    python setup.py install

# Install protobuf (needed for Delite cluster applications)
RUN cd /tmp/; \
    wget https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz; \
    tar -xzf protobuf-2.5.0.tar.gz; \
    cd protobuf-2.5.0; \
    ./configure; \
    make; \
    make install

# Protobuf libs are put here
ENV LD_LIBRARY_PATH /usr/local/lib/    

# Add executable scripts to our default path
ENV PATH $PATH:/usr/local/sbt/bin/

# SBT / Java options
ENV SBT_OPTS -Xmx3g -XX:ReservedCodeCacheSize=128m -Xss12m
ENV JAVA_OPTS -Xms1g -Xmx3g -Xss12m
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV SCALA_MAJOR_VER 2.11

# Start in the root of the repository
# Docker 1.2 does not expand env variables inside WORKDIR (should be fixed in 1.3)
WORKDIR /usr/local/main/
