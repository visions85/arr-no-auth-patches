# Authentik Outpost Configuration

This guide shows how to configure Authentik to work with your Sonarr/Radarr services.

## 1. Create Proxy Provider

Go to **Admin Interface → Applications → Providers** and create a new **Proxy Provider**:

### Sonarr Provider
```
Name: Sonarr Provider
Authorization Flow: default-authorization-flow (implicit consent)
Forward Auth (single application): ✓ Enabled
External Host: https://sonarr.yourdomain.com
Internal Host: http://sonarr-container:8989
Skip Path Regex: ^/api
```

### Radarr Provider  
```
Name: Radarr Provider
Authorization Flow: default-authorization-flow (implicit consent)
Forward Auth (single application): ✓ Enabled
External Host: https://radarr.yourdomain.com
Internal Host: http://radarr-container:7878
Skip Path Regex: ^/api
```

## 2. Create Applications

Go to **Admin Interface → Applications → Applications** and create applications:

### Sonarr Application
```
Name: Sonarr
Slug: sonarr
Provider: Sonarr Provider (from step 1)
Launch URL: https://sonarr.yourdomain.com
```

### Radarr Application
```
Name: Radarr
Slug: radarr  
Provider: Radarr Provider (from step 1)
Launch URL: https://radarr.yourdomain.com
```

## 3. Create or Update Outpost

Go to **Admin Interface → Applications → Outposts**:

If you already have a Traefik outpost, edit it and add the new providers:
```
Name: Traefik Outpost
Type: Proxy
Providers: 
  - Sonarr Provider
  - Radarr Provider
  - [your other providers]
```

If creating new:
```
Name: Traefik Outpost
Type: Proxy
Configuration:
  authentik_host: https://auth.yourdomain.com
  authentik_host_browser: https://auth.yourdomain.com
  authentik_host_insecure: false
  log_level: info
  object_naming_template: ak-outpost-%(name)s
  docker_network: proxy
  docker_map_ports: true
  container_image: null
Providers:
  - Sonarr Provider
  - Radarr Provider
```

## 4. Verify Configuration

### Check Outpost Status
1. Go to **Admin Interface → Applications → Outposts**
2. Your outpost should show "Healthy" status
3. Click on the outpost to see connected providers

### Test Authentication Flow
1. Visit `https://sonarr.yourdomain.com`
2. Should redirect to Authentik login
3. After login, should redirect back to Sonarr
4. No authentication popup should appear in Sonarr

## 5. Troubleshooting

### Common Issues

**"No provider for domain" error:**
- Verify External Host matches your domain exactly
- Check that the application is assigned to the outpost
- Restart the outpost container

**Blank screen after auth:**
- Ensure `RADARR__URLBASE=` is empty (for Radarr)
- Check internal host points to correct container/port
- Verify Skip Path Regex is set to `^/api`

**Auth popup still appears:**
- Clear browser cache (Ctrl+F5)
- Check container logs for patch messages
- Verify using the no-auth Docker images

### Logs to Check
```bash
# Authentik outpost logs
docker logs authentik-proxy-outpost

# Application container logs  
docker logs sonarr-container
docker logs radarr-container

# Traefik logs
docker logs traefik
```

## 6. Advanced Configuration

### Custom Authentication Headers
Add to your Traefik middleware if needed:
```yaml
authResponseHeaders:
  - X-authentik-username
  - X-authentik-groups
  - X-authentik-email
  - X-Remote-User
  - X-Remote-Groups
```

### API Access Without Auth
The `Skip Path Regex: ^/api` setting allows API access without authentication, which is needed for:
- Mobile apps (Sonarr/Radarr apps)
- Integration with download clients
- Automated scripts and tools

This is safe because the API still requires the API key for access.
