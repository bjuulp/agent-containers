FROM agent-base

USER node

RUN unset NODE_USE_ENV_PROXY HTTP_PPOXY HTTPS_PROXY http_proxy https_proxy && \
    curl -fsSL https://opencode.ai/v2/install | bash

