const mongoose = require('mongoose');
const messageSchema = require('../message/message.model');
const queueSchema = require('../queue/queue.model');

const roleSchema = mongoose.Schema({
    id: {
        type: mongoose.Types.ObjectId,
        unique: true,
        required: true
    },
    title: {
        type: String,
        unique: false,
        required: true
    },
    permissions: {
        type: [String],
        unique: false,
        required: true,
        default: []
    }
});

const memberSchema = mongoose.Schema({
    userId: {
        type: mongoose.Types.ObjectId,
        unique: false,
        required: true
    },
    roles: {
        type: [roleSchema],
        unique: false,
        required: true
    },
    nickname: {
        type: String,
        unique: true,
        required: false
    }
});

const eventSchema = mongoose.Schema({
    id: {
        type: mongoose.Types.ObjectId,
        unique: true,
        required: true
    },
    title: {
        type: String,
        unique: false,
        required: true
    },
    startDate: {
        type: Number,
        unique: false,
        required: true
    },
    endDate: {
        type: Number,
        unique: false,
        required: true
    },
    participants: {
        type: [mongoose.Types.ObjectId],
        unique: false,
        required: true
    }
});

const channelSchema = mongoose.Schema({
    id: {
        type: mongoose.Types.ObjectId,
        unique: true,
        required: true
    },
    name: {
        type: String,
        unique: true,
        required: true
    },
    roleRestrictions: {
        type: [roleSchema],
        unique: false,
        required: true,
        default: []
    },
    blacklist: {
        type: [mongoose.Types.ObjectId],
        unique: false,
        required: true
    },
    messages: {
        type: [messageSchema],
        unique: false,
        required: true,
        default: []
    },
});

const groupSchema = new mongoose.Schema({
    id: {
        type: mongoose.Types.ObjectId,
        unique: true,
        required: true
    },
    name: {
        type: String,
        unqiue: true,
        required: true
    },
    members: { 
        type: [memberSchema],
        unique: false,
        required: true
    },
    roles: { //Different available roles
        type: [roleSchema],
        unique: false,
        required: true
    },
    queue: {
        type: [queueSchema],
        unique: false,
        required: false
    },
    events: {
        type: [eventSchema],
        unique: false,
        required: false
    },
    statBlock: {
        type: Object,
        unique: false,
        required: false
    },
    channels: {
        type: [channelSchema],
        unique: false,
        required: true
    }
});

module.exports = groupSchema;