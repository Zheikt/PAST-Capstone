const kafka = require('./KafkaStreams/consumer');
const kafka_cons = require('./KafkaStreams/consumer');
const kafka_pro = require('./KafkaStreams/producer');

const consumer = kafka_cons.consumer({groupId: "past-user-consumer-group"});
const producer = kafka_pro.producer();

async function createConsumer(){
    await consumer.connect();
    await consumer.subscribe(['user', 'mongo']);
    await consumer.run({
        eachMessage: async ({ topic, partition, message, heartbeat, pause }) => {
            let messageObj;
            try{
                messageObj = JSON.parse(message.value);
            } catch (ex){
                console.log("Message parse failed");
            }
            switch(topic){
                case 'user':
                    switch(messageObj.operation){
                        case 'get':
                            GetUser(messageObj.data);
                            break;
                        case 'create':
                            CreateAccount(messageObj.data)
                            break;
                        case 'delete':
                            DeleteAccount(messageObj.data);
                            break;
                        case 'verify-email':
                            VerifyEmail(messageObj.data);
                            break;
                        case 'change-email':
                            ChangeEmail(messageObj.data);
                            break;
                        case 'change-username':
                            ChangeUsername(messageObj.data);
                            break;
                        case 'change-password':
                            ChangePassword(messageObj.data);
                            break;
                        case 'login':
                            CheckLogin(messageObj.data);
                            break;
                    }
                    break;
                case 'mongo':
                    //check for good response

                    //return confirmation/requested data
                    break;
            }
        }
    })
}

async function sendMessage(targetService, operation, data){
    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            {key: `${operation}`, value: JSON.stringify(data)}
        ]
    });
}

function GetUser(data){
    //verify structure

    sendMessage('mongo', 'get-user', data);
}

function CreateAccount(data){
    //verify structure

    sendMessage('mongo', 'create-user', data);
}

function DeleteAccount(data){

}

function VerifyEmail(data){

}

function ChangeEmail(data){
    
}

function ChangeUsername(data){

}

function ChangePassword(data){

}

function CheckLogin(data){

}

createConsumer();