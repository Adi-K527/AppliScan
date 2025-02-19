FROM node:16.8.0

WORKDIR /app

COPY . .

RUN npm ci

EXPOSE 8080

CMD ["npm", "run", "start"]