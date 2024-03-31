FROM node:latest

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 7001
CMD ["node", "app.js"]