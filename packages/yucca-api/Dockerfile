FROM node:25-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN npm install -g pnpm@10.28.1

FROM base AS deps
WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json .npmrc ./
COPY packages/common/package.json packages/common/
COPY packages/yucca-api/package.json packages/yucca-api/
RUN pnpm install --frozen-lockfile

FROM deps AS build
COPY packages/common/ packages/common/
COPY packages/yucca-api/ packages/yucca-api/
RUN pnpm --filter @common/server build
RUN pnpm --filter yucca-api build

FROM base AS production
WORKDIR /app
COPY pnpm-lock.yaml pnpm-workspace.yaml package.json .npmrc ./
COPY packages/common/package.json packages/common/
COPY packages/yucca-api/package.json packages/yucca-api/
RUN pnpm install --frozen-lockfile --prod
COPY --from=build /app/packages/common/dist packages/common/dist
COPY --from=build /app/packages/yucca-api/dist packages/yucca-api/dist

WORKDIR /app/packages/yucca-api
EXPOSE 3020
CMD ["node", "dist/main"]
