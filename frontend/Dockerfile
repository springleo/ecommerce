FROM node:20 AS build

WORKDIR /app

# Copy only dependency files first (better caching)
COPY package*.json ./

RUN npm install

# Then copy source
COPY . .

RUN npm run build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

