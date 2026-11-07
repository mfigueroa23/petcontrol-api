# syntax=docker/dockerfile:1

# Etapa 1: instala todas las dependencias, genera el cliente de Prisma y compila la API.
FROM node:26-alpine AS build
WORKDIR /app

RUN npm install --global pnpm@12.16.1

# El postinstall ejecuta `prisma generate`, que necesita el esquema y la configuración.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml prisma.config.ts ./
COPY prisma ./prisma
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm build

# Etapa 2: solo las dependencias de producción. Incluye el CLI de Prisma y su
# motor de migraciones, que usa el initContainer de Kubernetes (SDD 5.5).
FROM node:26-alpine AS deps
WORKDIR /app

RUN npm install --global pnpm@12.16.1

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml prisma.config.ts ./
COPY prisma ./prisma
RUN pnpm install --frozen-lockfile --prod

# Etapa 3: imagen final, sin pnpm ni código fuente, ejecutada sin privilegios de root.
FROM node:26-alpine
WORKDIR /app

ENV NODE_ENV=production

COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist
COPY --chown=node:node package.json prisma.config.ts ./
COPY --chown=node:node prisma ./prisma

USER node
EXPOSE 3000

# API: `node dist/main`. Migraciones (initContainer): `./node_modules/.bin/prisma migrate deploy`.
CMD ["node", "dist/main"]
