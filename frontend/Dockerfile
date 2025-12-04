# Build stage
FROM node:20-alpine AS build
WORKDIR /app

ARG VITE_API_URL=http://localhost:8080
ENV VITE_API_URL=$VITE_API_URL

RUN npm config set fund false && \
    npm config set audit false && \
    npm config set update-notifier false

COPY package*.json ./

RUN npm cache clean --force && \
    npm install --no-audit --no-fund --loglevel=error || \
    (sleep 3 && npm install --no-audit --no-fund --loglevel=error)

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

