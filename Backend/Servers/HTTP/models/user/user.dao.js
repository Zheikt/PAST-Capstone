const mongoose = require('mongoose');
const schema = require('./user.model')

schema.statics = {
    create: function(data, callback) 
    {
        const document = new this(data);
        document.save().then(callback);
    },
    read: function(query) 
    {
        return this.find(query);
    },
    update: function(query, data, callback) 
    {
        this.updateOne(query, {$set: data}).then(callback);
    },
    delete: function(query, callback) 
    {
        this.deleteOne(query).then(callback);
    }
};

const model = mongoose.model('User', schema);
module.exports = model;