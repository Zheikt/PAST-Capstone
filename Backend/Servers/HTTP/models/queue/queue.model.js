const mongoose = require('mongoose');

const queueSchema = new mongoose.Schema({
    id: {
        type: Number,
        unique: true,
        required: true
    },
    title: {
        type: String,
        unqiue: false,
        required: true,
        default: "New Queue"
    },
    champion: {
        type: String,
        unique: false,
        required: true
    },
    challengers: {
        type: [String],
        unique: false,
        required: true,
        default: []
    },
    group: {
        type: String,
        unique: false,
        required: true
    }
});

module.exports = queueSchema;