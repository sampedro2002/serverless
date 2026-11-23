// Compila hello.wat a hello.wasm y lo deja en ../web/
// Uso: npm install && node build.js
const fs = require('fs');
const path = require('path');
const wabtInit = require('wabt');

(async () => {
  const wabt = await wabtInit();

  const watPath = path.join(__dirname, 'hello.wat');
  const outDir = path.join(__dirname, '..', 'web');
  const outPath = path.join(outDir, 'hello.wasm');

  const source = fs.readFileSync(watPath, 'utf8');
  const module = wabt.parseWat('hello.wat', source);
  const { buffer } = module.toBinary({});

  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(outPath, buffer);
  console.log(`Compilado: ${outPath} (${buffer.length} bytes)`);
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
