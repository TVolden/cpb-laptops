#!/usr/bin/env bash
# Evaluate managed-laptop NixOS configs without building (admin only).
#
# Default: one host (koderup1). --all evaluates koderup1..koderup40 in
# succession so each Nix process stays small.
set -euo pipefail

usage() {
  cat <<EOF
Usage: eval-hosts [--all | HOST]

  (no args)  Evaluate koderup1
  HOST       Evaluate that nixosConfiguration
  --all      Evaluate koderup1 through koderup40, stop on first failure
EOF
}

facter_src() {
  local host=$1
  if [[ -f "hosts/${host}/facter.json" ]]; then
    echo "hosts/${host}/facter.json"
  else
    echo "facter.json (fleet default)"
  fi
}

eval_host() {
  local host=$1
  local src start elapsed status
  src=$(facter_src "$host")
  echo "==> eval ${host}  (facter: ${src})"
  start=$(date +%s)
  if nix eval --raw --show-trace --no-update-lock-file \
    ".#nixosConfigurations.${host}.config.system.build.toplevel.drvPath"; then
    elapsed=$(($(date +%s) - start))
    echo "    ok ${host} in ${elapsed}s"
  else
    status=$?
    elapsed=$(($(date +%s) - start))
    echo "    FAIL ${host} exit=${status} after ${elapsed}s"
    return "$status"
  fi
}

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi

case "${1:-}" in
  -h | --help)
    usage
    ;;
  --all)
    echo "==> sequential host eval (koderup1..koderup40)"
    for i in $(seq 1 40); do
      eval_host "koderup${i}"
    done
    echo "==> all hosts evaluated"
    ;;
  "")
    eval_host koderup1
    ;;
  -*)
    usage >&2
    exit 2
    ;;
  *)
    eval_host "$1"
    ;;
esac
