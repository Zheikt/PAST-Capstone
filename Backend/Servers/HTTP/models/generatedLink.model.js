const mongoose = require('mongoose');

const generatedLinkSchema = mongoose.Schema({
    route: {
        type: String,
        unique: true,
        required: true
    },
    relatedObject: {
        type: String,
        unique: false,
        required: true
    },
    validUntil: {
        type: Number,
        unique: false,
        required: true,
        default: Date.now() + 900_000 //now + 15 minutes
    }
});

module.exports = generatedLinkSchema;