const axios = require("axios");

async function verifyAccessToken(accessToken) {
    try {
        if (!accessToken || typeof accessToken !== "string" || !accessToken.trim()) {
            throw new Error("MSG91 access token is missing.");
        }

        const authkey = process.env.MSG91_AUTHKEY;
        if (!authkey) {
            throw new Error("MSG91_AUTHKEY is not configured.");
        }

        const cleanToken = accessToken.trim();
        const form = new URLSearchParams();
        form.append("authkey", authkey);
        form.append("access-token", cleanToken);

        const query = new URLSearchParams();
        query.append("authkey", authkey);
        query.append("access-token", cleanToken);

        const url = `https://control.msg91.com/api/v5/widget/verifyAccessToken?${query.toString()}`;

        console.log("MSG91 token verification request: access-token present = true");

        const response = await axios.post(url, form.toString(), {
            headers: {
                authkey,
                "access-token": cleanToken,
                Accept: "application/json",
                "Content-Type": "application/x-www-form-urlencoded"
            },
            timeout: 15000
        });

        console.log("MSG91 access-token verification result:", response.data);
        return response.data;
    } catch (error) {
        console.error("MSG91 verification error:", error.response?.data || error.message);
        throw error;
    }
}

module.exports = { verifyAccessToken };
