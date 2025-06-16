#!/usr/bin/env bash
set -euo pipefail

# Build OpenAI D examples
# Usage: build_examples.sh [all|core] [GROUP ...]
#   all    - build every example project (default)
#   core   - build a subset of key examples without underscores
#   GROUP  - optional example group such as "chat" or "audio". Only examples
#            starting with the group name will be built.

SCRIPT_DIR=$(cd -- "$(dirname "$0")" && pwd)
EXAMPLES_DIR="$SCRIPT_DIR/../examples"


# Parse mode and optional groups
mode="all"
groups=()
if [[ $# -gt 0 ]]; then
    case "$1" in
        all|core)
            mode="$1"
            shift
            ;;
    esac
    groups=("$@")
fi

cd "$EXAMPLES_DIR"

# Collect all example directories
mapfile -t all_dirs < <(find . -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort)

targets=()
for dir in "${all_dirs[@]}"; do
    include=true
    if [[ ${#groups[@]} -gt 0 ]]; then
        include=false
        for g in "${groups[@]}"; do
            if [[ "$dir" == "$g" || "$dir" == "$g"_* ]]; then
                include=true
                break
            fi
        done
    fi

    if $include; then
        if [[ "$mode" == "core" ]]; then
            if [[ "$dir" != *_* ]]; then
                targets+=("$dir")
            fi
        else
            targets+=("$dir")
        fi
    fi
done

for dir in "${targets[@]}"; do
    echo "\n## Building $dir" >&2
    (cd "$dir" && dub build)
done
