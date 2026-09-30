const express = require("express");

const jwt = require("jsonwebtoken");

const pool = require("../db");

const { verifyAccessToken } = require("../msg91");

const authMiddleware = require("../middleware/authMiddleware");



const router = express.Router();





// =========================================================

// =========================================================
// CHECK PHONE ACCOUNT
// =========================================================

router.get("/check-phone", async (req, res) => {
    try {
        const phone = String(req.query.phone || "").replace(/\D/g, "");
        if (!/^\d{10}$/.test(phone)) {
            return res.status(400).json({ message: "Enter a valid 10-digit phone number." });
        }
        const result = await pool.query(`SELECT id FROM users WHERE phone_number = $1 LIMIT 1`, [phone]);
        return res.status(200).json({ exists: result.rows.length > 0 });
    } catch (error) {
        console.error("Check phone error:", error);
        return res.status(500).json({ message: "Unable to check the account." });
    }
});


// REGISTER

// =========================================================



router.post("/register", async (req, res) => {

    try {



        let {
            phone,
            accessToken
        } = req.body;

        phone = String(phone || "").replace(/\D/g, "");





        if (!phone) {

            return res.status(400).json({

                message:

                    "Phone number is required"

            });

        }





        if (!accessToken) {

            return res.status(401).json({

                message:

                    "MSG91 access token is required"

            });

        }





        // Verify OTP token with MSG91

        const msg91Result =

            await verifyAccessToken(

                accessToken

            );





        console.log(

            "MSG91 verification result:",

            msg91Result

        );





        if (
            !msg91Result ||
            String(msg91Result.type || msg91Result.status || "").toLowerCase() !== "success"
        ) {
            console.error("MSG91 rejected registration access token:", msg91Result);
            return res.status(401).json({
                message: msg91Result?.message || "Phone number verification failed"
            });
        }





        const emailAddress =

            `${phone}@phonemail.com`;





        // Check duplicate phone number

        const existingUser =

            await pool.query(

                `SELECT id

                 FROM users

                 WHERE phone_number = $1`,

                [phone]

            );





        if (

            existingUser.rows.length > 0

        ) {

            return res.status(409).json({

                message:

                    "Phone number already registered"

            });

        }





        // Create user

        const result =

            await pool.query(

                `INSERT INTO users

                    (

                        phone_number,

                        email_address,

                        display_name,

                        language,

                        is_verified

                    )

                 VALUES

                    ($1, $2, $3, $4, $5)

                 RETURNING

                    id,

                    phone_number,

                    email_address,

                    display_name,

                    language,

                    is_verified,

                    created_at`,

                [

                    phone,

                    emailAddress,

                    "",

                    "en",

                    true

                ]

            );





        // Create JWT

        const token =

            jwt.sign(

                {

                    userId:

                        result.rows[0].id,



                    phone:

                        result.rows[0].phone_number

                },



                process.env.JWT_SECRET,



                {

                    expiresIn: "7d"

                }

            );





        res.status(201).json({



            message:

                "User registered successfully",



            token,



            user:

                result.rows[0]



        });





    } catch (error) {



        console.error(

            "Registration error:",

            error

        );





        res.status(500).json({



            message:

                "Registration failed"



        });



    }

});





// =========================================================

// LOGIN

// =========================================================



router.post("/login", async (req, res) => {

    try {



        let {
            phone,
            accessToken
        } = req.body;

        phone = String(phone || "").replace(/\D/g, "");





        if (!phone) {

            return res.status(400).json({

                message:

                    "Phone number is required"

            });

        }





        if (!accessToken) {

            return res.status(401).json({

                message:

                    "MSG91 access token is required"

            });

        }





        // Verify OTP token with MSG91

        const msg91Result =

            await verifyAccessToken(

                accessToken

            );





        console.log(

            "MSG91 login verification:",

            msg91Result

        );





        if (
            !msg91Result ||
            String(msg91Result.type || msg91Result.status || "").toLowerCase() !== "success"
        ) {
            console.error("MSG91 rejected login access token:", msg91Result);
            return res.status(401).json({
                message: msg91Result?.message || "Phone verification failed"
            });
        }





        // Find user

        const result =

            await pool.query(

                `SELECT

                    id,

                    phone_number,

                    email_address,

                    display_name,

                    language,

                    is_verified,

                    created_at

                 FROM users

                 WHERE phone_number = $1`,

                [phone]

            );





        if (

            result.rows.length === 0

        ) {

            return res.status(404).json({

                message:

                    "Phone number is not registered"

            });

        }





        // Create JWT

        const token =

            jwt.sign(

                {

                    userId:

                        result.rows[0].id,



                    phone:

                        result.rows[0].phone_number

                },



                process.env.JWT_SECRET,



                {

                    expiresIn: "7d"

                }

            );





        res.status(200).json({



            message:

                "Login successful",



            token,



            user:

                result.rows[0]



        });





    } catch (error) {



        console.error(

            "Login error:",

            error

        );





        res.status(500).json({



            message:

                "Login failed"



        });



    }

});





// =========================================================

// GET PROFILE

// =========================================================



router.get(

    "/profile",

    authMiddleware,

    async (req, res) => {



        try {



            const result =

                await pool.query(

                    `SELECT

                        id,

                        phone_number,

                        email_address,

                        display_name,

                        language,

                        is_verified,

                        created_at

                     FROM users

                     WHERE id = $1`,

                    [req.user.userId]

                );





            if (

                result.rows.length === 0

            ) {



                return res.status(404).json({



                    message:

                        "User not found"



                });



            }





            res.status(200).json({



                user:

                    result.rows[0]



            });





        } catch (error) {



            console.error(

                "Get profile error:",

                error

            );





            res.status(500).json({



                message:

                    "Failed to load profile"



            });



        }



    }

);





// =========================================================

// UPDATE PROFILE

// =========================================================



router.patch(

    "/profile",

    authMiddleware,

    async (req, res) => {



        try {



            const {

                displayName,

                language

            } = req.body;





            // -----------------------------------------------

            // VALIDATE LANGUAGE

            // -----------------------------------------------



            const allowedLanguages = [

                "en",

                "ta",

                "hi"

            ];





            if (

                language !== undefined &&

                !allowedLanguages.includes(

                    language

                )

            ) {



                return res.status(400).json({



                    message:

                        "Invalid language. Use en, ta, or hi."



                });



            }





            // -----------------------------------------------

            // VALIDATE DISPLAY NAME

            // -----------------------------------------------



            if (

                displayName !== undefined &&

                typeof displayName !== "string"

            ) {



                return res.status(400).json({



                    message:

                        "Display name must be text."



                });



            }





            const cleanDisplayName =

                displayName !== undefined

                    ? displayName.trim()

                    : undefined;





            if (

                cleanDisplayName !== undefined &&

                cleanDisplayName.length > 50

            ) {



                return res.status(400).json({



                    message:

                        "Display name must be 50 characters or less."



                });



            }





            // -----------------------------------------------

            // UPDATE DATABASE

            // -----------------------------------------------



            const result =

                await pool.query(

                    `UPDATE users

                     SET

                        display_name =

                            COALESCE($1, display_name),



                        language =

                            COALESCE($2, language),



                        updated_at =

                            CURRENT_TIMESTAMP



                     WHERE id = $3



                     RETURNING

                        id,

                        phone_number,

                        email_address,

                        display_name,

                        language,

                        is_verified,

                        created_at`,

                    [

                        cleanDisplayName !== undefined

                            ? cleanDisplayName

                            : null,



                        language !== undefined

                            ? language

                            : null,



                        req.user.userId

                    ]

                );





            if (

                result.rows.length === 0

            ) {



                return res.status(404).json({



                    message:

                        "User not found"



                });



            }





            res.status(200).json({



                message:

                    "Profile updated successfully",



                user:

                    result.rows[0]



            });





        } catch (error) {



            console.error(

                "Update profile error:",

                error

            );





            res.status(500).json({



                message:

                    "Failed to update profile"



            });



        }



    }

);





module.exports = router;