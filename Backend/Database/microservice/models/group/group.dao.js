const mongoose = require('mongoose');
const schema = require('./group.model')

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
        this.findOneAndUpdate(query, {$set: data}).then(callback);
    },
    delete: function(query, callback) 
    {
        this.findOneAndDelete(query).then(callback);
    }
};

const model = mongoose.model('Group', schema);
module.exports = model;