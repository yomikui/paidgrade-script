// api/validate.js
import { Client } from "pg";

export default async function handler(req, res) {
  // Only allow POST
  if (req.method !== "POST") {
    return res.status(405).json({ valid: false, error: "Method not allowed" });
  }

  const { key, hwid, script } = req.body;

  if (!key || !hwid || !script) {
    return res.status(400).json({ valid: false, error: "Missing fields" });
  }

  // Create a new client for this request
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
  });

  try {
    await client.connect();

    // Fetch the key
    const { rows } = await client.query(
      "SELECT * FROM licenses WHERE key = $1",
      [key]
    );

    const keyData = rows[0];

    if (!keyData) {
      return res.status(200).json({ valid: false, error: "Key not found" });
    }

    // Check expiration
    if (Date.now() > Number(keyData.expires)) {
      return res.status(200).json({ valid: false, error: "Key expired" });
    }

    // Check HWID
    if (keyData.hwid && keyData.hwid !== hwid) {
      return res.status(200).json({ valid: false, error: "HWID mismatch" });
    }

    // Lock HWID if first time
    if (!keyData.hwid) {
      await client.query(
        "UPDATE licenses SET hwid = $1, activatedAt = $2 WHERE key = $3",
        [hwid, Date.now(), key]
      );
    }

    // Respond with valid + activation timestamp
    return res.status(200).json({
      valid: true,
      activatedAt: keyData.activatedat || Date.now(),
    });
  } catch (err) {
    console.error("Validate API error:", err);
    return res.status(500).json({ valid: false, error: "Server error" });
  } finally {
    await client.end();
  }
}

