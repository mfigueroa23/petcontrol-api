import { existsSync } from 'node:fs';
import { defineConfig } from 'prisma/config';

// Prisma 7 no carga el archivo .env. En Local se carga con Node; en Producción
// las variables llegan desde el Secret de Kubernetes (SDD 6.4).
if (existsSync('.env')) {
  process.loadEnvFile('.env');
}

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    // Datos ficticios para Local (Plan de Pruebas 5.8). El archivo no se versiona.
    seed: 'tsx prisma/seed.ts',
  },
  // Se leen sin `env()` para que `prisma generate` funcione sin base de datos
  // (CI y construcción de la imagen). Las migraciones fallan si falta la URL.
  datasource: {
    url: process.env.DATABASE_URL,
    shadowDatabaseUrl: process.env.SHADOW_DATABASE_URL,
  },
});
