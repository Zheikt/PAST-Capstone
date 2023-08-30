const mongoose = require('mongoose');
const schema = require('./messageChannel.model')

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
    aggregate: function(query)
    {
        return this.aggregate(query);
    },
    update: function(query, data, callback) 
    {
        this.updateOne(query, {$set: data}).then(callback);
    },
    addtoList: function(query, data, callback)
    {
        this.findOneAndUpdate(query, {$push: data}).then(callback);
    },
    removeFromList: function(query, data, callback)
    {
        this.findOneAndUpdate(query, {$pull: data}).then(callback);
    },
    delete: function(query, callback) 
    {
        this.findOneAndDelete(query).then(callback);
    }
};

const model = mongoose.model('MessageChannel', schema);
module.exports = model;