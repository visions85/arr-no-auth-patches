# Arr No-Auth Patches

Docker patches to disable authentication popup modals for Sonarr and Radarr while using external authentication (like Authentik, Authelia, etc.).

## Overview

These patches solve the common issue where Sonarr/Radarr show annoying "Authentication Required" popup modals even when using external authentication providers. The patches:

- **Disable the authentication popup modal** without breaking other modals
- **Preserve all functionality** - search, interactive modals, etc. work perfectly
- **Use surgical patches** that target only authentication-related UI elements
- **Set proper URL base configuration** to prevent blank screen issues

## Quick Start

### Sonarr
```bash
docker build -t sonarr-no-auth:final ./sonarr
```

### Radarr  
```bash
docker build -t radarr-no-auth:final ./radarr
```

## Docker Compose Example

```yaml
services:
  sonarr:
    image: sonarr-no-auth:final
    container_name: sonarr-tv
    environment:
      - PUID=99
      - PGID=1000
      - TZ=America/Chicago
      - SONARR__AUTH__METHOD=None
      - SONARR__AUTH__REQUIRED=DisabledForLocalAddresses
      - SONARR__AUTH__APIKEY=your-api-key
      - SONARR__AUTH__AUTHENTICATION_REQUIRED=Disabled
    volumes:
      - ./config:/config
      - /path/to/tv:/tv
      - /path/to/downloads:/downloads
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarr.rule=Host(`sonarr.yourdomain.com`)"
      - "traefik.http.routers.sonarr.middlewares=authentik-forward-auth@file"
      # ... other Traefik labels
    restart: unless-stopped

  radarr:
    image: radarr-no-auth:final  
    container_name: radarr-movies
    environment:
      - PUID=99
      - PGID=1000
      - TZ=America/Chicago
      - RADARR__AUTH__METHOD=None
      - RADARR__AUTH__REQUIRED=DisabledForLocalAddresses
      - RADARR__AUTH__APIKEY=your-api-key
      - RADARR__AUTH__AUTHENTICATION_REQUIRED=Disabled
      - RADARR__URLBASE=
    volumes:
      - ./config:/config
      - /path/to/movies:/movies
      - /path/to/downloads:/downloads
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.radarr.rule=Host(`radarr.yourdomain.com`)"
      - "traefik.http.routers.radarr.middlewares=authentik-forward-auth@file"
      # ... other Traefik labels
    restart: unless-stopped
```

## How It Works

### JavaScript Patches
1. **Text Replacement**: Changes "Authentication Required" to "Auth-Disabled" 
2. **Flag Updates**: Sets `authenticationRequired: false` in all JS files
3. **Function Targeting**: Replaces authentication check functions

### CSS Patches  
1. **Modal Hiding**: Hides modal containers with username/password inputs
2. **Selective Targeting**: Uses `:has()` selectors to hide only auth modals
3. **Preservation**: Keeps all other modals (search, settings, etc.) functional

### Environment Variables
- **Auth Disable**: Sets proper environment variables to disable built-in auth
- **URL Base**: Configures empty URL base to prevent path conflicts with reverse proxies

## Tested With

- ✅ **Sonarr v4.0+** - Working perfectly
- ✅ **Radarr v5.0+** - Working perfectly  
- ✅ **Authentik** - Forward-auth middleware
- ✅ **Traefik** - Reverse proxy with auth middleware
- ✅ **Unraid** - Docker compose environment

## Features Preserved

- ✅ Interactive search modals
- ✅ Settings and configuration modals  
- ✅ Movie/series management interface
- ✅ API functionality
- ✅ Download client integration
- ✅ Import/export functionality
- ✅ All other UI modals and popups

## Troubleshooting

### Blank Screen Issue
If you get a blank screen, the issue is usually URL base configuration:
- **Radarr**: Ensure `RADARR__URLBASE=` is set (empty)
- **Sonarr**: Usually works with default URL base

### Auth Popup Still Shows
1. **Clear browser cache** (Ctrl+F5)
2. **Check container logs** for patch application messages
3. **Verify environment variables** are set correctly

### Other Modals Broken
If other modals don't work, the image may be using overly aggressive patches. These images use surgical patches that only target authentication modals.

## Building from Source

```bash
git clone <this-repo>
cd arr-no-auth-patches

# Build Sonarr image
docker build -t sonarr-no-auth:final ./sonarr

# Build Radarr image  
docker build -t radarr-no-auth:final ./radarr
```

## Automatic Updates

To automatically rebuild when upstream images update, see the included update script examples.

## License

MIT License - Feel free to use and modify as needed.

## Contributing

Pull requests welcome! Please test thoroughly with your setup before submitting.
