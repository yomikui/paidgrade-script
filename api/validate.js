export default function handler(req, res) {
    const { key } = req.query;

    const validKeys = [
        "ABC123",
        "DEF456",
        "VIP-KEY-001"
    ];

    if (!key) {
        return res.status(400).json({ valid: false, error: "No key provided" });
    }

    if (validKeys.includes(key)) {
        return res.status(200).json({ valid: true });
    } else {
        return res.status(401).json({ valid: false });
    }
}

