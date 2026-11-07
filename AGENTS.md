# Control de Mascotas - Backend

Proyecto en nestjs para el backend de la aplicacion de control de mascotas
utilizando una arquitectura monolitica con ORM y base de datos relacional.

## Comandos

- Iniciar el proyecto: `pnpm run start:dev`
- Ejecutar test unitarios: `pnpm run test`
- Ejecutar test de integracion: `pnpm run test:e2e`
- Ejecutar lint (ESLint): `pnpm run lint`
- Ejecutar formato de codigo: `pnpm run format`

## Reglas de desarollo

- Codigo fuente en ingles, mensajes y textos en español.
- No trabajar en la rama `main`, crear una rama con el nombre de la tarea a realizar `<type>/<JIRA-TICKET-KEY>-<tarea>`.
- Tickets de desarrollo en JIRA el proyecto con clave `CDM`
- Documentacion (SRS, SDD y TD) en Confluence con la clave `CDM`.
- Trabajo en pair programming: cada tarea se divide en pasos minimos verificables.
  Claude realiza un paso y se detiene para que el desarrollador lo revise; si lo aprueba
  se hace commit y se pasa al siguiente, de lo contrario se itera sobre el mismo paso
  hasta que quede aprobado. No se hace commit ni se avanza sin aprobacion explicita.
- Estructura del proyecto:
  - `src/<modulo>`: Modulos de la aplicacion.
  - `src/<modulo>/controllers`: Controladores de la aplicacion.
  - `src/<modulo>/services`: Servicios de la aplicacion.
  - `src/<modulo>/entities`: Entidades de la base de datos.
  - `src/<modulo>/dtos`: Objetos de transferencia de datos.
  - `src/<modulo>/tests`: Pruebas unitarias de la aplicacion.

## Al finalizar una tarea de desarrollo

- Comprobar que los test unitarios pasen correctamente.
- Realizar commit si se solicita siguiendo la convencion (sin agregar `co-autored` de claude-code):

```
<type>(<scope>): [<JIRA-TICKET-KEY>] <subject>

<Descripcion breve de los cambios realizados>

Cambios realizados:
- <Archvo modificado>: <Descripcion de los cambios realizados>
- ...
```

## Al solicitar un pull request

- Comprobar que los test unitarios pasen correctamente.
- Realizar un bump de version en el archivo `package.json` siguiendo la convencion de
  [SemVer](https://semver.org/) con su respectivo commit siguiendo la convencion.
- Abrir un pull request en Github con `gh pr create` siguiendo la convencion (sin agregar `co-autored` de claude-code):

```
<type>(<scope>): [<JIRA-TICKET-KEY>] <subject>

Objetivo:
<Description breve de los cambios realizados>

Cambios realizados:
- <Archvo modificado>: <Descripcion de los cambios realizados>
- ...

Impacto:
<Descripcion del impacto de los cambios realizados>

Pruebas realizadas:
- <Descripcion de las pruebas realizadas>
- ...
```
