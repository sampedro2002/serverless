# Serverless – Hello WebAssembly (monorepo)

Ejemplo mínimo de un monorepo con:

- **WebAssembly**: un módulo escrito en texto (`.wat`) que se compila a `.wasm`.
- **Web**: una página HTML que carga el `.wasm` y muestra su resultado.
- **Docker**: una imagen que compila el WebAssembly y sirve la web con nginx.

## Estructura

```
serverless/
├── wasm/                  # Código WebAssembly
│   ├── hello.wat          # Programa en WAT (aquí es donde cambias la lógica)
│   ├── build.js           # Compila hello.wat -> ../web/hello.wasm
│   └── package.json       # Dependencia: wabt (compilador WAT)
├── web/                   # Frontend estático
│   └── index.html         # Carga hello.wasm y muestra el texto y la suma
├── docker/
│   └── Dockerfile         # Compila el wasm y sirve la web con nginx
├── docker-compose.yml     # Atajo para levantar el contenedor
└── README.md
```

## Opción 1: Ejecutar con Docker (lo más sencillo)

No necesitas instalar nada más que Docker:

```bash
docker compose up --build
```

Abre http://localhost:8080 en el navegador. Deberías ver `Hello, WebAssembly!` y `2 + 3 = 5`.

Para parar: `Ctrl+C` o `docker compose down`.

## Opción 2: Ejecutar sin Docker (desarrollo local del WebAssembly)

Requiere Node.js 18+ :

```bash
cd wasm
npm install
npm run build          # genera ../web/hello.wasm
cd ../web
python3 -m http.server 8000
```

Abre http://localhost:8000.

## Cómo modificarlo

### Cambiar el WebAssembly

1. Edita `wasm/hello.wat`. Por ejemplo, cambia el texto de `(data ...)` y actualiza `message_len` con la nueva longitud.
2. Añade funciones con `(func (export "nombre") ...)` para exponerlas a JavaScript.
3. Recompila: `cd wasm && npm run build` (o simplemente `docker compose up --build`).

Desde JavaScript, las funciones exportadas se usan así: `instance.exports.nombre(...)`.
Ojo: WebAssembly solo maneja números (`i32`, `i64`, `f32`, `f64`). Para texto se usa la memoria lineal, como en este ejemplo.

### Cambiar la web

Edita `web/index.html`. Los cambios se ven con solo recargar la página en modo local, o con `docker compose up --build` en Docker.

### Cambiar Docker

Edita `docker/Dockerfile`:

- Etapa `wasm-build`: imagen de Node que compila el `.wat`.
- Etapa final (`nginx:alpine`): imagen que sirve la web. Puedes cambiar el puerto en `docker-compose.yml` (`"8080:80"`).

## Notas

- `web/hello.wasm` y `node_modules/` no se suben al repositorio (ver `.gitignore`): se generan al compilar.
- Para inicializar git en la raíz: `git init` (todavía no es un repositorio).
