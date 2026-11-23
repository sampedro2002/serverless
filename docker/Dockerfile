# Etapa 1: compila el WebAssembly (hello.wat -> hello.wasm dentro de ../web)
FROM node:20-alpine AS wasm-build
WORKDIR /src/wasm
COPY wasm/package.json ./
RUN npm install
COPY wasm/ ./
RUN npm run build

# Etapa 2: sirve la web estática con nginx
FROM nginx:alpine
COPY web/ /usr/share/nginx/html/
COPY --from=wasm-build /src/web/hello.wasm /usr/share/nginx/html/hello.wasm
EXPOSE 80
