const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendTaskNotification = functions.https.onCall(async (data, context) => {
  const tokens = data.tokens; // array of FCM tokens
  const taskName = data.taskName;

  if (!tokens || tokens.length === 0) {
    return { success: false, message: "No tokens provided" };
  }

  const payload = {
    notification: {
      title: "New Task Assigned",
      body: `Task: ${taskName}`,
    },
  };

  const response = await admin.messaging().sendToDevice(tokens, payload);
  return { success: true, response };
});
