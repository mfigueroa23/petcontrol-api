import { Global, Module } from '@nestjs/common';
import { PrismaService } from './services/prisma.service';

/**
 * Acceso a la base de datos con Prisma (ADR-005). Es global para que los
 * servicios de cada módulo inyecten PrismaService sin importarlo.
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
