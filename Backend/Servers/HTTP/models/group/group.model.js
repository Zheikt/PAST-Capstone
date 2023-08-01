const mongoose = require('mongoose');
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
        required: true,
        default: "New Role"
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
        required: true,
        default: []
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
        required: true,
        default: "New Event"
    },
    startDate: {
        type: Number,
        unique: false,
        required: true,
        default: Date.now()
    },
    endDate: {
        type: Number,
        unique: false,
        required: true,
        default: Date.now() + 86_400_000 //now + 24 hours
    },
    participants: {
        type: [mongoose.Types.ObjectId],
        unique: false,
        required: true,
        default: []
    }
});

const groupSchema = new mongoose.Schema({
    id: {
        type: String,
        unique: true,
        required: true
    },
    name: {
        type: String,
        unqiue: true,
        required: true,
        default: "New Group"
    },
    members: { 
        type: [memberSchema],
        unique: false,
        required: true,
        default: []
    },
    roles: { //Different available roles
        type: [roleSchema],
        unique: false,
        required: true,
        default: []
    },
    queue: {
        type: [queueSchema],
        unique: false,
        required: false,
        default: []
    },
    events: {
        type: [eventSchema],
        unique: false,
        required: false,
        default: []
    },
    statBlock: {
        type: Object,
        unique: false,
        required: false,
        default: {}
    },
    channels: {
        type: [String],
        unique: false,
        required: true,
        default: []
    }
});

module.exports = groupSchema;