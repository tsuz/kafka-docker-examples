# Elasticsearch Sink Connector in Docker

ElasticSearch Sink Connector using [Confluent's ElasticSearch Sink Connector][2]. For a full detailed tutorial, please see [here][3].

## Run

1. Download the artifacts from [Confluent's ElasticSearch Sink Connector][4] and place it under `connect-plugins` folder. Alternatively, you could use `confluent-hub install confluentinc/kafka-connect-elasticsearch:14.0.4` but this requires the user to enter values (which cannot be done in Docker).

1. Create containers

`docker-compose up -d`

This does the following:

- Creates Kafka clusters and its required components
- Creates Kafka Connect worker
- Starts Elasticsearch
- Creates Elasticsearch index `products-info`


3. Create a schema in schema registry. This will allow validation around correct data type mapping when importing into ElasticSearch. This post request returns the schema ID.

```sh

curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
--data '{"schema": "{ \"type\" : \"record\", \"name\" : \"Product\", \"fields\" : [ { \"name\" : \"id\" , \"type\" : \"string\" }, { \"name\" : \"name\" , \"type\" : \"string\" }, { \"name\" : \"category\" , \"type\" : \"string\" }, { \"name\" : \"price\" , \"type\" : \"int\" } ] }"}' http://localhost:8081/subjects/product-info/versions

> {"id":1}
```


4. Run a producer that writes to `products-info`

```
docker exec -it schema-registry bash

kafka-avro-console-producer --bootstrap-server broker:29092 --topic products-info --property schema.registry.url=http://schema-registry:8081 --property value.schema.id=1

{"id": "abcde1234", "name": "4K 27\" monitor LG", "category": "TV", "price": 45800 }
{"id": "7234fs", "name": "4K 24\" monitor DELL", "category": "TV", "price": 52900 }
{"id": "dasdfh3f82", "name": "4K 26\" monitor SONY", "category": "TV", "price": 62900 }
{"id": "23askudf", "name": "4K 32\" monitor SHARP", "category": "TV", "price": 142900 }
```

5. Query Elasticsearch for data

```
curl -XGET -H  "Content-Type:application/json"   http://localhost:9200/products-info/_search  | jq

```

Notice the produced data is now visible in Elastic's search query, instantly!

## Other useful commands

Verify whether the data is actually produced.

```
docker exec -it schema-registry bash

kafka-avro-console-consumer --bootstrap-server http://kafka:29092 --topic products-info --from-beginning
```

Whether the Connect task is running:

```
curl  http://localhost:8083/connectors/elasticsearch-sink-connector/status
```

See connect logs

```
docker logs -f connect-1
```

## Notes

- [Read the documentation][6] so that you can plan ahead about how the data will be mapped.
- Support for ElasticSearch Sink Connector is not fully compatibile with all the 8.x versions. See [here][5] for details.

[1]: https://www.elastic.co/guide/en/elasticsearch/reference/current/ingest.html
[2]: https://www.confluent.io/hub/confluentinc/kafka-connect-elasticsearch
[3]: https://docs.confluent.io/kafka-connectors/elasticsearch/current/overview.html#
[4]: https://www.confluent.io/hub/confluentinc/kafka-connect-elasticsearch
[5]: https://github.com/confluentinc/kafka-connect-elasticsearch/issues/620
[6]: https://docs.confluent.io/kafka-connectors/elasticsearch/current/overview.html