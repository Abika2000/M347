# Base image. Change the version if you want (e.g. nginx:1.27-alpine)
FROM nginx:alpine

# COPY <path on YOUR computer> <path inside the container>
# LEFT side:  must match your real folder name (here "www"), relative to the Dockerfile
# RIGHT side: must stay /usr/share/nginx/html, because nginx serves files from there
COPY www/ /usr/share/nginx/html/

# Documentation only: nginx listens on port 80 inside the container
EXPOSE 80