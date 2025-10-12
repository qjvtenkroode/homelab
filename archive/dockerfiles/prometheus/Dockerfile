FROM prom/prometheus
COPY ./prometheus.yml /etc/prometheus/prometheus.yml
ENV TZ=Europe/Amsterdam
EXPOSE 9090
ENTRYPOINT [ "prometheus", \
             "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]
USER root
