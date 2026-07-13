#!/usr/bin/env bash

# Advisory preflight scan for a Spring Boot 3.5 to 4.x migration.
# Usage: upgrade-audit.sh [--strict] [project-root]

set -uo pipefail

STRICT=false
ROOT="."
ROOT_SET=false

usage() {
    printf 'Usage: %s [--strict] [project-root]\n' "$0"
    printf '  --strict  exit 1 when review warnings are found\n'
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --strict)
            STRICT=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [[ "$ROOT_SET" == true ]]; then
                usage >&2
                exit 2
            fi
            ROOT="$1"
            ROOT_SET=true
            ;;
    esac
    shift
done

if [[ ! -d "$ROOT" ]]; then
    printf 'ERROR: project root is not a directory: %s\n' "$ROOT" >&2
    exit 2
fi

cd "$ROOT" || exit 2

if [[ ! -f pom.xml && ! -f build.gradle && ! -f build.gradle.kts && ! -f settings.gradle && ! -f settings.gradle.kts ]]; then
    printf 'ERROR: no Maven or Gradle build found at %s\n' "$(pwd)" >&2
    exit 2
fi

INFO_COUNT=0
WARN_COUNT=0

search_files() {
    local scope="$1"
    local pattern="$2"
    local common=(
        -RInE
        --exclude-dir=.git
        --exclude-dir=.gradle
        --exclude-dir=target
        --exclude-dir=build
        --exclude-dir=node_modules
    )

    case "$scope" in
        build)
            grep "${common[@]}" --include='pom.xml' --include='build.gradle' --include='build.gradle.kts' -- "$pattern" . 2>/dev/null || true
            ;;
        source)
            grep "${common[@]}" --include='*.java' --include='*.kt' -- "$pattern" . 2>/dev/null || true
            ;;
        config)
            grep "${common[@]}" --include='*.yml' --include='*.yaml' --include='*.properties' -- "$pattern" . 2>/dev/null || true
            ;;
        runtime)
            grep "${common[@]}" --include='Dockerfile*' --include='*.yml' --include='*.yaml' --include='*.xml' --include='*.sh' -- "$pattern" . 2>/dev/null || true
            ;;
        all)
            grep "${common[@]}" --include='pom.xml' --include='build.gradle' --include='build.gradle.kts' --include='*.java' --include='*.kt' --include='*.yml' --include='*.yaml' --include='*.properties' --include='Dockerfile*' -- "$pattern" . 2>/dev/null || true
            ;;
        *)
            return 2
            ;;
    esac
}

report_matches() {
    local severity="$1"
    local title="$2"
    local scope="$3"
    local pattern="$4"
    local matches

    matches="$(search_files "$scope" "$pattern")"
    if [[ -z "$matches" ]]; then
        return
    fi

    if [[ "$severity" == "WARN" ]]; then
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        INFO_COUNT=$((INFO_COUNT + 1))
    fi

    printf '\n[%s] %s\n' "$severity" "$title"
    printf '%s\n' "$matches" | sed 's/^/  /'
}

printf 'Spring Boot 4 upgrade preflight\n'
printf 'Project: %s\n' "$(pwd)"
printf 'Mode: %s\n' "$([[ "$STRICT" == true ]] && printf strict || printf advisory)"

report_matches INFO 'Spring Boot declarations to confirm' build \
    'spring-boot-starter-parent|org[.]springframework[.]boot|springBootVersion|spring-boot[.]version'

report_matches WARN 'Deprecated or transitional starter declarations require review' build \
    'spring-boot-starter-web([:@<"]|$)|spring-boot-starter-web-services|spring-boot-starter-classic|spring-boot-starter-test-classic'

report_matches WARN 'Undertow is not supported by Spring Boot 4 servlet applications' build \
    'spring-boot-starter-undertow|io[.]undertow'

report_matches WARN 'Removed Spring Boot test annotations require migration' source \
    '@(MockBean|SpyBean)\b|org[.]springframework[.]boot[.]test[.]mock[.]mockito'

report_matches WARN 'Legacy Spring Security DSL calls require review' source \
    'authorizeRequests[[:space:]]*\(|[.]and[[:space:]]*\([[:space:]]*\)'

report_matches INFO 'Jackson 2 application APIs require an explicit migration decision' source \
    'com[.]fasterxml[.]jackson[.](core|databind)|Jackson2ObjectMapperBuilderCustomizer|@Json(Component|Mixin)'

report_matches INFO 'Custom auto-configuration or broad Boot modules require modularization review' all \
    'spring-boot-autoconfigure|AutoConfiguration[.]imports|spring[.]factories|spring-autoconfigure-metadata[.]properties'

report_matches INFO 'Third-party integration families require upstream compatibility checks' build \
    'jsqlparser|pagehelper|springdoc|swagger|knife4j|httpclient5|hibernate-types|hypersistence|redisson|mybatis'

report_matches WARN 'Compatibility or safety controls are explicitly disabled' all \
    'compatibility-verifier[.]enabled[[:space:]]*[:=][[:space:]]*false|flyway[.]enabled[[:space:]]*[:=][[:space:]]*false|sslmode=disable|csrf.*(disable|ignoringRequestMatchers)'

report_matches INFO 'Virtual-thread-sensitive code or configuration is present' all \
    'spring[.]threads[.]virtual[.]enabled|ThreadLocal|InheritableThreadLocal|synchronized[[:space:]]*[(]'

report_matches INFO 'Custom JVM flags require runtime-specific justification' runtime \
    '--add-opens|--sun-misc-unsafe-memory-access|UnlockExperimentalVMOptions|UseCompactObjectHeaders|enable-preview'

printf '\nSummary: %d informational group(s), %d review warning group(s).\n' "$INFO_COUNT" "$WARN_COUNT"
printf 'Review findings against the selected Boot release and resolved dependency graph before editing.\n'

if [[ "$STRICT" == true && "$WARN_COUNT" -gt 0 ]]; then
    exit 1
fi

exit 0
