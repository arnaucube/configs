# nginx-config

In `/etc/nginx/sites-enabled`

- file: `sub.domain.com`:
```
server {
        server_name sub.domain.com;

        location / {
                proxy_pass http://localhost:PORT;
        }
}
```
Then generate certificate with `certbot`
