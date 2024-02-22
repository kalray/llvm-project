#!/usr/bin/bash
# Run this script to regenerate all generated test files

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

find_root_dir () {
  local dir
  dir=$(pwd)
  while [ "$(basename "$dir")" != "$1" ]; do
    dir=$(dirname "$dir")
  done
  echo "$dir"
}

ROOT_DIR=$(find_root_dir llvm-project)
TEST_DIR=$ROOT_DIR/llvm/test/CodeGen/KVX/

"$SCRIPT_DIR"/copro-regs.rb > "$TEST_DIR/copro-regs.ll"
echo "Done!"
