#!/bin/bash
set -uo pipefail
fail() { echo "FAIL: $1"; exit 1; }
cd ~/app

npx tsx ../scratch/bench.ts >/tmp/t1.log 2>&1 && fail "bench.ts outside a module package should not transform"
grep -q 'Top-level await is currently not supported with the "cjs" output format' /tmp/t1.log || fail "expected the cjs top-level await error"
echo "ok 1 - bench.ts with top-level await fails: tsx treats it as CommonJS"

cp ../scratch/bench.ts ../scratch/bench.mts
bash ~/scripts/start-server.sh >/dev/null
npx tsx ../scratch/bench.mts >/tmp/t2.log 2>&1 && fail "the import should try to start a second server"
grep -q "EADDRINUSE" /tmp/t2.log || fail "expected EADDRINUSE"
echo "ok 2 - bench.mts imports the server module and crashes with EADDRINUSE"

bash ~/scripts/stop-server.sh >/dev/null
timeout 3 npx tsx ../scratch/bench.mts >/tmp/t3.log 2>&1; code=$?
[ "$code" = 124 ] || fail "with the port free the script should hang on the imported server (got $code)"
grep -q "startup job ran" app-data.log || fail "the startup job should have run"
echo "ok 3 - with the port free, the import silently runs the startup job and never exits"
rm -f app-data.log

VITEST=1 npx tsx ../scratch/bench.mts >/tmp/t4.log 2>&1 || fail "the VITEST=1 workaround should run"
[ ! -e app-data.log ] || fail "the workaround should not run the startup job"
echo "ok 4 - pretending to be the test runner works, as a workaround"

bash ~/scripts/fix.sh >/dev/null
npx tsx ../scratch/bench.mts >/tmp/t5.log 2>&1 || fail "after the fix the benchmark should run"
grep -q "bench: 200 requests" /tmp/t5.log || fail "expected the benchmark result"
[ ! -e app-data.log ] || fail "after the fix the import must not run the startup job"
echo "ok 5 - with the entry-point check, the import has no side effects"

bash ~/scripts/start-server.sh >/dev/null
curl -fs http://localhost:3000/ | grep -q '"ok":true' || fail "the server should still start when run directly"
bash ~/scripts/stop-server.sh >/dev/null
echo "ok 6 - run directly, the server still starts"

echo "ALL PASSED"
