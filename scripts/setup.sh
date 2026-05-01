#!/usr/bin/env bash
# Dev environment setup for mona.cool (Linux).
# Installs Hugo extended, Dart Sass, and npm dependencies.
# Binaries land in ~/.local/bin
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.161.1}"
DART_SASS_VERSION="${DART_SASS_VERSION:-1.83.4}"
UV_VERSION="${UV_VERSION:-0.11.8}"

BIN_DIR="${HOME}/.local/bin"
OPT_DIR="${HOME}/.local/opt"
mkdir -p "${BIN_DIR}" "${OPT_DIR}"
export PATH="${BIN_DIR}:${PATH}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Required command not found: $1" >&2
    exit 1
  }
}

require_cmd curl
require_cmd tar

case "$(uname -s)" in
  Linux) ;;
  *) echo "This script targets Linux/WSL2. Detected: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64) ARCH_HUGO="amd64"; ARCH_SASS="x64"; ARCH_UV="x86_64-unknown-linux-gnu" ;;
  aarch64|arm64) ARCH_HUGO="arm64"; ARCH_SASS="arm64"; ARCH_UV="aarch64-unknown-linux-gnu" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

install_hugo() {
  local installed=""
  if [[ -x "${BIN_DIR}/hugo" ]]; then
    installed="$("${BIN_DIR}/hugo" version | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -n1 | sed 's/^v//')"
  fi
  if [[ "${installed}" == "${HUGO_VERSION}" ]]; then
    log "Hugo ${HUGO_VERSION} already installed."
    return
  fi

  log "Installing Hugo extended ${HUGO_VERSION}..."
  local url tmp
  url="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${ARCH_HUGO}.tar.gz"
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' RETURN
  curl -fsSL "${url}" -o "${tmp}/hugo.tar.gz"
  tar -xzf "${tmp}/hugo.tar.gz" -C "${tmp}" hugo
  install -m 0755 "${tmp}/hugo" "${BIN_DIR}/hugo"
}

install_dart_sass() {
  local installed=""
  if [[ -x "${BIN_DIR}/sass" ]]; then
    installed="$("${BIN_DIR}/sass" --version 2>/dev/null | head -n1 || true)"
  fi
  if [[ "${installed}" == "${DART_SASS_VERSION}" ]]; then
    log "Dart Sass ${DART_SASS_VERSION} already installed."
    return
  fi

  log "Installing Dart Sass ${DART_SASS_VERSION}..."
  local url tmp
  url="https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-${ARCH_SASS}.tar.gz"
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' RETURN
  curl -fsSL "${url}" -o "${tmp}/dart-sass.tar.gz"
  rm -rf "${OPT_DIR}/dart-sass"
  tar -xzf "${tmp}/dart-sass.tar.gz" -C "${OPT_DIR}"
  ln -sf "${OPT_DIR}/dart-sass/sass" "${BIN_DIR}/sass"
}

install_node_deps() {
  if ! command -v npm >/dev/null 2>&1; then
    warn "npm not found. Install Node.js (https://nodejs.org) and re-run this script, or run 'npm install' yourself."
    return
  fi
  log "Installing npm dependencies..."
  if [[ -f "${REPO_ROOT}/package-lock.json" ]]; then
    (cd "${REPO_ROOT}" && npm ci)
  else
    (cd "${REPO_ROOT}" && npm install)
  fi
}

install_uv() {
  local installed=""
  if [[ -x "${BIN_DIR}/uv" ]]; then
    installed="$("${BIN_DIR}/uv" --version 2>/dev/null | awk '{print $2}' || true)"
  fi
  if [[ "${installed}" == "${UV_VERSION}" ]]; then
    log "uv ${UV_VERSION} already installed."
    return
  fi

  log "Installing uv ${UV_VERSION}..."
  local url tmp
  url="https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-${ARCH_UV}.tar.gz"
  tmp="$(mktemp -d)"
  trap 'rm -rf "${tmp}"' RETURN
  curl -fsSL "${url}" -o "${tmp}/uv.tar.gz"
  tar -xzf "${tmp}/uv.tar.gz" -C "${tmp}"
  install -m 0755 "${tmp}/uv-${ARCH_UV}/uv" "${BIN_DIR}/uv"
  if [[ -f "${tmp}/uv-${ARCH_UV}/uvx" ]]; then
    install -m 0755 "${tmp}/uv-${ARCH_UV}/uvx" "${BIN_DIR}/uvx"
  fi
}

install_pre_commit() {
  if ! command -v uv >/dev/null 2>&1; then
    warn "uv not on PATH — skipping pre-commit install. Add ${BIN_DIR} to PATH and re-run."
    return
  fi

  if uv tool list 2>/dev/null | grep -q '^pre-commit '; then
    log "pre-commit already installed via uv. Upgrading..."
    uv tool upgrade pre-commit >/dev/null
  else
    log "Installing pre-commit via uv (will fetch a managed Python on first run)..."
    uv tool install pre-commit
  fi

  log "Wiring pre-commit git hook..."
  (cd "${REPO_ROOT}" && pre-commit install)
}

install_hugo
install_dart_sass
install_uv
install_node_deps
install_pre_commit

log "Done."
case ":${PATH}:" in
  *":${BIN_DIR}:"*) ;;
  *) warn "${BIN_DIR} is not on your PATH. Add: export PATH=\"\${HOME}/.local/bin:\${PATH}\"" ;;
esac
