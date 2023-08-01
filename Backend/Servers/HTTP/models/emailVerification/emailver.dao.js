const mongoose = require('mongoose');
const schema = require('./emailver.model')

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
    delete: function(query, callback) 
    {
        this.findOneAndDelete(query).then(callback);
    }
};

const model = mongoose.model('EmailVerification', schema);
module.exports = model;