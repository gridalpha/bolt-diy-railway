#!/bin/sh
# Derives the gateway's credentials and starts Caddy.
#
# Caddy's basic_auth takes a bcrypt hash and never a plaintext password, so the
# hash cannot be expressed as a Railway variable and is computed here at boot
# from the single secret the deployer supplies.
set -eu

: "${PORT:=8080}"
: "${BOLT_UPSTREAM:=boltdiy.railway.internal:5173}"
: "${BOLT_AUTH_USERNAME:=admin}"

if [ -z "${BOLT_AUTH_PASSWORD_HASH:-}" ]; then
	if [ -z "${BOLT_AUTH_PASSWORD:-}" ]; then
		echo "FATAL: set BOLT_AUTH_PASSWORD (or BOLT_AUTH_PASSWORD_HASH for a" >&2
		echo "       pre-computed bcrypt hash). Refusing to publish bolt.diy" >&2
		echo "       without authentication." >&2
		exit 1
	fi

	BOLT_AUTH_PASSWORD_HASH="$(caddy hash-password --plaintext "$BOLT_AUTH_PASSWORD")"
fi

unset BOLT_AUTH_PASSWORD
export PORT BOLT_UPSTREAM BOLT_AUTH_USERNAME BOLT_AUTH_PASSWORD_HASH

echo "gateway: :${PORT} -> ${BOLT_UPSTREAM}, basic auth as '${BOLT_AUTH_USERNAME}'"

caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
