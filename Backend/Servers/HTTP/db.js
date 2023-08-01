const mongoose = require('mongoose');

module.exports = function()
{
    let {MONGOIPADDRESS} = process.env;
    if(!MONGOIPADDRESS){
        //remove +srv and change /?retryWrites... to /?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.5.0
        //for dist sys
        MONGOIPADDRESS = "admin:Nu200645818@distsyscluster.gj02b6a.mongodb.net";
    }
    mongoose.connect(`mongodb://${MONGOIPADDRESS}/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.5.0`)
    .then((result) => {
        return result;
    })
    .catch((err) => {
        console.log('Error connecting to db: ', err);
    });

    mongoose.connection.on('connected', () => {
        console.log('We connected to the database.');
    });

    mongoose.connection.on('error', () => {
        console.log('That did not work as planned');
    });

    process.on('SIGINT', () => {
        mongoose.connection.close(true, () => {
            console.log('Forcing db connection to close');
            process.exit(0);
        });
    })
};