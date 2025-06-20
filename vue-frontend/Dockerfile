FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Vite's default dev server port is 5173, but we configure it to 8080 in vite.config.js
EXPOSE 8080

CMD ["npm", "run", "dev"]
