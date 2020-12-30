#! /bin/bash


test -z $PROMETHEUS && PROMETHEUS="true"
test -z $ALERTMANAGER && ALERTMANAGER="true"
test -z $PUSHGATEWAY && PUSHGATEWAY="true"
test -z $TIMEZONE && TIMEZONE="UTC"
test -z $PROMETHEUS_OPT || echo "Run Prometheus wiht option"$PROMETHEUS_OPT
test -z $ALERTMANAGER_OPT || echo "Run AlertManager wiht option"$ALERTMANAGER_OPT
test -z $PUSHGATEWAY_OPT || echo "Run PushGateway wiht option"$PUSHGATEWAY_OPT


if [ ! -f /etc/prometheus/prometheus.yml ]; then
    echo "[Info] Not found prometheus.yml, Prometheus will not be started."
    PROMETHEUS="false"
fi
if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
    echo "[Info] Not found alertmanager.yml, AlertManager will not be started."
    ALERTMANAGER="false"
fi


ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime


if [ $PROMETHEUS == "true" ]; then
    if [ $PUSHGATEWAY == "true" ]; then
        /bin/pushgateway $PUSHGATEWAY_OPT >> /var/log/pushgateway.log 2>&1 &
    fi
    if [ $ALERTMANAGER == "true" ]; then
        /bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml \
            --storage.path=/alertmanager \
            $ALERTMANAGER_OPT >> /var/log/alertmanager.log 2>&1 &
    fi
    /bin/prometheus --config.file=/etc/prometheus/prometheus.yml \
        --storage.tsdb.path=/prometheus \
        --web.console.libraries=/usr/share/prometheus/console_libraries \
        --web.console.templates=/usr/share/prometheus/consoles \
        $PROMETHEUS_OPT
elif [ $ALERTMANAGER == "true" ]; then
    if [ $PUSHGATEWAY == "true" ]; then
        /bin/pushgateway $PUSHGATEWAY_OPT >> /var/log/pushgateway.log 2>&1 &
    fi
    /bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml \
        --storage.path=/alertmanager \
        $ALERTMANAGER_OPT
else
    /bin/pushgateway $PUSHGATEWAY_OPT 
fi

