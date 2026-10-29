#!/bin/sh
set -eu

docker build --build-arg APP_BUILD_REVISION="$CI_COMMIT_SHA" -t yuvomi:local .

# Recreate the compose project that runs the yuvomi container, wherever it lives
# on the host, so no host path is committed to this public repo.
if ! dir=$(docker inspect yuvomi --format '{{ index .Config.Labels "com.docker.compose.project.working_dir" }}' 2>/dev/null); then
  echo "no yuvomi container yet, image built only"
  exit 0
fi
project=$(docker inspect yuvomi --format '{{ index .Config.Labels "com.docker.compose.project" }}')

# A sibling container on the host daemon, so the stack's folder (and its relative
# bind mounts and .env) can be mounted at its real host path.
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$dir:$dir:ro" -w "$dir" \
  docker:28-cli docker compose -p "$project" up -d
docker image prune -f
