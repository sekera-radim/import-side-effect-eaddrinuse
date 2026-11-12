# Importing a module starts the server: EADDRINUSE

A small Node.js API whose main file both exports `createApp()` and starts the server at the bottom,
guarded only by a test-runner environment variable. A benchmark script that imports `createApp`
therefore starts a second server and crashes with `EADDRINUSE`. With the port free it is worse:
the import silently runs the startup job and the script never exits.

The demo also shows a second trap on the way: a `.ts` script with top-level await, placed in a folder
without a `"type": "module"` package, fails under tsx with
`Top-level await is currently not supported with the "cjs" output format`. Renaming it to `.mts` fixes that.

The fix is an entry-point check: `if (import.meta.main) main();` (Node.js 22.18+ or 24.2+).
On older versions, keep `createApp` in a module without side effects and start the server from a separate entry file.

## Run it

```bash
docker build -t import-side-effect-demo .
docker run --rm import-side-effect-demo
```

The test prints six `ok` lines and `ALL PASSED`.

- `template/app/src/server.ts`: the API with the guard at the bottom
- `template/scratch/bench.ts`: the benchmark script
- `scripts/fix.sh`: applies the entry-point check
- `scripts/test.sh`: every step shown in the video
