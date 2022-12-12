# Connector - Start a MySQL connector

[MySQL source connector][1] collects MySQL records into Kafka brokers.

### Pre-requisites

- Install mysqlsh client


## Run

1. Create and assign a connector user

```
mysqlsh --sql
\connect root@localhost:3306
CREATE USER 'connector'@'%' IDENTIFIED BY 'connector-password';
GRANT ALL PRIVILEGES ON example.* TO 'connector'@'%';
ALTER USER 'connector'@'%' IDENTIFIED WITH mysql_native_password BY 'connector-password'; 
GRANT RELOAD, REPLICATION CLIENT, REPLICATION SLAVE ON *.* TO 'connector'@'%';
```


2. Register the connector

```
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-mysql-json.json
```


3. Validate the connector is running

```
> curl http://localhost:8083/connectors/mysql-json-connector/status | jq                                                                         
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   177  100   177    0     0   1242      0 --:--:-- --:--:-- --:--:--  1291
{
  "name": "mysql-json-connector",
  "connector": {
    "state": "RUNNING",
    "worker_id": "mysql-connect:8083"
  },
  "tasks": [
    {
      "id": 0,
      "state": "RUNNING",
      "worker_id": "mysql-connect:8083"
    }
  ],
  "type": "source"
}
```


4. Read existing data

```
docker exec -it zookeeper  /bin/bash
kafka-console-consumer --bootstrap-server broker:29092 --topic mysql-json.example.users --from-beginning
```

Do not close the connection 

5. Publish data in a new window

```
mysqlsh --sql

use example;

INSERT INTO users (name) VALUES ("Jane");
UPDATE users SET name = "Jane2" where id = 1;
DELETE FROM users WHERE id = 1;
```

In the consumer side, you should see something like this:

```

{"before":null,"after":{"id":1,"name":"Jane","created_at":"2022-12-12T12:49:50Z"},"source":{"version":"1.9.7.Final","connector":"mysql","name":"mysql-json","ts_ms":1670849390000,"snapshot":"false","db":"example","sequence":null,"table":"users","server_id":1,"gtid":null,"file":"binlog.000002","pos":1645,"row":0,"thread":9,"query":null},"op":"c","ts_ms":1670849457961,"transaction":null}

{"before":{"id":1,"name":"Jane","created_at":"2022-12-12T12:49:50Z"},"after":{"id":1,"name":"Jane2","created_at":"2022-12-12T12:49:50Z"},"source":{"version":"1.9.7.Final","connector":"mysql","name":"mysql-json","ts_ms":1670849478000,"snapshot":"false","db":"example","sequence":null,"table":"users","server_id":1,"gtid":null,"file":"binlog.000002","pos":2209,"row":0,"thread":9,"query":null},"op":"u","ts_ms":1670849478737,"transaction":null}

{"before":{"id":1,"name":"Jane2","created_at":"2022-12-12T12:49:50Z"},"after":null,"source":{"version":"1.9.7.Final","connector":"mysql","name":"mysql-json","ts_ms":1670849491000,"snapshot":"false","db":"example","sequence":null,"table":"users","server_id":1,"gtid":null,"file":"binlog.000002","pos":2526,"row":0,"thread":9,"query":null},"op":"d","ts_ms":1670849491395,"transaction":null}
```

