const mongoose = require('mongoose');



const messageSchema = new mongoose.Schema({
    id: {
        type: String,
        unique: true,
        required: true
    },
    sender: {
        type: String,
        unqiue: false,
        required: true
    },
    recipient: {
        type: String,
        unique: false,
        required: true
    },
    content: {
        type: String,
        unique: false,
        required: true
    },
    timestamp: {
        type: Number,
        unique: false,
        required: true,
        default: Date.now()
    }
});

module.exports = messageSchema;