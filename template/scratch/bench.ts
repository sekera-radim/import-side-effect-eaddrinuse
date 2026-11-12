import { createApp } from '../app/src/server.ts';

// Benchmark the request handler on a private, random port.
const app = createApp();
await new Promise<void>((resolve) => app.listen(0, resolve));
const { port } = app.address() as { port: number };

const N = 200;
for (let i = 0; i < N; i++) {
  await fetch(`http://127.0.0.1:${port}/`).then((r) => r.text());
}
console.log(`bench: ${N} requests answered on port ${port}`);
app.close();
