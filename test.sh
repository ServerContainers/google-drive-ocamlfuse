#!/bin/sh
# automated smoke test for the google-drive-ocamlfuse container
# builds the image and asserts the from-source binary + its runtime libs load.
#
# NOTE: a full Google Drive mount can't be tested headless/in CI - it needs an
# interactive OAuth flow (browser consent + credentials). so the meaningful
# functional check is running the compiled binary and confirming it executes,
# prints its version and that the fuse runtime is present. this proves the
# opam-built binary and its shared libs (fuse3, gmp, sqlite, curl, ...) load.
set -eu

IMAGE=google-drive-ocamlfuse-test
NAME=google-drive-ocamlfuse-test-run

FAILED=0
fail() {
  echo "FAIL: $*" >&2
  FAILED=1
}

cleanup() {
  echo ">> cleanup: removing container $NAME"
  docker rm -f "$NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

echo ">> building image $IMAGE"
docker build -t "$IMAGE" .

# start a long-lived container overriding the entrypoint (the real entrypoint
# tries to mount google drive and would exit without credentials). we keep it
# idle and poke it with docker exec - no host bind-mounts.
echo ">> (re)starting container $NAME"
docker rm -f "$NAME" >/dev/null 2>&1 || true
docker run -d --name "$NAME" --entrypoint sh "$IMAGE" -c 'sleep 300'

echo ">> assert: container is running"
if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "ok - container running"
else
  echo "!! container is not running, dumping logs:" >&2
  docker logs "$NAME" >&2 2>&1 || true
  fail "container not running"
fi

if docker ps --format '{{.Names}}' | grep -q "^${NAME}$"; then

  echo ">> assert: google-drive-ocamlfuse binary exists and is executable"
  if docker exec "$NAME" sh -c 'command -v google-drive-ocamlfuse >/dev/null'; then
    echo "ok - binary present on PATH"
  else
    fail "google-drive-ocamlfuse not found on PATH"
  fi

  echo ">> assert: 'google-drive-ocamlfuse -version' runs and prints 0.9.x"
  VERSION_OUT=$(docker exec "$NAME" google-drive-ocamlfuse -version 2>&1 || true)
  echo "$VERSION_OUT"
  if echo "$VERSION_OUT" | grep -Eq 'google-drive-ocamlfuse, version 0\.9\.[0-9]+'; then
    echo "ok - binary executed and reported version: $(echo "$VERSION_OUT" | grep -Eo 'version 0\.9\.[0-9]+')"
  else
    fail "binary did not report expected 0.9.x version (runtime libs may be missing)"
  fi

  echo ">> assert: fuse3 runtime (fusermount3) is present"
  if docker exec "$NAME" sh -c 'command -v fusermount3 >/dev/null'; then
    echo "ok - fusermount3 available"
  else
    fail "fusermount3 not found (fuse3 runtime missing)"
  fi

fi

echo
if [ "$FAILED" -eq 0 ]; then
  echo "ALL TESTS PASSED"
  echo "(note: a full Google Drive mount is not tested - it requires interactive OAuth credentials)"
  exit 0
else
  echo "SOME TESTS FAILED"
  exit 1
fi
