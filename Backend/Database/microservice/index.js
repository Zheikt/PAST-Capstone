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

setTimeout(() => { db(); main(); }, 20000); //waits a little for the mongodb instance to spin up

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
                case 'check-token':
                    CheckAuthToken(messageObj, msgCode);
                    break;
                case 'create-email-verification':
                    CreateEmailVerifications(messageObj);
                    break;
                case 'create-password-verification':
                    CreatePasswordVerifications(messageObj);
                    break;
                case 'create-group':
                    CreateGroup(messageObj, msgCode);
                    break;
                case 'get-group':
                    GetGroup(messageObj.groupId, msgCode);
                    break;
                case 'delete-group':
                    DeleteGroup(messageObj.groupId, msgCode);
                    break;
                case 'change-group-name':
                    ChangeGroupName(messageObj, msgCode)
                    break;
                case 'join-group':
                    JoinGroup(messageObj, msgCode);
                    break;
                case 'leave-group':
                    LeaveGroup(messageObj, msgCode);
                    break;
                case 'get-user-groups':
                    GetUserGroups(messageObj.userId, msgCode);
                    break;
                default:
                    console.log("No match found. Key: " + message.key);
                    break;
            }
        }
    })
}

//#region User Operations
function GetUser(queryId, msgCode) {
    User.read({ id: queryId }).then(res => {
        console.log(res);
        if (res.length == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'No user found with id: ' + queryId })
        }
        else {
            sendMessage('user', 'mongo-response', { operation: 'get-user', response: res, status: 'success', 'msgCode': msgCode });
        }
    })
}

function CreateUser(user, msgCode) {
    User.create(user, function (res, err) {
        console.log(err);
        console.log(res);
        if (err) {
            console.log(err);
            sendMessage('user', 'mongo-error-response', { type: 'mongo-error', message: err, 'msgCode': msgCode })
        } else {
            sendMessage('user', 'mongo-response', { operation: 'create-user', response: res, status: 'success', 'msgCode': msgCode })
        }
    })
}

function DeleteUser(queryId, msgCode) {
    User.delete({ id: queryId }, function (res) {
        console.log(res);
        if (res.deletedCount == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'mongo-error', message: 'No user found with id: ' + queryId, 'msgCode': msgCode })
        } else {
            sendMessage('user', 'mongo-response', { operation: 'delete-user', response: res, status: 'success', 'msgCode': msgCode })
        }
    })
}

function VerifyEmail(queryRoute, msgCode) {
    console.log(queryRoute);
    EmailVer.read({ route: queryRoute }).then(res => {
        console.log(res);
        if (res.length == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'No object with matching route found' });
        }
        else {
            let evObj = res[0];
            if (evObj.validUntil <= Date.now()) {
                sendMessage('user', 'mongo-error-response', { type: 'expiry-error', message: 'Route has expired' });
                //Should the entry be deleted?
                EmailVer.delete({ route: queryRoute }, function (delRes) {
                    console.log(delRes);
                })
                return;
            }
            else {
                User.update({ id: evObj.relatedObject }, { 'email.verified': true }, function (innerRes) {
                    if (innerRes.matchedCount == 0) {
                        sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'No user found with id: ' + res.relatedObject, 'msgCode': msgCode })
                    } else {
                        sendMessage('user', 'mongo-response', { operation: 'verify-email', response: res, status: 'success', 'msgCode': msgCode })
                        EmailVer.delete({ route: queryRoute }, function (delRes) {
                            console.log(delRes);
                        })
                    }
                })
            }
        }
    })
}

function ChangeEmail(data, msgCode) {
    User.update({ id: data.userId }, { email: { email: data.newEmail, verified: false } }, function (res) {
        console.log(res);
        if (res.matchedCount == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'mongo-error', message: 'No user found with id: ' + data.userId, 'msgCode': msgCode })
        } else {
            sendMessage('user', 'mongo-response', { operation: 'change-email', response: res, status: 'success', 'msgCode': msgCode })
            EmailVer.deleteMany({ relatedObject: data.userId }, function (res) {
                console.log(res);
            })
        }
    })
}

function ChangeUsername(data, msgCode) {
    User.update({ id: data.userId }, { username: data.username }, function (res) {
        console.log(res);
        if (res.matchedCount == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'No user found with id: ' + data.userId, 'msgCode': msgCode })
        } else {
            sendMessage('user', 'mongo-response', { operation: 'change-username', response: res, status: 'success', 'msgCode': msgCode })
        }
    })
}

function ChangePassword(data, msgCode) {
    if (data.route) {
        PassVer.read({ route: data.route }).then(function (res) {
            console.log(res);
            if (res.length == 0) {
                sendMessage('user', 'mongo-error-response', { type: 'mongo-error', message: 'Invalid route', 'msgCode': msgCode })
            } else {
                let pvObj = res[0];
                if (pvObj.validUntil < Date.now()) {
                    sendMessage('user', 'mongo-error-response', { type: 'expiry-error', message: 'Route has expired', 'msgCode': msgCode })
                    return;
                }
                ChangePasswordOperation({ userId: pvObj.relatedObject, newPassword: data.newPassword }, msgCode);
                PassVer.delete({ route: data.route }, function (res) {
                    console.log('Delete PassVer after change: ' + res);
                })
            }
        })
    } else {
        ChangePasswordOperation(data, msgCode);
    }
}

function CheckLogin(data, msgCode) {
    console.log(data);
    User.read({ id: data.userId, username: data.username, password: data.password }).then(function (res) {
        console.log(res);
        if (res.length == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'Login Failed', 'msgCode': msgCode })
        } else {
            sendMessage('user', 'mongo-response', { operation: 'login', response: res, status: 'success', 'msgCode': msgCode })
        }
    })
}

function ChangePasswordOperation(data, msgCode) {
    console.log(data);
    User.update({ id: data.userId }, { password: data.newPassword }, function (res) {
        console.log(res);
        if (res.matchedCount == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'No user found with id:' + data.userId, 'msgCode': msgCode })
        } else {
            sendMessage('user', 'mongo-response', { operation: 'change-password', response: res, status: 'success', 'msgCode': msgCode })
        }
    })
}

function CheckAuthToken(data, msgCode){
    console.log(data);
    User.read({'id': data.userId, 'validAuthTokens.token': data.authToken}).then(res => {
        if(res.length > 0){
            let targetTokens = res[0].validAuthTokens.filter(elem => elem.token == data.authToken && elem.validUntil >= Date.now());
            if(targetTokens.length > 0){
                sendMessage('wss', 'mongo-response', {operation: 'check-token', 'status': 'success', response: res, 'msgCode': msgCode})
            } else {
                sendMessage('wss', 'mongo-error-response', {operation: 'check-token', 'status': 'failure', message: 'The token provided was out of date', 'msgCode': msgCode});
                let validTokens = res[0].validAuthTokens.filter(elem => elem.validUntil > Date.now());
                User.update({'id': data.userId}, {validAuthTokens: validTokens}, (resp) => console.log('Remove Expired Tokens resp: ' + resp));
            }
        } else {
            sendMessage('wss', 'mongo-error-response', {operation: 'check-token', 'status': 'failure', message: 'No user found with id: ' + data.userId + ' and token: ' + data.token, 'msgCode': msgCode})
        }
    })
}
//#endregion

//#region Group Operations

function CreateGroup(data, msgCode) {
    let groupObj = {id: data.id, name: data.name, statBlock: data.statBlock, members: data.members, events: data.events, roles: data.roles, queue: data.queue, channels: data.channels}
    Group.create(groupObj, function (res, err) {
        console.log(err);
        console.log(res);
        if (err) {
            console.log(err);
            sendMessage('group', 'mongo-error-response', { type: 'mongo-error', message: err, 'msgCode': msgCode })
        } else {
            sendMessage('group', 'mongo-response', { operation: 'create-group', response: res, status: 'success', 'msgCode': msgCode })
        }
    })
}

function GetGroup(groupId, msgCode) {
    Group.read({ 'id': groupId }).then(res => {
        sendMessage('group', 'mongo-response', { operation: 'get-group', response: res, status: 'success', 'msgCode': msgCode });
    });
}

function DeleteGroup(groupId, msgCode) {
    Group.delete({ 'id': groupId }, function(res) {
        if (res.id == groupId) {
            sendMessage('group', 'mongo-response', { operation: 'delete-group', response: res, status: 'success', 'msgCode': msgCode });
        } else {
            sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No Group found with id: ' + groupId, 'msgCode': msgCode })
        }
    });
}

function ChangeGroupName(data, msgCode) {
    Group.update({id: data.groupId}, {name: data.name}, function(res){
        if(res.matchedCount > 0){
            sendMessage('group', 'mongo-response', {operation: 'change-group-name', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No Group found with id: ' + data.groupId, 'msgCode': msgCode })
        }
    })
}

function JoinGroup(data, msgCode) {
    Group.read({ 'id': data.groupId }).then(res => {
        let newMembers = res[0].members;
        newMembers.push({userId: data.userId, roles: [], nickname: data.username});
        if(res.length > 0){
            Group.update({'id': data.groupId}, {members: newMembers}, function(resp){
                console.log(resp)
                if(resp.id == data.groupId){
                    sendMessage('group', 'mongo-response', {operation: 'join-group', response: resp, status: 'success', 'msgCode': msgCode});
                } else {
                    sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No Group found with id: ' + data.groupId, 'msgCode': msgCode })
                }
            });
        } else {
            sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No Group found with id: ' + data.groupId, 'msgCode': msgCode })
        }
    });
}

function LeaveGroup(data, msgCode) {
    Group.read({ 'id': data.groupId }).then(res => {
        let newMembers = res[0].members.filter(elem => elem.userId != data.userId);
        if(res.length > 0){
            console.log("Finished Read")
        Group.update({'id': data.groupId}, {members: newMembers}, function(resp){
            console.log(resp);
            if(resp.id == data.groupId){
                sendMessage('group', 'mongo-response', {operation: 'leave-group', response: resp, status: 'success', 'msgCode': msgCode});
            } else {
                console.log("Failed Update");
                sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No Group found with id: ' + data.groupId, 'msgCode': msgCode })
            }
        });
    } else {
        sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No Group found with id: ' + data.groupId, 'msgCode': msgCode })
    }
    });
}

function GetUserGroups(userId, msgCode) {
    Group.read({ 'members.userId': userId }).then(res => {
        sendMessage('group', 'mongo-response', { operation: 'get-user-groups', response: res, status: 'success', 'msgCode': msgCode });
    });
}

//#endregion

function CreateEmailVerifications(data) {
    EmailVer.create(data, function (res) {
        console.log("Created Email Ver: " + res);
    })
}

function CreatePasswordVerifications(data) {
    PassVer.create(data, function (res) {
        console.log("Created Password Ver: " + res);
    })
}

async function sendMessage(targetService, operation, data) {
    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            { key: `${operation}`, value: JSON.stringify(data) }
        ]
    })
}