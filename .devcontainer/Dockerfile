FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bullseye

# Install Rails (as vscode)
RUN su vscode -c "gem install rails webdrivers"
RUN su vscode -c "/usr/local/rvm/bin/rvm fix-permissions"

# Default value to allow debug server to serve content over GitHub Codespaces' port forwarding
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# OS packages you wanted
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends postgresql-client

# --- Node.js (via nvm) + Claude Code CLI ---
# These 'bash -lc' shells ensure nvm is sourced properly inside Docker build.
# Installs Node 20 (good LTS for most CLIs), sets it default, then installs the CLI globally.
RUN su vscode -c "bash -lc 'source /usr/local/share/nvm/nvm.sh \
  && nvm install 20 \
  && nvm alias default 20 \
  && nvm use 20 \
  && node -v && npm -v \
  && npm install -g @anthropic-ai/claude-code \
  && claude --version'"

# Make sure non-login shells inside the container can see nvm's Node on PATH
# (Most devcontainer terminals already source this; these lines make it more robust.)
RUN echo 'export NVM_DIR=\"/usr/local/share/nvm\"' | tee -a /etc/profile.d/nvm.sh \
 && echo '[ -s \"$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\"' >> /etc/profile.d/nvm.sh

# If you ever want to install additional global npm packages:
# RUN su vscode -c "bash -lc 'source /usr/local/share/nvm/nvm.sh && nvm use 20 && npm install -g <your-package-here>'" 2>&1
