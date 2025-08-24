#!/bin/bash

# Auto-rebuild sonarr-no-auth when upstream updates
# Place this in /mnt/cache/docker/sonarr-no-auth/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG_FILE="/mnt/user/logs/sonarr-rebuild.log"
LOCK_FILE="/tmp/sonarr-rebuild.lock"
UPSTREAM_IMAGE="linuxserver/sonarr:latest"
CUSTOM_IMAGE="sonarr-no-auth:final"
COMPOSE_DIR="/mnt/cache/docker/media"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send notification (optional)
notify() {
    local message="$1"
    log "$message"
    # Uncomment and configure for your notification system:
    # curl -X POST "your-webhook-url" -d "message=$message" || true
}

# Check for lock file to prevent multiple runs
if [ -f "$LOCK_FILE" ]; then
    log "Rebuild already in progress (lock file exists)"
    exit 1
fi

# Create lock file
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

log "🔍 Starting Sonarr auto-rebuild check..."

# Get current upstream image digest
log "Pulling latest upstream image..."
if ! docker pull "$UPSTREAM_IMAGE" >&2; then
    log "❌ Failed to pull upstream image"
    exit 1
fi

# Get image digests
UPSTREAM_DIGEST=$(docker inspect "$UPSTREAM_IMAGE" --format='{{index .RepoDigests 0}}' 2>/dev/null || echo "")
CUSTOM_DIGEST=$(docker inspect "$CUSTOM_IMAGE" --format='{{.Config.Labels.upstream_digest}}' 2>/dev/null || echo "")

log "Upstream digest: $UPSTREAM_DIGEST"
log "Custom image upstream digest: $CUSTOM_DIGEST"

# Check if rebuild is needed
if [ "$UPSTREAM_DIGEST" = "$CUSTOM_DIGEST" ]; then
    log "✅ No rebuild needed - images are up to date"
    exit 0
fi

log "🔄 Upstream image has been updated - rebuilding custom image..."
notify "🔄 Sonarr: Starting rebuild due to upstream update"

# Add upstream digest as label to track
sed -i '/^FROM linuxserver\/sonarr:latest/a LABEL upstream_digest="'$UPSTREAM_DIGEST'"' Dockerfile.final

# Rebuild the custom image
log "🔨 Building new custom image..."
if ! docker build -f Dockerfile.final -t "$CUSTOM_IMAGE" . >&2; then
    log "❌ Failed to build custom image"
    notify "❌ Sonarr: Custom image build failed"
    exit 1
fi

log "✅ Custom image rebuilt successfully"

# Restart the containers
log "🔄 Restarting Sonarr containers..."
cd "$COMPOSE_DIR"

# Stop containers
docker-compose stop sonarr sonarr-anime

# Remove old containers
docker rm sonarr-tv sonarr-anime 2>/dev/null || true

# Start with new image
if docker-compose up -d sonarr sonarr-anime; then
    log "✅ Containers restarted successfully"
    notify "✅ Sonarr: Auto-rebuild completed and containers restarted"
else
    log "❌ Failed to restart containers"
    notify "❌ Sonarr: Container restart failed after rebuild"
    exit 1
fi

# Clean up old images (optional)
log "🧹 Cleaning up old images..."
docker image prune -f >&2 || true

log "🎉 Auto-rebuild process completed successfully"
