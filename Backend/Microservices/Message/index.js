const kafka_cons = require('./KafkaStreams/consumer');
const kafka_pro = require('./KafkaStreams/producer');

const consumer = kafka_cons.consumer({ groupId: "past-messagechannel-consumer-group" });
const producer = kafka_pro.producer();

setTimeout((() => CreateConsumer()), 15000);

async function CreateConsumer() {
    await consumer.connect();
    await consumer.subscribe({ topics: ['message'], fromBeginning: false });
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
            if (!switchTarget.startsWith('mongo')) { switchTarget = messageObj.operation; }
            console.log(switchTarget);
            switch (switchTarget) {
                case 'create-channel':
                    CreateChannel(messageObj.data, msgCode)
                    break;
                case 'change-restrictions':
                    break;
                case 'rename-channel':
                    RenameChannel(messageObj.data, msgCode);
                    break;
                case 'add-blocked-user':
                    break;
                case 'remove-blocked-user':
                    break;
                case 'delete-channel':
                    DeleteChannel(messageObj.data, msgCode);
                    break;
                case 'get-channel':
                    GetChannel(messageObj.data, msgCode);
                    break;
                case 'get-group-channels':
                    GetGroupChannels(messageObj.data, msgCode);
                    break;
                case 'send-message':
                    CreateMessage(messageObj.data, msgCode);
                    break;
                case 'get-message':
                    GetMessage(messageObj.data, msgCode);
                    break;
                case 'edit-message':
                    EditMessage(messageObj.data, msgCode);
                    break;
                case 'delete-message':
                    DeleteMessage(messageObj.data, msgCode);
                    break;
                case 'get-channel-messages':
                    GetChannelMessages(messageObj.data, msgCode);
                case 'mongo-response':
                    sendMessage('wss', 'success', { "msgCode": msgCode, data: {operation: messageObj['operation'], response: messageObj['response']} })
                    break;
                case 'mongo-error-response':
                    sendMessage('wss', 'failure', { "msgCode": msgCode, reason: messageObj['message'] })
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

function CreateChannel(data, msgCode) {
    const idChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345679'
    //verify structure
    let targetKeys = ['name', 'roleRestrictions', 'groupId'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        let id = 'c-';

        while (id.length < 8) {
            id += idChars[Math.trunc(Math.random() * idChars.length)];
        }

        data = Object.assign(data, { "id": id })
        sendMessage('mongo', 'create-channel--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function RenameChannel(data, msgCode) {
    let targetKeys = ['channelId', 'newName']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'rename-channel--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function DeleteChannel(data, msgCode) {
    let targetKeys = ['channelId']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'delete-channel--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function GetChannel(data, msgCode) {
    let targetKeys = ['channel']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'get-channel--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function GetGroupChannels(data, msgCode) {
    let targetKeys = ['groupId', 'channelIds']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'get-group-channels--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function CreateMessage(data, msgCode) {
    const idChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345679'
    //verify structure
    let targetKeys = ['sender', 'recipient', 'content', 'channelId'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        let id = 'm-';

        while (id.length < 8) {
            id += idChars[Math.trunc(Math.random() * idChars.length)];
        }

        data = Object.assign(data, { "id": id })
        sendMessage('mongo', 'create-message--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function GetMessage(data, msgCode) {
    let targetKeys = ['messageId']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'get-message--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function GetChannelMessages(data, msgCode) {
    let targetKeys = ['channelId', 'messageIds']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'get-channel-messages--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function EditMessage(data, msgCode) {
    let targetKeys = ['messageId', 'newContent']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'edit-message--' + msgCode, data)
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function DeleteMessage(data, msgCode) {
    let targetKeys = ['messageId']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'delete-message--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
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