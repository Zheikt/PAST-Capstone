//Test code recieved from https://www.nginx.com/blog/websocket-nginx/ to set-up NGINX with WebSockets
//#region Set-up
console.log("Server started");
var Msg = '';
var WebSocketServer = require('ws').Server
    , wss = new WebSocketServer({port: 2001, clientTracking: true});

const kafka_prod = require('./KafkaStreams/producer');
const producer = kafka_prod.producer();

const kafka_cons = require('./KafkaStreams/consumer');
const consumer = kafka_cons.consumer({groupId: 'wss-consumer-group'});

const msgCodeChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; //length = 62

const msgCharsCount = msgCodeChars.length;

const msgCodeLength = 7;

let pendingResponses = [];
//#endregion

setTimeout(() => makeConsumer(), 15000); //wait until Kafka is up

wss.on('connection', function(ws) {
    //Do login/token auth

        ws.on('message', function(message) {
        console.log('Received from client: %s', message);
        ws.send('Server received from client: ' + message);
        let data;
        try{
            data = JSON.parse(message);
        } catch (ex){
            console.log(ex);
            ws.send("Body not formatted as JSON string");
        }
        console.log(data);
        sendMessage("user", "create", JSON.parse(data), this)
    });
});

async function sendMessage(targetService, operation, data, senderSocket){
    let body = data;
    let msgCode = '';
    
    do
    {
        while(msgCode.length < msgCodeLength)
        {
            msgCode += msgCodeChars[Math.trunc((Math.random() * msgCodeChars.length))];
        }
    } while(pendingResponses.find(elem => elem.msgCode == msgCode) != undefined);

    body['msgCode'] = msgCode;

    body = Object.assign(body, {"msgCode": msgCode});

    pendingResponses.push({'msgCode': msgCode, 'sender': senderSocket})
    
    console.log(body);

    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            {key: `${operation}-${msgCode}`, value: JSON.stringify(body)}
        ]
    });
}

async function makeConsumer()
{
    await consumer.connect();
    await consumer.subscribe({topics: ['wss']});
    await consumer.run({
        eachMessage: async ({ topic, partition, message, heartbeat, pause }) => {
            //message.key and message.value
            let messageObj = JSON.parse(message.value);
            console.log(messageObj);
            let msgCode = messageObj.msgCode;
            console.log(msgCode);
            let msgObj = pendingResponses.find(elem => elem.msgCode == msgCode);
            let ws = msgObj.sender;
            console.log(msgObj);
            console.log(pendingResponses);
            
            ws.send(JSON.stringify(messageObj.data))

            pendingResponses = pendingResponses.filter(elem => elem.msgCode !== msgCode);
        }
    })
}

function verifyLogin(ws){

}