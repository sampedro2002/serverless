# Docker & WebAssembly (Wasm) – Complete Guide & POC

A comprehensive reference and minimal working monorepo demonstrating **Docker** and **WebAssembly (Wasm)**: exploring each technology individually, providing a hands-on Proof of Concept (POC), and concluding with an in-depth side-by-side comparison.

---

## Table of Contents

1. [Part 1: Docker](#part-1-docker)
   - [What is Docker?](#what-is-docker)
   - [How Does Docker Work?](#how-does-docker-work)
   - [Where Can You Use Docker?](#where-can-you-use-docker)
   - [Who Created Docker?](#who-created-docker)
   - [Who Has Implemented and Adopted Docker?](#who-has-implemented-and-adopted-docker)
2. [Part 2: WebAssembly (Wasm)](#part-2-webassembly-wasm)
   - [What is WebAssembly?](#what-is-webassembly)
   - [How Does WebAssembly Work?](#how-does-webassembly-work)
   - [Where Can You Use WebAssembly?](#where-can-you-use-webassembly)
   - [Who Created WebAssembly?](#who-created-webassembly)
   - [Who Has Implemented and Adopted WebAssembly?](#who-has-implemented-and-adopted-webassembly)
3. [Part 3: Proof of Concept (POC) – WebAssembly + Docker](#part-3-proof-of-concept-poc--webassembly--docker)
   - [Monorepo Structure](#monorepo-structure)
   - [Code Walkthrough](#code-walkthrough)
   - [How to Run the POC](#how-to-run-the-poc)
4. [Part 4: Docker vs. WebAssembly – Comprehensive Comparison](#part-4-docker-vs-webassembly--comprehensive-comparison)
   - [Comparison Matrix](#comparison-matrix)
   - [Architectural Differences](#architectural-differences)
   - [Better Together: How Docker and Wasm Complement Each Other](#better-together-how-docker-and-wasm-complement-each-other)

---

# Part 1: Docker

## What is Docker?

**Docker** is an open-source platform that enables developers to build, package, ship, and run applications inside isolated, portable environments known as **containers**. 

Unlike full hardware virtualization (Virtual Machines), which bundles an entire guest operating system, Docker shares the host operating system's kernel. A container encapsulates only the application code, runtime, system tools, libraries, and configurations required to run. This ensures that software behaves identically across all environments—from a developer’s local laptop to continuous integration (CI) pipelines and production cloud clusters.

---

## How Does Docker Work?

Docker relies on low-level Linux kernel features to provide lightweight process isolation and resource governance:

```
+--------------------------------------------------------------+
|                     User Application / Process               |
+--------------------------------------------------------------+
|                     Container Filesystem (OverlayFS)         |
+--------------------------------------------------------------+
|  Linux Kernel Primitives:                                    |
|   • Namespaces (PID, NET, IPC, MNT, UTS, USER) -> Isolation  |
|   • Cgroups (CPU, Memory, Disk I/O, Network)   -> Quotas     |
|   • Seccomp / AppArmor                         -> Security   |
+--------------------------------------------------------------+
|                     Host Operating System Kernel             |
+--------------------------------------------------------------+
|                     Physical / Virtual Hardware              |
+--------------------------------------------------------------+
```

### Core Mechanisms:

1. **Linux Namespaces**: Provide discrete isolation boundaries so a containerized process cannot inspect or interfere with other system processes:
   - `pid` (Process IDs): Process tree isolation.
   - `net` (Networking): Independent network interfaces, IP addresses, and routing tables.
   - `mnt` (Mount points): Isolated filesystem mount points.
   - `ipc` (Inter-Process Communication): Isolated shared memory and message queues.
   - `uts` (Hostname): Isolated hostnames and domain names.
   - `user` (User IDs): Maps container root (`UID 0`) to an unprivileged host UID.

2. **Control Groups (`cgroups`)**: Enforce hard limits and monitor physical hardware resources allocated to a container (e.g., maximum memory limits, CPU shares, I/O bandwidth).

3. **Union Filesystems & Layering (OverlayFS)**: Docker images are structured as an immutable stack of read-only layers defined by each instruction in a `Dockerfile`. When a container runs, a thin, read-write layer is mounted on top, ensuring rapid container instantiation and shared layer caching.

4. **Docker Architecture (Client-Server Model)**:
   - **Docker CLI (`docker`)**: The command-line tool used by developers to issue instructions.
   - **Docker Daemon (`dockerd`)**: The background service managing containers, images, networks, and storage volumes.
   - **containerd & runc**: The industry-standard container runtime executing containers adhering to the Open Container Initiative (OCI) specification.

---

## Where Can You Use Docker?

1. **Microservices Architectures**: Packaging distributed services into independently scalable, self-contained units.
2. **Local Development Environments**: Eliminating the *"it works on my machine"* problem by mirroring production runtime stacks locally via `docker-compose`.
3. **CI/CD Pipelines**: Creating consistent, disposable build and test environments that start and tear down in seconds.
4. **Cloud Migration & Hybrid Deployments**: Deploying workloads seamlessly across private data centers, AWS, Azure, Google Cloud, and Kubernetes clusters without modifying application code.
5. **Legacy Application Modernization**: Wrapping older software stacks in container images with fixed dependencies to run stably on modern operating systems.

---

## Who Created Docker?

- **Original Creator**: **Solomon Hykes** and his engineering team (including Sébastien Pahl and Andrea Luzzardi).
- **Company**: Developed internally at **dotCloud**, a Platform-as-a-Service (PaaS) company in San Francisco.
- **Release**: Solomon Hykes publicly unveiled Docker at **PyCon 2013** in Santa Clara, California. Following overwhelming open-source enthusiasm, dotCloud rebranded itself to **Docker, Inc.** and open-sourced the platform under the Apache 2.0 license.

---

## Who Has Implemented and Adopted Docker?

Docker is standard infrastructure across modern software engineering:
- **Major Cloud Providers**: AWS (ECS, EKS, Fargate), Google Cloud (Google Kubernetes Engine, Cloud Run), Microsoft Azure (AKS, Container Apps).
- **Container Orchestration**: Kubernetes (K8s), HashiCorp Nomad, Docker Swarm.
- **Enterprise Engineering Teams**: Netflix, Uber, Spotify, PayPal, GitHub, and thousands of enterprises build and ship their software products with Docker containers.

---

# Part 2: WebAssembly (Wasm)

## What is WebAssembly?

**WebAssembly (abbreviated Wasm)** is a binary code format and virtual machine specification designed for safe, portable, high-performance execution of code at near-native speed.

Originally built to execute computational workloads in web browsers alongside JavaScript, WebAssembly has expanded server-side via the **WASI (WebAssembly System Interface)** standard. It acts as a universal compilation target: developers write code in languages such as Rust, C, C++, Go, or Zig, and compile it into compact `.wasm` binary modules that execute across any operating system or CPU architecture without modification.

---

## How Does WebAssembly Work?

WebAssembly operates as a **stack-based virtual machine** with a strict, memory-safe execution sandbox:

```
[ Source Code ]
  (C, C++, Rust, Go, or WAT)
             │
             ▼  Compiler Toolchain (clang / rustc / wabt)
[ hello.wasm Bytecode ]
             │
             ▼  Host Runtime (Browser V8 / Wasmtime / WasmEdge)
+--------------------------------------------------------------+
| WebAssembly Sandbox Instance                                 |
|                                                              |
|   1. Bytecode Validation (Stack & Type verification)         |
|   2. Linear Memory (Isolated raw byte array [0 .. N])        |
|   3. Function Table & Call Stack (Protected from corruption) |
|   4. Execution Engine (JIT / AOT Compiler -> CPU Machine Code)|
+--------------------------------------------------------------+
             │
             ▼  Imports / Exports / System Interface (WASI)
[ Host System or Browser Window / DOM ]
```

### Core Mechanisms:

1. **Binary Format & Compilation**: WebAssembly modules are pre-compiled into compact, platform-independent binary opcode streams (`.wasm`). Developers can inspect and author modules directly in the human-readable text format (`.wat`).
2. **Stack-Based Architecture**: Instructions push values onto and pop values off an internal operand stack (e.g., `local.get`, `i32.add`).
3. **Linear Memory Model**: A Wasm module has no direct access to the host's operating system memory or heap. Instead, it operates over **linear memory**—a contiguous, resizable array of raw bytes exported to or imported from the host. This prevents buffer overflows from corrupting host memory.
4. **Validation and Security**: Before executing, the runtime verifies the bytecode to ensure it does not violate type safety, overflow the call stack, or access unauthorized memory boundaries.
5. **Execution (JIT / AOT)**: Modern runtimes (such as Google V8, SpiderMonkey, Wasmtime, or WasmEdge) compile the bytecode to native machine code (x86_64, ARM64, RISC-V) using Just-In-Time (JIT) or Ahead-Of-Time (AOT) compilation.
6. **WASI (WebAssembly System Interface)**: When executed outside the browser, WASI provides a secure, capability-based interface for accessing files, network sockets, system clocks, and random numbers without direct OS syscall access.

---

## Where Can You Use WebAssembly?

1. **Browser Compute & Media Processing**: Executing heavy workloads in client browsers—including 3D graphics rendering, computer vision, video editing, and physics simulations.
2. **Serverless & Edge Computing**: Executing serverless microservices with sub-millisecond cold starts (< 1 ms) and negligible memory footprints compared to full OS containers.
3. **Extensible Plugin Systems**: Allowing third-party developers to upload custom business logic or filters (e.g., in databases, API gateways, and CMS engines) without security risks.
4. **Cross-Platform Shared Logic**: Writing core business algorithms or cryptography modules once in Rust or C++ and deploying them simultaneously to web browsers, mobile apps, and backend servers.
5. **IoT & Embedded Devices**: Running portable application modules on constrained hardware chips without needing an entire Linux userland.

---

## Who Created WebAssembly?

- **Creators**: Co-designed and standardized by the **World Wide Web Consortium (W3C)** WebAssembly Working Group.
- **Collaborating Companies**: Key engineers from **Mozilla, Google, Microsoft, and Apple** joined forces to replace proprietary or fragmented solutions (like Google Native Client / NaCl and Mozilla asm.js) with a unified open standard.
- **Timeline**:
  - **2015**: Project announced publicly.
  - **2017**: Production support shipped across all four major browser engines (V8, SpiderMonkey, JavaScriptCore, Chakra).
  - **December 2019**: Official recommendation by the W3C, making WebAssembly the 4th standard web language alongside HTML, CSS, and JavaScript.
  - **Bytecode Alliance**: Founded in 2019 by Mozilla, Fastly, Intel, and Red Hat to advance server-side Wasm and WASI standards.

---

## Who Has Implemented and Adopted WebAssembly?

WebAssembly is actively deployed by leading tech companies:
- **Cloudflare**: Powers **Cloudflare Workers**, executing millions of serverless functions globally on V8 Wasm isolates with zero cold start.
- **Fastly**: Developed **Compute@Edge**, running customer code on edge servers using Lucet / Wasmtime with microsecond startup times.
- **Figma**: Engineered their core 2D vector rendering engine in C++ and compiled it to WebAssembly for desktop-speed web performance.
- **Adobe**: Brought **Photoshop Web** to browsers by compiling millions of lines of desktop C++ code to WebAssembly using Emscripten.
- **Shopify**: Uses WebAssembly in **Shopify Functions**, enabling merchants to inject custom logic into checkout flows safely and at scale.
- **Fermyon**: Built **Spin**, an open-source serverless framework for building and running microservices natively on WebAssembly.
- **Envoy Proxy**: Supports **Proxy-Wasm**, enabling dynamic, hot-reloadable traffic filtering and security plugins.

---

# Part 3: Proof of Concept (POC) – WebAssembly + Docker

This repository contains a working Proof of Concept that bridges both technologies:
- A custom **WebAssembly** module written in text format (`.wat`) that exposes memory and arithmetic functions.
- A **Web client** that fetches, instantiates, and executes the module directly in the browser.
- A **Docker** multi-stage build that compiles the `.wat` to `.wasm` and serves the web application using Nginx.

---

## Monorepo Structure

```
serverless/
├── wasm/
│   ├── hello.wat          # WebAssembly source in text format
│   ├── build.js           # Compilation script using wabt (WAT -> WASM)
│   └── package.json       # Node package with compiler dependencies
├── web/
│   └── index.html         # Frontend interface consuming the compiled .wasm
├── docker/
│   └── Dockerfile         # Multi-stage build (Builder + Nginx server)
├── docker-compose.yml     # Container orchestration shortcut
└── README.md              # Documentation
```

---

## Code Walkthrough

### 1. The WebAssembly Module (`wasm/hello.wat`)
The module is authored in WebAssembly Text format (WAT):
- It allocates 1 page (64 KB) of linear memory shared with JavaScript.
- It stores the string `"Hello, WebAssembly!"` at byte offset 0.
- It exports pointer (`message_ptr`) and length (`message_len`) getters.
- It exports an `add` function taking two 32-bit integers (`$a`, `$b`) and returning their sum.

```lisp
(module
  ;; Linear memory shared with the host (1 page = 64KB)
  (memory (export "memory") 1)

  ;; Store ASCII string starting at memory address 0
  (data (i32.const 0) "Hello, WebAssembly!")

  ;; Returns the starting byte offset of the string
  (func (export "message_ptr") (result i32)
    i32.const 0)

  ;; Returns the string length in bytes
  (func (export "message_len") (result i32)
    i32.const 19)

  ;; Adds two 32-bit integers and returns the result
  (func (export "add") (param $a i32) (param $b i32) (result i32)
    local.get $a
    local.get $b
    i32.add)
)
```

### 2. Compilation (`wasm/build.js`)
Uses the official `wabt` (WebAssembly Binary Toolkit) inside a Node.js script to compile the text format into binary bytecode:
```javascript
const fs = require('fs');
const path = require('path');
const wabt = require('wabt')();

const wat = fs.readFileSync(path.join(__dirname, 'hello.wat'), 'utf8');
const wasmModule = wabt.parseWat('hello.wat', wat);
const { buffer } = wasmModule.toBinary({});
fs.writeFileSync(path.join(__dirname, '../web/hello.wasm'), Buffer.from(buffer));
```

### 3. Frontend Web Interface (`web/index.html`)
The browser fetches and streams the `.wasm` file, reads the string from linear memory, and runs the exported `add` function:
```html
<script>
  async function main() {
    // Stream-compile and instantiate the WebAssembly module
    const { instance } = await WebAssembly.instantiateStreaming(fetch('hello.wasm'));
    const { memory, message_ptr, message_len, add } = instance.exports;

    // Read string out of linear memory via TextDecoder
    const ptr = message_ptr();
    const len = message_len();
    const bytes = new Uint8Array(memory.buffer, ptr, len);
    document.getElementById('message').textContent = new TextDecoder().decode(bytes);

    // Call exported arithmetic function
    document.getElementById('sum').textContent = add(2, 3);
  }
  main();
</script>
```

### 4. Hermetic Containerization (`docker/Dockerfile`)
The Dockerfile utilizes multi-stage builds to produce a lightweight, production-ready image:
```dockerfile
# Stage 1: Build .wasm from .wat using Node and wabt
FROM node:20-alpine AS wasm-build
WORKDIR /src/wasm
COPY wasm/package.json ./
RUN npm install
COPY wasm/ ./
RUN npm run build

# Stage 2: Serve static assets using Nginx
FROM nginx:alpine
COPY web/ /usr/share/nginx/html/
COPY --from=wasm-build /src/web/hello.wasm /usr/share/nginx/html/hello.wasm
EXPOSE 80
```

---

## How to Run the POC

### Option 1: Run with Docker (Recommended)

Requires only [Docker](https://docs.docker.com/get-docker/) installed on your system.

```bash
# Build the images and start the container
docker compose up --build
```

1. Open your browser and navigate to **[http://localhost:8080](http://localhost:8080)**.
2. You will see:
   - **`Hello, WebAssembly!`** (read from Wasm linear memory).
   - **`2 + 3 = 5`** (computed in WebAssembly).
3. To stop the container, press `Ctrl + C` or run:
   ```bash
   docker compose down
   ```

### Option 2: Run Locally without Docker

Requires **Node.js 18+** and **Python 3**:

```bash
# 1. Compile the WebAssembly module
cd wasm
npm install
npm run build          # Compiles hello.wat -> ../web/hello.wasm

# 2. Serve the static frontend
cd ../web
python3 -m http.server 8000
```

Open your browser at **[http://localhost:8000](http://localhost:8000)**.

> **Important:** run the server from the `web/` folder, not from `wasm/` or the root.
> If you start it from the wrong folder, `index.html` loads but `hello.wasm` returns **404** and the page stays empty.

Quick checks:

```bash
pwd                                # should end in /serverless/web
ls hello.wasm                      # the compiled module must exist
curl -I http://localhost:8000/hello.wasm   # should return "200 OK"
```

To stop the server, press `Ctrl+C` in its terminal.

---

# Part 4: Docker vs. WebAssembly – Comprehensive Comparison

While both Docker and WebAssembly provide sandboxed, isolated execution environments, they operate at fundamentally different abstraction levels and solve distinct problems.

## Comparison Matrix

| Comparison Dimension | Docker (Linux Containers) | WebAssembly (Wasm / WASI) |
|---|---|---|
| **Primary Abstraction** | Operating System-level virtualization | Virtual Machine / Bytecode specification |
| **Execution Target** | Linux kernel processes | Wasm Virtual Machine (V8, Wasmtime, WasmEdge) |
| **Artifact Size** | Tens of MB to several GB (contains OS userland) | Kilobytes to a few MB (pure compiled binary) |
| **Startup / Cold-Start Latency** | Hundreds of milliseconds to seconds | **Sub-millisecond to microseconds (< 1 ms)** |
| **Memory Overhead** | Megabytes to gigabytes per container | Kilobytes per instance (extremely lightweight) |
| **Isolation Mechanism** | Linux namespaces, cgroups, seccomp filters | Memory-safe bytecode sandbox & isolated linear memory |
| **Architecture Portability** | Architecture-dependent (x86_64 image requires x86_64 host or emulation) | **Architecture-agnostic** (compile once, run on x86, ARM, RISC-V) |
| **OS Independence** | Requires Linux kernel (or VM on Windows/macOS) | Completely OS-independent (runs in browser, Linux, macOS, Windows) |
| **System Call Access** | Direct POSIX / Linux syscalls | Capability-based security via WASI (deny-by-default) |
| **Supported Languages** | Any language (packs runtime and OS dependencies) | Languages with Wasm compilers (Rust, C/C++, Go, Zig, etc.) |
| **Maturity & Ecosystem** | Mature (decade of enterprise production use, OCI standard) | Rapidly maturing (WASI preview-2, Component Model evolving) |

---

## Architectural Differences

### 1. Level of Virtualization & Isolation
- **Docker**: Isolates **processes** sharing a single operating system kernel. A container is a standard Linux process isolated via kernel namespaces and resource-capped via cgroups.
- **WebAssembly**: Isolates **code execution** inside an abstract virtual machine. Wasm code cannot make direct operating system calls, read arbitrary memory, or inspect host registers; all interactions must be explicitly imported from the host runtime.

### 2. Startup Latency and Density
- **Docker**: Requires spawning a process tree, initializing cgroups, mounting layered filesystems, and configuring virtual network interfaces. This yields startup times in the range of `100ms - 2s`.
- **WebAssembly**: Runtimes can instantiate a validated Wasm module in under `1 millisecond` (microseconds in engines like Wasmtime). A single host can run tens of thousands of concurrent Wasm instances where it could only host hundreds of Docker containers.

### 3. Portability
- **Docker**: An image built for `linux/amd64` cannot natively run on an Apple Silicon `darwin/arm64` chip without QEMU emulation (which incurs significant performance overhead).
- **WebAssembly**: A `.wasm` binary is completely processor- and architecture-independent. The same binary runs without recompilation on x86_64, ARM64, RISC-V, or inside any modern web browser.

---

## Better Together: How Docker and Wasm Complement Each Other

Rather than WebAssembly replacing Docker, the industry is converging on a model where **Docker and WebAssembly work together**:

1. **Docker as the Packaging and Distribution Standard (OCI)**:
   - Wasm modules can be packaged as **OCI-compliant artifacts** and pushed to standard container registries (Docker Hub, AWS ECR, GitHub Packages).
2. **Docker Desktop & Engine Wasm Runtimes**:
   - Docker integrates with runtimes like **WasmEdge**, **Wasmtime**, and **Spin** via containerd `runwasi` shims.
   - Developers can run Wasm workloads using familiar commands (`docker run --runtime=io.containerd.wasmedge.v1 ...`) right alongside traditional Linux containers.
3. **Hybrid Architectures**:
   - Complex enterprise stacks use traditional Docker containers for legacy databases, cache stores, and heavy services, while offloading high-velocity, edge, and event-driven functions to ultra-fast WebAssembly modules.
