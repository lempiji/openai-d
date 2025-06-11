#!/usr/bin/env bash
set -euo pipefail

# Build OpenAI D examples
# Usage: build_examples.sh [all|fast]
#   all  - build every example project (default)
#   fast - build a subset of key examples to save time

SCRIPT_DIR=$(cd -- "$(dirname "$0")" && pwd)
EXAMPLES_DIR="$SCRIPT_DIR/../examples"

mode="${1:-all}"
if [[ "$mode" != "all" && "$mode" != "fast" ]]; then
    echo "Usage: $0 [all|fast]" >&2
    exit 1
fi

cd "$EXAMPLES_DIR"

fast_examples=(
    chat
    completion
    embedding
    moderation
    responses
)

if [[ "$mode" == "all" ]]; then
    mapfile -t targets < <(find . -maxdepth 1 -mindepth 1 -type d | sort)
else
    targets=("${fast_examples[@]}")
fi

for dir in "${targets[@]}"; do
    echo "\n## Building $dir" >&2
    (cd "$dir" && dub build)
done
