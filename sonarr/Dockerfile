FROM linuxserver/sonarr:latest
LABEL upstream_digest="linuxserver/sonarr@sha256:1a90192952c30f9420994b2e2171083ea8cae100357de5e9eb25890efa90a6ce"

# Environment variables for auth modal control
ENV DISABLE_AUTH_MODAL=true
ENV SONARR_DISABLE_AUTH_POPUP=true

# Apply targeted authentication modal patches
RUN echo "🎯 Applying FINAL authentication modal patches..." && \
    \
    # Replace auth modal text (primary method) \
    find /app -name "*.js" -type f -exec sed -i 's/"Authentication Required"/"Auth-Disabled"/g' {} \; && \
    find /app -name "*.js" -type f -exec sed -i "s/'Authentication Required'/'Auth-Disabled'/g" {} \; && \
    \
    # Target specific auth requirement flags only \
    find /app -name "*.js" -type f -exec sed -i 's/authenticationRequired.*:.*true/authenticationRequired:false/gi' {} \; && \
    find /app -name "*.js" -type f -exec sed -i 's/requireAuthentication.*:.*true/requireAuthentication:false/gi' {} \; && \
    find /app -name "*.js" -type f -exec sed -i 's/authRequired.*=.*true/authRequired=false/gi' {} \; && \
    find /app -name "*.js" -type f -exec sed -i 's/isAuthRequired.*=.*true/isAuthRequired=false/gi' {} \; && \
    \
    echo "✅ JavaScript auth patches applied"

# CSS patches for auth modal hiding
RUN echo "🎨 Applying CSS auth modal patches..." && \
    find /app -name "*.css" -type f | head -3 | while read cssfile; do \
        echo "Patching CSS: $cssfile" && \
        echo "" >> "$cssfile" && \
        echo "/* Hide Authentication Modal Only */" >> "$cssfile" && \
        echo ".Modal-modalContainer-xTUsI:has(input[name=\"username\"]) { display: none !important; }" >> "$cssfile" && \
        echo ".Modal-modalContainer-xTUsI:has(input[name=\"password\"]) { display: none !important; }" >> "$cssfile" && \
        echo ".Modal-modalContainer-xTUsI:has(.ModalHeader-modalHeader-THPud:contains(\"Auth-Disabled\")) { display: none !important; }" >> "$cssfile" && \
        echo ".Modal-modalContainer-xTUsI:has(.ModalHeader-modalHeader-THPud:empty) { display: none !important; }" >> "$cssfile"; \
    done && \
    \
    echo "✅ CSS auth patches applied"

# Create runtime script
RUN echo '#!/bin/bash' > /app/auth-patch.sh && \
    echo 'echo "🎯 Auth modal patches loaded"' >> /app/auth-patch.sh && \
    echo 'if [ "$DISABLE_AUTH_MODAL" = "true" ]; then' >> /app/auth-patch.sh && \
    echo '    echo "✅ Auth modal disabled"' >> /app/auth-patch.sh && \
    echo 'fi' >> /app/auth-patch.sh && \
    chmod +x /app/auth-patch.sh

# Create init wrapper
RUN echo '#!/bin/bash' > /custom-init && \
    echo 'echo "🚀 Sonarr with refined auth patches"' >> /custom-init && \
    echo '/app/auth-patch.sh' >> /custom-init && \
    echo 'exec "$@"' >> /custom-init && \
    chmod +x /custom-init

RUN echo "✅ Final auth modal patches completed"

ENTRYPOINT ["/custom-init", "/init"]
