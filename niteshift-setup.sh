#!/bin/bash
#
# Niteshift Setup Script for Directus Admin App
# This script starts the Vue.js development server on port 8080
#

set -e

# Use NITESHIFT_LOG_FILE if set, otherwise default
LOG_FILE="${NITESHIFT_LOG_FILE:-/root/.niteshift/niteshift-setup.log}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting Directus Admin App setup..."

cd /root/directus-app

# Install dependencies if node_modules doesn't exist or package-lock.json changed
if [ ! -d "node_modules" ] || [ "package-lock.json" -nt "node_modules" ]; then
    log "Installing npm dependencies..."
    npm install 2>&1 | tee -a "$LOG_FILE"
else
    log "node_modules already up to date, skipping npm install"
fi

# Create config.js with demo API endpoints if it doesn't exist
if [ ! -f "public/config.js" ]; then
    log "Creating public/config.js with demo API configuration..."
    cat > public/config.js << 'EOF'
/* eslint-disable */

(function directusConfig() {
  const config = {
    // Demo API endpoints for local development
    api: {
      "https://demo-api.directus.app/_/": "Directus Demo API"
    },

    // Allow the user to connect to any API by entering a URL
    allowOtherAPI: true,

    // Use hash mode for routing (works without server rewrites)
    routerMode: "hash",

    // Base URL for routing
    routerBaseUrl: "/"
  };

  window.__DirectusConfig__ = config;
})();
EOF
else
    log "public/config.js already exists, keeping existing configuration"
fi

# Set NODE_OPTIONS for OpenSSL compatibility with older webpack on Node 22+
# This resolves "error:0308010C:digital envelope routines::unsupported"
export NODE_OPTIONS="--openssl-legacy-provider"

log "Starting Vue CLI development server on port 8080..."

# Start the dev server (this will keep running)
exec npm run dev 2>&1 | tee -a "$LOG_FILE"
