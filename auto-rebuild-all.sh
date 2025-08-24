#!/bin/bash

# Auto-rebuild script for Arr No-Auth patches
# This script checks for upstream image updates and rebuilds custom images

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="/mnt/cache/docker/media"  # Adjust to your docker-compose location
LOG_FILE="/var/log/arr-rebuild.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_and_rebuild() {
    local service_name="$1"
    local image_name="$2"
    local dockerfile_path="$3"
    
    log "Checking $service_name for updates..."
    
    # Pull latest upstream image
    docker pull linuxserver/$service_name:latest
    
    # Get current digests
    UPSTREAM_DIGEST=$(docker image inspect linuxserver/$service_name:latest | jq -r '.[0].Id')
    CURRENT_DIGEST=""
    
    # Check if our custom image exists
    if docker image inspect "$image_name" >/dev/null 2>&1; then
        # Get the upstream digest that our image was built from
        CURRENT_DIGEST=$(docker image inspect "$image_name" | jq -r '.[0].Config.Labels."upstream_digest" // empty')
    fi
    
    if [ "$UPSTREAM_DIGEST" != "$CURRENT_DIGEST" ]; then
        log "Upstream $service_name image updated. Rebuilding custom image..."
        
        # Build new image with upstream digest label
        docker build \
            --label "upstream_digest=$UPSTREAM_DIGEST" \
            --label "build_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            -t "$image_name" \
            "$dockerfile_path"
            
        if [ $? -eq 0 ]; then
            log "Successfully rebuilt $image_name"
            
            # Restart the service if docker-compose is available
            if [ -f "$COMPOSE_DIR/docker-compose.yml" ]; then
                log "Restarting $service_name service..."
                cd "$COMPOSE_DIR"
                docker-compose up -d "$service_name"
                log "$service_name service restarted"
            fi
        else
            log "Failed to rebuild $image_name"
        fi
    else
        log "No update needed for $service_name"
    fi
}

main() {
    log "Starting Arr rebuild check..."
    
    # Create lock file to prevent concurrent runs
    LOCK_FILE="/tmp/arr-rebuild.lock"
    if [ -f "$LOCK_FILE" ]; then
        log "Another rebuild process is running. Exiting."
        exit 0
    fi
    
    touch "$LOCK_FILE"
    trap "rm -f $LOCK_FILE" EXIT
    
    # Check and rebuild each service
    check_and_rebuild "sonarr" "sonarr-no-auth:final" "$SCRIPT_DIR/sonarr"
    check_and_rebuild "radarr" "radarr-no-auth:final" "$SCRIPT_DIR/radarr"
    
    log "Arr rebuild check completed"
}

main "$@"
