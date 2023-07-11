const mongoose = require('mongoose');

const generatedLinkSchema = mongoose.Schema({
    id:{
        type: mongoose.Types.ObjectId,
        unique: true,
        required: true
    },
    route: {
        type: String,
        unique: true,
        required: true
    },
    relatedObject: {
        type: mongoose.Types.ObjectId,
        unique: false,
        required: true
    },
    validUntil: {
        type: Date,
        unique: false,
        required: true
    }
});

module.exports = generatedLinkSchema;