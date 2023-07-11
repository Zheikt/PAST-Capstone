FROM node:16

WORKDIR /pasthttpserver/v1

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 2001

ENV API_PORT=2000

ENV NGINX_PORT=2024

CMD ["npm", "start"]