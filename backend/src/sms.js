const axios = require("axios");

const TEXTBEE_URL =
    "https://api.textbee.dev/api/v1/gateway/send-sms";

async function sendNewEmailSMS({
    phone,
    sender,
    subject
}) {
    try {
        if (!process.env.TEXTBEE_API_KEY) {
            console.log(
                "TextBee SMS skipped: TEXTBEE_API_KEY is missing."
            );
            return null;
        }

        if (!process.env.TEXTBEE_DEVICE_ID) {
            console.log(
                "TextBee SMS skipped: TEXTBEE_DEVICE_ID is missing."
            );
            return null;
        }

        if (!phone) {
            console.log(
                "TextBee SMS skipped: recipient phone number missing."
            );
            return null;
        }

        const mobile = String(phone).replace(/\D/g, "");

        if (mobile.length !== 10) {
            console.log(
                "TextBee SMS skipped: invalid recipient phone number."
            );
            return null;
        }

        const recipient = `+91${mobile}`;

        const message =
            `PhoneMail: New message from ${sender || "PhoneMail user"}. ` +
            `Subject: ${subject || "(No subject)"}`;

        const response = await axios.post(
            TEXTBEE_URL,
            {
                deviceId: process.env.TEXTBEE_DEVICE_ID,
                recipients: [recipient],
                message: message
            },
            {
                headers: {
                    "Content-Type": "application/json",
                    "x-api-key": process.env.TEXTBEE_API_KEY
                },
                timeout: 15000
            }
        );

        console.log(
            "TextBee SMS result:",
            response.data
        );

        return response.data;

    } catch (error) {
        console.error(
            "TextBee SMS error:",
            error.response?.data ||
            error.message
        );

        return null;
    }
}

module.exports = {
    sendNewEmailSMS
};