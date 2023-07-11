const mongoose = require('mongoose');



const messageSchema = new mongoose.Schema({
    id: {
        type: mongoose.Types.ObjectId,
        unique: true,
        required: true
    },
    sender: {
        type: mongoose.Types.ObjectId,
        unqiue: false,
        required: true
    },
    recipient: {
        type: mongoose.Types.ObjectId,
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
        required: true
    }
});

module.exports = messageSchema;