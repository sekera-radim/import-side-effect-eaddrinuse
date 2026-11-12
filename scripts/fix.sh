#!/bin/bash
# Replace the environment-variable guard with an entry-point check.
cd ~/app
sed -i 's/^if (!process.env.VITEST) main();$/if (import.meta.main) main();/' src/server.ts
sed -i 's|^// Do not start the server when the test runner imports this file.$|// Start the server only when this file is the program that was run.|' src/server.ts
echo "fixed: src/server.ts now ends with"
tail -2 src/server.ts
