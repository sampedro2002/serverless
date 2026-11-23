# Serverless – Hello WebAssembly (monorepo)

Minimal monorepo example with:

- **WebAssembly**: a module written in text format (`.wat`) that is compiled to `.wasm`.
- **Web**: an HTML page that loads the `.wasm` and shows its result.
- **Docker**: an image that compiles the WebAssembly and serves the web app with nginx.

## Structure

```
serverless/
├── wasm/                  # WebAssembly code
│   ├── hello.wat          # Program in WAT (this is where you change the logic)
│   ├── build.js           # Compiles hello.wat -> ../web/hello.wasm
│   └── package.json       # Dependency: wabt (WAT compiler)
├── web/                   # Static frontend
│   └── index.html         # Loads hello.wasm and shows the text and the sum
├── docker/
│   └── Dockerfile         # Compiles the wasm and serves the web app with nginx
├── docker-compose.yml     # Shortcut to run the container
└── README.md
```

## Option 1: Run with Docker (simplest)

You only need Docker installed:

```bash
docker compose up --build
```

Open http://localhost:8080 in your browser. You should see `Hello, WebAssembly!` and `2 + 3 = 5`.

To stop: `Ctrl+C` or `docker compose down`.

## Option 2: Run without Docker (local WebAssembly development)

Requires Node.js 18+:

```bash
cd wasm
npm install
npm run build          # generates ../web/hello.wasm
cd ../web
python3 -m http.server 8000
```

Open http://localhost:8000.

## How to modify it

### Change the WebAssembly

1. Edit `wasm/hello.wat`. For example, change the text in `(data ...)` and update `message_len` with the new length.
2. Add functions with `(func (export "name") ...)` to expose them to JavaScript.
3. Rebuild: `cd wasm && npm run build` (or simply `docker compose up --build`).

From JavaScript, exported functions are used like this: `instance.exports.name(...)`.
Note: WebAssembly only handles numbers (`i32`, `i64`, `f32`, `f64`). For text, use linear memory, as in this example.

### Change the web app

Edit `web/index.html`. Changes show up by reloading the page in local mode, or with `docker compose up --build` in Docker.

### Change Docker

Edit `docker/Dockerfile`:

- `wasm-build` stage: Node image that compiles the `.wat`.
- Final stage (`nginx:alpine`): image that serves the web app. You can change the port in `docker-compose.yml` (`"8080:80"`).

## Notes

- `web/hello.wasm` and `node_modules/` are not committed (see `.gitignore`): they are generated when building.
- To initialize git at the root: `git init` (it is not a repository yet).
