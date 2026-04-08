FROM node:25-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN npm install -g pnpm@10.28.1

FROM base AS deps
WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json .npmrc ./
COPY packages/ packages/
RUN pnpm install --frozen-lockfile

FROM deps AS build
RUN pnpm --filter yucca-api-client build
RUN pnpm --filter orchestration-ui build
RUN pnpm --filter web lingui:compile
RUN pnpm --filter web build

FROM base AS production
WORKDIR /app
COPY --from=build /app/ .

WORKDIR /app/packages/web
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000
CMD ["node", "build/index.js"]
