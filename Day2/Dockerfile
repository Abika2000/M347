# Start with the same nginx version used by the original Compose setup.
FROM nginx:1.27-alpine

# Add the reverse proxy configuration; certificates are mounted at runtime.
COPY nginx.conf /etc/nginx/conf.d/default.conf
