# Docker & WebAssembly (Wasm) – POC Serverless

### Integrantes
- Esteban Narváez
- Daniel Tumbaco
- Bruno Sampedro

---

## Conceptos Clave

### ¿Qué es Docker?
Plataforma de virtualización a nivel de sistema operativo basada en contenedores.
- **Funcionamiento**: Comparte el kernel del sistema operativo anfitrión y aísla procesos mediante *namespaces* y *cgroups* de Linux.
- **Ventaja principal**: Empaqueta la aplicación completa con todas sus dependencias y sistema de archivos, garantizando consistencia en cualquier entorno.

### ¿Qué es WebAssembly (Wasm)?
Formato binario de instrucciones y máquina virtual basada en pila diseñada para ejecución segura y de alto rendimiento.
- **Funcionamiento**: Código fuente (Rust, C/C++, Go, WAT) compilado a un binario (`.wasm`) que se ejecuta dentro de un sandbox seguro con memoria lineal aislada.
- **Ventaja principal**: Inicio ultrarrápido (<1 ms), huella de memoria mínima y portabilidad total entre arquitecturas de CPU y navegadores/servidores (WASI).

---

## Tabla de Comparación: Docker vs. WebAssembly

| Criterio | Docker (Contenedores) | WebAssembly (Wasm) |
|---|---|---|
| **Nivel de Abstracción** | Virtualización a nivel de SO (Kernel compartido) | Máquina virtual a nivel de bytecode / sandbox |
| **Objetivo de Ejecución** | Procesos del kernel de Linux | Runtimes Wasm (V8, Wasmtime, WasmEdge) |
| **Tamaño de Artefacto** | Decenas de MB a varios GB | Kilobytes a pocos MB |
| **Tiempo de Arranque (Cold Start)** | Cientos de milisegundos a segundos | Sub-milisegundo a microsegundos (< 1 ms) |
| **Consumo de Memoria** | Megabytes a Gigabytes por contenedor | Kilobytes por instancia |
| **Mecanismo de Aislamiento** | Namespaces, cgroups y seccomp | Aislamiento de bytecode y memoria lineal segura |
| **Portabilidad** | Depende de la arquitectura del CPU (x86_64, ARM) | Totalmente agnóstico de arquitectura y SO |
| **Acceso al Sistema** | Syscalls directas de Linux / POSIX | Restringido por defecto; por capacidades con WASI |
| **Casos de Uso Ideales** | Microservicios completos, apps heredadas, stacks OS | Serverless/Edge, plugins, lógica de alto cómputo |

---

## Prueba de Concepto (POC)

Esta POC demuestra la compilación de un módulo WebAssembly escrito en formato de texto (`.wat`) a binario (`.wasm`) y su posterior despliegue en un contenedor Docker con Nginx.

### Estructura Rápida
- `wasm/`: Código fuente (`hello.wat`) y script de compilación con `wabt`.
- `web/`: Frontend (`index.html`) que consume y ejecuta el módulo `.wasm`.
- `docker/`: Dockerfile multi-etapa (build Node + servidor Nginx).

### Cómo Ejecutar

#### Opción 1: Con Docker (Recomendado)
```bash
docker compose up --build
```
Abrir en el navegador: **[http://localhost:8080](http://localhost:8080)**.

Para detener el servicio:
```bash
docker compose down
```

#### Opción 2: Localmente (Node.js 18+ y Python 3)
```bash
# 1. Compilar el módulo Wasm
cd wasm
npm install
npm run build

# 2. Servir el frontend
cd ../web
python3 -m http.server 8000
```
Abrir en el navegador: **[http://localhost:8000](http://localhost:8000)**.
