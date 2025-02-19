FROM node:16.8.0

WORKDIR /app

COPY . .

RUN npm ci

CMD "npm run start"