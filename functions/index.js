const admin = require("firebase-admin");
const functions = require("firebase-functions");

admin.initializeApp();

const TOPIC = "rescue_all_users";

function buildNotificationPayload(title, body, data) {
  const payloadData = {};
  for (const [key, value] of Object.entries(data)) {
    payloadData[key] = String(value);
  }

  return {
    topic: TOPIC,
    notification: {
      title,
      body,
    },
    data: payloadData,
  };
}

async function broadcastToEnabledUsers({
  title,
  message,
  region,
  sourceId,
  sourceType,
}) {
  const db = admin.firestore();
  const usersSnap = await db.collection("users").get();
  const enabledUsers = usersSnap.docs.filter(
    (doc) => doc.get("notificationsEnabled") !== false,
  );

  const batches = [];
  let batch = db.batch();
  let writes = 0;

  for (const userDoc of enabledUsers) {
    const notifRef = db.collection("notifications").doc();
    batch.set(notifRef, {
      userId: userDoc.id,
      title,
      message,
      region: region || "",
      sourceId: sourceId || "",
      sourceType: sourceType || "",
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    writes += 1;

    if (writes === 450) {
      batches.push(batch.commit());
      batch = db.batch();
      writes = 0;
    }
  }

  if (writes > 0) {
    batches.push(batch.commit());
  }

  await Promise.all(batches);
  await admin.messaging().send(
    buildNotificationPayload(title, message, {
      region: region || "",
      sourceId: sourceId || "",
      sourceType: sourceType || "",
    }),
  );
}

exports.onIncidentCreated = functions.firestore
  .document("incidents/{incidentId}")
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};
    const title = "New Incident Reported";
    const message = `${data.type || "Incident"} at ${data.location || "an area"} has been reported.`;

    await broadcastToEnabledUsers({
      title,
      message,
      region: data.region || "",
      sourceId: context.params.incidentId,
      sourceType: "incident",
    });
  });

exports.onPostCreated = functions.firestore
  .document("community_posts/{postId}")
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};
    const title = "New Community Post";
    const message = `${data.rawTitle || data.title || "A community post"} has been published.`;

    await broadcastToEnabledUsers({
      title,
      message,
      region: data.region || "",
      sourceId: context.params.postId,
      sourceType: "post",
    });
  });
