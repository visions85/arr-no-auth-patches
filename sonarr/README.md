# Sonarr No-Auth Patch

This Docker image disables the "Authentication Required" popup modal in Sonarr while preserving all other functionality.

## Features

- ✅ Disables authentication popup modal
- ✅ Preserves interactive search modal  
- ✅ Preserves settings and configuration modals
- ✅ Preserves all TV series management functionality
- ✅ Works with external authentication (Authentik, Authelia, etc.)

## Build

```bash
docker build -t sonarr-no-auth:final .
```

## Environment Variables

```yaml
environment:
  - SONARR__AUTH__METHOD=None
  - SONARR__AUTH__REQUIRED=DisabledForLocalAddresses
  - SONARR__AUTH__APIKEY=your-api-key
  - SONARR__AUTH__AUTHENTICATION_REQUIRED=Disabled
```

## Patches Applied

1. **JavaScript**: Replaces "Authentication Required" text and sets auth flags to false
2. **CSS**: Hides modal containers with authentication form fields
3. **Runtime**: Applies environment-based configuration

## Verification

Check container logs for these messages:
```
🚀 Sonarr with refined auth patches
🎯 Auth modal patches loaded
✅ Auth modal disabled
```

## Tested With

- Sonarr v4.0+
- Authentik forward-auth
- Traefik reverse proxy
- Unraid Docker environment
