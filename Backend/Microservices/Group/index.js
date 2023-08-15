const kafka_cons = require('./KafkaStreams/consumer');
const kafka_pro = require('./KafkaStreams/producer');

const consumer = kafka_cons.consumer({ groupId: "past-group-consumer-group" });
const producer = kafka_pro.producer();

setTimeout((() => createConsumer()), 15000);

async function createConsumer() {
    await consumer.connect();
    await consumer.subscribe({ topics: ['group'], fromBeginning: false });
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
            console.log(msgCode);let switchTarget = message.key.toString();
            if(!switchTarget.startsWith('mongo')) {switchTarget = messageObj.operation;}
            console.log(switchTarget);
            switch (switchTarget) {
                case 'get':
                    GetGroup(messageObj.data, msgCode)
                    break;
                case 'create':
                    CreateGroup(messageObj.data, msgCode);
                    break;
                case 'delete':
                    DeleteGroup(messageObj.data, msgCode);
                    break;
                case 'change-group-name':
                    ChangeGroupName(messageObj.data, msgCode);
                    break;
                case 'join-group':
                    AddUser(messageObj.data, msgCode);
                    break;
                case 'leave-group':
                    RemoveUser(messageObj.data, msgCode);
                    break;
                case 'get-user-groups':
                    GetUserGroups(messageObj.data, msgCode);
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
                case 'edit-group-stat-block':
                    break;
                case 'mongo-response':
                    sendMessage('wss', 'success', {"msgCode": msgCode, data: messageObj['response']})
                    break;
                case 'mongo-error-response':
                    sendMessage('wss', 'failure', {"msgCode": msgCode, reason: messageObj['message']})
                    break;
                default:
                    sendMessage('wss', 'error', { 'msgCode': msgCode, 'type': 'bad-operation', message: 'Invalid Operation' });
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

function GetGroup(data, msgCode) {
    let targetKeys = ['groupId'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'get-group--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function GetUserGroups(data, msgCode) {
    let targetKeys = ['userId'];
    let actualKeys = Object.keys(data);

    if (VerifyStructure(targetKeys, actualKeys)) {
        sendMessage('mongo', 'get-user-groups--' + msgCode, data);
    }
    else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function CreateGroup(data, msgCode) {
    const idChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz012345679';
    //verify structure
    let targetKeys = ['name', 'statBlock', 'creatorId', 'creatorUsername'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        let subKeys = Object.keys(data.statBlock);
        if (subKeys.length > 0) {
            data = Object.assign(data, { 'members': [{userId: data.creatorId, roles: [], nickname: data.creatorUsername}] });
            data = Object.assign(data, { 'events': [] });
            data = Object.assign(data, { 'roles': [] });
            data = Object.assign(data, { 'queue': [] });
            data = Object.assign(data, { 'channels': [] });

            let id = 'g-';

            while (id.length < 8) {
                id += idChars[Math.trunc(Math.random() * idChars.length)];
            }

            data = Object.assign(data, { "id": id })
            sendMessage('mongo', 'create-group--' + msgCode, data);
        }
        else {
            console.log("empty stat block");
            sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
        }
    }
    else {
        console.log("missing required field");
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function DeleteGroup(data, msgCode) {
    let targetKeys = ['groupId'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'delete-group--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function ChangeGroupName(data, msgCode) {
    let targetKeys = ['groupId', 'newName'];
    let acutalKeys = Object.keys(data);

    let valid = VerifyStructure(targetKeys, acutalKeys);

    if (valid) {
        sendMessage('mongo', 'change-group-name--' + msgCode, data);
    } else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function AddUser(data, msgCode) {
    let targetKeys = ['userId', 'groupId', 'username'];
    let acutalKeys = Object.keys(data);

    if (VerifyStructure(targetKeys, acutalKeys)) {
        sendMessage('mongo', 'join-group--' + msgCode, data);
    }
    else {
        sendMessage('wss', 'error--' + msgCode, { type: "bad-format", message: "Request improperly formatted", 'msgCode': msgCode })
    }
}

function RemoveUser(data, msgCode) {
    let targetKeys = ['userId', 'groupId'];
    let acutalKeys = Object.keys(data);

    if (VerifyStructure(targetKeys, acutalKeys)) {
        sendMessage('mongo', 'leave-group--' + msgCode, data);
    }
    else {
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