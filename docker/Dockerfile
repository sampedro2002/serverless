# Stage 1: compile the WebAssembly (hello.wat -> hello.wasm inside ../web)
FROM node:20-alpine AS wasm-build
WORKDIR /src/wasm
COPY wasm/package.json ./
RUN npm install
COPY wasm/ ./
RUN npm run build

# Stage 2: serve the static web app with nginx
FROM nginx:alpine
COPY web/ /usr/share/nginx/html/
COPY --from=wasm-build /src/web/hello.wasm /usr/share/nginx/html/hello.wasm
EXPOSE 80
