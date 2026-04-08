FROM node:25-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN npm install -g pnpm@10.28.1

FROM base AS deps
WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json .npmrc ./
COPY packages/yucca-api-client/package.json packages/yucca-api-client/
COPY packages/yucca-sdk/orchestration-ui/package.json packages/yucca-sdk/orchestration-ui/
COPY packages/web/package.json packages/web/
RUN pnpm install --frozen-lockfile

FROM deps AS build
COPY packages/yucca-api-client/ packages/yucca-api-client/
COPY packages/yucca-sdk/orchestration-ui/ packages/yucca-sdk/orchestration-ui/
COPY packages/web/ packages/web/
RUN pnpm --filter yucca-api-client build
RUN pnpm --filter orchestration-ui build
RUN pnpm --filter web build

FROM base AS production
WORKDIR /app
COPY --from=build /app/packages/web/build build/
COPY --from=build /app/packages/web/package.json .

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000
CMD ["node", "build/index.js"]
