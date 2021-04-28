# Dockerfile-Prometheus
Use to build the image to run the Prometheus, AlertManager, and PushGateway service

## Description
An container image for running Prometheus, AlertManager, and PushGateway and let you can run there three services in one container or more. So that you can manage your exporter more easily.

## Run
### Docker
You can run the image by using `docker` command. To use `-p` option to expose the service.

`docker run -p 9090:9090/tcp -p 9093:9093/tcp -p 9091:9091/tcp chouhongming/prometheus`

Also, you must use `-v` option to mount the configure file and the data file if you have your own Prometheus and AlertManager settings and you want to keep everything.

`docker run -p 9090:9090/tcp -p 9093:9093/tcp -p 9091:9091/tcp -v ./prometheus.yml:/etc/prometheus/prometheus.yml -v ./alertmanager.yml:/etc/alertmanager/alertmanager.yml -v ./prometheus_storage:/prometheus -v ./alertmanager_storage:/alertmanager -v ./prometheus-rule:/prometheus-rule chouhongming/prometheus`

### Docker Compose
You can use the `docker-compose.yml` file to run the service easily. Due to the different directory structure, you may need to change your working directory to example directory or use `-f` option to start the service.

`docker-compose -f example/docker-compose.yml up -d`

The command for stopping the service, if you use `-f` option to start the service.

`docker-compose -f example/docker-compose.yml down`

And you can use exec action to login to the container to run the command that you want.

`docker-compose -f example/docker-compose.yml exec prometheus bash`

If you want to rebuild the image, you can replace `image: chouhongming/prometheus` with `build: ..` and run the `docker-compose` with `--build` option, for example:

```
version: "3.7"
services:
  prometheus:
    build:
      context: ..
      dockerfile: Alpine.Dockerfile
    ports:
      - "22:22/tcp"
      - "80:80/tcp"
```

`docker-compose -f example/docker-compose.yml up -d --build`

### Kubernetes
You can copy the `k8s-resource.yml` file and do the following step to let the setting be correct:
1. To replace the word `[YOUR_K8S_NAMESPACE]` with the namespace that you want to apply the service.
2. To replace the word `[YOUR_NFS_PATH]` and `[YOUR_NFS_ADDRESS]` with your NFS setting. If you don't use NFS as your _PersistentVolume_, you can replace `nfs` section with your storage setting.

    ```yaml
      nfs:
        path: [YOUR_NFS_PATH]
        server: [YOUR_NFS_ADDRESS]
    ```
3. To replace the word `[YOUR_K8S_DOMAIN]` with your Kubernetes domain that is set in the `Cluster Configuration`. If you didn't change the default setting, that may be `cluster.local`.
4. To replace the word `[YOUR_K8S_HOST_IP]` with your Kubernetes host IP that you want to monitor it, you may have several IPs to instead of this word.
5. To replace the word `[YOUR_SLACK_URL]` and `[YOUR_SLACK_CHANNEL]` with your Slack bot URL and the channel that you want to receive the message to that the notification works.
6. To replace the word `[YOUR_DOMAIN]` with your domain name to let Traefik redirect the traffic into Prometheus Pod if you use Traefik as your Ingress controller.
7. If you also use Traefik 2.0+ as your Kubernetes ingress controller, you can replace the word `[YOUR_HTTPS_REDIRECT_MIDDLEWARE]` and `[YOUR_RESOLVER_NAME]` with your middleware of HTTPS redirector and your cert resolver. Or you can delete the YAML section of the two IngressRoute and add the new one to fit your ingress controller. Also, you can delete the YAML sections of the IngressRoute is called `prometheus-web` and `prometheus-websecure` and you can delete the following section in the `prometheus-web` IngressRoute section if you don't want to use HTTPS.

    ```yaml
        middlewares:
        - name: [YOUR_K8S_REDIRECT-MIDDLEWARES]
    ```

After your done the `k8s-resource.yml` file, you can apply to the Kubernetes cluster.

`kubectl apply -f k8s-resource.yml`

## Volume
- /etc/prometheus/prometheus.yml

    To import your own Prometheus settings. You can edit the example for the specific service and mount it again.

- /etc/alertmanager/alertmanager.yml

    To import your own AlertManager settings. You can edit the example for the specific service and mount it again.

- /prometheus

    To save the data that Prometheus produces when AlertManager running.

- /alertmanager

    To save the data that AlertManager produces when AlertManager running.

- /prometheus-rule

    To save the YAML file of Prometheus rule.

## Environment
- PROMETHEUS=true

    Set `ture` to enable Prometheus. If you don't provide the Prometheus settings or you mount it in the wrong path, it may set to `false` automatically or run with default settings.

- ALERTMANAGER=true

    Set `ture` to enable AlertManager. If you don't provide the AlertManager settings or you mount it in the wrong path, it may set to `false` automatically or run with default settings.

- PUSHGATEWAY=true

    Set `ture` to enable PushGateway.

- TIMEZONE=UTC

    Set the timezone in the container.

- PROMETHEUS_OPT=

    Provide more option/parameter when the Prometheus startup.
    There is the option that the Prometheus can use:

    ```
    usage: prometheus [<flags>]

    The Prometheus monitoring server

    Flags:
      -h, --help                     Show context-sensitive help (also try --help-long and --help-man).
          --version                  Show application version.
          --config.file="prometheus.yml"  
                                    Prometheus configuration file path.
          --web.listen-address="0.0.0.0:9090"  
                                    Address to listen on for UI, API, and telemetry.
          --web.read-timeout=5m      Maximum duration before timing out read of the request, and closing idle connections.
          --web.max-connections=512  Maximum number of simultaneous connections.
          --web.external-url=<URL>   The URL under which Prometheus is externally reachable (for example, if Prometheus is served via a reverse proxy). Used for generating relative and
                                    absolute links back to Prometheus itself. If the URL has a path portion, it will be used to prefix all HTTP endpoints served by Prometheus. If omitted,
                                    relevant URL components will be derived automatically.
          --web.route-prefix=<path>  Prefix for the internal routes of web endpoints. Defaults to path of --web.external-url.
          --web.user-assets=<path>   Path to static asset directory, available at /user.
          --web.enable-lifecycle     Enable shutdown and reload via HTTP request.
          --web.enable-admin-api     Enable API endpoints for admin control actions.
          --web.console.templates="consoles"  
                                    Path to the console template directory, available at /consoles.
          --web.console.libraries="console_libraries"  
                                    Path to the console library directory.
          --web.page-title="Prometheus Time Series Collection and Processing Server"  
                                    Document title of Prometheus instance.
          --web.cors.origin=".*"     Regex for CORS origin. It is fully anchored. Example: 'https?://(domain1|domain2)\.com'
          --storage.tsdb.path="data/"  
                                    Base path for metrics storage.
          --storage.tsdb.retention=STORAGE.TSDB.RETENTION  
                                    [DEPRECATED] How long to retain samples in storage. This flag has been deprecated, use "storage.tsdb.retention.time" instead.
          --storage.tsdb.retention.time=STORAGE.TSDB.RETENTION.TIME  
                                    How long to retain samples in storage. When this flag is set it overrides "storage.tsdb.retention". If neither this flag nor "storage.tsdb.retention"
                                    nor "storage.tsdb.retention.size" is set, the retention time defaults to 15d. Units Supported: y, w, d, h, m, s, ms.
          --storage.tsdb.retention.size=STORAGE.TSDB.RETENTION.SIZE  
                                    [EXPERIMENTAL] Maximum number of bytes that can be stored for blocks. A unit is required, supported units: B, KB, MB, GB, TB, PB, EB. Ex: "512MB". This
                                    flag is experimental and can be changed in future releases.
          --storage.tsdb.no-lockfile  
                                    Do not create lockfile in data directory.
          --storage.tsdb.allow-overlapping-blocks  
                                    [EXPERIMENTAL] Allow overlapping blocks, which in turn enables vertical compaction and vertical query merge.
          --storage.tsdb.wal-compression  
                                    Compress the tsdb WAL.
          --storage.remote.flush-deadline=<duration>  
                                    How long to wait flushing sample on shutdown or config reload.
          --storage.remote.read-sample-limit=5e7  
                                    Maximum overall number of samples to return via the remote read interface, in a single query. 0 means no limit. This limit is ignored for streamed
                                    response types.
          --storage.remote.read-concurrent-limit=10  
                                    Maximum number of concurrent remote read calls. 0 means no limit.
          --storage.remote.read-max-bytes-in-frame=1048576  
                                    Maximum number of bytes in a single frame for streaming remote read response types before marshalling. Note that client might have limit on frame size
                                    as well. 1MB as recommended by protobuf by default.
          --rules.alert.for-outage-tolerance=1h  
                                    Max time to tolerate prometheus outage for restoring "for" state of alert.
          --rules.alert.for-grace-period=10m  
                                    Minimum duration between alert and restored "for" state. This is maintained only for alerts with configured "for" time greater than grace period.
          --rules.alert.resend-delay=1m  
                                    Minimum amount of time to wait before resending an alert to Alertmanager.
          --alertmanager.notification-queue-capacity=10000  
                                    The capacity of the queue for pending Alertmanager notifications.
          --alertmanager.timeout=10s  
                                    Timeout for sending alerts to Alertmanager.
          --query.lookback-delta=5m  The maximum lookback duration for retrieving metrics during expression evaluations and federation.
          --query.timeout=2m         Maximum time a query may take before being aborted.
          --query.max-concurrency=20  
                                    Maximum number of queries executed concurrently.
          --query.max-samples=50000000  
                                    Maximum number of samples a single query can load into memory. Note that queries will fail if they try to load more samples than this into memory, so
                                    this also limits the number of samples a query can return.
          --log.level=info           Only log messages with the given severity or above. One of: [debug, info, warn, error]
          --log.format=logfmt        Output format of log messages. One of: [logfmt, json]
    ```

- ALERTMANAGER_OPT=

    Provide more option/parameter when the AlertManager startup.
    There is the option that the AlertManager can use:

    ```
    usage: alertmanager [<flags>]

    Flags:
      -h, --help                     Show context-sensitive help (also try --help-long and --help-man).
          --config.file="alertmanager.yml"  
                                    Alertmanager configuration file name.
          --storage.path="data/"     Base path for data storage.
          --data.retention=120h      How long to keep data for.
          --alerts.gc-interval=30m   Interval between alert GC.
          --web.external-url=WEB.EXTERNAL-URL  
                                    The URL under which Alertmanager is externally reachable (for example, if Alertmanager is served via a reverse proxy). Used for generating relative and
                                    absolute links back to Alertmanager itself. If the URL has a path portion, it will be used to prefix all HTTP endpoints served by Alertmanager. If
                                    omitted, relevant URL components will be derived automatically.
          --web.route-prefix=WEB.ROUTE-PREFIX  
                                    Prefix for the internal routes of web endpoints. Defaults to path of --web.external-url.
          --web.listen-address=":9093"  
                                    Address to listen on for the web interface and API.
          --web.get-concurrency=0    Maximum number of GET requests processed concurrently. If negative or zero, the limit is GOMAXPROC or 8, whichever is larger.
          --web.timeout=0            Timeout for HTTP requests. If negative or zero, no timeout is set.
          --cluster.listen-address="0.0.0.0:9094"  
                                    Listen address for cluster. Set to empty string to disable HA mode.
          --cluster.advertise-address=CLUSTER.ADVERTISE-ADDRESS  
                                    Explicit address to advertise in cluster.
          --cluster.peer=CLUSTER.PEER ...  
                                    Initial peers (may be repeated).
          --cluster.peer-timeout=15s  
                                    Time to wait between peers to send notifications.
          --cluster.gossip-interval=200ms  
                                    Interval between sending gossip messages. By lowering this value (more frequent) gossip messages are propagated across the cluster more quickly at the
                                    expense of increased bandwidth.
          --cluster.pushpull-interval=1m0s  
                                    Interval for gossip state syncs. Setting this interval lower (more frequent) will increase convergence speeds across larger clusters at the expense of
                                    increased bandwidth usage.
          --cluster.tcp-timeout=10s  Timeout for establishing a stream connection with a remote node for a full state sync, and for stream read and write operations.
          --cluster.probe-timeout=500ms  
                                    Timeout to wait for an ack from a probed node before assuming it is unhealthy. This should be set to 99-percentile of RTT (round-trip time) on your
                                    network.
          --cluster.probe-interval=1s  
                                    Interval between random node probes. Setting this lower (more frequent) will cause the cluster to detect failed nodes more quickly at the expense of
                                    increased bandwidth usage.
          --cluster.settle-timeout=1m0s  
                                    Maximum time to wait for cluster connections to settle before evaluating notifications.
          --cluster.reconnect-interval=10s  
                                    Interval between attempting to reconnect to lost peers.
          --cluster.reconnect-timeout=6h0m0s  
                                    Length of time to attempt to reconnect to a lost peer.
          --log.level=info           Only log messages with the given severity or above. One of: [debug, info, warn, error]
          --log.format=logfmt        Output format of log messages. One of: [logfmt, json]
          --version                  Show application version.
    ```

- PUSHGATEWAY_OPT=

    Provide more option/parameter when the PushGateway startup.
    There is the option that the PushGateway can use:

    ```
    usage: pushgateway [<flags>]

    The Pushgateway

    Flags:
      -h, --help                     Show context-sensitive help (also try --help-long and --help-man).
          --web.listen-address=":9091"  
                                    Address to listen on for the web interface, API, and telemetry.
          --web.telemetry-path="/metrics"  
                                    Path under which to expose metrics.
          --web.external-url=        The URL under which the Pushgateway is externally reachable.
          --web.route-prefix=""      Prefix for the internal routes of web endpoints. Defaults to the path of --web.external-url.
          --web.enable-lifecycle     Enable shutdown via HTTP request.
          --web.enable-admin-api     Enable API endpoints for admin control actions.
          --persistence.file=""      File to persist metrics. If empty, metrics are only kept in memory.
          --persistence.interval=5m  The minimum interval at which to write out the persistence file.
          --push.disable-consistency-check  
                                    Do not check consistency of pushed metrics. DANGEROUS.
          --log.level=info           Only log messages with the given severity or above. One of: [debug, info, warn, error]
          --log.format=logfmt        Output format of log messages. One of: [logfmt, json]
          --version                  Show application version.
    ```

