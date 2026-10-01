const express = require("express");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const pool = require("../db");
const authMiddleware = require("../middleware/authMiddleware");
const { sendEmail } = require("../resend");
const { sendNewEmailSMS } = require("../sms");

const router = express.Router();

const uploadDir = path.join(__dirname, "../../uploads");

if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => {
    cb(null, uploadDir);
  },

  filename: (_req, file, cb) => {
    const ext = path.extname(file.originalname);

    const name = `${Date.now()}-${Math.random()
      .toString(36)
      .slice(2, 10)}${ext}`;

    cb(null, name);
  },
});

// ============================================================
// ATTACHMENT LIMITS
// Maximum 100 MB per file
// Maximum 5 files per message
// ============================================================

const MAX_ATTACHMENT_SIZE = 100 * 1024 * 1024;

const upload = multer({
  storage,

  limits: {
    fileSize: MAX_ATTACHMENT_SIZE,
    files: 5,
  },
});

// ============================================================
// HELPERS
// ============================================================

function userId(req) {
  return req.user?.id || req.user?.userId;
}

function normalizePhone(value) {
  return String(value || "")
    .replace(/\D/g, "")
    .slice(-10);
}

function emailForPhone(phone) {
  return `${normalizePhone(phone)}@phonemail.com`;
}

function cleanupFiles(files) {
  for (const file of files || []) {
    try {
      if (file.path && fs.existsSync(file.path)) {
        fs.unlinkSync(file.path);
      }
    } catch (e) {
      console.error(
        "Failed to clean uploaded file:",
        e.message
      );
    }
  }
}

// ============================================================
// SEND EXTERNAL EMAIL
// ============================================================

async function sendExternalEmail({
  sender,
  receiver,
  subject,
  body,
  files,
}) {
  try {
    const attachments = [];

    for (const file of files || []) {
      if (fs.existsSync(file.path)) {
        attachments.push({
          filename: file.originalname,
          content: fs.readFileSync(file.path),
        });
      }
    }

    await sendEmail({
      from:
        sender.email_address ||
        emailForPhone(sender.phone_number),

      to:
        receiver.email_address ||
        emailForPhone(receiver.phone_number),

      subject: subject || "(No subject)",

      text: body || "",

      attachments,
    });
  } catch (error) {
    console.error(
      "Resend email failed:",
      error.response?.data ||
        error.message ||
        error
    );
  }
}

// ============================================================
// INBOX
// ============================================================

router.get(
  "/inbox",
  authMiddleware,
  async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT
            m.id,
            m.conversation_id,
            m.sender_id,
            m.subject,
            m.body,
            m.is_read,
            m.is_starred,
            m.reply_to_message_id,
            m.created_at,

            u.phone_number AS sender_phone,
            u.email_address AS sender_email,
            u.display_name AS sender_name

         FROM messages m

         JOIN users u
           ON u.id = m.sender_id

         WHERE m.is_deleted = false
           AND m.is_spam = false

           AND EXISTS (
             SELECT 1
             FROM message_recipients mr
             WHERE mr.message_id = m.id
               AND mr.recipient_id = $1
           )

         ORDER BY m.created_at DESC`,
        [userId(req)]
      );

      res.json({
        messages: result.rows,
      });
    } catch (error) {
      console.error(
        "Inbox error:",
        error
      );

      res.status(500).json({
        message: "Failed to load inbox.",
      });
    }
  }
);

// ============================================================
// SENT
// ============================================================

router.get(
  "/sent",
  authMiddleware,
  async (req, res) => {
    try {
      const result = await pool.query(
        `SELECT
            m.id,
            m.conversation_id,
            m.sender_id,
            m.subject,
            m.body,
            m.is_read,
            m.is_starred,
            m.reply_to_message_id,
            m.created_at,

            u.phone_number AS recipient_phone,
            u.email_address AS recipient_email,
            u.display_name AS recipient_name

         FROM messages m

         JOIN message_recipients mr
           ON mr.message_id = m.id

         JOIN users u
           ON u.id = mr.recipient_id

         WHERE m.sender_id = $1
           AND m.is_deleted = false

         ORDER BY m.created_at DESC`,
        [userId(req)]
      );

      res.json({
        messages: result.rows,
      });
    } catch (error) {
      console.error(
        "Sent error:",
        error
      );

      res.status(500).json({
        message: "Failed to load sent mail.",
      });
    }
  }
);

// ============================================================
// CONVERSATION
// ============================================================

router.get(
  "/conversation/:id",
  authMiddleware,
  async (req, res) => {
    try {
      const uid = userId(req);

      const conversationId =
        Number(req.params.id);

      const member = await pool.query(
        `SELECT 1
         FROM conversation_members
         WHERE conversation_id = $1
           AND user_id = $2
         LIMIT 1`,
        [
          conversationId,
          uid,
        ]
      );

      if (!member.rowCount) {
        return res.status(403).json({
          message:
            "Not a conversation member.",
        });
      }

      const result = await pool.query(
        `SELECT
            m.id,
            m.conversation_id,
            m.sender_id,
            m.subject,
            m.body,
            m.is_read,
            m.is_starred,
            m.reply_to_message_id,
            m.created_at,

            u.phone_number AS sender_phone,
            u.email_address AS sender_email,
            u.display_name AS sender_name

         FROM messages m

         JOIN users u
           ON u.id = m.sender_id

         WHERE m.conversation_id = $1
           AND m.is_deleted = false

         ORDER BY m.created_at ASC`,
        [conversationId]
      );

      const ids =
        result.rows.map(
          (r) => r.id
        );

      let attachments = [];

      if (ids.length) {
        const a = await pool.query(
          `SELECT
              id,
              message_id,
              file_name,
              mime_type,
              file_size,
              created_at

           FROM message_attachments

           WHERE message_id = ANY($1::int[])

           ORDER BY created_at ASC`,
          [ids]
        );

        attachments = a.rows;
      }

      res.json({
        conversationId,

        messages: result.rows.map(
          (m) => ({
            ...m,

            attachments:
              attachments.filter(
                (a) =>
                  a.message_id === m.id
              ),
          })
        ),
      });
    } catch (error) {
      console.error(
        "Conversation error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to load conversation.",
      });
    }
  }
);

// ============================================================
// SEND NEW MAIL
// ============================================================

router.post(
  "/send",
  authMiddleware,
  upload.array("attachments", 5),
  async (req, res) => {
    const client =
      await pool.connect();

    try {
      const uid = userId(req);

      const recipientValue =
        String(
          req.body.recipient || ""
        ).trim();

      const subject =
        String(
          req.body.subject || ""
        ).trim() || "(No subject)";

      const body =
        String(
          req.body.body || ""
        ).trim();

      const files =
        req.files || [];

      if (!uid) {
        cleanupFiles(files);

        return res.status(401).json({
          message: "Unauthorized.",
        });
      }

      if (!recipientValue) {
        cleanupFiles(files);

        return res.status(400).json({
          message:
            "Recipient is required.",
        });
      }

      // Message can contain text,
      // attachments, or both.
      if (
        !body &&
        files.length === 0
      ) {
        cleanupFiles(files);

        return res.status(400).json({
          message:
            "Write your message or attach a file.",
        });
      }

      const senderResult =
        await client.query(
          `SELECT
              id,
              phone_number,
              email_address,
              display_name

           FROM users

           WHERE id = $1

           LIMIT 1`,
          [uid]
        );

      const receiverResult =
        await client.query(
          `SELECT
              id,
              phone_number,
              email_address,
              display_name

           FROM users

           WHERE phone_number = $1
              OR email_address = $1

           LIMIT 1`,
          [recipientValue]
        );

      if (!senderResult.rowCount) {
        cleanupFiles(files);

        return res.status(404).json({
          message:
            "Sender account not found.",
        });
      }

      if (!receiverResult.rowCount) {
        cleanupFiles(files);

        return res.status(404).json({
          message:
            "Recipient is not registered with PhoneMail.",
        });
      }

      const sender =
        senderResult.rows[0];

      const receiver =
        receiverResult.rows[0];

      if (
        Number(sender.id) ===
        Number(receiver.id)
      ) {
        cleanupFiles(files);

        return res.status(400).json({
          message:
            "You cannot send an email to yourself.",
        });
      }

      const receiverEmail =
        receiver.email_address ||
        emailForPhone(
          receiver.phone_number
        );

      await client.query("BEGIN");

      // Create conversation
      const conversation =
        await client.query(
          `INSERT INTO conversations
             (type, subject)

           VALUES ($1, $2)

           RETURNING id`,
          [
            "direct",
            subject,
          ]
        );

      const conversationId =
        conversation.rows[0].id;

      // Add members
      await client.query(
        `INSERT INTO conversation_members
           (conversation_id, user_id)

         VALUES
           ($1, $2),
           ($1, $3)`,
        [
          conversationId,
          sender.id,
          receiver.id,
        ]
      );

      // Create message
      const message =
        await client.query(
          `INSERT INTO messages
             (
               conversation_id,
               sender_id,
               subject,
               body,
               is_read,
               is_starred,
               is_deleted,
               is_spam,
               reply_to_message_id
             )

           VALUES
             (
               $1,
               $2,
               $3,
               $4,
               false,
               false,
               false,
               false,
               NULL
             )

           RETURNING id, created_at`,
          [
            conversationId,
            sender.id,
            subject,
            body,
          ]
        );

      const messageId =
        message.rows[0].id;

      // Add recipient
      await client.query(
        `INSERT INTO message_recipients
           (
             message_id,
             recipient_id,
             recipient_email,
             recipient_type
           )

         VALUES
           ($1, $2, $3, $4)`,
        [
          messageId,
          receiver.id,
          receiverEmail,
          "to",
        ]
      );

      // Save attachments
      for (const file of files) {
        await client.query(
          `INSERT INTO message_attachments
             (
               message_id,
               file_name,
               stored_name,
               mime_type,
               file_size,
               file_path
             )

           VALUES
             ($1, $2, $3, $4, $5, $6)`,
          [
            messageId,
            file.originalname,
            file.filename,
            file.mimetype,
            file.size,
            file.path,
          ]
        );
      }

      await client.query(
        `UPDATE conversations

         SET updated_at = NOW()

         WHERE id = $1`,
        [conversationId]
      );

      await client.query(
        "COMMIT"
      );

      // External email
      await sendExternalEmail({
        sender,
        receiver,
        subject,
        body,
        files,
      });

      // SMS notification
      try {
        await sendNewEmailSMS({
          phone:
            receiver.phone_number,

          sender:
            sender.display_name ||
            sender.phone_number,

          subject,
        });
      } catch (e) {
        console.error(
          "SMS notification failed:",
          e.message
        );
      }

      res.status(201).json({
        message:
          "Email sent successfully.",

        conversationId,

        messageId,

        attachments:
          files.map((f) => ({
            file_name:
              f.originalname,

            mime_type:
              f.mimetype,

            file_size:
              f.size,
          })),
      });
    } catch (error) {
      try {
        await client.query(
          "ROLLBACK"
        );
      } catch (_) {}

      cleanupFiles(req.files);

      console.error(
        "Send error:",
        error
      );

      res.status(500).json({
        message:
          error.message ||
          "Failed to send email.",
      });
    } finally {
      client.release();
    }
  }
);

// ============================================================
// REPLY
// ============================================================

router.post(
  "/reply",
  authMiddleware,
  upload.array("attachments", 5),
  async (req, res) => {
    const client =
      await pool.connect();

    try {
      const uid = userId(req);

      const originalMessageId =
        Number(
          req.body.originalMessageId
        );

      const body =
        String(
          req.body.body || ""
        ).trim();

      const files =
        req.files || [];

      if (!uid) {
        cleanupFiles(files);

        return res.status(401).json({
          message: "Unauthorized.",
        });
      }

      if (!originalMessageId) {
        cleanupFiles(files);

        return res.status(400).json({
          message:
            "Original message is required.",
        });
      }

      // Reply can contain:
      // text only
      // attachment only
      // text + attachments
      if (
        !body &&
        files.length === 0
      ) {
        cleanupFiles(files);

        return res.status(400).json({
          message:
            "Write a reply or attach a file.",
        });
      }

      const originalResult =
        await client.query(
          `SELECT
              m.id,
              m.conversation_id,
              m.sender_id,
              m.subject,

              u.phone_number,
              u.email_address,
              u.display_name

           FROM messages m

           JOIN users u
             ON u.id = m.sender_id

           WHERE m.id = $1

           LIMIT 1`,
          [originalMessageId]
        );

      if (!originalResult.rowCount) {
        cleanupFiles(files);

        return res.status(404).json({
          message:
            "Original message not found.",
        });
      }

      const original =
        originalResult.rows[0];

      // Verify conversation membership
      const member =
        await client.query(
          `SELECT 1

           FROM conversation_members

           WHERE conversation_id = $1
             AND user_id = $2

           LIMIT 1`,
          [
            original.conversation_id,
            uid,
          ]
        );

      if (!member.rowCount) {
        cleanupFiles(files);

        return res.status(403).json({
          message:
            "You are not part of this conversation.",
        });
      }

      if (
        Number(original.sender_id) ===
        Number(uid)
      ) {
        cleanupFiles(files);

        return res.status(400).json({
          message:
            "You cannot reply to your own message.",
        });
      }

      const senderResult =
        await client.query(
          `SELECT
              id,
              phone_number,
              email_address,
              display_name

           FROM users

           WHERE id = $1

           LIMIT 1`,
          [uid]
        );

      if (!senderResult.rowCount) {
        cleanupFiles(files);

        return res.status(404).json({
          message:
            "Sender account not found.",
        });
      }

      const sender =
        senderResult.rows[0];

      // Prevent duplicate reply
      const duplicate =
        await client.query(
          `SELECT id

           FROM messages

           WHERE conversation_id = $1
             AND sender_id = $2
             AND reply_to_message_id = $3

           LIMIT 1`,
          [
            original.conversation_id,
            uid,
            originalMessageId,
          ]
        );

      if (duplicate.rowCount) {
        cleanupFiles(files);

        return res.status(400).json({
          message:
            "You have already replied to this message.",
        });
      }

      let replySubject =
        original.subject ||
        "(No subject)";

      if (
        !replySubject
          .toLowerCase()
          .startsWith("re:")
      ) {
        replySubject =
          `Re: ${replySubject}`;
      }

      const receiverEmail =
        original.email_address ||
        emailForPhone(
          original.phone_number
        );

      await client.query(
        "BEGIN"
      );

      // Insert reply
      const reply =
        await client.query(
          `INSERT INTO messages
             (
               conversation_id,
               sender_id,
               subject,
               body,
               is_read,
               is_starred,
               is_deleted,
               is_spam,
               reply_to_message_id
             )

           VALUES
             (
               $1,
               $2,
               $3,
               $4,
               false,
               false,
               false,
               false,
               $5
             )

           RETURNING id, created_at`,
          [
            original.conversation_id,
            sender.id,
            replySubject,
            body,
            originalMessageId,
          ]
        );

      const replyId =
        reply.rows[0].id;

      // Recipient
      await client.query(
        `INSERT INTO message_recipients
           (
             message_id,
             recipient_id,
             recipient_email,
             recipient_type
           )

         VALUES
           ($1, $2, $3, $4)`,
        [
          replyId,
          original.sender_id,
          receiverEmail,
          "to",
        ]
      );

      // Reply attachments
      for (const file of files) {
        await client.query(
          `INSERT INTO message_attachments
             (
               message_id,
               file_name,
               stored_name,
               mime_type,
               file_size,
               file_path
             )

           VALUES
             ($1, $2, $3, $4, $5, $6)`,
          [
            replyId,
            file.originalname,
            file.filename,
            file.mimetype,
            file.size,
            file.path,
          ]
        );
      }

      await client.query(
        `UPDATE conversations

         SET
           subject = $1,
           updated_at = NOW()

         WHERE id = $2`,
        [
          replySubject,
          original.conversation_id,
        ]
      );

      await client.query(
        "COMMIT"
      );

      // External email
      await sendExternalEmail({
        sender,

        receiver: {
          phone_number:
            original.phone_number,

          email_address:
            receiverEmail,
        },

        subject: replySubject,

        body,

        files,
      });

      // SMS notification
      try {
        await sendNewEmailSMS({
          phone:
            original.phone_number,

          sender:
            sender.display_name ||
            sender.phone_number,

          subject: replySubject,
        });
      } catch (e) {
        console.error(
          "Reply SMS failed:",
          e.message
        );
      }

      res.status(201).json({
        message:
          "Reply sent successfully.",

        messageId: replyId,

        conversationId:
          original.conversation_id,

        attachments:
          files.map((f) => ({
            file_name:
              f.originalname,

            mime_type:
              f.mimetype,

            file_size:
              f.size,
          })),
      });
    } catch (error) {
      try {
        await client.query(
          "ROLLBACK"
        );
      } catch (_) {}

      cleanupFiles(req.files);

      console.error(
        "Reply error:",
        error
      );

      res.status(500).json({
        message:
          error.message ||
          "Failed to send reply.",
      });
    } finally {
      client.release();
    }
  }
);

// ============================================================
// MARK AS READ
// ============================================================

router.patch(
  "/message/:id/read",
  authMiddleware,
  async (req, res) => {
    try {
      const result =
        await pool.query(
          `UPDATE messages m

           SET is_read = true

           WHERE m.id = $1

             AND EXISTS (
               SELECT 1

               FROM message_recipients mr

               WHERE mr.message_id = m.id
                 AND mr.recipient_id = $2
             )

           RETURNING m.id`,
          [
            Number(req.params.id),
            userId(req),
          ]
        );

      if (!result.rowCount) {
        return res.status(404).json({
          message:
            "Message not found.",
        });
      }

      res.json({
        message:
          "Message marked as read.",
      });
    } catch (error) {
      console.error(
        "Read error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to mark message as read.",
      });
    }
  }
);

// =========================================================
// STAR
// =========================================================

router.patch(
    "/:id/star",
    authMiddleware,
    async (req, res) => {

        try {

            const {
                is_starred
            } = req.body;

            const result =
                await pool.query(
                    `UPDATE messages m
                     SET is_starred = $1
                     WHERE
                        m.id = $2
                        AND (
                            m.sender_id = $3
                            OR EXISTS (
                                SELECT 1
                                FROM message_recipients mr
                                WHERE
                                    mr.message_id = m.id
                                    AND mr.recipient_id = $3
                            )
                        )
                     RETURNING id, is_starred`,
                    [
                        Boolean(is_starred),
                        Number(req.params.id),
                        req.user.userId
                    ]
                );

            if (
                result.rows.length === 0
            ) {

                return res.status(404).json({
                    message:
                        "Message not found."
                });

            }

            res.json({

                message:
                    "Star status updated.",

                data:
                    result.rows[0]

            });

        } catch (error) {

            console.error(
                "Star status error:",
                error
            );

            res.status(500).json({

                message:
                    "Failed to update star status."

            });

        }

    }
);
// ============================================================
// DOWNLOAD ATTACHMENT
// ============================================================

router.get(
  "/attachment/:id",
  authMiddleware,
  async (req, res) => {
    try {
      const result =
        await pool.query(
          `SELECT
              ma.file_name,
              ma.mime_type,
              ma.file_path

           FROM message_attachments ma

           JOIN messages m
             ON m.id = ma.message_id

           WHERE ma.id = $1

             AND (
               m.sender_id = $2

               OR EXISTS (
                 SELECT 1

                 FROM message_recipients mr

                 WHERE mr.message_id = m.id
                   AND mr.recipient_id = $2
               )

               OR EXISTS (
                 SELECT 1

                 FROM conversation_members cm

                 WHERE cm.conversation_id =
                       m.conversation_id

                   AND cm.user_id = $2
               )
             )

           LIMIT 1`,
          [
            Number(req.params.id),
            userId(req),
          ]
        );

      if (!result.rowCount) {
        return res.status(404).json({
          message:
            "Attachment not found.",
        });
      }

      const file =
        result.rows[0];

      if (
        !fs.existsSync(
          file.file_path
        )
      ) {
        return res.status(404).json({
          message:
            "Attachment file is missing.",
        });
      }

      res.setHeader(
        "Content-Type",
        file.mime_type ||
          "application/octet-stream"
      );

      res.download(
        file.file_path,
        file.file_name
      );
    } catch (error) {
      console.error(
        "Attachment error:",
        error
      );

      if (!res.headersSent) {
        res.status(500).json({
          message:
            "Failed to download attachment.",
        });
      }
    }
  }
);

// ============================================================
// SPAM / TRASH COMMON FUNCTION
// ============================================================

async function folderMessages(
  req,
  res,
  folder
) {
  try {
    const uid =
      userId(req);

    const condition =
      folder === "spam"
        ? `
          m.is_spam = true
          AND m.is_deleted = false
        `
        : `
          m.is_deleted = true
        `;

    const result =
      await pool.query(
        `SELECT
            m.id,
            m.conversation_id,
            m.sender_id,
            m.subject,
            m.body,
            m.is_read,
            m.is_starred,
            m.reply_to_message_id,
            m.created_at,

            u.phone_number AS sender_phone,
            u.email_address AS sender_email,
            u.display_name AS sender_name

         FROM messages m

         JOIN users u
           ON u.id = m.sender_id

         WHERE ${condition}

           AND (
             m.sender_id = $1

             OR EXISTS (
               SELECT 1

               FROM message_recipients mr

               WHERE mr.message_id = m.id
                 AND mr.recipient_id = $1
             )
           )

         ORDER BY m.created_at DESC`,
        [uid]
      );

    res.json({
      messages:
        result.rows,
    });
  } catch (error) {
    console.error(
      `${folder} folder error:`,
      error
    );

    res.status(500).json({
      message:
        `Failed to load ${folder} folder.`,
    });
  }
}

// ============================================================
// SPAM FOLDER
// ============================================================

router.get(
  "/spam",
  authMiddleware,
  async (req, res) => {
    await folderMessages(
      req,
      res,
      "spam"
    );
  }
);

// ============================================================
// TRASH FOLDER
// ============================================================

router.get(
  "/trash",
  authMiddleware,
  async (req, res) => {
    await folderMessages(
      req,
      res,
      "trash"
    );
  }
);

// ============================================================
// MOVE TO TRASH
// ============================================================

router.patch(
  "/message/:id/trash",
  authMiddleware,
  async (req, res) => {
    try {
      const result =
        await pool.query(
          `UPDATE messages m

           SET is_deleted = true

           WHERE m.id = $1

             AND (
               m.sender_id = $2

               OR EXISTS (
                 SELECT 1

                 FROM message_recipients mr

                 WHERE mr.message_id = m.id
                   AND mr.recipient_id = $2
               )
             )

           RETURNING m.id`,
          [
            Number(req.params.id),
            userId(req),
          ]
        );

      if (!result.rowCount) {
        return res.status(404).json({
          message:
            "Message not found.",
        });
      }

      res.json({
        message:
          "Message moved to Trash.",
      });
    } catch (error) {
      console.error(
        "Trash error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to move message to Trash.",
      });
    }
  }
);

// ============================================================
// RESTORE FROM TRASH
// ============================================================

router.patch(
  "/message/:id/restore",
  authMiddleware,
  async (req, res) => {
    try {
      const result =
        await pool.query(
          `UPDATE messages m

           SET is_deleted = false

           WHERE m.id = $1

             AND (
               m.sender_id = $2

               OR EXISTS (
                 SELECT 1

                 FROM message_recipients mr

                 WHERE mr.message_id = m.id
                   AND mr.recipient_id = $2
               )
             )

           RETURNING m.id`,
          [
            Number(req.params.id),
            userId(req),
          ]
        );

      if (!result.rowCount) {
        return res.status(404).json({
          message:
            "Message not found.",
        });
      }

      res.json({
        message:
          "Message restored.",
      });
    } catch (error) {
      console.error(
        "Restore error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to restore message.",
      });
    }
  }
);

// ============================================================
// MOVE TO SPAM
// ============================================================

router.patch(
  "/message/:id/spam",
  authMiddleware,
  async (req, res) => {
    try {
      const result =
        await pool.query(
          `UPDATE messages m

           SET
             is_spam = true,
             is_deleted = false

           WHERE m.id = $1

             AND (
               m.sender_id = $2

               OR EXISTS (
                 SELECT 1

                 FROM message_recipients mr

                 WHERE mr.message_id = m.id
                   AND mr.recipient_id = $2
               )
             )

           RETURNING m.id`,
          [
            Number(req.params.id),
            userId(req),
          ]
        );

      if (!result.rowCount) {
        return res.status(404).json({
          message:
            "Message not found.",
        });
      }

      res.json({
        message:
          "Message moved to Spam.",
      });
    } catch (error) {
      console.error(
        "Spam error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to move message to Spam.",
      });
    }
  }
);

// ============================================================
// REMOVE FROM SPAM
// ============================================================

router.patch(
  "/message/:id/not-spam",
  authMiddleware,
  async (req, res) => {
    try {
      const result =
        await pool.query(
          `UPDATE messages m

           SET
             is_spam = false,
             is_deleted = false

           WHERE m.id = $1

             AND (
               m.sender_id = $2

               OR EXISTS (
                 SELECT 1

                 FROM message_recipients mr

                 WHERE mr.message_id = m.id
                   AND mr.recipient_id = $2
               )
             )

           RETURNING m.id`,
          [
            Number(req.params.id),
            userId(req),
          ]
        );

      if (!result.rowCount) {
        return res.status(404).json({
          message:
            "Message not found.",
        });
      }

      res.json({
        message:
          "Message restored from Spam.",
      });
    } catch (error) {
      console.error(
        "Not-spam error:",
        error
      );

      res.status(500).json({
        message:
          "Failed to restore message from Spam.",
      });
    }
  }
);

// ============================================================
// MULTER / UPLOAD ERROR HANDLER
// ============================================================

router.use(
  (
    error,
    _req,
    res,
    _next
  ) => {
    if (
      error instanceof
      multer.MulterError
    ) {
      if (
        error.code ===
        "LIMIT_FILE_SIZE"
      ) {
        return res.status(400).json({
          message:
            "Each attachment must be 100 MB or smaller.",
        });
      }

      if (
        error.code ===
        "LIMIT_FILE_COUNT"
      ) {
        return res.status(400).json({
          message:
            "Maximum 5 attachments are allowed.",
        });
      }

      return res.status(400).json({
        message:
          error.message ||
          "File upload error.",
      });
    }

    console.error(
      "Mail route error:",
      error
    );

    res.status(500).json({
      message:
        error.message ||
        "Mail operation failed.",
    });
  }
);

// ============================================================
// EXPORT
// ============================================================

module.exports = router;