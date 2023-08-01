const mongoose = require('mongoose');

const roleSchema = mongoose.Schema({
    id: {
        type: String,
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

module.exports = roleSchema;