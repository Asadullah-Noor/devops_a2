# ---------- Stage 1: Builder ----------
# Node image sirf website build karne ke liye (pinned tag, no :latest)
FROM node:22-alpine AS builder
# Container ke andar working directory
WORKDIR /app
# Pehle sirf package files copy karo (layer cache ke liye)
COPY package*.json ./
# Lock file se exact versions install karo
RUN npm ci
# Ab source aur styles copy karo
COPY src/ ./src/
COPY styles/ ./styles/
# Parcel se dist/ generate karo
RUN npm run build
# ---------- Stage 2: Runtime ----------
# Chhota Nginx image jo static files serve karega (pinned tag)
FROM nginx:1.27-alpine
# Sirf built files builder stage se copy karo
COPY --from=builder /app/dist /usr/share/nginx/html
# Nginx port 80 par sunta hai
EXPOSE 80
# Nginx ko foreground mein chalao taake container zinda rahe
CMD ["nginx", "-g", "daemon off;"]