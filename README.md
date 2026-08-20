# bolt.diy on Railway — authenticating gateway

A one-image [Caddy](https://caddyserver.com) gateway that puts HTTP basic auth in
front of a private [bolt.diy](https://github.com/stackblitz-labs/bolt.diy) service.

bolt.diy ships no authentication, and its `/api/git-proxy/*` route forwards a
request to any `https` host it is given. Published directly, a deployment is an
open forward proxy and — once any provider key is configured on it — an open
door to the operator's model credits. So the app service is kept private and this
gateway is the only service with a public domain.

## Why a repo instead of a start command

Caddy's `basic_auth` takes a **bcrypt hash**, never a plaintext password. A hash
cannot be expressed as a Railway variable, so `entrypoint.sh` derives it at boot
from the one secret the deployer supplies.

## Variables

| Variable | Default | Purpose |
|---|---|---|
| `BOLT_AUTH_PASSWORD` | *(none — required)* | Password for the gateway. The container refuses to start without it. |
| `BOLT_AUTH_USERNAME` | `admin` | Username for the gateway. |
| `BOLT_UPSTREAM` | `boltdiy.railway.internal:5173` | Private address of the bolt.diy service. |
| `BOLT_AUTH_PASSWORD_HASH` | *(unset)* | Override: supply your own bcrypt hash (`caddy hash-password`) and `BOLT_AUTH_PASSWORD` is ignored. |
| `PORT` | `8080` | Set by Railway. |

Health check: `/healthz`, served by Caddy itself and outside the auth handler.

## Local check

```sh
docker build -t bolt-gateway .
docker run --rm -e BOLT_AUTH_PASSWORD=hunter2 -e BOLT_UPSTREAM=host.docker.internal:5173 -p 8080:8080 bolt-gateway
```
