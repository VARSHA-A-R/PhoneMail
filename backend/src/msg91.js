const axios = require("axios");

async function verifyAccessToken(accessToken) {
    if (!accessToken || typeof accessToken !== "string") {
        throw new Error("MSG91 access token is missing.");
    }

    const authkey = process.env.MSG91_AUTHKEY;

    if (!authkey || typeof authkey !== "string") {
        throw new Error("MSG91_AUTHKEY is not configured.");
    }

    const cleanToken = accessToken.trim();

    if (!cleanToken) {
        throw new Error("MSG91 access token is empty.");
    }

    try {
        console.log("MSG91: verifying access token...");
        console.log("MSG91: access token received from app: YES");

        const response = await axios.post(
            "https://control.msg91.com/api/v5/widget/verifyAccessToken",
            {
                authkey: authkey.trim(),
                "access-token": cleanToken
            },
            {
                headers: {
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                },
                timeout: 15000
            }
        );

        console.log(
            "MSG91 access-token verification response:",
            response.data
        );

        return response.data;

    } catch (error) {
        console.error(
            "MSG91 access-token verification failed:",
            error.response?.data || error.message
        );

        throw new Error(
            error.response?.data?.message ||
            error.response?.data?.error ||
            "MSG91 access-token verification failed."
        );
    }
}

module.exports = {
    verifyAccessToken
};