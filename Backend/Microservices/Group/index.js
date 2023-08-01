const kafka = require('./KafkaStreams/consumer');
const kafka_cons = require('./KafkaStreams/consumer');
const kafka_pro = require('./KafkaStreams/producer');

const consumer = kafka_cons.consumer({ groupId: "past-user-consumer-group" });
const producer = kafka_pro.producer();

setTimeout((() => createConsumer()), 10000);

async function createConsumer() {
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
            switch(topic)
            {
                case 'get':
                    break;
                case 'create':
                    break;
                case 'delete':
                    break;
                case 'add-user':
                    break;
                case 'remove-user':
                    break;
                case 'get-user-groups':
                    break;
                case 'create-role':
                    break;
                case 'add-role':
                    break;
                case 'change-roles':
                    break;
                case 'delete-roles':
                    break;
                case 'edit-role':
                    break;
                default:
                    sendMessage('wss', 'error', {'msgCode': msgCode, 'type': 'bad-operation', message: 'Invalid Operation'});
                    break;
            }
        }
    })
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