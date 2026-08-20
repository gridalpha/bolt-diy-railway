# Authenticating gateway that fronts a private bolt.diy service on Railway.
FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY entrypoint.sh /usr/local/bin/gateway-entrypoint.sh
RUN chmod +x /usr/local/bin/gateway-entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/gateway-entrypoint.sh"]
