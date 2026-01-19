export default function handler(req, res) {
    if (req.method !== "POST") {
        return res.status(405).json({ valid: false });
    }

    const { key } = req.body;

    const validKeys = [
        "ABC123",
        "XlvyTKPIezoKMyNHAZbIYLYaeWMZZTkm",
        "M9vxNDS7V8eyg3HXP7zZxddM"
    ];

    if (!key) {
        return res.status(400).json({ valid: false, error: "No key provided" });
    }

    if (validKeys.includes(key)) {
        return res.status(200).json({ valid: true });
    }

    return res.status(401).json({ valid: false });
}
