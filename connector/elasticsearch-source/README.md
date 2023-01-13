# Elasticsearch Source Connector in Docker

ElasticSearch Source Connector using [dariobalinzo/kafka-connect-elasticsearch-source][2].

## Run

1. Create containers

`docker-compose up -d`

This does the following:

- Creates Kafka clusters and its required components
- Creates Kafka Connect worker
- Starts Elasticsearch
- Creates Elasticsearch index and its first data

2. Run a consumer listening to topic `es_example-index`

```
docker exec -it broker sh
kafka-console-consumer --bootstrap-server localhost:9092 --topic es_example-index --from-beginning

# you may already see data because the first one is already written
```

3. Add another data

```
curl -X POST -H  "Content-Type:application/json" \
    http://localhost:9200/example-index/_doc \  -d '{
            "id": "983724",
            "age": 20,
            "name": {
              "first": "Hoge",
              "last": "Tanaka"
            },
            "@timestamp": "2023-01-13 01:14:00"
        }'
```

Notice the data is now visible by the consumer.

4. Add another data. Notice the @timestamp is less than what it was before.

```
curl -X POST -H  "Content-Type:application/json" \
    http://localhost:9200/example-index/_doc \  -d '{
            "id": "983724",
            "age": 20,
            "name": {
              "first": "Foo",
              "last": "Bar"
            },
            "@timestamp": "2023-01-13 01:13:00"
        }'
```

Notice the data is not processed. 

## Considerations

- The connector short polls ElasticSearch. Making `poll.interval.ms` in the Connector task can add load to the Elastic service.
- The data is only populated if the timestamp is greater than the last because it looks up by a sorted value. Using [Ingest Pipeline][1] could be a better alternative than the application adding the timestamp.
- This is an open source version and has no enterprise support.

[1]: https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html
[2]: https://www.confluent.io/hub/dariobalinzo/kafka-connect-elasticsearch-source