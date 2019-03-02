# nginx-config

In `/etc/nginx/sites-enabled`

- file: `sub.domain.com`:
```
server {
        server_name sub.domain.com;

        location / {
                proxy_pass http://localhost:PORT;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection "upgrade";
                proxy_read_timeout 86400;
        }
}
```
Then generate certificate with `certbot`
