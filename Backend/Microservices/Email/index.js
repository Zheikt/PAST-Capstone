const nodemailer = require('nodemailer');
const ConsumerImport = require('./streams/consumer');
const ProducerImport = require('./streams/producer');

const linkChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGIJKLMNOPQRSTUVWXYZ0123456789';

const consumer = ConsumerImport.consumer({
    groupId: "past-email-consumer-group"
});

const producer = ProducerImport.producer();

function main() {
    let transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: 'pastnoreply@gmail.com',
            pass: process.env.password
        }
    });

    setUpConsumer(transporter);
}

async function setUpConsumer(transporter) {
    await consumer.connect();

    await consumer.subscribe({ topics: ['email'] })

    await consumer.run({
        eachMessage: async ({ topic, partition, message, heartbeat, pause }) => {
            switch (message.key.toString()) {
                case 'change-password':
                    SendPasswordChangeEmail(JSON.parse(message.value))
                    break;
                case 'verify-email':
                    SendEmailVerificationEmail(JSON.parse(message.value));
                    break; 
            }
        }
    })
}

async function SendPasswordChangeEmail(targetData, transporter){
    let targetEmail = targetData.email;

    let passwordLink = 'p';

    while(passwordLink.length < 10){
        passwordLink += linkChars[Math.trunc(Math.random() * linkChars.length)];
    }

    let emailInfo = await transporter.sendMail({
        from: '"P.A.S.T. Support No-Reply" <pastnoreply@gmail.com>',
        to: targetEmail,
        subject: "Password Change Requested",
        text: `A password change has been requested for your account.\nClick this link:\n, http://localhost:2024/h/${passwordLink}\n\nThank you for using P.A.S.T.!\nThe Team Behind P.A.S.T.`
    })
    sendMessage('mongo', 'create-password-verification', {route: emailLink, relatedObject: targetData.id, validUntil: (Date.now() + 86_400_000)}); //Adds 1-day
}

async function SendEmailVerificationEmail(targetData, transporter){
    let targetEmail = targetData.email;

    let emailLink = 'e';

    while(emailLink.length < 10){
        emailLink += linkChars[Math.trunc(Math.random() * linkChars.length)];
    }

    let emailInfo = await transporter.sendMail({
        from: '"P.A.S.T. Support No-Reply" <pastnoreply@gmail.com>',
        to: targetEmail,
        subject: "Email Verification Needed",
        text: `We need to verify this email.\nClick this link:\n, http://localhost:2024/h/${emailLink}\n\nThank you for using P.A.S.T.!\nThe Team Behind P.A.S.T.`
    })

    sendMessage('mongo', 'create-email-verification', {route: emailLink, relatedObject: targetData.id, validUntil: (Date.now() + 604_800_000)}); //Adds 1-week
}

async function sendMessage(targetService, operation, data) {
    await producer.connect();
    producer.send({
        topic: targetService,
        messages: [
            { key: `${operation}`, value: JSON.stringify(data) }
        ]
    });
}

main();