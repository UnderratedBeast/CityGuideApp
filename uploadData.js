const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Import all your city data
const citiesData = {
  // lagos: require("./data/lagos.json"),
  // abuja: require("./data/abuja.json"),
  // port_harcourt: require("./data/port_harcourt.json"),
  // kano: require("./data/kano.json"),
  // ibadan: require("./data/ibadan.json"),
  // onitsha: require("./data/onitsha.json"),
  calabar: require("./data/calabar.json"),
  // enugu: require("./data/enugu.json"),
  // jos: require("./data/jos.json"),
  // kaduna: require("./data/kaduna.json"),
  // bauchi: require("./data/bauchi.json"),
  // yola: require("./data/yola.json"),
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

/**
 * Sanitize Firestore document ID
 * - Removes illegal characters (/)
 * - Trims spaces
 */
function createSafeDocId(name) {
  return name
    .replace(/\//g, "-")     // Firestore does not allow "/"
    .replace(/#/g, "")      // remove hashtags if any
    .replace(/\?/g, "")     // remove question marks
    .trim();
}

async function uploadCity(cityId, cityData) {
  try {
    const cityRef = db.collection("cities").doc(cityId);

    const { attractions, hotels, dining, events, ...cityInfo } = cityData;

    // Upload main city document
    await cityRef.set(cityInfo, { merge: true });
    console.log(`✅ ${cityId} main city data uploaded`);

    const subcollections = {
      attractions,
      hotels,
      dining,
      events,
    };

    // Upload subcollections using batch writes
    for (const [collectionName, collectionData] of Object.entries(subcollections)) {
      if (!Array.isArray(collectionData) || collectionData.length === 0) continue;

      const batch = db.batch();

      for (const item of collectionData) {
        if (!item.name) continue; // skip if no name

        const docId = createSafeDocId(item.name);
        const docRef = cityRef.collection(collectionName).doc(docId);

        // Add rating fields to every listing
        batch.set(docRef, {
          ...item,  // spread existing item data
          reviewCount: 0,
          totalRating: 0,
          averageRating: 0
        }, { merge: true });
      }

      await batch.commit();
      console.log(`✅ ${cityId} ${collectionName} uploaded (${collectionData.length} items)`);
    }

    console.log(`🔥 ${cityId} fully uploaded!\n`);
  } catch (error) {
    console.error(`❌ Error uploading ${cityId}:`, error);
  }
}

// Upload all cities
(async () => {
  try {
    for (const [cityId, cityData] of Object.entries(citiesData)) {
      await uploadCity(cityId, cityData);
    }
    console.log("🚀 All cities uploaded successfully!");
    process.exit();
  } catch (error) {
    console.error("❌ Upload process failed:", error);
    process.exit(1);
  }
})();