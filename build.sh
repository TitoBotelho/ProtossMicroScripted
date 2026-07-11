#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${ROOT_DIR}/build"

echo "[build] preparing ${OUT_DIR}"
rm -rf "${OUT_DIR}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "[build] copying project files"
cp -a "${ROOT_DIR}/." "${TMP_DIR}/"

echo "[build] pruning unwanted files"
rm -rf "${TMP_DIR}/.git" \
       "${TMP_DIR}/.github" \
       "${TMP_DIR}/.venv" \
       "${TMP_DIR}/__pycache__" \
       "${TMP_DIR}/build"

find "${TMP_DIR}" -type d -name "__pycache__" -prune -exec rm -rf {} + 2>/dev/null || true
find "${TMP_DIR}" -type f -name "*.pyc" -delete 2>/dev/null || true

echo "[build] creating runtime launcher"
cat > "${TMP_DIR}/run_bot.sh" <<'INNER'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if [[ -f pyproject.toml ]] && command -v poetry >/dev/null 2>&1; then
  exec poetry run python run.py "$@"
fi

if command -v python3 >/dev/null 2>&1; then
  exec python3 run.py "$@"
fi

echo "python3 not found in PATH" >&2
exit 127
INNER

chmod +x "${TMP_DIR}/run_bot.sh"

if [[ ! -f "${TMP_DIR}/run.py" ]]; then
  echo "[build][error] run.py not found in repository root" >&2
  exit 1
fi

mv "${TMP_DIR}" "${OUT_DIR}"

if [[ -z "$(find "${OUT_DIR}" -mindepth 1 -print -quit)" ]]; then
  echo "[build][error] build directory is empty" >&2
  exit 1
fi

echo "[build] done: ${OUT_DIR}"
echo "[build] launcher: ${OUT_DIR}/run_bot.sh"
