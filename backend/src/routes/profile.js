const express = require("express");
const pool = require("../db");
const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();


// =========================================================
// GET PROFILE
// =========================================================

router.get("/", authMiddleware, async (req, res) => {

    try {

        const result = await pool.query(
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

        if (result.rows.length === 0) {

            return res.status(404).json({
                message: "User not found"
            });
        }

        res.json({
            user: result.rows[0]
        });

    } catch (error) {

        console.error(
            "Profile loading error:",
            error
        );

        res.status(500).json({
            message: "Failed to load profile"
        });
    }
});


// =========================================================
// UPDATE PROFILE
// =========================================================

router.patch("/", authMiddleware, async (req, res) => {

    try {

        const {
            display_name,
            language
        } = req.body;

        const cleanName =
            typeof display_name === "string"
                ? display_name.trim()
                : "";

        const cleanLanguage =
            typeof language === "string"
                ? language.trim()
                : "English";

        if (
            cleanName.length > 50
        ) {

            return res.status(400).json({
                message:
                    "Display name must be 50 characters or less."
            });
        }

        const result = await pool.query(
            `UPDATE users
             SET
                display_name = $1,
                language = $2,
                updated_at = NOW()
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
                cleanName || null,
                cleanLanguage,
                req.user.userId
            ]
        );

        if (result.rows.length === 0) {

            return res.status(404).json({
                message: "User not found"
            });
        }

        res.json({
            message:
                "Profile updated successfully",

            user:
                result.rows[0]
        });

    } catch (error) {

        console.error(
            "Profile update error:",
            error
        );

        res.status(500).json({
            message:
                "Failed to update profile"
        });
    }
});


module.exports = router;