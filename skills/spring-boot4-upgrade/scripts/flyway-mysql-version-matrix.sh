#!/usr/bin/env bash

# Inspect MySQL support guards in explicitly selected Flyway release artifacts.
# Usage: flyway-mysql-version-matrix.sh <version> [version ...]

set -euo pipefail

usage() {
    printf 'Usage: %s <flyway-version> [flyway-version ...]\n' "$0" >&2
    printf 'Example: %s 9.22.3 10.21.0\n' "$0" >&2
}

if [[ $# -eq 0 ]]; then
    usage
    exit 2
fi

for command_name in curl unzip javap grep sed mktemp; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        printf 'ERROR: required command not found: %s\n' "$command_name" >&2
        exit 2
    fi
done

MAVEN_CENTRAL_BASE="${MAVEN_CENTRAL_BASE:-https://repo1.maven.org/maven2}"
WORK_DIRECTORY="$(mktemp -d -t flyway-mysql-matrix.XXXXXX)"
trap 'rm -rf "$WORK_DIRECTORY"' EXIT
SUCCESS_COUNT=0
FAILURE_COUNT=0

download_artifact() {
    local artifact="$1"
    local version="$2"
    local destination="$3"
    local url="${MAVEN_CENTRAL_BASE}/org/flywaydb/${artifact}/${version}/${artifact}-${version}.jar"
    curl -fsSL "$url" -o "$destination"
}

for version in "$@"; do
    printf '\n=== Flyway %s ===\n' "$version"

    jar_path="$WORK_DIRECTORY/flyway-$version.jar"
    artifact="flyway-mysql"

    if ! download_artifact "$artifact" "$version" "$jar_path" 2>/dev/null; then
        artifact="flyway-core"
        if ! download_artifact "$artifact" "$version" "$jar_path" 2>/dev/null; then
            printf 'Unable to download Flyway %s from %s\n' "$version" "$MAVEN_CENTRAL_BASE" >&2
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
            continue
        fi
    fi

    extract_directory="$WORK_DIRECTORY/extract-$version"
    mkdir -p "$extract_directory"

    class_path='org/flywaydb/database/mysql/MySQLDatabase.class'
    if ! unzip -oq "$jar_path" "$class_path" -d "$extract_directory" 2>/dev/null; then
        class_path='org/flywaydb/core/internal/database/mysql/MySQLDatabase.class'
        if ! unzip -oq "$jar_path" "$class_path" -d "$extract_directory" 2>/dev/null; then
            printf 'MySQLDatabase.class was not found in %s:%s\n' "$artifact" "$version"
            FAILURE_COUNT=$((FAILURE_COUNT + 1))
            continue
        fi
    fi

    printf 'Artifact: org.flywaydb:%s:%s\n' "$artifact" "$version"
    output="$(
        javap -c -p "$extract_directory/$class_path" 2>/dev/null \
            | sed -n '/ensureSupported/,/^  [[:alpha:]].*);$/p' \
            | grep -E 'String|ensureDatabase|recommend' || true
    )"

    if [[ -n "$output" ]]; then
        printf '%s\n' "$output"
    else
        printf 'No recognizable support guard was found; inspect the artifact and official support matrix manually.\n'
    fi
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
done

printf '\nBytecode strings are diagnostic evidence, not a licensing or support guarantee.\n'
printf 'Confirm database and edition support in the official documentation for each selected release.\n'
printf 'Inspected %d version(s); %d failed.\n' "$SUCCESS_COUNT" "$FAILURE_COUNT"

if [[ "$FAILURE_COUNT" -gt 0 ]]; then
    exit 1
fi
