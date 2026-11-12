import { createServer } from 'node:http';
import { appendFileSync } from 'node:fs';

const PORT = 3000;

export function createApp() {
  return createServer((_req, res) => {
    res.setHeader('content-type', 'application/json');
    res.end(JSON.stringify({ ok: true }) + '\n');
  });
}

export function main() {
  // Startup work a real service does: open its data file, run a first job.
  appendFileSync('app-data.log', 'startup job ran\n');
  console.log('startup job ran, data file: app-data.log');
  createApp().listen(PORT, () => console.log(`listening on ${PORT}`));
}

// Do not start the server when the test runner imports this file.
if (!process.env.VITEST) main();
