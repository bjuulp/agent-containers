FROM agent-base

USER node

RUN unset NODE_USE_ENV_PROXY HTTP_PPOXY HTTPS_PROXY http_proxy https_proxy && \
    npm install -g --ignore-scripts @earendil-works/pi-coding-agent
