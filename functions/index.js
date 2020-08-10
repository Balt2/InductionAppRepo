'use strict';
// var firebase = require("firebase/app");
// require("firebase/auth");
// require("firebase/firestore");
var fs = require('fs');
const path = require('path');


const functions = require('firebase-functions');
const nodemailer = require('nodemailer');
// var database = firebase.database();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

// admin.initializeApp({
//   credential: admin.credential.applicationDefault()
// });




// const gmailEmail = "inductionlearn@gmail.com";
// const gmailPassword = "Brooks39-";

const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;


const mailTransport = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});

// Your company name to include in the emails
// TODO: Change this to your app or company name to customize the email sent.
const APP_NAME = 'Induction Learning';

// [START sendWelcomeEmail]
/**
 * Sends a welcome email to new user.
 */
// [START onCreateTrigger]
exports.sendWelcomeEmail = functions.auth.user().onCreate((user) => {
    // [END onCreateTrigger]
      // [START eventAttributes]
      const email = user.email; // The email of the user.
      const userId = user.uid;
      const db = admin.firestore();

      
      // return firebase

      
      //const fname = user.fname; // The display name of the user.
      // [END eventAttributes]
    
      return sendWelcomeEmail(email, userId, db);
    });
    // [END sendWelcomeEmail]

// Sends a welcome email to the given user.
async function sendWelcomeEmail(email, userId, db) {
  const satTestsDir = path.join(__dirname, '/SATTests.zip');
  const actTestsDir = path.join(__dirname, '/ACTTests.zip');
    const mailOptions = {
      from: `${APP_NAME} <noreply@firebase.com>`,
      to: email
      //,
      // attachments: [
      //   {   // file on disk as an attachment
      //     filename: 'SATTests.zip',
      //     path: satTestsDir
      //   },
      //   {   // file on disk as an attachment
      //     filename: 'ACTTests.zip',
      //     path: actTestsDir
      //   }
      // ]
    };
    console.log(`This is the user id: ${userId}`)

    var userFirstName = "";

    const docRef = db.collection('users').doc(userId);
      const doc = await docRef.get();
      if (!doc.exists) {
        console.log('No such document!');
      } else {
        userFirstName = doc.data().firstN
        console.log('Document data:', doc.data());
      }


    
    // The user subscribed to the newsletter.
    mailOptions.subject = `Welcome to ${APP_NAME}!`;
    mailOptions.text = `Hey ${userFirstName}! Welcome to ${APP_NAME}. In order to use the application please follow the steps below to get the test PDFs. 
    \n1. Click this link (https://www.dropbox.com/sh/uif30uoxawktjoh/AACvRVJG3eCAmSGOiG_ufCila?dl=1) to download the test files. 
    \n2. Go to files and click on the zip file.
    \n3. Go to your Induction Learning app and click choose test.
    \n4. Click on a test and upload the file with the corresponding name and it is on your device forever. For example if you wanted to take College Board Test 9, you would upload the pdf file CB9.
    \n
    \nBest,
    \nInduction Leaning `;
    await mailTransport.sendMail(mailOptions);
    console.log('New welcome email sent to:', email);
    return null;
  }


// // Take the text parameter passed to this HTTP endpoint and insert it into 
// // Cloud Firestore under the path /messages/:documentId/original
// exports.addMessage = functions.https.onRequest(async (req, res) => {
//     // Grab the text parameter.
//     const original = req.query.text;
//     // Push the new message into Cloud Firestore using the Firebase Admin SDK.
//     const writeResult = await admin.firestore().collection('messages').add({original: original});
//     // Send back a message that we've succesfully written the message
//     res.json({result: `Message with ID: ${writeResult.id} added.`});
//   });


// // Listens for new messages added to /messages/:documentId/original and creates an
// // uppercase version of the message to /messages/:documentId/uppercase
// exports.makeUppercase = functions.firestore.document('/messages/{documentId}')
//     .onCreate((snap, context) => {
//       // Grab the current value of what was written to Cloud Firestore.
//       const original = snap.data().original;

//       // Access the parameter `{documentId}` with `context.params`
//       functions.logger.log('Uppercasing', context.params.documentId, original);
      
//       const uppercase = original.toUpperCase();
      
//       // You must return a Promise when performing asynchronous tasks inside a Functions such as
//       // writing to Cloud Firestore.
//       // Setting an 'uppercase' field in Cloud Firestore document returns a Promise.
//       return snap.ref.set({uppercase}, {merge: true});
//     });
