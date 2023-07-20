"use strict";
const db = require('./db');
const mongoose = require('mongoose');
const User = require('./models/user/user.dao');
const Group = require('./models/group/group.dao');
const Queue = require('./models/queue/queue.dao');
const Message = require('./models/message/message.dao');
const EmailVer = require('./models/emailVerification/emailver.dao');
const PassVer = require('./models/passwordVerification/passver.dao');
const ConsumerImport = require('./streams/consumer');
const ProducerImport = require('./streams/producer');
const { ResourcePatternTypes } = require('kafkajs');

setTimeout(() => db(), 20000); //waits a little for the mongodb instance to spin up

const consumer = ConsumerImport.consumer({
    groupId: 'mongo-consumer-group'
});

const producer = ProducerImport.producer();

async function main() {
    await consumer.connect();
    await consumer.subscribe({ topics: ['mongo'] });
    await consumer.run({
        eachMessage: async ({ topic, partition, message, heartbeat, pause }) => {
            let messageObj;
            try {
                messageObj = JSON.parse(message.value);
            } catch (ex) {
                console.log(ex);
                return //sendMessage
            }
            console.log(message.key.toString());
            console.log(messageObj);
            let keyParts = message.key.toString().split('--', 2);
            let operation = keyParts[0];
            let msgCode = keyParts[1];
            switch (operation) {
                case 'get-user':
                    GetUser(messageObj.userId, msgCode)
                    break;
                case 'create-user':
                    CreateUser(messageObj, msgCode);
                    break;
                case 'delete-user':
                    DeleteUser(messageObj.userId, msgCode)
                    break;
                case 'verify-email':
                    VerifyEmail(messageObj.route, msgCode);
                    break;
                case 'change-email':
                    ChangeEmail(messageObj, msgCode);
                    break;
                case 'change-username':
                    ChangeUsername(messageObj, msgCode);
                    break;
                case 'change-password':
                    ChangePassword(messageObj, msgCode);
                    break;
                case 'login':
                    CheckLogin(messageObj, msgCode);
                    break;
                default:
                    console.log("No match found. Key: " + message.key);
                    break;
            }
        }
    })
}

function GetUser(queryId, msgCode){
    User.read({id: queryId}).then(res => {
        console.log(res);
        if(res.length == 0)
        {
            sendMessage('user', 'mongo-error-response', {type: 'user-error', message: 'No user found with id: ' + queryId})
        }
        else 
        {
            sendMessage('user', 'mongo-response', {operation: 'get-user', response: res, status: 'success', 'msgCode': msgCode});
        }
    })
}

function CreateUser(user, msgCode){
    User.create(user, function(res, err){
        console.log(err);
        console.log(res);
        if(err){
            console.log(err);
            sendMessage('user', 'mongo-error-response', {type: 'mongo-error', message: err, 'msgCode': msgCode})
        } else {
            sendMessage('user', 'mongo-response', {operation: 'create-user', response: res, status: 'success', 'msgCode': msgCode})
        }
    })
}

function DeleteUser(queryId, msgCode){
    User.delete({id: queryId}, function(res){
        console.log(res);
        if(res.deletedCount == 0){
            sendMessage('user', 'mongo-error-response', {type: 'mongo-error', message: 'No user found with id: ' + queryId, 'msgCode': msgCode})
        } else {
            sendMessage('user', 'mongo-response', {operation: 'delete-user', response: res, status: 'success', 'msgCode': msgCode})
        }
    })
}

function VerifyEmail(queryRoute, msgCode){
    console.log(queryRoute);
    EmailVer.read({route: queryRoute}).then(res => {
        console.log(res);
        if(res.length == 0)
        {
            sendMessage('user', 'mongo-error-response', {type: 'user-error', message: 'No object with matching route found'});
        }
        else
        {
            let evObj = res[0];
            if(evObj.validUntil <= Date.now())
            {
                sendMessage('user', 'mongo-error-response', {type: 'expiry-error', message: 'Route has expired'});
                //Should the entry be deleted?
                return;
            } 
            else
            {
                User.update({id: res.relatedObject}, {'email.verified': true}, function(innerRes){
                    if(innerRes.matchedCount == 0){
                        sendMessage('user', 'mongo-error-response', {type: 'user-error', message: 'No user found with id: ' + res.relatedObject, 'msgCode': msgCode})
                    } else {
                        sendMessage('user', 'mongo-response', {operation: 'verify-email', response: res, status: 'success', 'msgCode': msgCode})
                        EmailVer.delete({route: queryRoute}, function(res){
                            console.log(res);
                        })
                    }
                })
            }
        }
    })
}

function ChangeEmail(data, msgCode){
    User.update({id: data.userId}, {email: {email: data.newEmail, verified: false}}, function(res){
        console.log(res);
        if(res.matchedCount == 0){
            sendMessage('user', 'mongo-error-response', {type: 'mongo-error', message: 'No user found with id: ' + data.userId, 'msgCode': msgCode})
        } else {
            sendMessage('user', 'mongo-response', {operation: 'change-email', response: res, status: 'success', 'msgCode': msgCode})
            EmailVer.deleteMany({relatedObject: data.userId}, function(res){
                console.log(res);
            })
        }
    })
}

function ChangeUsername(data, msgCode){
    User.update({id: data.userId}, {username: data.username}, function(res){
        console.log(res);
        if(res.matchedCount == 0){
            sendMessage('user', 'mongo-error-response', {type: 'user-error', message: 'No user found with id: ' + data.userId, 'msgCode': msgCode})
        } else {
            sendMessage('user', 'mongo-response', {operation: 'change-username', response: res, status: 'success', 'msgCode': msgCode})
        }
    })
}

function ChangePassword(data, msgCode){
    if(data.route){
        PassVer.read({route: data.route}).then(function(res){
            console.log(res);
            if(res.length == 0){
                sendMessage('user', 'mongo-error-response', {type: 'mongo-error', message: 'Invalid route', 'msgCode': msgCode})
            } else {
                let pvObj = res[0];
                if(pvObj.validUntil < Date.now())
                {
                    sendMessage('user', 'mongo-error-response', {type: 'expiry-error', message: 'Route has expired'})
                    return;
                }
                ChangePasswordOperation(res.relatedObject);
                PassVer.delete({route: data.route}, function(res){
                    console.log('Delete PassVer after change: ' + res);
                })
            }
        })
    } else {
        ChangePasswordOperation(data.userId, msgCode);
    }
}

function CheckLogin(data, msgCode){
    User.read({id: data.userId, username: data.username, password: data.password}).then(function(res){
        console.log(res);
        if(res.length == 0){
            sendMessage('user', 'mongo-error-response', {type: 'user-error', message: 'Login Failed', 'msgCode': msgCode})
        } else {
            sendMessage('user', 'mongo-response', {operation: 'login', response: res, status: 'success', 'msgCode': msgCode})
        }
    })
}

function ChangePasswordOperation(queryId, msgCode){
    User.update({id: queryId}, {username: data.username}, function(res){
        console.log(res);
        if(res.matchedCount){
            sendMessage('user', 'mongo-error-response', {type: 'user-error', message: 'No user found with id:' + queryId, 'msgCode': msgCode})
        } else {
            sendMessage('user', 'mongo-response', {operation: 'change-password', response: res, status: 'success', 'msgCode': msgCode})
        }
    })
}

async function sendMessage(targetService, operation, data) {
    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            { key: `${operation}`, value: JSON.stringify(data) }
        ]
    });
}

main();