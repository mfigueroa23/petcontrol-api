# petcontrol-api

Backend de **Control de Mascotas**. Es un monolito modular en NestJS (ADR-001), con un módulo de NestJS por dominio funcional. El frontend está en el repositorio `petcontrol-web` (ADR-010).

La documentación del proyecto (SRS, SDD y TD) está en Confluence, en el espacio `CDM`, y los tickets en Jira, en el proyecto `CDM`.

## Requisitos

- Node.js 24 o superior
- pnpm (la versión está fijada en `packageManager` de `package.json`)

## Instalación

```bash
pnpm install
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

## Estructura del proyecto

```text
src/
  main.ts               punto de entrada
  app.module.ts         módulo raíz, importa todos los módulos de dominio
  <modulo>/
    <modulo>.module.ts  definición del módulo de NestJS
    controllers/        controladores (sin reglas de negocio)
    services/           servicios (únicos que acceden a la base de datos)
    entities/           entidades de la base de datos
    dtos/               objetos de transferencia de datos
    tests/              pruebas unitarias del módulo
test/                   pruebas de integración (e2e)
```

### Módulos

| Módulo | Componente del SDD |
| --- | --- |
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

## Calidad del código

- **ESLint** (`eslint.config.mjs`) con `typescript-eslint` y reglas con información de tipos. `no-floating-promises` es un error.
- **Prettier** (`.prettierrc`) con comillas simples y coma final. ESLint informa las diferencias de formato.
- **Jest** para las pruebas unitarias (`*.spec.ts`) y **Supertest** para las de integración (`test/*.e2e-spec.ts`).

## Flujo de trabajo

- `main` siempre debe poder desplegarse. El trabajo se hace en ramas `<type>/<JIRA-TICKET-KEY>-<tarea>` que se integran mediante un PR.
- Los commits siguen Conventional Commits: `<type>(<scope>): [<JIRA-TICKET-KEY>] <subject>`.
- Cada versión se publica con una etiqueta `X.Y.Z` siguiendo SemVer.
