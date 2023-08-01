const mongoose = require('mongoose');

const linkSchema = require('../generatedLink.model');

const authSchema = mongoose.Schema({
    token: {
        type: String,
        unique: true,
        required: true
    },
    validUntil: {
        type: Number,
        unique: false,
        required: true,
        default: Date.now() + 86_400_000 //valid for 1 day
    }
})

const emailSchema = mongoose.Schema({
    email: {
        type: String,
        unique: true,
        required: true
    },
    verified: {
        type: Boolean,
        required: true,
        default: false
    }
})

const userSchema = new mongoose.Schema({
    id: {
        type: String,
        unique: true,
        required: true
    },
    username: {
        type: String,
        unqiue: true,
        required: true
    },
    password: {
        type: String,
        unique: false,
        required: true
    },
    email: {
        type: emailSchema,
        unique: true,
        required: true
    },
    stats: { //manually tell the db that this has changed
        type: Array,
        unique: false,
        required: true,
        default: []
    },
    validAuthTokens: {
        type: [authSchema],
        unique: false,
        required: true,
        default: []
    }
});

module.exports = userSchema;