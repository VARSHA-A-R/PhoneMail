const { Resend } = require("resend");

const resend = new Resend(
    process.env.RESEND_API_KEY
);

async function sendEmail({
    from,
    to,
    subject,
    text,
    html,
    attachments = []
}) {
    if (!process.env.RESEND_API_KEY) {
        throw new Error(
            "RESEND_API_KEY is not configured."
        );
    }

    const payload = {
        from,
        to,
        subject,
        text,

        ...(html
            ? { html }
            : {}),

        ...(attachments.length
            ? { attachments }
            : {})
    };

    const result =
        await resend.emails.send(
            payload
        );

    console.log(
        "Resend email result:",
        result
    );

    if (result?.error) {
        throw new Error(
            result.error.message ||
                "Resend failed."
        );
    }

    return result;
}

module.exports = {
    sendEmail
};