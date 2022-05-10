DOCKER_NETWORK = hbase
ENV_FILE = hadoop.env
current_branch := $(shell git rev-parse --abbrev-ref HEAD)
hadoop_branch := 2.0.0-hadoop2.7.4-java8
build:
	lima nerdctl build -t cjoongho/hbase-base:$(current_branch) ./base
	lima nerdctl build -t cjoongho/hbase-master:$(current_branch) ./hmaster
	lima nerdctl build -t cjoongho/hbase-regionserver:$(current_branch) ./hregionserver
	lima nerdctl build -t cjoongho/hbase-standalone:$(current_branch) ./standalone

wordcount:
	lima nerdctl run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(hadoop_branch) hdfs dfs -mkdir -p /input/
	lima nerdctl run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(hadoop_branch) hdfs dfs -copyFromLocal -f /opt/hadoop-2.7.4/README.txt /input/
	lima nerdctl run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	lima nerdctl run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(hadoop_branch) hdfs dfs -cat /output/*
	lima nerdctl run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(hadoop_branch) hdfs dfs -rm -r /output
	lima nerdctl run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} cjoongho/hadoop-base:$(hadoop_branch) hdfs dfs -rm -r /input
