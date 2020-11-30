FROM debian:10.6-slim

ENV VERSION_FULL=2.3.3-fc2c6ae8
ENV VERSION=2.3.3
ENV GIT=https://github.com/qjvtenkroode/homelab-cribl

RUN apt-get update \
    && apt-get -y install curl git \
    && curl https://cdn.cribl.io/dl/${VERSION}/cribl-${VERSION_FULL}-linux-x64.tgz \
    | tar -zxvC /opt/

EXPOSE 9000

CMD git clone ${GIT} \
    && mkdir /opt/cribl/local \
    && mv homelab-cribl/* /opt/cribl/local \
    && /opt/cribl/bin/cribl start \
    && tail -f /opt/cribl/log/*.log
