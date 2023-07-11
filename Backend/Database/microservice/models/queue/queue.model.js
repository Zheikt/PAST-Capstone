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
        required: true
    },
    champion: {
        type: mongoose.Types.ObjectId,
        unique: false,
        required: true
    },
    challengers: {
        type: [mongoose.Types.ObjectId],
        unique: false,
        required: true
    },
    group: {
        type: mongoose.Types.ObjectId,
        unique: false,
        required: true
    }
});

module.exports = queueSchema;