FROM node:16.8.0

WORKDIR /app

ENV PORT 3000

COPY . .

RUN npm ci

CMD "npm run start"