#!/bin/bash
# Start the API in the background and wait until it answers.
cd ~/app
nohup node --import tsx src/server.ts >/tmp/server.log 2>&1 &
echo $! > /tmp/server.pid
for i in $(seq 1 50); do curl -fs http://localhost:3000/ >/dev/null 2>&1 && break; sleep 0.1; done
echo "server started on port 3000"
