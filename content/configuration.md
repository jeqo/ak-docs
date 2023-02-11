# Configuration

Kafka uses key-value pairs in the [property file format](http://en.wikipedia.org/wiki/.properties) for configuration.
These values can be supplied either from a file or programmatically.

## 3.1 Broker Configs {#brokerconfigs .anchor-link}

The essential configurations are the following:

-   `broker.id`
-   `log.dirs`
-   `zookeeper.connect`

Topic-level configurations and defaults are discussed in more detail
[below](#topicconfigs).

<!--#include virtual="generated/kafka_config.html" -->

More details about broker configuration can be found in the scala class
`kafka.server.KafkaConfig`.

### 3.1.1 Updating Broker Configs {#dynamicbrokerconfigs .anchor-link}

From Kafka version 1.1 onwards, some of the broker configs can be
updated without restarting the broker. See the `Dynamic Update Mode`
column in [Broker Configs](#brokerconfigs) for the update mode of each
broker config.

-   `read-only`: Requires a broker restart for update
-   `per-broker`: May be updated dynamically for each broker
-   `cluster-wide`: May be updated dynamically as a cluster-wide
    default. May also be updated as a per-broker value for testing.

To alter the current broker configs for broker id 0 (for example, the
number of log cleaner threads):

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 0 --alter --add-config log.cleaner.threads=2
```

To describe the current dynamic broker configs for broker id 0:

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 0 --describe
```

To delete a config override and revert to the statically configured or
default value for broker id 0 (for example, the number of log cleaner
threads):

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-name 0 --alter --delete-config log.cleaner.threads
```

Some configs may be configured as a cluster-wide default to maintain
consistent values across the whole cluster. All brokers in the cluster
will process the cluster default update. For example, to update log
cleaner threads on all brokers:

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-default --alter --add-config log.cleaner.threads=2
```

To describe the currently configured dynamic cluster-wide default
configs:

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type brokers --entity-default --describe
```

All configs that are configurable at cluster level may also be
configured at per-broker level (e.g. for testing). If a config value is
defined at different levels, the following order of precedence is used:

-   Dynamic per-broker config stored in ZooKeeper
-   Dynamic cluster-wide default config stored in ZooKeeper
-   Static broker config from `server.properties`
-   Kafka default, see [broker configs](#brokerconfigs)

#### Updating Password Configs Dynamically

Password config values that are dynamically updated are encrypted before
storing in ZooKeeper. The broker config `password.encoder.secret` must
be configured in `server.properties` to enable dynamic update of
password configs. The secret may be different on different brokers.

The secret used for password encoding may be rotated with a rolling
restart of brokers. The old secret used for encoding passwords currently
in ZooKeeper must be provided in the static broker config
`password.encoder.old.secret` and the new secret must be provided in
`password.encoder.secret`. All dynamic password configs stored in
ZooKeeper will be re-encoded with the new secret when the broker starts
up.

In Kafka 1.1.x, all dynamically updated password configs must be
provided in every alter request when updating configs using
`kafka-configs.sh` even if the password config is not being altered.
This constraint will be removed in a future release.

#### Updating Password Configs in ZooKeeper Before Starting Brokers

From Kafka 2.0.0 onwards, `kafka-configs.sh` enables dynamic broker
configs to be updated using ZooKeeper before starting brokers for
bootstrapping. This enables all password configs to be stored in
encrypted form, avoiding the need for clear passwords in
`server.properties`. The broker config `password.encoder.secret` must
also be specified if any password configs are included in the alter
command. Additional encryption parameters may also be specified.
Password encoder configs will not be persisted in ZooKeeper. For
example, to store SSL key password for listener `INTERNAL` on broker 0:

``` line-numbers
> bin/kafka-configs.sh --zookeeper localhost:2182 --zk-tls-config-file zk_tls_config.properties --entity-type brokers --entity-name 0 --alter --add-config
    'listener.name.internal.ssl.key.password=key-password,password.encoder.secret=secret,password.encoder.iterations=8192'
```

The configuration `listener.name.internal.ssl.key.password` will be
persisted in ZooKeeper in encrypted form using the provided encoder
configs. The encoder secret and iterations are not persisted in
ZooKeeper.

#### Updating SSL Keystore of an Existing Listener

Brokers may be configured with SSL keystores with short validity periods
to reduce the risk of compromised certificates. Keystores may be updated
dynamically without restarting the broker. The config name must be
prefixed with the listener prefix `listener.name.{listenerName}.` so
that only the keystore config of a specific listener is updated. The
following configs may be updated in a single alter request at per-broker
level:

-   `ssl.keystore.type`
-   `ssl.keystore.location`
-   `ssl.keystore.password`
-   `ssl.key.password`

If the listener is the inter-broker listener, the update is allowed only
if the new keystore is trusted by the truststore configured for that
listener. For other listeners, no trust validation is performed on the
keystore by the broker. Certificates must be signed by the same
certificate authority that signed the old certificate to avoid any
client authentication failures.

#### Updating SSL Truststore of an Existing Listener

Broker truststores may be updated dynamically without restarting the
broker to add or remove certificates. Updated truststore will be used to
authenticate new client connections. The config name must be prefixed
with the listener prefix `listener.name.{listenerName}.` so that only
the truststore config of a specific listener is updated. The following
configs may be updated in a single alter request at per-broker level:

-   `ssl.truststore.type`
-   `ssl.truststore.location`
-   `ssl.truststore.password`

If the listener is the inter-broker listener, the update is allowed only
if the existing keystore for that listener is trusted by the new
truststore. For other listeners, no trust validation is performed by the
broker before the update. Removal of CA certificates used to sign client
certificates from the new truststore can lead to client authentication
failures.

#### Updating Default Topic Configuration

Default topic configuration options used by brokers may be updated
without broker restart. The configs are applied to topics without a
topic config override for the equivalent per-topic config. One or more
of these configs may be overridden at cluster-default level used by all
brokers.

-   `log.segment.bytes`
-   `log.roll.ms`
-   `log.roll.hours`
-   `log.roll.jitter.ms`
-   `log.roll.jitter.hours`
-   `log.index.size.max.bytes`
-   `log.flush.interval.messages`
-   `log.flush.interval.ms`
-   `log.retention.bytes`
-   `log.retention.ms`
-   `log.retention.minutes`
-   `log.retention.hours`
-   `log.index.interval.bytes`
-   `log.cleaner.delete.retention.ms`
-   `log.cleaner.min.compaction.lag.ms`
-   `log.cleaner.max.compaction.lag.ms`
-   `log.cleaner.min.cleanable.ratio`
-   `log.cleanup.policy`
-   `log.segment.delete.delay.ms`
-   `unclean.leader.election.enable`
-   `min.insync.replicas`
-   `max.message.bytes`
-   `compression.type`
-   `log.preallocate`
-   `log.message.timestamp.type`
-   `log.message.timestamp.difference.max.ms`

From Kafka version 2.0.0 onwards, unclean leader election is
automatically enabled by the controller when the config
`unclean.leader.election.enable` is dynamically updated. In Kafka
version 1.1.x, changes to `unclean.leader.election.enable` take effect
only when a new controller is elected. Controller re-election may be
forced by running:

``` line-numbers
> bin/zookeeper-shell.sh localhost
  rmr /controller
```

#### Updating Log Cleaner Configs

Log cleaner configs may be updated dynamically at cluster-default level
used by all brokers. The changes take effect on the next iteration of
log cleaning. One or more of these configs may be updated:

-   `log.cleaner.threads`
-   `log.cleaner.io.max.bytes.per.second`
-   `log.cleaner.dedupe.buffer.size`
-   `log.cleaner.io.buffer.size`
-   `log.cleaner.io.buffer.load.factor`
-   `log.cleaner.backoff.ms`

#### Updating Thread Configs

The size of various thread pools used by the broker may be updated
dynamically at cluster-default level used by all brokers. Updates are
restricted to the range `currentSize / 2` to `currentSize * 2` to ensure
that config updates are handled gracefully.

-   `num.network.threads`
-   `num.io.threads`
-   `num.replica.fetchers`
-   `num.recovery.threads.per.data.dir`
-   `log.cleaner.threads`
-   `background.threads`

#### Updating ConnectionQuota Configs

The maximum number of connections allowed for a given IP/host by the
broker may be updated dynamically at cluster-default level used by all
brokers. The changes will apply for new connection creations and the
existing connections count will be taken into account by the new limits.

-   `max.connections.per.ip`
-   `max.connections.per.ip.overrides`

#### Adding and Removing Listeners

Listeners may be added or removed dynamically. When a new listener is
added, security configs of the listener must be provided as listener
configs with the listener prefix `listener.name.{listenerName}.`. If the
new listener uses SASL, the JAAS configuration of the listener must be
provided using the JAAS configuration property `sasl.jaas.config` with
the listener and mechanism prefix. See [JAAS configuration for Kafka
brokers](#security_jaas_broker) for details.

In Kafka version 1.1.x, the listener used by the inter-broker listener
may not be updated dynamically. To update the inter-broker listener to a
new listener, the new listener may be added on all brokers without
restarting the broker. A rolling restart is then required to update
`inter.broker.listener.name`.

In addition to all the security configs of new listeners, the following
configs may be updated dynamically at per-broker level:

-   `listeners`
-   `advertised.listeners`
-   `listener.security.protocol.map`

Inter-broker listener must be configured using the static broker
configuration `inter.broker.listener.name` or
`security.inter.broker.protocol`.

## 3.2 Topic-Level Configs {#topicconfigs .anchor-link}

Configurations pertinent to topics have both a server default as well an
optional per-topic override. If no per-topic configuration is given the
server default is used. The override can be set at topic creation time
by giving one or more `--config` options. This example creates a topic
named *my-topic* with a custom max message size and flush rate:

``` line-numbers
> bin/kafka-topics.sh --bootstrap-server localhost:9092 --create --topic my-topic --partitions 1 \
  --replication-factor 1 --config max.message.bytes=64000 --config flush.messages=1
```

Overrides can also be changed or set later using the alter configs
command. This example updates the max message size for *my-topic*:

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my-topic
  --alter --add-config max.message.bytes=128000
```

To check overrides set on the topic you can do

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name my-topic --describe
```

To remove an override you can do

``` line-numbers
> bin/kafka-configs.sh --bootstrap-server localhost:9092  --entity-type topics --entity-name my-topic
  --alter --delete-config max.message.bytes
```

The following are the topic-level configurations. The server\'s default
configuration for this property is given under the Server Default
Property heading. A given server default config value only applies to a
topic if it does not have an explicit topic config override.
  
<!--#include virtual="generated/topic_config.html" -->

## 3.3 Producer Configs {#producerconfigs .anchor-link}

Below is the configuration of the producer:

<!--#include virtual="generated/producer_config.html" -->

## 3.4 Consumer Configs {#consumerconfigs .anchor-link}

Below is the configuration for the consumer:

<!--#include virtual="generated/consumer_config.html" -->

## 3.5 Kafka Connect Configs {#connectconfigs .anchor-link}

Below is the configuration of the Kafka Connect framework.
  
<!--#include virtual="generated/connect_config.html" -->

### 3.5.1 Source Connector Configs {#sourceconnectconfigs .anchor-link}

Below is the configuration of a source connector.
  
<!--#include virtual="generated/source_connector_config.html" -->

### 3.5.2 Sink Connector Configs {#sinkconnectconfigs .anchor-link}

Below is the configuration of a sink connector.
  
<!--#include virtual="generated/sink_connector_config.html" -->

## 3.6 Kafka Streams Configs {#streamsconfigs .anchor-link}

Below is the configuration of the Kafka Streams client library.
  
<!--#include virtual="generated/streams_config.html" -->

## 3.7 Admin Configs {#adminclientconfigs .anchor-link}

Below is the configuration of the Kafka Admin client library.
  
<!--#include virtual="generated/admin_client_config.html" -->
