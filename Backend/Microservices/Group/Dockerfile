FROM node:16

WORKDIR /pastgroupservice/v1

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 2001

ENV API_PORT=2000

CMD ["npm", "start"]