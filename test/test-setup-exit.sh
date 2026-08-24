#!/usr/bin/env bash
# Offline: unresolved VERSION is I/O, so the wrapper must exit 2, not 1.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STUB="$(mktemp -d)"
trap 'rm -rf "$STUB"' EXIT

cat > "$STUB/curl" <<'EOF'
#!/usr/bin/env bash
echo '{"tag_name":""}'
exit 0
EOF
chmod +x "$STUB/curl"

export PATH="$STUB:$PATH"
export VERSION=latest
set +e
bash "$ROOT/scan/trustabl-scan.sh" >/tmp/trustabl-setup-exit.log 2>&1
rc=$?
set -e
[ "$rc" -eq 2 ] || {
  echo "expected exit 2 when VERSION cannot be resolved, got $rc"
  cat /tmp/trustabl-setup-exit.log
  exit 1
}
echo "ok: unresolved VERSION exits 2"
