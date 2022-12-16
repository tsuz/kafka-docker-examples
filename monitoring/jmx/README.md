
# Querying JMX

This example shows how to query a Kafka broker's JMX metrics.

## Run


1. Start containers

```
cd monitoring/jmx
docker-compose up -d
```

2. Query JMX metrics

```
> docker exec broker \
kafka-run-class kafka.tools.JmxTool \
 --jmx-url service:jmx:rmi:///jndi/rmi://127.0.0.1:49999/jmxrmi \
 --object-name kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec

Trying to connect to JMX url: service:jmx:rmi:///jndi/rmi://127.0.0.1:49999/jmxrmi.
"time","kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec:Count","kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec:EventType","kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec:FifteenMinuteRate","kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec:FiveMinuteRate","kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec:MeanRate","kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec:OneMinuteRate","kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec:RateUnit"
1671184877840,0,messages,0.0,0.0,0.0,0.0,SECONDS
1671184879868,0,messages,0.0,0.0,0.0,0.0,SECONDS

```

To see a list of JMX commands, see [here][2].

Note: this is not production ready. [See security concerns][3].

[2]: https://kafka.apache.org/documentation/#monitoring
[3]: https://docs.confluent.io/platform/current/installation/docker/operations/monitoring.html#configure-security