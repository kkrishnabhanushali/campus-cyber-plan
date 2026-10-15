FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY app/ /usr/share/nginx/html/
EXPOSE 8080
HEALTHCHECK CMD wget -qO- http://localhost:8080/ || exit 1
