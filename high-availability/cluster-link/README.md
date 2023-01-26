# Cluster Linking

Cluster linking for Docker based on [this tutorial][1].

## Install

```
docker-compose up -d
```
## Run

1. Create a topic

```sh
docker exec -it source-cluster bash
kafka-topics --create --topic demo --bootstrap-server source-cluster:9092
```

2. Create a cluster link on the destination cluster

```sh
docker exec -it dest-cluster bash

kafka-cluster-links --bootstrap-server dest-cluster:9092 --create --link demo-link --config bootstrap.servers=source-cluster:9092 
```

3. Verify the cluster link is in the destination cluster


```sh
kafka-cluster-links --bootstrap-server dest-cluster:9092 --list 

Link name: 'demo-link', link ID: 'RokoqjtdToKLlJd3GHAg_w', remote cluster ID: 'FANZLiPrTD25GtykdvjeUg', local cluster ID: 'FANZLiPrTD25GtykdvjeUg', remote cluster available: 'true'
```

4. Create a mirror topic on the destination

```sh
kafka-mirrors --create --mirror-topic demo --link demo-link --bootstrap-server dest-cluster:9092
```

5. Create a consumer for the destination cluster's mirror topic.

```sh
kafka-console-consumer --topic demo --bootstrap-server dest-cluster:9092 --from-beginning
```


6. Produce messages to the source cluster's topic.

```sh
kafka-console-producer --bootstrap-server dest-cluster:9092 --topic demo

>hello
>世界
```

7. Try to produce to the mirror topic. Notice you cannot write to a mirror topic.

```sh

kafka-console-producer --bootstrap-server source-cluster:9092 --topic demo

>hi

[2023-01-24 09:29:49,216] ERROR Error when sending message to topic demo with key: null, value: 6 bytes with error: (org.apache.kafka.clients.producer.internals.ErrorLoggingCallback)
org.apache.kafka.common.errors.InvalidRequestException: Cannot append records to read-only mirror topic 'demo'

```


[1]: https://docs.confluent.io/platform/current/multi-dc-deployments/cluster-linking/topic-data-sharing.html#create-the-cluster-link-and-the-mirror-topic