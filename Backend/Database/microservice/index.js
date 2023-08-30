"use strict";
const db = require('./db');
const mongoose = require('mongoose');
const User = require('./models/user/user.dao');
const Group = require('./models/group/group.dao');
const Queue = require('./models/queue/queue.dao');
const Message = require('./models/message/message.dao');
const MessageChannel = require('./models/messageChannel/messageChannel.dao');
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
                case 'edit-stats':
                    EditStats(messageObj, msgCode);
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
                case 'get-group-by-name':
                    GetGroupByName(messageObj, msgCode);
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
                case 'add-channel':
                    AddChannel(messageObj, msgCode);
                    break;
                case 'remove-channel':
                    RemoveChannel(messageObj, msgCode);
                    break;
                case 'remove-member':
                    RemoveUser(messageObj, msgCode);
                    break;
                case 'create-channel':
                    CreateChannel(messageObj, msgCode);
                    break;
                case 'get-channel':
                    GetChannel(messageObj, msgCode);
                    break;
                case 'delete-channel':
                    DeleteChannel(messageObj, msgCode);
                    break;
                case 'get-group-channels':
                    GetGroupChannels(messageObj.userId, msgCode);
                    break;
                case 'rename-channel':
                    RenameChannel(messageObj, msgCode);
                    break;
                case 'add-message':
                    AddMessage(messageObj, msgCode);
                    break;
                case 'remove-message':
                    RemoveMessage(messageObj, msgCode);
                    break;
                case 'create-message':
                    CreateMessage(messageObj, msgCode);
                    break;
                case 'get-message':
                    GetMessage(messageObj, msgCode);
                    break;
                case 'get-channel-messages':
                    GetChannelMessages(messageObj, msgCode);
                    break;
                case 'edit-message':
                    EditMessage(messageObj, msgCode);
                    break;
                case 'delete-message':
                    DeleteMessage(messageObj, msgCode);
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
            sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'No user found with id: ' + queryId, msgCode: msgCode })
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

function EditStats(data, msgCode){
    User.update({id: data.userId, 'stats.groupId': data.groupId }, {'stats.$.stats': data.stats}, function (res){
        if (res.matchedCount == 0) {
            sendMessage('user', 'mongo-error-response', { type: 'user-error', message: 'No user found with id:' + data.userId, 'msgCode': msgCode })
        } else {
            sendMessage('user', 'mongo-response', { operation: 'edit-stats', response: {...res, 'userId': data.userID}, status: 'success', 'msgCode': msgCode });
        }
    })
}

function CheckAuthToken(data, msgCode){
    console.log(data);
    User.read({'id': data.userId, 'validAuthTokens.token': data.authToken.token}).then(res => {
        console.log(res);
        if(res.length > 0){
            let targetTokens = res[0].validAuthTokens.filter(elem => elem.token == data.authToken.token && elem.validUntil >= Date.now());
            console.log(targetTokens);
            if(targetTokens.length > 0){
                console.log("Success");
                sendMessage('wss', 'mongo-response', {operation: 'check-token', 'status': 'success', response: res, 'msgCode': msgCode})
            } else {
                console.log('Fail');
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
            //sendMessage('group', 'mongo-response', { operation: 'create-group', response: res, status: 'success', 'msgCode': msgCode })
            sendMessage('message', 'create-channel', { name: 'general', roleRestrictions: [], groupId: data.id});
        }
    })
}

function GetGroup(groupId, msgCode) {
    Group.read({ 'id': groupId }).then(res => {
        if (res.length == 0) {
            sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No group found with id: ' + groupId, msgCode: msgCode })
        }
        else {
            sendMessage('group', 'mongo-response', { operation: 'get-group', response: res, status: 'success', 'msgCode': msgCode });
        }
    });
}

function GetGroupByName(data, msgCode){
    Group.read({'name': data.name}).then(res => {
        if (res.length == 0) {
            sendMessage('group', 'mongo-error-response', { type: 'user-error', message: 'No group found with id: ' + groupId, msgCode: msgCode })
        }
        else {
            sendMessage('group', 'mongo-response', { operation: 'get-group-by-name', response: res, status: 'success', 'msgCode': msgCode });
        }
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
        if(res.id == data.groupId){
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

function AddChannel(data, msgCode){
    Group.updateList({id: data.groupId}, {'channels': data.channelId}, function (res){
        if(res.id == data.groupId){
            sendMessage('group', 'mongo-response', {operation: 'add-channel', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('group', 'mongo-error-response', {type: 'user-error', message: 'No Group found with id: ' + data.groupId, msgCode: msgCode})
        }
    });
}

function RemoveChannel(data, msgCode){
    Group.removeFromList({id: data.groupId}, {'channels': data.channelId}, function (res){
        if(res.id == data.groupId){
            sendMessage('message', 'mongo-response', {operation: 'remove-channel', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', {type: 'user-error', message: 'No Group found with id: ' + data.groupId, msgCode: msgCode})
        }
    });
}

function RemoveUser(data, msgCode){
    Group.removeFromManyLists({}, {'members.$.userId': data.userId}, function(res){
        if(res.id == data.messageId){
            sendMessage('message', 'mongo-response', {operation: 'remove-user', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', {type: 'user-error', message: 'No Group found with id: ' + data.groupId, msgCode: msgCode})
        }
    });
}

//#endregion

//#region MessageChannel Operations

function CreateChannel(data, msgCode){
    let mcObj = {id: data.id, name: data.name, roleRestrictions: data.roleRestrictions, blacklist: [], messages: []}
    MessageChannel.create(mcObj, function (res, err) {
        console.log(err);
        console.log(res);
        if (err) {
            console.log(err);
            sendMessage('message', 'mongo-error-response', { type: 'mongo-error', message: err, 'msgCode': msgCode })
        } else {
            //sendMessage('message', 'mongo-response', { operation: 'create-message-channel', response: res, status: 'success', 'msgCode': msgCode })
            sendMessage('group', 'add-channel', {groupId: data.groupId, channelId: data.id});
        }
    })
}

function RenameChannel(data, msgCode){
    MessageChannel.update({id: data.channelId}, {name: data.name}, function(res){
        if(res.matchedCount > 0){
            sendMessage('message', 'mongo-response', {operation: 'rename-channel', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', { type: 'user-error', message: 'No Channel found with id: ' + data.channelId, 'msgCode': msgCode })
        }
    })
}

function DeleteChannel(data, msgCode){
    MessageChannel.delete({id: data.channelId}, function(res){
        if (res.id == data.channelId) {
            //sendMessage('message', 'mongo-response', { operation: 'delete-channel', response: res, status: 'success', 'msgCode': msgCode });
            sendMessage('group', 'remove-channel', {groupId: data.groupId, channelId: data.id, 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', { type: 'user-error', message: 'No Channel found with id: ' + data.channelId, 'msgCode': msgCode })
        }
    })
}

function GetChannel(data, msgCode){
    MessageChannel.read({id: data.channelId}).then(function(resp){
        if(resp.length > 0){
            sendMessage('message', 'mongo-response', { operation: 'get-channel', response: resp, status: 'success', 'msgCode': msgCode })
        } else [
            sendMessage('message', 'mongo-error-response', { type: 'user-error', message: 'No Channel found with id: ' + data.channelId, 'msgCode': msgCode })
        ]
    })
}

function GetGroupChannels(data, msgCode){
    MessageChannel.aggregate([{"$match": {id: {"$in": data.channelIds}}}]).then((res) => {
        if(response.length < 0){
            sendMessage('message', 'mongo-response', {operation: 'get-group-channels', response: res, status: 'success', 'msgCode': msgCode})
        } else {
            sendMessage('message', 'mongo-error-response', {type: 'user-error', message: 'No channels found with ids: ' + data.channelIds, 'msgCode': msgCode })
        }
    })
}

function AddMessage(data, msgCode){
    MessageChannel.updateList({id: data.channelId}, {'messages': data.messageId}, function (res){
        if(res.id == data.groupId){
            sendMessage('message', 'mongo-response', {operation: 'add-message', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', {type: 'user-error', message: 'No Channel found with id: ' + data.channelId, msgCode: msgCode})
        }
    });
}

function RemoveMessage(data, msgCode){
    MessageChannel.removeFromList({id: data.channelId}, {'messages': data.messageId}, function (res){
        if(res.id == data.messageId){
            sendMessage('message', 'mongo-response', {operation: 'remove-message', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', {type: 'user-error', message: 'No Channel found with id: ' + data.channelId, msgCode: msgCode})
        }
    });
}

//#endregion

//#region Message Operations

function CreateMessage(data, msgCode){
    let msgObj = {id: data.id, sender: data.sender, recipient: data.recipient, content: data.content, timestamp: Date.now()};

    Message.create(msgObj, function(res, err){
        if (err) {
            console.log(err);
            sendMessage('message', 'mongo-error-response', { type: 'mongo-error', message: err, 'msgCode': msgCode })
        } else {
            sendMessage('message', 'mongo-response', { operation: 'create-message', response: res, status: 'success', 'msgCode': msgCode })
        }
    })
}

function GetMessage(data, msgCode){
    Message.read({id: data.messageId}).then(res => {
        if (res.length == 0) {
            sendMessage('message', 'mongo-error-response', { type: 'user-error', message: 'No message found with id: ' + data.messageId, msgCode: msgCode })
        }
        else {
            sendMessage('message', 'mongo-response', { operation: 'get-message', response: res, status: 'success', 'msgCode': msgCode });
        }
    })
}

function GetChannelMessages(data, msgCode){
    Message.aggregate([{"$match": {id: {"$in": data.messageIds}}}]).then(res => {
        if (res.length == 0) {
            sendMessage('message', 'mongo-error-response', { type: 'user-error', message: 'No message found with id: ' + data.messageIds, msgCode: msgCode })
        }
        else {
            sendMessage('message', 'mongo-response', { operation: 'get-channel-messages', response: res, status: 'success', 'msgCode': msgCode });
        }
    })
}

function EditMessage(data, msgCode){
    Message.update({id: data.messageId}, {"content": data.newContent, "timestamp": Date.now()}, function(res){
        if(res.id == data.messageId){
            sendMessage('message', 'mongo-response', {operation: 'edit-message', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', {type: 'user-error', message: 'No message found with id: ' + data.messageId, msgCode: msgCode})
        }
    })
}

function DeleteMessage(data, msgCode){
    Message.delete({id: data.messageId}, function(res){
        if(res.id == data.messageId){
            sendMessage('message', 'mongo-response', {operation: 'delete-message', response: res, status: 'success', 'msgCode': msgCode});
        } else {
            sendMessage('message', 'mongo-error-response', {type: 'user-error', message: 'No message found with id: ' + data.messageId, msgCode: msgCode})
        }
    })
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
    console.log('Sending DB Response');
    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            { key: `${operation}`, value: JSON.stringify(data) }
        ]
    })
}