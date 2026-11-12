FROM node:22-slim
RUN apt-get update -qq && apt-get install -y -qq curl >/dev/null && rm -rf /var/lib/apt/lists/*
RUN useradd -m dev
USER dev
WORKDIR /home/dev
COPY --chown=dev template/ /home/dev/
RUN cd app && npm install --silent && npm config set update-notifier false
COPY --chown=dev scripts /home/dev/scripts
CMD ["bash", "scripts/test.sh"]
