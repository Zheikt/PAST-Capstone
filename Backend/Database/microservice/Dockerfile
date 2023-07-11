FROM node:16

WORKDIR /pastdbservice/v1

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 2002

ENV MONGOIPADDRESS=pastmongo:27017

ENV KAFKA_BROKER_SERVER=pastbroker:29092

CMD ["npm", "start"]