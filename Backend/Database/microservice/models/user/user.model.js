const mongoose = require('mongoose');

const linkSchema = require('../generatedLink.model');

const authSchema = mongoose.Schema({
    token: {
        type: String,
        unique: true,
        required: true
    },
    validUntil: {
        type: Date,
        unique: false,
        required: true
    }
})

const userSchema = new mongoose.Schema({
    id: {
        type: Number,
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
        type: Number,
        unique: true,
        required: true
    },
    stats: { //manually tell the db that this has changed
        type: Array,
        unique: false,
        required: true
    },
    validAuthTokens: {
        type: [authSchema],
        unique: false,
        required: true
    },
    validEmailVerificationRoutes: {
        type: [linkSchema],
        unique: false,
        required: true
    },
    validPasswordVerificationRoutes: {
        type: [linkSchema],
        unique: false,
        required: true
    }
});

module.exports = userSchema;