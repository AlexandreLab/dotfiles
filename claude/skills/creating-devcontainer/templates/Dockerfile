# Base image: current Node.js LTS, which runs the Node-based agent CLIs.
# For a Python-first project, keep this base and add uv below rather than
# switching images, so the Node-based agents still work.
FROM node:24

ARG TZ=UTC
ENV TZ="$TZ"

# System tools
RUN apt-get update && apt-get install -y --no-install-recommends \
  # Core
  git curl wget jq unzip less sudo procps \
  # Firewall (init-firewall.sh needs all of these)
  iptables ipset iproute2 dnsutils aggregate \
  # Shell
  zsh fzf nano vim \
  # GitHub CLI
  gh \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Directories
RUN mkdir -p /commandhistory /workspace /home/node/.claude \
  && chown -R node:node /commandhistory /workspace /home/node/.claude

ENV SHELL=/bin/zsh
ENV EDITOR=nano
ENV VISUAL=nano

# Persist shell history across container restarts
RUN echo "export PROMPT_COMMAND='history -a'" >> /home/node/.bashrc \
  && echo "export HISTFILE=/commandhistory/.bash_history" >> /home/node/.bashrc

# Firewall script. The node user may run only this script as root, not general sudo.
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
RUN chmod +x /usr/local/bin/init-firewall.sh \
  && echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
     > /etc/sudoers.d/node-firewall \
  && chmod 0440 /etc/sudoers.d/node-firewall

# Non-root user from here on
USER node
WORKDIR /workspace

# User-level install locations for npm globals, the Claude Code native installer and uv tools
ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=/home/node/.local/bin:/home/node/.npm-global/bin:$PATH

# AI agent CLIs: keep the ones you need.
# These run at build time, before the firewall exists. At run time, each agent's
# API domain must be in the allowlist in init-firewall.sh.

# Claude Code (native installer, installs to ~/.local/bin)
RUN curl -fsSL https://claude.ai/install.sh | bash

# OpenAI Codex
# RUN npm install -g @openai/codex

# Gemini CLI
# RUN npm install -g @google/gemini-cli

# Aider, via uv (uv fetches a Python if the image lacks a suitable one)
# RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
#   && uv tool install aider-chat
