#!/usr/bin/env bash

# Find Maven repository JARs whose decompressed contents contain a binary class name.
# Usage: scan-class-references.sh <class-binary-name> [maven-repository]

set -euo pipefail

usage() {
    printf 'Usage: %s <class-binary-name> [maven-repository]\n' "$0" >&2
    printf 'Example: %s net/sf/jsqlparser/statement/select/SelectBody ~/.m2/repository\n' "$0" >&2
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage
    exit 2
fi

CLASS_REF="$1"
REPOSITORY="${2:-${HOME}/.m2/repository}"

if [[ "$CLASS_REF" != */* && "$CLASS_REF" == *.* ]]; then
    CLASS_REF="${CLASS_REF//.//}"
fi

if [[ ! -d "$REPOSITORY" ]]; then
    printf 'ERROR: Maven repository not found: %s\n' "$REPOSITORY" >&2
    exit 2
fi

for command_name in find unzip strings grep; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'ERROR: required command not found: %s\n' "$command_name" >&2
        exit 2
    fi
done

export LC_ALL=C

TOTAL=0
MATCHED=0

printf 'Binary class reference: %s\n' "$CLASS_REF"
printf 'Repository: %s\n' "$REPOSITORY"

while IFS= read -r -d '' jar_path; do
    TOTAL=$((TOTAL + 1))
    hit_count="$(
        unzip -p "$jar_path" 2>/dev/null \
            | strings 2>/dev/null \
            | grep -F -c -- "$CLASS_REF" || true
    )"
    hit_count="${hit_count:-0}"

    if [[ "$hit_count" -gt 0 ]]; then
        relative_path="${jar_path#"$REPOSITORY"/}"
        printf '%6d  %s\n' "$hit_count" "$relative_path"
        MATCHED=$((MATCHED + 1))
    fi
done < <(find "$REPOSITORY" -type f -name '*.jar' -print0)

printf 'Scanned %d JAR(s); %d contained the reference.\n' "$TOTAL" "$MATCHED"
printf 'Confirm candidates with javap or a bytecode analysis tool before changing dependencies.\n'
