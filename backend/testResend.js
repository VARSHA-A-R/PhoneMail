require("dotenv").config();

const { sendEmail } = require("./src/resend");

async function test() {
    try {
        const result = await sendEmail({
            from: "onboarding@resend.dev",
            to: "delivered@resend.dev",
            subject: "PhoneMail Resend Test",
            text: "This is a test email from the PhoneMail backend."
        });

        console.log("EMAIL SENT SUCCESSFULLY");
        console.log(result);

    } catch (error) {
        console.error("EMAIL TEST FAILED");
        console.error(error);
    }
}

test();