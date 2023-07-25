const express = require('express');

const app = express();

app.get('/h/', function(req, res, next){
    switch(req.url.substring(3)[0])
    {
        case 'e':
            //verify email
            
            break;
        case 'p':
            //change password
            break;
        case 'g':
            //join group
            break;
    }
})