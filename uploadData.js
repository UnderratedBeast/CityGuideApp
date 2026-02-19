// const admin = require("firebase-admin");
// const serviceAccount = require("./serviceAccountKey.json");
// const lagosData = require("./data/lagos.json");

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount)
// });

// const db = admin.firestore();

// async function uploadLagos() {
//   try {
//     const cityRef = db.collection("cities").doc("lagos");

//     // 1️⃣ Upload main city document (without subcollections)
//     const { attractions, hotels, dining, events, ...cityInfo } = lagosData;
//     await cityRef.set(cityInfo, { merge: true });

//     console.log("✅ City data uploaded");

//     // 2️⃣ Upload Attractions
//     if (attractions) {
//       for (const id in attractions) {
//         await cityRef.collection("attractions").doc(id).set(attractions[id]);
//       }
//       console.log("✅ Attractions uploaded");
//     }

//     // 3️⃣ Upload Hotels
//     if (hotels) {
//       for (const id in hotels) {
//         await cityRef.collection("hotels").doc(id).set(hotels[id]);
//       }
//       console.log("✅ Hotels uploaded");
//     }

//     // 4️⃣ Upload Dining
//     if (dining) {
//       for (const id in dining) {
//         await cityRef.collection("dining").doc(id).set(dining[id]);
//       }
//       console.log("✅ Dining uploaded");
//     }

//     // 5️⃣ Upload Events
//     if (events) {
//       for (const id in events) {
//         await cityRef.collection("events").doc(id).set(events[id]);
//       }
//       console.log("✅ Events uploaded");
//     }

//     console.log("🔥 Lagos fully uploaded successfully!");
//   } catch (error) {
//     console.error("❌ Error uploading data:", error);
//   }
// }

// uploadLagos();


const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Import all your city data
const citiesData = {
  lagos: require("./data/lagos.json"),
  abuja: require("./data/abuja.json"),
  port_harcourt: require("./data/port_harcourt.json"),
  kano: require("./data/kano.json"),
  ibadan: require("./data/ibadan.json"),
  onitsha: require("./data/onitsha.json"),
  calabar: require("./data/calabar.json"),
  enugu: require("./data/enugu.json"),
  jos: require("./data/jos.json"),
  kaduna: require("./data/kaduna.json"),
  bauchi: require("./data/bauchi.json"),
  yola: require("./data/yola.json"),
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Generic function
async function uploadCity(cityId, cityData) {
  try {
    const cityRef = db.collection("cities").doc(cityId);

    const { attractions, hotels, dining, events, ...cityInfo } = cityData;
    await cityRef.set(cityInfo, { merge: true });
    console.log(`✅ ${cityId} main city data uploaded`);

    // Upload subcollections
    for (const [key, collection] of Object.entries({ attractions, hotels, dining, events })) {
      if (collection) {
        for (const id in collection) {
          await cityRef.collection(key).doc(id).set(collection[id]);
        }
        console.log(`✅ ${cityId} ${key} uploaded`);
      }
    }

    console.log(`🔥 ${cityId} fully uploaded!`);
  } catch (error) {
    console.error(`❌ Error uploading ${cityId}:`, error);
  }
}

// Upload all cities
(async () => {
  for (const [cityId, cityData] of Object.entries(citiesData)) {
    await uploadCity(cityId, cityData);
  }
})();

