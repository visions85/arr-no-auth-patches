# Complete Setup Guide

This guide walks you through setting up Sonarr and Radarr with no authentication popups using Traefik and Authentik.

## Prerequisites

- Docker and Docker Compose installed
- Domain name with DNS pointing to your server
- Cloudflare account (for SSL certificates)
- Basic understanding of Docker networking

## Step 1: Clone and Build Images

```bash
git clone https://github.com/visions85/arr-no-auth-patches.git
cd arr-no-auth-patches

# Build the custom images
docker build -t sonarr-no-auth:final ./sonarr
docker build -t radarr-no-auth:final ./radarr
```

## Step 2: Setup Environment

```bash
# Copy environment template
cp examples/.env.example .env

# Edit with your values
nano .env
```

Fill in your domain, paths, and API keys.

## Step 3: Create Docker Network

```bash
docker network create proxy
```

## Step 4: Deploy Traefik

Create Traefik configuration directory:
```bash
mkdir -p traefik/rules
cp examples/traefik/middlewares.yml traefik/rules/
```

Update the Authentik server address in `middlewares.yml` to match your setup.

## Step 5: Deploy Complete Stack

```bash
# Start the complete stack
docker-compose -f examples/complete-stack.yml up -d

# Check all services are running
docker-compose -f examples/complete-stack.yml ps
```

## Step 6: Configure Authentik

1. Wait for Authentik to start (~2 minutes)
2. Visit `https://auth.yourdomain.com`
3. Complete initial setup with admin user
4. Follow the detailed guide in `examples/authentik/outpost-config.md`

## Step 7: Test Authentication

1. Visit `https://sonarr.yourdomain.com`
2. Should redirect to Authentik login
3. After login, should show Sonarr without auth popup
4. Repeat for `https://radarr.yourdomain.com`

## Troubleshooting

### Services won't start
- Check logs: `docker-compose logs service-name`
- Verify .env file is properly configured
- Ensure Docker network exists: `docker network ls`

### Authentication not working
- Check Authentik outpost status in admin panel
- Verify provider configuration matches your domains exactly
- Check Traefik middleware is applied: `docker logs traefik`

### Blank screen after auth
- For Radarr: Ensure `RADARR__URLBASE=` is empty
- Clear browser cache (Ctrl+F5)
- Check application logs for errors

### Auth popup still appears
- Verify you're using the no-auth images
- Check container logs for patch application messages
- Clear browser cache completely

## Advanced Configuration

### Custom Headers
Add to Traefik middleware if you need custom authentication headers.

### API Access
API endpoints remain accessible via `/api` path for mobile apps and integrations.

### Multiple Instances
You can run multiple Sonarr/Radarr instances by:
1. Creating additional services in docker-compose
2. Using different container names and ports
3. Creating separate Authentik providers/applications

## Security Notes

- Change all default passwords
- Use strong API keys
- Restrict Traefik dashboard access
- Keep Authentik updated
- Monitor logs for suspicious activity

## Support

- Check existing GitHub issues
- Create new issue with logs and configuration
- Join relevant Discord/Reddit communities for help
