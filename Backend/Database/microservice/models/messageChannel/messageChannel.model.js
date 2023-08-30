const mongoose = require('mongoose');


const channelSchema = mongoose.Schema({
    id: {
        type: String,
        unique: true,
        required: true
    },
    name: {
        type: String,
        unique: true,
        required: true,
        default: "New Channel"
    },
    roleRestrictions: {
        type: [String],
        unique: false,
        required: true,
        default: []
    },
    blacklist: {
        type: [String],
        unique: false,
        required: true,
        default: []
    },
    messages: {
        type: [String],
        unique: false,
        required: true,
        default: []
    },
});

module.exports = channelSchema;