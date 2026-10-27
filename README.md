# INTERCOMERCIO — Panel de catálogo (Nuxt 4 + SQL Server)

Aplicación Nuxt 4 que usa la base de datos **INTERCOMERCIO** (SQL Server) como esqueleto central
del proyecto. El backend expone APIs de Nitro (una por archivo) y el frontend las consume con
`useFetch` / `$fetch`, reutilizando componentes y un design system propio.

## Requisitos

- Node.js 20+ y npm
- SQL Server local con la base `INTERCOMERCIO` creada (`server/db/db.sql`)
- **Autenticación de Windows** + **ODBC Driver 17 for SQL Server** instalado
- (La conexión usa el driver `msnodesqlv8`, por eso se instala como dependencia del proyecto)

> ℹ️ `typescript` se fija en `^5.9` porque `vue-tsc@3` (usado por `npm run typecheck`) todavía no
> es compatible con TypeScript 7.

Variables de entorno opcionales (si difieren de los valores por defecto):

```
SQL_SERVER=localhost
SQL_DATABASE=INTERCOMERCIO
SQL_ODBC_DRIVER=ODBC Driver 17 for SQL Server
```

## Scripts

| Comando | Descripción |
|---------|-------------|
| `npm run dev` | Servidor de desarrollo en http://localhost:3000 |
| `npm run build` | Build de producción (`.output/`) |
| `npm run preview` | Previsualiza el build de producción |
| `npm run typecheck` | Verifica los tipos con `vue-tsc` (`nuxt typecheck`) |
| `npm run postinstall` | Genera los tipos de Nuxt (`nuxt prepare`) |

## Estructura

```
nuxt-proyecto/
├── app/
│   ├── app.vue                 # Raíz (NuxtLayout + NuxtPage)
│   ├── assets/css/main.css     # Design system: tokens + clases reutilizables
│   ├── components/             # Auto-importados (UI y dominio)
│   │   ├── AppButton.vue  AppInput.vue  AppSelect.vue  AppTextarea.vue
│   │   ├── AppCard.vue    AppBadge.vue  AppAlert.vue   AppModal.vue
│   │   ├── ProductoForm.vue     # Alta de producto + alta en línea de catálogos
│   │   ├── ProductoTabla.vue    # Listado
│   │   ├── ProductoFiltros.vue  # Búsqueda + filtro por categoría
│   │   ├── CategoriaModal.vue   # Alta rápida de categoría
│   │   └── MarcaModal.vue       # Alta rápida de marca
│   ├── composables/         # (reservado)
│   ├── layouts/default.vue  # Cabecera, navegación y pie compartidos
│   ├── pages/
│   │   ├── index.vue              # Panel de inicio (conteos del resumen)
│   │   └── productos/
│   │       ├── index.vue          # Listado con filtros y paginación
│   │       └── crear.vue          # Ruta de creación de productos
│   └── utils/formato.ts     # Moneda, fechas y mensajes de error
├── server/
│   ├── api/                 # Una API por archivo
│   ├── db/db.sql            # DDL de la base INTERCOMERCIO
│   └── utils/
│       ├── db.ts            # Pool compartido (msnodesqlv8 + Windows Auth)
│       └── validacion.ts    # Validadores reutilizables
├── shared/
│   ├── types/               # Tipos compartidos frontend/backend
│   └── utils/slug.ts        # Generación de slugs
└── nuxt.config.ts
```

## API

| Método | Ruta | Archivo | Descripción |
|--------|------|---------|-------------|
| GET | `/api/productos` | `server/api/productos.get.ts` | Listado paginado (`q`, `categoria`, `page`, `pageSize`) |
| POST | `/api/productos` | `server/api/productos.post.ts` | Alta de producto (valida, 409 si el SKU existe) |
| GET | `/api/categorias` | `server/api/categorias.get.ts` | Categorías activas |
| POST | `/api/categorias` | `server/api/categorias.post.ts` | Alta de categoría (slug autogenerado) |
| GET | `/api/marcas` | `server/api/marcas.get.ts` | Marcas activas |
| POST | `/api/marcas` | `server/api/marcas.post.ts` | Alta de marca |
| GET | `/api/vendedores` | `server/api/vendedores.get.ts` | Vendedores activos |
| GET | `/api/resumen` | `server/api/resumen.get.ts` | Conteos del panel de inicio |

### Convenciones de la API

- Un archivo por endpoint (`nombre.metodo.ts`), como permite Nitro.
- Errores con `createError`: 400 (validación), 409 (duplicado), 500 (inesperado).
- Los catálogos devuelven arreglos; el listado de productos devuelve
  `{ items, total, page, pageSize, totalPaginas }`.

## Notas técnicas

- **Driver:** se usa `mssql/msnodesqlv8.js` (no el `mssql` estándar) porque la instancia local
  funciona con autenticación de Windows y el protocolo TCP deshabilitado.
  No hace falta configurar `nitro.externals`: Nitro detecta la dependencia y **copia el paquete
  completo, incluido el binario nativo**, en `.output/server/node_modules/msnodesqlv8/prebuilds/`.
  ⚠️ Si algún día se agrega, `nitro.externals` debe ser un **objeto** (`{ external: [...] }`).
  Un array (`externals: ['mssql']`) rompe el trazado de dependencias de Nitro y provoca
  `500 Either manifest or precomputed data must be provided` en todas las páginas SSR.
- **Inputs numéricos:** Vue convierte a `Number` el `v-model` de cualquier
  `<input type="number">` (`castToNumber = number || type === 'number'` en `vModelText`).
  Por eso `AppInput` enlaza `:value` + `@input` a mano y garantiza que su modelo
  **siempre sea un string**; de lo contrario `form.precio_base.trim()` revienta con
  `TypeError: ... .trim is not a function`. El formulario además normaliza con `texto()`
  antes de validar y convierte a número al construir el payload.
- **Enteros IDENTITY:** el driver los devuelve como texto; las consultas aplican
  `CAST(columna AS INT)` para que lleguen al frontend como números (aplica a IDs de
  `productos`, `categorias`, `marcas` y `vendedores`).
- **Variables de conexión opcionales:** `SQL_SERVER`, `SQL_DATABASE`, `SQL_ODBC_DRIVER`.
  No hay credenciales en el código (autenticación de Windows).
- **Al compilar en Windows:** cierra cualquier proceso `node` antes de `npm run build`;
  si un proceso mantiene abierto el `.node` nativo, el build falla con
  `EPERM: operation not permitted, unlink ...msnodesqlv8.node`.
- **Vendedores:** el catálogo `dbo.vendedores` no tiene alta desde la UI (solo se consume);
  el select de vendedor del formulario aparece deshabilitado mientras esté vacío.

## Estilos

Todo el estilo vive en `app/assets/css/main.css`:

- *Tokens* (`:root`): colores, tipografía, espaciado, radios y sombras.
- *Clases base*: `.btn`, `.control`, `.campo`, `.card`, `.tabla`, `.badge`, `.alerta`,
  `.modal`, `.paginacion`, `.hero`, `.spinner`, etc.
- Los componentes `App*` encapsulan estas clases para no repetir marcado ni estilos.

## Flujo de creación

1. `GET /productos` → listado con filtros.
2. `GET /productos/crear` → formulario (`ProductoForm`).
3. Si faltan categorías o marcas, se crean desde el propio formulario
   (`CategoriaModal` / `MarcaModal`) y quedan seleccionadas al instante.
4. El frontend valida en cliente y el POST valida de nuevo en el servidor.
5. Al guardar, `POST /api/productos` responde 201 y se vuelve a `/productos?creado=<SKU>`,
   donde se muestra una alerta de confirmación y el producto aparece primero en la lista
   (orden `fecha_creacion DESC, id_producto DESC`).
