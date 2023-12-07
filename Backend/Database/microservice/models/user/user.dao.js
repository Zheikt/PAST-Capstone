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
    updateList: function(query, data, callback)
    {
        this.findOneAndUpdate(query, {$push: data}).then(callback);
    },
    removeFromList: function(query, data, callback)
    {
        this.findOneAndUpdate(query, {$pull: data}).then(callback);
    },
    removeFromManyLists: function(query, data, callback)
    {
        this.updateMany(query, {$pull: data}).then(callback);
    },
    delete: function(query, callback) 
    {
        this.deleteOne(query).then(callback);
    }
};

const model = mongoose.model('User', schema);
module.exports = model;