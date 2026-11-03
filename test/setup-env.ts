import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { parseEnv } from 'node:util';

// Las pruebas de integración usan la base de datos de DATABASE_URL.
// En Local se lee del archivo .env; en CI la entrega el pipeline.
// No se usa process.loadEnvFile(): Jest entrega a cada prueba una copia de
// process.env, y esa función escribe en el process.env real.
const envFile = resolve(__dirname, '..', '.env');
if (existsSync(envFile)) {
  const variables = parseEnv(readFileSync(envFile, 'utf8'));
  for (const [name, value] of Object.entries(variables)) {
    process.env[name] ??= value;
  }
}
