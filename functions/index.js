const functions = require("firebase-functions");
const algoliasearch = require("algoliasearch");

const ALGOLIA_APP_ID = "3KOA1FDQVO";
const ALGOLIA_ADMIN_KEY = "bbb4119176cda5702e93e08ac4f5e122";
const ALGOLIA_INDEX_NAME = "Airports";

const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);
const index = client.initIndex(ALGOLIA_INDEX_NAME);

exports.searchAirports = functions.https.onCall(async (data, context) => {
  // 🚩 Fixed circular JSON error by logging selectively
  console.log("🚦 Received data from client:",
      {query: data.query, type: data.type});

  const query = data?.query;
  const type = data?.type;

  console.log("📥 Extracted Query:", query);
  console.log("📥 Extracted Type:", type);

  if (!query || !type) {
    console.error("❌ Missing 'query' or 'type'", {query, type});
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing 'query' or 'type'. Received data: " +
        JSON.stringify({query, type}),
    );
  }

  let filters = "flightable:true";
  if (type === "airport") filters += " AND iata_type:airport";
  else if (type === "city") filters += " AND iata_type:city";
  else if (type === "country") filters += " AND iata_type:country";

  console.log("🔧 Algolia filters:", filters);

  try {
    const {hits} = await index.search(query, {
      hitsPerPage: 10,
      filters,
    });

    const results = hits.map((hit) => {
      const name = hit.name_translations?.en || hit.name || "";
      const city = hit.city || "";
      const country = hit.country || "";
      const code = hit.code || "";
      return `${name} — ${city}, ${country} (${code})`;
    });

    console.log("✅ Algolia Results:", results);

    return results;
  } catch (err) {
    console.error("❌ Algolia search error:", err);
    throw new functions.https.HttpsError("internal", "Search failed");
  }
});
