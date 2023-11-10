FROM debian:10.6-slim

ENV VERSION_FULL=2.4.2-4c6fdc49
ENV VERSION=2.4.2
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
