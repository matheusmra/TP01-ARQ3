#!/usr/bin/env bash
set -euo pipefail

PROG=$(basename "$0")
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build}"
SIM="${SIM:-iverilog}"
TESTBENCH="tb_cache_controller"
WAVES=false
CLEAN=false
RUN_ALL=false

usage() {
  cat <<EOF
Usage: $PROG [options]
Options:
  --testbench <name>   Run a specific testbench from tb/ (default: tb_cache_controller)
  --waves              Open GTKWave after simulation
  --run-all            Execute all testbenches sequentially
  --clean              Remove generated build artifacts
  --sim <simulator>    Simulator to use (default: iverilog)
  --outdir <dir>       Build output directory (default: build)
  --help               Show this message
EOF
}

error() {
  printf "ERROR: %s\n" "$*" >&2
  exit 1
}

log() {
  printf "=> %s\n" "$*"
}

check_cmd() {
  command -v "$1" >/dev/null 2>&1 || error "Missing dependency: $1"
}

if [ $# -eq 0 ]; then
  :
fi

while [ $# -gt 0 ]; do
  case "$1" in
    --testbench)
      shift
      [ $# -gt 0 ] || error "--testbench requires a name"
      TESTBENCH="$1"
      ;;
    --waves)
      WAVES=true
      ;;
    --run-all)
      RUN_ALL=true
      ;;
    --clean)
      CLEAN=true
      ;;
    --sim)
      shift
      [ $# -gt 0 ] || error "--sim requires a value"
      SIM="$1"
      ;;
    --outdir)
      shift
      [ $# -gt 0 ] || error "--outdir requires a directory"
      BUILD_DIR="$1"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      ;;
  esac
  shift
done

if [ "$CLEAN" = true ]; then
  check_cmd make
  log "Cleaning build artifacts in $BUILD_DIR"
  make -C "$ROOT_DIR" clean BUILD_DIR="$BUILD_DIR"
  exit 0
fi

check_cmd make
case "$SIM" in
  iverilog)
    check_cmd iverilog
    check_cmd vvp
    ;;
  xsim)
    check_cmd xvlog
    check_cmd xelab
    check_cmd xsim
    ;;
  *)
    error "Unsupported simulator: $SIM. Supported: iverilog, xsim"
    ;;
esac

if [ "$WAVES" = true ]; then
  check_cmd gtkwave
fi

if [ "$RUN_ALL" = true ]; then
  log "Running all testbenches with SIM=$SIM"
  make -C "$ROOT_DIR" SIM="$SIM" BUILD_DIR="$BUILD_DIR" run_all
  exit 0
fi

log "Running testbench $TESTBENCH with SIM=$SIM"
make -C "$ROOT_DIR" SIM="$SIM" BUILD_DIR="$BUILD_DIR" RUN_TB="$TESTBENCH" run

if [ "$WAVES" = true ]; then
  log "Opening GTKWave for generated waveform"
  gtkwave "$BUILD_DIR/waves.vcd"
fi
