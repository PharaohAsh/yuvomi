#!/bin/sh
set -u

NTFY_URL="${NTFY_URL:-}"
NTFY_TOKEN="${NTFY_TOKEN:-}"

repo="${CI_REPO:-unknown/repo}"
branch="${CI_COMMIT_BRANCH:-unknown}"
sha="${CI_COMMIT_SHA:-unknown}"
short_sha=$(printf '%s' "$sha" | cut -c1-8)
build="${CI_PIPELINE_NUMBER:-${CI_BUILD_NUMBER:-?}}"
link="${CI_PIPELINE_FORGE_URL:-${CI_BUILD_LINK:-}}"
author="${CI_COMMIT_AUTHOR:-unknown}"
message="${CI_COMMIT_MESSAGE:-}"

title="Crow CI: ${repo} pipeline #${build} failed"
body="$(printf 'branch: %s\ncommit: %s (%s)\nauthor: %s\n\n%s\n%s' \
  "$branch" "$short_sha" "$sha" "$author" "$message" "$link")"

if command -v curl >/dev/null 2>&1 && [ -n "$NTFY_URL" ]; then
  curl -fsS --max-time 15 \
    -H "Title: ${title}" \
    -H "Priority: urgent" \
    -H "Tags: rotating_light,crow" \
    ${NTFY_TOKEN:+-H "Authorization: Bearer ${NTFY_TOKEN}"} \
    -d "$body" "$NTFY_URL" >/dev/null \
    && echo "ntfy sent (${title})" \
    || echo "ntfy notification failed"
else
  echo "curl or NTFY_URL missing; skipped failure notification"
fi
