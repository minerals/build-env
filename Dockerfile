FROM ubuntu:16.04
MAINTAINER piotr@mines.io

#common
RUN apt-get update && apt-get install -y man git g++ make vim wget curl byobu unzip libopenblas-dev \
    python-setuptools python-dev bc ant maven openjdk-8-jdk octave
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
