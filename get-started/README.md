# Get Started

## How to

### Start Kafka broker

```
docker-compose up -d
```

### View Kakfa configuration

```
# Log into Kafka container
> docker exec -it broker /bin/bash

> cat /etc/kafka/server.properties
```

Broker config reference can be found [here][1].

### Validate if broker is registered in ZooKeeper

```
> docker exec broker zookeeper-shell zookeeper:2181 ls /brokers/ids

Connecting to zookeeper:2181

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[1] <--- this means broker 1 is up
[2022-11-28 08:52:09,552] ERROR Exiting JVM with code 0 (org.apache.zookeeper.util.ServiceUtils)

```

### Send and receive messages

1. Log into any container that has Kafka CLI.

```
# log into zookeeper container
> docker exec -it zookeeper /bin/bash

# create a consumer (receiver) and receive messages from broker
> kafka-console-consumer --bootstrap-server broker:29092 --topic my-topic
```

2. Open another terminal shell and log into zookeeper container.
```
# log into zookeeper container
> docker exec -it zookeeper /bin/bash

# create a producer (sender) and send messages to the broker
> kafka-console-producer --bootstrap-server broker:29092 --topic my-topic
key, {"foo": "bar"}
```

3. Notice messages are received by the consumer. 

Note: The consumers and producers can be run from local machine by connecting to localhost:9092.

## Notes

When `docker-compose up -d` is run the second time, an error log can be seen below:

```
kafka_1      | [2018-08-28 05:47:34,119] ERROR Error while creating ephemeral at /brokers/ids/1001, node already exists and owner '100620751440642057' does not match current session '100626284643549184' (kafka.zk.KafkaZkClient$CheckedEphemeral)
```

To avoid this, `restart: always` is set according to [this workaround][2].

[1]: https://kafka.apache.org/documentation/#brokerconfigs
[2]: https://github.com/wurstmeister/kafka-docker/issues/389