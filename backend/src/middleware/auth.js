const jwt = require("jsonwebtoken");

function authMiddleware(req, res, next) {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader) {
            return res.status(401).json({
                message: "Authentication token is required."
            });
        }

        if (!authHeader.startsWith("Bearer ")) {
            return res.status(401).json({
                message: "Invalid authentication format."
            });
        }

        const token = authHeader.substring(7).trim();

        if (!token) {
            return res.status(401).json({
                message: "Authentication token is missing."
            });
        }

        if (!process.env.JWT_SECRET) {
            console.error("JWT_SECRET is missing from backend .env");

            return res.status(500).json({
                message: "Server authentication configuration is missing."
            });
        }

        const decoded = jwt.verify(
            token,
            process.env.JWT_SECRET
        );

        /*
         * Support both id and userId.
         * This keeps the middleware compatible with
         * the rest of the PhoneMail backend.
         */

        req.user = {
            ...decoded,
            id: decoded.id || decoded.userId,
            userId: decoded.userId || decoded.id
        };

        if (!req.user.id) {
            return res.status(401).json({
                message: "Invalid authentication token."
            });
        }

        next();

    } catch (error) {

        console.error(
            "Authentication middleware error:",
            error.message
        );

        if (error.name === "TokenExpiredError") {
            return res.status(401).json({
                message: "Your session has expired. Please log in again."
            });
        }

        if (error.name === "JsonWebTokenError") {
            return res.status(401).json({
                message: "Invalid authentication token."
            });
        }

        return res.status(401).json({
            message: "Authentication failed."
        });
    }
}

module.exports = authMiddleware;