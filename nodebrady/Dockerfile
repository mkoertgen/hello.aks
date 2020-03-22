FROM node:13.10.1-alpine3.11 AS base
WORKDIR /app

FROM base AS dependencies
COPY package*.json ./
RUN npm ci

FROM dependencies AS build
WORKDIR /app
COPY . /app
RUN npm run test

FROM base AS release
WORKDIR /app
COPY --from=dependencies /app/package.json ./
RUN npm install --only=production
COPY --from=build /app ./
CMD ["npm", "start"]
