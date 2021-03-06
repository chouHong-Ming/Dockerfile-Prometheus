FROM centos:7.7.1908


ARG PROMETHEUS_VERSION="2.23.0"
ARG ALERTMANAGER_VERSION="0.21.0"
ARG PUSHGATEWAY_VERSION="1.3.1"


RUN yum update -y && \
    yum install -y epel-release wget

RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
    tar zxvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
RUN wget https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz && \
    tar zxvf alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz
RUN wget https://github.com/prometheus/pushgateway/releases/download/v${PUSHGATEWAY_VERSION}/pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz && \
    tar zxvf pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64.tar.gz


RUN mkdir -p /etc/prometheus && \
    mkdir -p /usr/share/prometheus && \
    mkdir -p /prometheus
RUN cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /bin/prometheus && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /bin/promtool && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml && \
    cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /usr/share/prometheus/ && \
    cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /usr/share/prometheus/ && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/LICENSE /LICENSE && \
    cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/NOTICE /NOTICE
RUN ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/


RUN mkdir -p /etc/alertmanager && \
    mkdir -p /alertmanager
RUN cp alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager /bin/alertmanager && \
    cp alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/amtool /bin/amtool && \
    cp alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager.yml /etc/alertmanager/alertmanager.yml


RUN mkdir -p /pushgateway
RUN cp pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64/pushgateway /bin/pushgateway


RUN rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64* alertmanager-${ALERTMANAGER_VERSION}.linux-amd64* pushgateway-${PUSHGATEWAY_VERSION}.linux-amd64* && \
    yum remove -y wget

RUN mkdir -p /prometheus-rule


ADD asset/entrypoint.sh .
ENTRYPOINT ["sh", "entrypoint.sh"]

