const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.newStudent = functions.firestore.document('users/{documentID}').onCreate((snap, context)=>{
    const newValue = snap.data();
    const status = newValue.status;
    const name = newValue.name;
    const notification  = {
        notification:{
            title: "A new student signed up",
            body: "The student is "+name,
            icon: "default",
            sound: "default",
        }
    };
    const options = {
        priority: 'high',
        timeToLive: 60*60*24,
    };
    
    if(status == 'student'){
        return admin.messaging().sendToTopic('studentNotifier',notification,options);
    }
   
});
exports.newTeacher = functions.firestore.document('users/{documentID}').onCreate((snap, context)=>{
    const newValue = snap.data();
    const status = newValue.status;
    const name = newValue.name;
    const notification  = {
        notification:{
            title: "A new teacher signed up",
            body: "The teacher is "+name,
            icon: "default",
            sound: "default",
        }
    };
    const options = {
        priority: 'high',
        timeToLive: 60*60*24,
    };
    if(status == 'teacher'){
        return admin.messaging().sendToTopic(
            'teacherNotifier'
            ,notification,options);
    }
   
});

exports.approved = functions.firestore.document('users/{documentID}').onUpdate((snap, context)=>{
    const before = snap.before.data().approved;
    const after = snap.after.data().approved;
    const token = snap.after.data().fcmtoken;
    console.log(token);
    const notification1 = {
        // notification:{
        //     title: 'Your account has been approved',
        //     body: 'You can now access the content of the app',
        //     icon: "default",
        //     sound: 'default',
        //     color: 'orange',
        // },
        android:{
            title: 'Your account has been approved',
            body : 'You can now access the content of the app',
            icon: 'ic_stat_ic_notification',
            sound: 'default',
            color: 'orange',
        },
    };
    const notification2 = {
        notification:{
            title: 'Your account has been invalidated',
            body: 'You can no longer access the content of the app',
            icon: "default",
            sound: 'default',
            color: 'orange',
        }
    };
    if(before != after){
        if(after){
            return admin.messaging().sendToDevice(token, notification1);
        }
        else{
            return admin.messaging().sendToDevice(token, notification2);
        }
    }
});
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
