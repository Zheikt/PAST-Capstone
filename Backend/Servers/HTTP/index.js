const express = require('express');
const ProducerImport = require('./KafkaStreams/producer');
const ConsumerImport = require('./KafkaStreams/consumer');
//#region DBImports
const User = require('./models/user/user.dao');
const Group = require('./models/group/group.dao');
const EmailVer = require('./models/emailVerification/emailver.dao');
const PassVer = require('./models/passwordVerification/passver.dao');
const db = require('./db');
const mongoose = require('mongoose');
//#endregion
const app = express();

setTimeout(() => db(), 20000);

app.get('/h/:route', express.json(), function(req, res, next){
    console.log(req.body);
    console.log(req);
    console.log(Object.keys(req));
    switch(req.params.route.substring(0,1))
    {
        case 'e':
            //verify email
            VerifyEmail(req, res);
            break;
        case 'p':
            //change password
            ChangePassword(req, res);
            break;
        case 'g':
            //join group
            JoinGroup(req, res);
            break;
        case 'l':
            //login
            Login(req, res);
            break;
        case 'r':
            //register user
            RegisterUser(req, res);
            break;
    }
})

app.listen(2001, () => console.log("Lisetning on port " + process.env.NGINX_PORT));

function VerifyEmail(req, res)
{
    EmailVer.read({'route': req.body.route}).then((resp) =>
    {
        if(resp.length > 0)
        {
            let emailVer = resp[0];
            if(emailVer.validUntil >= Date.now())
            {
                User.update({id: emailVer.relatedObject}, {'email.verified': true}, (resp1) => {
                    res.status(200).json({'status': 'success', 'message': 'Email succesffully verified'});
                    EmailVer.delete({route: req.body.data.route}, (resp2) => console.log(resp2))
                })
            }
            else
            {
                EmailVer.delete({route: req.body.route}, (resp2) => console.log(resp2))
                res.status(410).json({'status': 'fail', 'message': "Email Verification request Expired"});
            }
        }
        else
        {
            res.status(404).json({"status": "fail", "message": "No verification found with the given route"})
        }
    })
}

function ChangePassword(req, res)
{
    console.log("Changing password")
    PassVer.read({route: req.body.route}).then((resp) => {
        console.log('Finished Read');
        if(resp.length > 0)
        {
            console.log('FOUND');
            let passVer = resp[0];
            if(passVer.validUntil >= Date.now())
            {
                console.log("IN-DATE")
                //Does this need to get changed to serve a page first?
                User.update({id: resp.relatedObject}, {password: req.body.newPassword}, function(resp1, err){
                    console.log('Updated User');
                    console.log(resp1);
                    res.status(200).json({status: 'success', message: 'Password changed successfully'})
                    PassVer.delete({route: req.body.route}, (resp2) => console.log(resp2))
                
                })
            }
            else
            {
                console.log('OUT-OF-DATE')
                res.status(410).json({status: 'fail', message: 'Password Change Request Expired'})
                PassVer.delete({route: req.body.route}, (resp2) => console.log(resp2))
            }
        }
        else
        {
            console.log('NOT FOUND')
            res.status(404).json({status: 'fail', message: 'Route not found'})
        }
    })
}

function JoinGroup(req, res)
{

}

function Login(req, res){
    User.read({username: req.body.username, password: req.body.password}).then(function(resp){
        console.log(resp);
        if(resp.length == 0){
            res.status(404).json({'status': 'fail', 'message': 'Username/Password did not match'});
        } else {
            let tokens = AddAuthToken(resp[0].validAuthTokens);
            User.update({id: resp[0].id}, {validAuthTokens: tokens}, (finResp) => res.status(200).json({'status': 'success', 'message': 'Login Successful', 'token': tokens[tokens.length - 1]}));
        }
    })
}

function RegisterUser(req, res)
{
    //username, password, and email provided

    let user = {username: req.body.username, password: req.body.password, email: {email: req.body.email, verified: false}, stats: [], validAuthTokens: []}

    User.create(user, (resp, err) =>
    {
        console.log(resp);
        console.log(err);
        if(resp.length > 0)
        {
            let tokens = AddAuthToken([]);
            User.update({id: resp[0].id}, {validAuthTokens: tokens}, (resp1) => res.status(200).json({status: 'success', message: 'User created successfully', 'token': tokens[tokens.length - 1]}));
        }
    })
}

function AddAuthToken(tokenArray)
{
    //sample = 238JfuUhae03oswja3La
    let authCode = '';
    let tokenChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    while(authCode.length < 20)
    {
        authCode += tokenChars[Math.trunc(Math.random() * tokenChars.length)];
        if(authCode.length == 20 && tokenArray.find(elem => elem == authCode) != undefined)
            authCode = '';
    }
    tokenArray.push({token: authCode, validUntil: Date.now() + 86_400_000});

    return tokenArray;
}