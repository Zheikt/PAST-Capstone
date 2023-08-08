const kafka_cons = require('./KafkaStreams/consumer');
const kafka_pro = require('./KafkaStreams/producer');

const consumer = kafka_cons.consumer({ groupId: "past-messagechannel-consumer-group" });
const producer = kafka_pro.producer();

setTimeout((() => createConsumer()), 15000);

async function CreateConsumer(){
    await consumer.connect();
    await consumer.subscribe({topics: ['user'], fromBeginning: false});
    await consumer.run({
        eachMessage: async ({ topic, partition, message, heartbeat, pause }) => {
            let messageObj;
            try {
                messageObj = JSON.parse(message.value);
            } catch (ex) {
                console.log("Message parse failed");
                return; //Return error message
            }
            console.log(messageObj);
            console.log(Object.keys(messageObj))
            let msgCode = messageObj['msgCode'];
            if (!msgCode) msgCode = message.key.toString().split('--')[1];
            console.log(msgCode);
            let switchTarget = message.key.toString();
            if(!switchTarget.startsWith('mongo')) {switchTarget = messageObj.operation;}
            console.log(switchTarget);
            switch(switchTarget){
                case 'create-channel':
                    break;
                case 'change-restrictions':
                    break;
                case 'rename-channel':
                    break;
                case 'delete-channel':
                    break;
                case 'send-message':
                    break;
                case 'edit-message':
                    break;
                case 'delete-message':
                    break;
                case 'mongo-response':
                    sendMessage('wss', 'success', {"msgCode": msgCode, data: messageObj['response']})
                    break;
                case 'mongo-error-response':
                    sendMessage('wss', 'failure', {"msgCode": msgCode, reason: messageObj['message']})
                    break;
                default:
                    sendMessage('wss', 'error', { "msgCode": msgCode, type: 'bad-operation', message: 'Invalid Operation' })
                    break;
            }
        }
    });
}

async function sendMessage(targetService, operation, data) {
    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            { key: operation, value: JSON.stringify(data) }
        ]
    });
}