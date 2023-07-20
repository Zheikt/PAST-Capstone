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
            let switchTarget = message.key.toString();
            if(!switchTarget.startsWith('mongo')) {switchTarget = messageObj.operation;}
            console.log(switchTarget);
            switch (topic) {
                case 'user':
                    switch (switchTarget) {
                        case 'get':
                            GetUser(messageObj.data, msgCode);
                            break;
                        case 'create':
                            CreateAccount(messageObj.data, msgCode)
                            break;
                        case 'delete':
                            DeleteAccount(messageObj.data, msgCode);
                            break;
                        case 'verify-email':
                            VerifyEmail(messageObj.data, msgCode);
                            break;
                        case 'change-email':
                            ChangeEmail(messageObj.data, msgCode);
                            break;
                        case 'change-username':
                            ChangeUsername(messageObj.data, msgCode);
                            break;
                        case 'change-password':
                            ChangePassword(messageObj.data, msgCode);
                            break;
                        case 'login':
                            CheckLogin(messageObj.data, msgCode);
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

function GetUser(data, msgCode) {
    //verify structure
    let targetKeys = ['userId']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'get-user--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--'+ msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function CreateAccount(data, msgCode) {
    const idChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345679'
    //verify structure
    let targetKeys = ['username', 'password', 'email', 'stats', 'validAuthTokens'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        let subKeys = ['email', 'verified'];

        let valid = VerifyStructure(subKeys, Object.keys(data.email));

        if (valid) {
            let id = 'u-';

            while(id.length < 8){
                id += idChars[Math.trunc(Math.random() * idChars.length)];
            }

            data = Object.assign(data, {"id": id})
            sendMessage('mongo', 'create-user--' + msgCode, data);
        } else {
            sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
        }
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function DeleteAccount(data, msgCode) {
    let targetKeys = ['userId']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'delete-user--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function VerifyEmail(data, msgCode) {
    let targetKeys = ['route']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'verify-email--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function ChangeEmail(data, msgCode) {
    let targetKeys = ['userId', 'newEmail']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'change-email--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function ChangeUsername(data, msgCode) {
    let targetKeys = ['userId', 'username']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'change-username--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function ChangePassword(data, msgCode) {
    let targetKeys = ['route', 'newPassword'];
    let altTargetKeys = ['userId', 'newPassword'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys) || VerifyStructure(altTargetKeys, actualKeys);

    if (valid) {
        sendMessage('mongo', 'change-password--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function CheckLogin(data, msgCode) {
    let targetKeys = ['userId', 'username', 'password']
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'login--' + msgCode, data);
    } else {
        sendMessage('wss', 'error', { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
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