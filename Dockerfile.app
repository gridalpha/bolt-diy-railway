# bolt.diy for Railway.
#
# The published image is built on node:22-bookworm-slim, whose own build ends in
# `apt-get purge --auto-remove` and takes ca-certificates with it: /etc/ssl/certs
# is empty and the package is not installed. Node carries its own root store so
# the app boots and serves fine, but wrangler runs the Remix server inside
# workerd, which uses the *system* trust store — so every server-side HTTPS call
# fails with
#
#   kj/compat/tls.c++:256: TLS peer's certificate is not trusted;
#   reason = unable to get local issuer certificate
#
# which is every LLM provider request, the git proxy behind "clone a repo" and
# the starter templates, and the GitHub / GitLab / Netlify / Vercel / Supabase
# integrations. This layer restores the trust store; nothing else is changed, so
# ENTRYPOINT, CMD and the image's own environment are inherited as published.
FROM ghcr.io/stackblitz-labs/bolt.diy:latest

RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates \
	&& update-ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# workerd resolves its trust store through OpenSSL's default paths, which are not
# Debian's. Name the bundle explicitly rather than relying on the compiled-in one.
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
	SSL_CERT_DIR=/etc/ssl/certs

EXPOSE 5173
