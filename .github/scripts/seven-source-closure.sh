#!/usr/bin/env bash
set -euo pipefail

if (( $# != 3 )); then
  echo 'usage: seven-source-closure.sh <all.sources> <entry.sev> <output.sources>' >&2
  exit 2
fi

source_index=$1
entry=$2
output=$3

declare -A modules=()
declare -A source_modules=()
declare -A seen=()

test -f "$source_index" || { echo "missing source index: $source_index" >&2; exit 1; }

while IFS= read -r file || [[ -n "$file" ]]; do
  [[ -z "$file" || "$file" == \#* ]] && continue
  if [[ ! -f "$file" ]]; then
    echo "missing source file: $file" >&2
    exit 1
  fi
  module=$(sed -n '/^modulo[[:space:]]/{s/^modulo[[:space:]]*//;p;q;}' "$file")
  if [[ -z "$module" ]]; then
    echo "missing module declaration: $file" >&2
    exit 1
  fi
  if [[ -n "${source_modules[$file]:-}" ]]; then
    echo "duplicate source in index: $file" >&2
    exit 1
  fi
  source_modules[$file]=$module
  modules[$module]+=" $file"
done < "$source_index"

if [[ -z "${source_modules[$entry]:-}" ]]; then
  echo "entry missing from index: $entry" >&2
  exit 1
fi

queue=("${source_modules[$entry]}")
files=()
index=0
while (( index < ${#queue[@]} )); do
  module=${queue[index]}
  index=$((index + 1))
  [[ -n "${seen[$module]:-}" ]] && continue
  seen[$module]=1

  if [[ -z "${modules[$module]:-}" ]]; then
    echo "unresolved module: $module" >&2
    exit 1
  fi

  # Paths in seven.sources are repository-relative and cannot contain spaces.
  read -r -a members <<< "${modules[$module]}"
  for file in "${members[@]}"; do
    files+=("$file")
    while IFS= read -r dependency; do
      [[ -z "$dependency" ]] && continue
      if [[ -z "${modules[$dependency]:-}" ]]; then
        echo "unresolved import $dependency in $file" >&2
        exit 1
      fi
      queue+=("$dependency")
    done < <(awk '$1 == "usa" {print $2}' "$file")
  done
done

printf '%s\n' "${files[@]}" | LC_ALL=C sort -u > "$output"

test -s "$output" || { echo "empty closure for $entry" >&2; exit 1; }
