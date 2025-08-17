FROM subquerynetwork/subql-node-ethereum:latest
USER root

# try apk (alpine) then apt-get (debian/ubuntu) installations
RUN if command -v apk >/dev/null 2>&1; then \
    apk add --no-cache curl; \
    elif command -v apt-get >/dev/null 2>&1; then \
    apt-get update && apt-get install -y curl && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    else \
    echo "No known package manager to install curl"; exit 1; \
    fi

USER node