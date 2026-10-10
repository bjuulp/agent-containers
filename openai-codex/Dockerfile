FROM agent-base

USER node

RUN npm install -g @openai/codex

CMD ["codex", "--approval-mode", "auto-edit"]
