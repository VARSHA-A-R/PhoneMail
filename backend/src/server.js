require("dotenv").config();

const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth");
const mailRoutes = require("./routes/mail");

const app = express();

app.use(
    cors({
        origin: true,
        credentials: true
    })
);

app.use(
    express.json({
        limit: "30mb"
    })
);

app.use(
    express.urlencoded({
        extended: true,
        limit: "30mb"
    })
);


/*
|--------------------------------------------------------------------------
| Health check
|--------------------------------------------------------------------------
*/

app.get("/", (req, res) => {
    res.json({
        message: "PhoneMail backend is running."
    });
});


/*
|--------------------------------------------------------------------------
| API routes
|--------------------------------------------------------------------------
*/

app.use("/api/auth", authRoutes);
app.use("/api/mail", mailRoutes);


/*
|--------------------------------------------------------------------------
| 404 handler
|--------------------------------------------------------------------------
*/

app.use((req, res) => {
    res.status(404).json({
        error: "API route not found."
    });
});


/*
|--------------------------------------------------------------------------
| Error handler
|--------------------------------------------------------------------------
*/

app.use((error, req, res, next) => {
    console.error("Unhandled server error:", error);

    res.status(500).json({
        error: "Internal server error."
    });
});


/*
|--------------------------------------------------------------------------
| Start server
|--------------------------------------------------------------------------
*/

const PORT = Number(process.env.PORT || 3000);

const server = app.listen(PORT, () => {
    console.log(`PhoneMail backend running on http://localhost:${PORT}`);
});

server.on("error", (error) => {
    console.error("Server error:", error);
});