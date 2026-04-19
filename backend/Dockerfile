FROM node:20-bookworm-slim AS base

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production

FROM base AS deps

COPY package*.json ./
RUN npm ci --omit=dev \
    && npm cache clean --force

COPY prisma ./prisma
RUN npx prisma generate

FROM base AS runtime

COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --from=deps --chown=node:node /app/prisma ./prisma
COPY --chown=node:node package*.json ./
COPY --chown=node:node index.js ./
COPY --chown=node:node docker-entrypoint.sh ./
COPY --chown=node:node src ./src

RUN chmod +x docker-entrypoint.sh

USER node

EXPOSE 5000

ENTRYPOINT ["./docker-entrypoint.sh"]
