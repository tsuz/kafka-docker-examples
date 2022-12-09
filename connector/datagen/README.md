# Connector - Start a datagen connector

[Datagen source connector][1] will start generating mock data into Kafka brokers.


## Run

1. Run `docker-compose up -d`
2. Check connector is up and is available `curl localhost:8083`
3. Add a data generation task: 

```
curl -i -X PUT http://localhost:8083/connectors/log/config \
     -H "Content-Type: application/json" \
     -d '{
        "connector.class": "io.confluent.kafka.connect.datagen.DatagenConnector",
        "kafka.topic": "transactions",
        "quickstart": "transactions",
        "key.converter": "org.apache.kafka.connect.storage.StringConverter",
        "value.converter": "org.apache.kafka.connect.json.JsonConverter",
        "value.converter.schemas.enable": "false",
        "max.interval": 1000,
        "tasks.max": "1"
    }'
```

4. Check the status of this task.

```
> curl localhost:8083/connectors/log/status  | jq

{
  "name": "log",
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
  "type": "source"
}
```

5. Check if the mock messages can be received

```
> docker exec -it zookeeper /bin/bash
> kafka-console-consumer --bootstrap-server broker:29092 --topic transactions

{"transaction_id":274,"card_id":16,"user_id":"User_4","purchase_id":273,"store_id":2}
{"transaction_id":275,"card_id":22,"user_id":"User_5","purchase_id":274,"store_id":2}
{"transaction_id":276,"card_id":17,"user_id":"User_9","purchase_id":275,"store_id":5}
{"transaction_id":277,"card_id":1,"user_id":"User_8","purchase_id":276,"store_id":6}

```

[Documentation][2]

[Tutorial][3]


[1]: https://www.confluent.io/hub/confluentinc/kafka-connect-datagen
[2]: https://github.com/confluentinc/kafka-connect-datagen
[3]: https://developer.confluent.io/tutorials/kafka-connect-datagen/kafka.html