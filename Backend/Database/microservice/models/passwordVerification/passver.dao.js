const mongoose = require('mongoose');
const schema = require('./passver.model')

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
    delete: function(query, callback) 
    {
        this.findOneAndDelete(query, callback);
    }
};

const model = mongoose.model('passwordVerification', schema);
module.exports = model;