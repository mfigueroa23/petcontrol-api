# petcontrol-api

Backend de **Control de Mascotas**. Es un monolito modular en NestJS (ADR-001), con un módulo de NestJS por dominio funcional. El frontend está en el repositorio `petcontrol-web` (ADR-010).

La documentación del proyecto (SRS, SDD y TD) está en Confluence, en el espacio `CDM`, y los tickets en Jira, en el proyecto `CDM`.

## Requisitos

- Node.js 24 o superior. Prisma 7.10 soporta oficialmente Node.js 20.19+, 22.12+ y 24; con versiones más nuevas funciona, pero muestra un aviso.
- pnpm (la versión está fijada en `packageManager` de `package.json`)
- PostgreSQL 17 en Docker (ver [Base de datos](#base-de-datos))

## Instalación

```bash
pnpm install          # también genera el cliente de Prisma en src/generated/prisma
cp .env.example .env  # completar las URLs de la base de datos
pnpm run db:migrate   # aplica las migraciones
```

## Comandos

| Comando | Descripción |
| --- | --- |
| `pnpm run start:dev` | Inicia la API en modo desarrollo con recarga automática (puerto `3000` o `PORT`). |
| `pnpm run build` | Compila el proyecto en `dist/`. |
| `pnpm run start:prod` | Ejecuta la versión compilada. |
| `pnpm run test` | Ejecuta las pruebas unitarias (Jest). |
| `pnpm run test:cov` | Ejecuta las pruebas unitarias con reporte de cobertura en `coverage/`. |
| `pnpm run test:e2e` | Ejecuta las pruebas de integración (Jest y Supertest) de `test/`. |
| `pnpm run lint` | Revisa el código con ESLint y corrige lo que se pueda corregir automáticamente. |
| `pnpm run lint:check` | Revisa el código con ESLint sin modificar archivos. |
| `pnpm run format` | Da formato al código con Prettier. |
| `pnpm run format:check` | Comprueba el formato sin modificar archivos. |
| `pnpm run db:migrate` | Aplica las migraciones pendientes en Local, o crea una nueva si cambió el esquema (`prisma migrate dev`). |
| `pnpm run db:deploy` | Aplica las migraciones pendientes sin crear nuevas (`prisma migrate deploy`), como en Producción. |
| `pnpm run db:status` | Muestra el estado de las migraciones de la base de datos. |
| `pnpm run db:seed` | Carga los datos ficticios de `prisma/seed.ts`, que no se versiona. |
| `pnpm run db:reset` | Elimina los datos y vuelve a aplicar todas las migraciones. No carga la semilla: ejecutar después `db:seed`. Solo en Local. |
| `pnpm run db:generate` | Genera el cliente de Prisma después de cambiar el esquema. |

## Estructura del proyecto

```text
prisma/
  schema.prisma         esquema de la base de datos (SDD 5.6)
  migrations/           migraciones versionadas, con SQL manual (ADR-005)
  seed.ts               datos ficticios para Local (no se versiona)
prisma.config.ts        configuración de Prisma: esquema, migraciones, semilla y URLs
src/
  main.ts               punto de entrada
  app.module.ts         módulo raíz, importa todos los módulos de dominio
  generated/prisma/     cliente de Prisma generado (no se versiona)
  prisma/               PrismaModule global y PrismaService
  <modulo>/
    <modulo>.module.ts  definición del módulo de NestJS
    controllers/        controladores (sin reglas de negocio)
    services/           servicios (únicos que acceden a la base de datos)
    entities/           entidades de la base de datos
    dtos/               objetos de transferencia de datos
    tests/              pruebas unitarias del módulo
test/                   pruebas de integración (e2e)
```

Los modelos de la base de datos se definen en `prisma/schema.prisma`, y sus tipos se importan del cliente generado en `src/generated/prisma`. No se duplican como clases en `entities/`.

### Módulos

| Módulo | Componente del SDD |
| --- | --- |
| `prisma` | Acceso a la base de datos con Prisma (ADR-005). Módulo global que exporta `PrismaService` |
| `auth` | Auth: inicio y cierre de sesión, vigencia de las sesiones, recuperación y cambio de contraseña |
| `accounts` | Accounts: registro, confirmación, datos de la cuenta y eliminación |
| `vet-requests` | VetRequests: ciclo de vida de las solicitudes del rol Veterinario |
| `user-admin` | UserAdmin: gestión de cuentas y roles por parte de los administradores |
| `access-control` | AccessControl: control de acceso a todas las rutas, denegado por defecto (ADR-002) |
| `pets` | Pets: mascotas de cada dueño y su carnet |
| `pet-types` | PetTypes: tipos de mascota y su activación |
| `history` | History: registros del historial de cada mascota |
| `carnet-vets` | CarnetVets: veterinario del carnet y vínculo por RUT |
| `vet-consult` | VetConsult: consulta de solo lectura del veterinario y desvinculación |
| `admin-metrics` | AdminMetrics: cifras y gráficas de administración |
| `audit-metrics` | AuditMetrics: indicadores agregados de auditoría |
| `action-log` | ActionLog: registro de acciones administrativas y su retención |
| `mail` | Mail: plantillas y envío de correos mediante Brevo |

### Reglas de dependencia

- Un módulo usa a otro solo mediante los servicios que este exporta.
- Solo los servicios acceden a la base de datos. Los controladores no contienen reglas de negocio.
- Las respuestas de la API usan modelos explícitos (DTOs), nunca entidades de la base de datos.

## Base de datos

PostgreSQL con Prisma 7 como capa de acceso a datos (ADR-005). El esquema implementa la Vista de Datos del SDD (sección 5.6), con una tabla por tipo de registro del historial (ADR-006).

### Base de datos local

En Local se usa una base dedicada con un usuario propio dentro del contenedor Docker de PostgreSQL 17. Para crearlos, con el usuario administrador del contenedor:

```sql
CREATE ROLE petcontrol LOGIN PASSWORD '<password>';
CREATE DATABASE petcontrol OWNER petcontrol;
CREATE DATABASE petcontrol_shadow OWNER petcontrol;
REVOKE ALL ON DATABASE petcontrol FROM PUBLIC;
REVOKE ALL ON DATABASE petcontrol_shadow FROM PUBLIC;
```

`petcontrol_shadow` es la base temporal que usa `prisma migrate dev` para detectar cambios en el esquema. Al crearla de antemano, el usuario no necesita el permiso `CREATEDB`.

| Variable | Propósito |
| --- | --- |
| `DATABASE_URL` | Conexión a la base de datos. La API no arranca si falta o si la base no responde. |
| `SHADOW_DATABASE_URL` | Base temporal de `prisma migrate dev`. Solo en Local. |

Prisma 7 no carga el archivo `.env`: lo cargan `prisma.config.ts`, `src/main.ts` y `test/setup-env.ts`. En Producción las variables llegan desde Kubernetes (SDD 6.4).

### Migraciones

- Después de cambiar `prisma/schema.prisma`, ejecutar `pnpm run db:migrate --name <cambio>` y versionar la carpeta creada en `prisma/migrations/`.
- La migración inicial incluye SQL manual con reglas que el esquema de Prisma no expresa. Las migraciones siguientes deben conservarlas, y `prisma migrate diff` no las ve como diferencias:

| Regla | Objeto en la base de datos |
| --- | --- |
| Nombre de tipo sin distinguir mayúsculas (REQ-075) | Índice único `pet_types_name_lower_key` sobre `lower(name)` |
| Un peso por mascota y mes calendario (REQ-046) | Índice único `weights_pet_id_month_key` sobre `pet_id` y `date_trunc('month', measured_on::timestamp)` |
| Una solicitud pendiente por cuenta (REQ-018) | Índice único parcial `vet_role_requests_account_id_pending_key` con `status = 'pending'` |
| Valores mayores que cero (REQ-049) | `CHECK` en `quantity_kg`, `quantity_units`, `price_clp` y `weight_kg` |

- Los tipos de mascota Perro y Gato se crean en la migración inicial, por lo que existen en todos los entornos.

### Datos ficticios

`prisma/seed.ts` carga datos ficticios para Local según la sección 5.8 del Plan de Pruebas: cuentas de cada rol y con varios roles, sin confirmar y desactivadas, tipos activos y desactivados, mascotas con y sin veterinario del carnet, registros de cada tipo y solicitudes en cada estado.

- El archivo no se versiona (`.gitignore`). Sin él, `pnpm run db:seed` falla.
- Vacía los datos antes de cargarlos, por lo que se puede ejecutar varias veces, y no se ejecuta con `NODE_ENV=production`.

## Calidad del código

- **ESLint** (`eslint.config.mjs`) con `typescript-eslint` y reglas con información de tipos. `no-floating-promises` es un error.
- **Prettier** (`.prettierrc`) con comillas simples y coma final. ESLint informa las diferencias de formato.
- **Jest** para las pruebas unitarias (`*.spec.ts`) y **Supertest** para las de integración (`test/*.e2e-spec.ts`).

## Flujo de trabajo

- `main` siempre debe poder desplegarse. El trabajo se hace en ramas `<type>/<JIRA-TICKET-KEY>-<tarea>` que se integran mediante un PR.
- Los commits siguen Conventional Commits: `<type>(<scope>): [<JIRA-TICKET-KEY>] <subject>`.
- Cada versión se publica con una etiqueta `X.Y.Z` siguiendo SemVer.
