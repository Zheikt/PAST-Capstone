//Test code recieved from https://www.nginx.com/blog/websocket-nginx/ to set-up NGINX with WebSockets
//#region Set-up
console.log("Server started");
var Msg = '';
var WebSocketServer = require('ws').Server
    , wss = new WebSocketServer({ port: 2001, clientTracking: true });

const kafka_prod = require('./KafkaStreams/producer');
const producer = kafka_prod.producer();

const kafka_cons = require('./KafkaStreams/consumer');
const consumer = kafka_cons.consumer({ groupId: 'wss-consumer-group' });

const msgCodeChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; //length = 62

const msgCharsCount = msgCodeChars.length;

const msgCodeLength = 7;

let pendingResponses = [];

let clients = [];

let tm;

function ping(ws) {
    ws.send('__ping__');
    tm = setTimeout(() => ws.close(), 5000);
}

function pong(){
    clearTimeout(tm);
}
//#endregion

setTimeout(() => makeConsumer(), 15000); //wait until Kafka is up

//requests that need to propagate across multiple sockets
/*
|Group Level| (Propagate across a group)
- Message Send
- Message Edit
- Message Delete
- Add User to Group
- Remove User from Group
- User Nickname changes
- User Name changes
- Add Role to User
- Remove Role from User
- Add Message Channel
- Delete Message Channel
- Rename Group
- Rename Message Channel
- Enqueue User
- Dequeue User
- Delete Group
- Delete User (While a member)
*/

//Requests that require multiple messages
/*
- Delete Group (Group, Message Channels, Messages, Queues, User (stats))
- Delete User (User, Group, Queues, Message (change sender to "deleted user"))
- Delete Message Channel (Message Channel, Group, Messages)
*/

wss.on('connection', function (ws) {
    //Save socket and msgCode
    let msgCode = '';
    while (msgCode.length < msgCodeLength) {
        msgCode += msgCodeChars[Math.trunc((Math.random() * msgCodeChars.length))];
    }
    clients.push({ socket: ws, code: msgCode });
    setInterval(() => ping(ws), 30000);
    //set ws.onMessage to only check for the initial messgae (userId, authToken) then set it to broader onMessage once it is verified
    ws.on('message', function (message) {
        let data;
        let postman;
        try {
            data = JSON.parse(message);
            postman = JSON.parse(data);
        } catch (ex) {
            if (data == undefined) {
                console.log(ex);
                ws.send(JSON.stringify({ result: "Body not formatted as JSON string" }));
                return;
            }
        }

        if(data.operation == '__pong__'){
            pong();
            return;
        }

        let keys = Object.keys(data.data);
        let targetKeys = ['userId', 'authToken'];

        let valid = VerifyStructure(targetKeys, keys);

        if (valid) {
            //let obj = { "userId": data.data.userId, "authToken": data.data.authToken};
            sendMessage('mongo', 'check-token-', data.data, this);
        } else {
            ws.send(JSON.stringify({ result: 'Cannot parse any messages until this socket has been verified by the server' }));
        }
    });

    ws.on('close', function (code, reason) {
        clients = clients.filter(elem => elem.socket != ws);
    })
});

async function sendMessage(targetService, operation, data, senderSocket) {
    console.log(data);
    let body = data;
    let msgCode = '';

    do {
        while (msgCode.length < msgCodeLength) {
            msgCode += msgCodeChars[Math.trunc((Math.random() * msgCodeChars.length))];
        }
    } while (pendingResponses.find(elem => elem.msgCode == msgCode) != undefined);

    body['msgCode'] = msgCode;

    body = Object.assign(body, { "msgCode": msgCode });

    pendingResponses.push({ 'msgCode': msgCode, 'sender': senderSocket })

    console.log(body);

    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            { key: `${operation}-${msgCode}`, value: JSON.stringify(body) }
        ]
    });
}

async function makeConsumer() {
    await consumer.connect();
    await consumer.subscribe({ topics: ['wss'] });
    await consumer.run({
        eachMessage: async ({ topic, partition, message, heartbeat, pause }) => {
            //message.key and message.value
            let messageObj = JSON.parse(message.value);
            let msgCode = messageObj.msgCode;
            let msgObj = pendingResponses.find(elem => elem.msgCode == msgCode);
            let ws = msgObj.sender;
            console.log(messageObj);
            if (messageObj.operation == 'check-token') {
                let clientObj = clients.find(elem => elem.socket == ws);
                if (clientObj != undefined && clientObj != null) {
                    let socket = clientObj.socket;
                    let success = messageObj.status == 'success'
                    console.log(messageObj);
                    socket.send(JSON.stringify(success ? { result: 'Successful Auth', data: messageObj.response } : messageObj.message.includes('user') ? { result: 'UserId or AuthToken Invalid' } : { result: 'Expired Token' }));

                    if (success) {
                        let newClients = clients.filter(elem => elem == clientObj);
                        newClients.push({ socket: clientObj.socket, userId: messageObj.response[0].id })
                        ws.on('message', function (message) {
                            console.log('Received from client: %s', message);
                            let data;
                            try {
                                data = JSON.parse(message);
                            } catch (ex) {
                                console.log(ex);
                                ws.send("Body not formatted as JSON string");
                                return;
                            }

                            console.log(data);

                            sendMessage(data.service, data.operation, data, this)
                        });
                    }
                }
            } else {
                if (messageObj.operation == 'edit-stats' || messageObj.operation == 'change-username') {
                    sendMessage('user', 'get', { userId: messageObj.data.userId }, ws);
                    return;
                }
                //propogate changes across relevant sockets
                ws.send(JSON.stringify(message.key.toString() == 'success' ? messageObj.data : message.key.toString().startsWith('error') ? messageObj.message : messageObj.reason));
            }
            pendingResponses = pendingResponses.filter(elem => elem.msgCode !== msgCode);
        }
    })
}

function VerifyStructure(targetKeys, acutalKeys) {
    let valid = targetKeys.length == acutalKeys.length;
    targetKeys.forEach(element => {
        if (valid) {
            let found = acutalKeys.filter(elem => elem === element);

            if (!found) {
                valid = false;
            }
        }
    })
    return valid;
}