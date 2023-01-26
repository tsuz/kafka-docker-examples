# Schema Registry

Schema Registry for Docker based on [this tutorial][1]. This docker example creates a series of messages and copy them over to another cluster using [Cluster Linking][2].

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


5. Create a schema called my-schema for context `my-env` in source schema registry.

```sh
docker exec -it source-schema-registry bash

curl -XPOST -H 'Content-Type: application/json' --data @/data/demo-schema.avro http://source-schema-registry:8081/subjects/:.my-env:my-schema/versions
```


6. Create a consumer for the source schema registry.

```sh
docker exec -it source-schema-registry bash

kafka-avro-console-consumer --bootstrap-server source-cluster:9092 --topic demo --from-beginning --property schema.registry.url=http://source-schema-registry:8081/contexts/.my-env
```


7. In another window, create a producer using the source schema registry.

```sh
docker exec -it source-schema-registry bash

kafka-avro-console-producer --bootstrap-server source-cluster:9092 --topic demo --property schema.registry.url=http://source-schema-registry:8081/contexts/.my-env --property value.schema.id=1

> {"my_field1": 1, "my_field2": 30.55, "my_field3": "hoge"} 
```

8. Notice in the avro consumer, the message arrives and is deserialized correctly.

9. Create a consumer on the schema registry destination.

```sh
docker exec -it dest-schema-registry bash

kafka-avro-console-consumer --bootstrap-server dest-cluster:9092 --topic demo --from-beginning --property schema.registry.url=http://dest-schema-registry:8081/contexts/.my-env
```

Notice there is an error that schema ID does not exist.

10. Create a schema exporter from source to destination.

```sh
docker exec -it source-schema-registry bash

schema-exporter --create --name my-env-schema-backup --subjects ":.my-env:*" --config-file /data/config.txt --schema.registry.url http://source-schema-registry:8081/ --context-type NONE

> Successfully created exporter my-env-schema-backup
```

11. Get the status for schema exporter.

```sh
schema-exporter --get-status   --schema.registry.url http://source-schema-registry:8081 --name  my-env-schema-backup
{"name":"my-env-schema-backup","state":"RUNNING","offset":8,"ts":1674719973735}
```

12. Now you can view the messages on the destination cluster using the destination's schema registry.

```sh
kafka-avro-console-consumer --bootstrap-server dest-cluster:9092 --topic demo --from-beginning --property schema.registry.url=http://dest-schema-registry:8081/contexts/.my-env
```



[1]: https://docs.confluent.io/platform/current/multi-dc-deployments/cluster-linking/topic-data-sharing.html#create-the-cluster-link-and-the-mirror-topic
[2]: https://docs.confluent.io/platform/current/multi-dc-deployments/cluster-linking/topic-data-sharing.html#create-the-cluster-link-and-the-mirror-topic