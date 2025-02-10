# prometheus + graphana to monitor node
*(src: https://theawesomegarage.com/blog/monitor-your-raspberry-pi-with-prometheus-and-grafana)*

```
sudo apt install prometheus

sudo apt-get install prometheus-node-exporter
```

now visiting http://localhost:9100/metrics should return metrics

start the prometheus-node-exporter:
```
sudo systemctl enable prometheus-node-exporter
sudo systemctl start prometheus-node-exporter
```

for monitoring too the mounted devices (ie. usb):
edit `/etc/default/prometheus-node-exporter`:
```
ARGS="--collector.filesystem.mount-points-exclude="^/(dev|proc|run|sys|mnt|var/lib/docker/.+)($|/)""
```

restart the service:
`sudo systemctl restart prometheus-node-exporter`


Install Graphana: https://grafana.com/docs/grafana/latest/setup-grafana/installation/
