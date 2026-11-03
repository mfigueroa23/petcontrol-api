import { existsSync } from 'node:fs';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  // En Local las variables se leen del archivo .env; en Producción llegan
  // desde el ConfigMap y el Secret de Kubernetes (SDD 6.4).
  if (existsSync('.env')) {
    process.loadEnvFile('.env');
  }

  const app = await NestFactory.create(AppModule);
  // Cierra la conexión a la base de datos al recibir SIGTERM de Kubernetes.
  app.enableShutdownHooks();
  await app.listen(process.env.PORT ?? 3000);
}
void bootstrap();
