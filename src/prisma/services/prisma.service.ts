import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../generated/prisma/client';

/**
 * Cliente de Prisma compartido por los servicios de todos los módulos (ADR-005).
 * Solo los servicios acceden a la base de datos (SDD 5.4).
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  constructor() {
    const connectionString = process.env.DATABASE_URL;
    if (!connectionString) {
      throw new Error('La variable de entorno DATABASE_URL no está definida.');
    }
    super({ adapter: new PrismaPg({ connectionString }) });
  }

  /**
   * Comprueba la conexión al iniciar, para que la API no arranque sin base de datos.
   * Con el adaptador de pg, $connect() no abre una conexión, por eso se ejecuta una consulta.
   */
  async onModuleInit(): Promise<void> {
    await this.$connect();
    await this.$queryRaw`SELECT 1`;
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }
}
