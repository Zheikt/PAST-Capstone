"use strict";
const db = require('./db');
const mongoose = require('mongoose');
const User = require('./models/user.dao');
const Group = require('./models/group.dao');
const Queue = require('./models/queue.dao');
const Message = require('./models/message.dao');
const ConsumerImport = require('./streams/consumer');

//setTimeout(() => db(), 15000); //waits a little for the mongodb instance to spin up

const consumer = ConsumerImport.consumer({
    groupId: 'mongo-consumer-group'
});

//Anime and Studio need to be replaced throughout

async function main(){
    await consumer.connect();
    await consumer.subscribe({topics: ['anime', 'studio']});
    await consumer.run({
        eachMessage: async ({ topic, partition, message, heartbeat, pause }) => {
            switch (topic) {
                case 'anime':
                    var anime = JSON.parse(message.value);
                    AnimeDBOperations(anime, message.key.toString());
                    break;
                case 'studio':
                    console.log(JSON.stringify(message));
                    var studio = JSON.parse(message.value);
                    StudioDBOperations(studio, message.key.toString());
                    break;
            }
        }
    })
}

function AnimeDBOperations(anime, key){
    switch(key){
        case "create-anime": //also update related studio with anime
            Anime.create(anime, function(err, res){
                if(err){
                    console.log("Error creating anime. Error: " + err);
                } else {
                    console.log("Anime created succesfully");
                    Studio.read({'id': anime.studio}).then((result) => {
                        let animeMade = result[0]._doc.animeMade.map(elem => elem);
                        animeMade.push(anime.id);
                        Studio.updateOne({'id': anime.studio}, {$set: {'animeMade': animeMade}}, function(err, updResult){
                            if(err){
                                console.log("Error updating studio. Error: ", err);
                            } else {
                                console.log("Studio updated successfully");
                            }
                        })
                    })
                }
            })
            break;
        case "update-anime":
            Anime.updateOne({'id': anime.id}, anime, function(err, res){
                if(err){
                    console.log("Error updating anime. Error: ", err);
                } else {
                    console.log("Anime updated successfully");
                }
            })
            break;
        case "delete-anime": //remove anime from its studio's list
            Anime.delete({'id': anime.id}, function(err, result){
                if(err){
                    console.log("Error deleting Anime. Error: ", err);
                } else{
                    console.log("Anime deleted successfully");
                    Studio.read({'id': result.studio}).then((innerResult) => {
                        let animeMade = innerResult[0]._doc.animeMade.map(elem => elem);
                        animeMade.splice(animeMade.indexOf(anime.id), 1);
                        Studio.updateOne({'id': result.studio}, {$set: {'animeMade': animeMade}}, function(err, updResult){
                            if(err){
                                console.log("Error updating studio. Error: ", err);
                            } else {
                                console.log("Studio updated successfully");
                            }
                        })
                    })
                }
            })
            break;
    }
}

function StudioDBOperations(studio, key){
    console.log(key);
    switch(key){
        case "create-studio":
            Studio.create(studio, function(err, res){
                if(err){
                    console.log("Error creating studio. Error: " + err);
                } else {
                    console.log("Studio created succesfully");
                }
            })
            break;
        case "update-studio":
            Studio.updateOne({id: studio.id}, studio, function(err, res){
                if(err){
                    console.log("Error updating studio. Error: ", err);
                } else {
                    console.log("Studio updated successfully");
                }
            })
            break;
        case "delete-studio": //make sure to remove all references to the studio from its anime (should this delete the anime also?)
            Studio.delete({id: studio.id}, function(err, result){
                if(err){
                    console.log("Error deleting studio. Error: ", err);
                } else{
                    console.log("Studio deleted successfully");
                    console.log(JSON.stringify(result));
                    for(let iter = 0; iter < result.animeMade.length; iter++){
                        Anime.findOneAndUpdate({'id': result.animeMade[iter]}, {$set: {'studio': -1}}, function(err, result){
                            if(err){
                                console.log('Error updating anime. Error: ' + err);
                            } else {
                                console.log("Anime updated successfully")
                            }
                        })
                    }
                }
            })
            break;
    }
}

main();