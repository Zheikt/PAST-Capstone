const mongoose = require('mongoose');
const schema = require('./message.model')

schema.statics = {
    create: function(data, callback) 
    {
        const document = new this(data);
        document.save(callback);
    },
    read: function(query) 
    {
        return this.find(query);
    },
    update: function(query, data, callback) 
    {
        this.findOneAndUpdate(query, {$set: data}, callback);
    },
    delete: function(query, callback) 
    {
        this.findOneAndDelete(query, callback);
    }
};

const model = mongoose.model('Message', schema);
module.exports = model;