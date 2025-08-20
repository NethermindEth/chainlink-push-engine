# base node image

FROM node:24-bullseye-slim as base

# set for base and all layer that inherit from it

ENV NODE_ENV production

# Install all node_modules, including dev dependencies

FROM base as deps

WORKDIR /push-engine

ADD package.json ./
RUN npm install --include=dev

# Setup production node_modules

FROM base as production-deps

WORKDIR /push-engine

COPY --from=deps /push-engine/node_modules /push-engine/node_modules
ADD package.json ./
RUN npm prune --omit=dev

# Build the app

FROM base as build

WORKDIR /push-engine

COPY --from=deps /push-engine/node_modules /push-engine/node_modules

ADD . .
RUN npm run build

# Finally, build the production image with minimal footprint

FROM base

WORKDIR /push-engine

COPY --from=production-deps /push-engine/node_modules /push-engine/node_modules

COPY --from=build /push-engine/build /push-engine/build
COPY --from=build /push-engine/public /push-engine/public
ADD . .

# Create a non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 --gid 1001 nodeuser

# Set ownership of application files
RUN chown -R nodeuser:nodejs /push-engine

# Switch to non-root user for runtime
USER nodeuser

CMD ["npm", "start"]