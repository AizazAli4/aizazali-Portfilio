// ==========================================
// GA4 ANALYTICS — SECURE SERVERLESS PROXY
// ==========================================
// Runs on Netlify, never in the browser. It:
//   1. Verifies the caller is a logged-in admin (checks the Supabase session token)
//   2. Calls the Google Analytics Data API using a service account
//   3. Returns the raw report shapes the admin dashboard already knows how to render
//
// Required environment variables (Netlify -> Site configuration -> Environment variables):
//   GA4_PROPERTY_ID          - numeric GA4 property id (Admin -> Property Settings)
//   GA4_SERVICE_ACCOUNT_JSON - the full service-account JSON key, pasted as one string
//   SUPABASE_URL              - same URL used in supabaseClient.js
//   SUPABASE_ANON_KEY         - same anon/public key used in supabaseClient.js
// ==========================================

const { BetaAnalyticsDataClient } = require("@google-analytics/data");
const { createClient } = require("@supabase/supabase-js");

const PROPERTY_ID = process.env.GA4_PROPERTY_ID;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

function getCredentials() {
  const raw = process.env.GA4_SERVICE_ACCOUNT_JSON;
  if (!raw) return null;
  try { return JSON.parse(raw); } catch { return null; }
}

exports.handler = async (event) => {
  const headers = { "Content-Type": "application/json" };

  if (event.httpMethod !== "GET") {
    return { statusCode: 405, headers, body: JSON.stringify({ error: "Method not allowed" }) };
  }

  // --- 1. Require a valid logged-in admin session (Supabase JWT) ---
  const authHeader = event.headers.authorization || event.headers.Authorization || "";
  const token = authHeader.replace(/^Bearer\s+/i, "");
  if (!token || !SUPABASE_URL || !SUPABASE_ANON_KEY) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: "Not authenticated." }) };
  }
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  const { data: userData, error: userErr } = await supabase.auth.getUser(token);
  if (userErr || !userData?.user) {
    return { statusCode: 401, headers, body: JSON.stringify({ error: "Not authenticated." }) };
  }

  // --- 2. Bail out with a clear message if GA4 hasn't been configured yet ---
  const credentials = getCredentials();
  if (!credentials || !PROPERTY_ID) {
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        error: "GA4_PROPERTY_ID and/or GA4_SERVICE_ACCOUNT_JSON are not set in Netlify environment variables yet.",
      }),
    };
  }

  // --- 3. Pull real traffic data from Google Analytics ---
  try {
    const client = new BetaAnalyticsDataClient({ credentials });
    const property = `properties/${PROPERTY_ID}`;

    const [dailyRes, summaryRes, countryRes, pageRes, deviceRes] = await Promise.all([
      // Daily active users + pageviews, last 14 days — powers the trend chart.
      client.runReport({
        property,
        dateRanges: [{ startDate: "13daysAgo", endDate: "today" }],
        dimensions: [{ name: "date" }],
        metrics: [{ name: "activeUsers" }, { name: "screenPageViews" }],
        orderBys: [{ dimension: { dimensionName: "date" } }],
      }),
      // Current 28-day period vs the prior 28-day period, in ONE call.
      // GA4 automatically adds a "date_range_0" / "date_range_1" pseudo-dimension
      // as dimensionValues[0] whenever two dateRanges are supplied.
      client.runReport({
        property,
        dateRanges: [
          { startDate: "27daysAgo", endDate: "today" },
          { startDate: "55daysAgo", endDate: "28daysAgo" },
        ],
        metrics: [
          { name: "activeUsers" },
          { name: "newUsers" },
          { name: "sessions" },
          { name: "screenPageViews" },
          { name: "averageSessionDuration" },
          { name: "bounceRate" },
        ],
      }),
      client.runReport({
        property,
        dateRanges: [{ startDate: "27daysAgo", endDate: "today" }],
        dimensions: [{ name: "country" }],
        metrics: [{ name: "activeUsers" }],
        orderBys: [{ metric: { metricName: "activeUsers" }, desc: true }],
        limit: 6,
      }),
      client.runReport({
        property,
        dateRanges: [{ startDate: "27daysAgo", endDate: "today" }],
        dimensions: [{ name: "pagePath" }],
        metrics: [{ name: "screenPageViews" }],
        orderBys: [{ metric: { metricName: "screenPageViews" }, desc: true }],
        limit: 6,
      }),
      client.runReport({
        property,
        dateRanges: [{ startDate: "27daysAgo", endDate: "today" }],
        dimensions: [{ name: "deviceCategory" }],
        metrics: [{ name: "activeUsers" }],
        orderBys: [{ metric: { metricName: "activeUsers" }, desc: true }],
      }),
    ]);

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        dailyReport: dailyRes[0],
        summaryReport: summaryRes[0],
        countryReport: countryRes[0],
        pageReport: pageRes[0],
        deviceReport: deviceRes[0],
      }),
    };
  } catch (err) {
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};
