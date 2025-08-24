# Radarr No-Auth Patch

This Docker image disables the "Authentication Required" popup modal in Radarr while preserving all other functionality.

## Features

- ✅ Disables authentication popup modal
- ✅ Preserves interactive search modal
- ✅ Preserves settings and configuration modals  
- ✅ Preserves all movie management functionality
- ✅ Works with external authentication (Authentik, Authelia, etc.)
- ✅ Fixes blank screen issues with URL base configuration

## Build

```bash
docker build -t radarr-no-auth:final .
```

## Environment Variables

```yaml
environment:
  - RADARR__AUTH__METHOD=None
  - RADARR__AUTH__REQUIRED=DisabledForLocalAddresses
  - RADARR__AUTH__APIKEY=your-api-key
  - RADARR__AUTH__AUTHENTICATION_REQUIRED=Disabled
  - RADARR__URLBASE=  # Important: Empty URL base prevents blank screen
```

## Patches Applied

1. **JavaScript**: Replaces "Authentication Required" text and sets auth flags to false
2. **CSS**: Hides modal containers with authentication form fields  
3. **Environment**: Sets empty URL base to work with reverse proxies
4. **Runtime**: Applies environment-based configuration

## Verification

Check container logs for these messages:
```
🚀 Radarr with refined auth patches
🎯 Radarr auth modal patches loaded  
✅ Auth modal disabled
```

## Important Notes

- **URL Base**: Must be empty (`RADARR__URLBASE=`) to prevent blank screens with reverse proxies
- **Browser Cache**: May need to clear cache (Ctrl+F5) after first deployment

## Tested With

- Radarr v5.0+
- Authentik forward-auth
- Traefik reverse proxy  
- Unraid Docker environment
