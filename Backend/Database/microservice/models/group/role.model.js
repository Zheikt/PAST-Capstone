const mongoose = require('mongoose');

const colorSchema = mongoose.Schema({
    red: {
        type: Number,
        required: true,
        default: 0,
        min: 0,
        max: 255,
    },
    green: {
        type: Number,
        required: true,
        default: 0,
        min: 0,
        max: 255,
    },
    blue: {
        type: Number,
        required: true,
        default: 0,
        min: 0,
        max: 255,
    },
})

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
    color: {
        type: colorSchema,
        required: true,
    },
    permissions: {
        type: [String],
        unique: false,
        required: true,
        default: []
    }
});

module.exports = roleSchema;