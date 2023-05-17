# AWS Lambda Sink Connector

## Purpose:

To quickly setup one of the two workflows:

1. Confluent Cloud Kafka -> AWS Lambda Sink Connector -> AWS Lambda
1. Local Kafka -> AWS Lambda Sink Connector -> AWS Lambda

## Setup

### 1. Setup Kafka

Setup your kafka in one of the following ways:

a. Run Kafka on Confluent Cloud

```
terraform -target kafka.tf 
```

b. Run a local Kafka

```
docker-compose -f docker-compose.local.yml up -d
```

### 2. Setup AWS Lambda

Setup AWS either by:

// TODO
a. running a Terraform script

```

```

b. manually creating AWS Lambda

### 3. Setup AWS Credentials

You have a few options for setting up AWS credentials.

a. Setup `~/.aws/credentials` on the local machine

```
[default]
role_arn=arn:aws:iam::037803949979:role/kinesis_cross_account_role
source_profile=staging
role_session_name = OPTIONAL_SESSION_NAME

[staging]
 aws_access_key_id = <STAGING KEY>
 aws_secret_access_key = <STAGING SECRET>
```

b. Set environmental variables

```
export AWS_DEFAULT_REGION=ap-northeast-1
export AWS_ACCESS_KEY_ID=****************
export AWS_SECRET_ACCESS_KEY=*********
```

### 4. Setup Connect

a. Setup Connect that connects to Confluent Cloud

```
# Set kafka config
export BOOTSTRAP_SERVER="pkc-********.ap-northeast-1.aws.confluent.cloud:9092"

# Kafka cluster-specific API Key (not cloud key)
export CCLOUD_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username='******' password='****+/****';"

AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY BOOTSTRAP_SERVER=$BOOTSTRAP_SERVER CCLOUD_JAAS_CONFIG=$CCLOUD_JAAS_CONFIG  docker-compose -f docker-compose.hybrid.yml  up -d
```

b. Setup Connect that connects to a local Kafka

```
# Set kafka config
export BOOTSTRAP_SERVER="PLAINTEXT://broker:29092"

AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY BOOTSTRAP_SERVER=$BOOTSTRAP_SERVER  docker-compose -f docker-compose.local.yml  up -d
```

Verify the connect is up
```
curl localhost:8083

{"version":"7.3.3-ce","commit":"84463f9f5ad066ed","kafka_cluster_id":"lkc-*****"}
```

### 4. Setup Connect File

Save the below values as `lambda-sink-connector.hybrid.json` and make these changes:

1. Replace <BOOTSTRAP_SERVER> with $BOOTSTRAP_SERVER
1. Replace <JAAS_CONFIG> with $CCLOUD_JAAS_CONFIG

```js
{
    "name": "LambdaSinkConnector",
    "config" : {
      "connector.class" : "io.confluent.connect.aws.lambda.AwsLambdaSinkConnector",
      "name": "LambdaSinkConnector",
      "tasks.max" : "1",
 
      "topics" : "orders",
 
      "aws.lambda.function.name" : "taku-lambda-sink-test-role",
      "aws.lambda.invocation.type" : "sync",
      "aws.lambda.batch.size" : "1",
      "aws.lambda.region": "ap-northeast-1",
 
      "behavior.on.error" : "fail",
 
      "confluent.topic.bootstrap.servers": "<BOOTSTRAP_SERVER>",
      "confluent.topic.sasl.jaas.config": "<JAAS_CONFIG>",
      "confluent.topic.security.protocol": "SASL_SSL",
      "confluent.topic.sasl.mechanism": "PLAIN",
      "confluent.topic.ssl.endpoint.identification.algorithm":"https",
      "confluent.topic.request.timeout.ms":20000,
      "confluent.topic.retry.backoff.ms":500,
      "confluent.topic.replication.factor" : "1",
 
      "reporter.error.topic.name": "",
      "reporter.result.topic.name": ""
    }
}
 
```

### 5. Install connector

5a. For Confluent Cloud

```sh
curl -s -X POST -H 'Content-Type: application/json' --data @lambda-sink-connector.json  http://localhost:8083/connectors

```

5b. For local Kafka

```sh
curl -s -X POST -H 'Content-Type: application/json' --data @lambda-sink-connector.local.json  http://localhost:8083/connectors
```

#### 6. Verify connector

```sh
curl localhost:8083/connectors/LambdaSinkConnector/status | jq 

{
  "name": "LambdaSinkConnector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "connect-1:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "connect-1:8083"
    }
  ],
  "type": "sink"
}
```

#### 7. Produce data

a. In local Kafka

```sh
> docker ps

CONTAINER ID   IMAGE                                      COMMAND                   CREATED          STATUS                      PORTS                              NAMES
9e556b860051   confluentinc/cp-kafka-connect-base:7.3.3   "bash -c 'echo \"Inst…"   24 minutes ago   Up 24 minutes (unhealthy)   0.0.0.0:8083->8083/tcp, 9092/tcp   connect-1
ccf9421fea99   confluentinc/cp-kafka:7.3.0                "/etc/confluent/dock…"    26 minutes ago   Up 26 minutes               9092/tcp                           broker
6739af31bd47   confluentinc/cp-zookeeper:7.3.0            "/etc/confluent/dock…"    40 minutes ago   Up 40 minutes               2181/tcp, 2888/tcp, 3888/tcp       zookeeper
```

```sh
docker exec -it 9e556b860051 bash
kafka-console-producer --bootstrap-server broker:29092 --topic orders
>1 {"a":"b"}
```

b. For Confluent Cloud, create a datagen source on the cloud that can generate mock data