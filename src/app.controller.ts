import { Controller, Get, Header } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  /**
   * Ruta de salud para las sondas de Kubernetes y el pipeline (SDD 5.5).
   * No consulta la base de datos: una caída de PostgreSQL no debe reiniciar la API.
   */
  @Get('healthz')
  @Header('Content-Type', 'text/plain; charset=utf-8')
  @Header('Cache-Control', 'no-store')
  getHealth(): string {
    return 'ok';
  }
}
