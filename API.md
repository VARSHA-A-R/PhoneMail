# PhoneMail API Documentation

Base URL:
http://localhost:3000

## Authentication

All protected endpoints require:

Authorization: Bearer <JWT_TOKEN>

---

## AUTH APIs

### Check phone number

GET /api/auth/check-phone?phone=9876543210

Response:
{
  "exists": true
}

---

### Register

POST /api/auth/register

Body:
{
  "phone": "9876543210",
  "accessToken": "<MSG91_ACCESS_TOKEN>"
}

Response:
{
  "token": "<JWT_TOKEN>",
  "user": {}
}

---

### Login

POST /api/auth/login

Body:
{
  "phone": "9876543210",
  "accessToken": "<MSG91_ACCESS_TOKEN>"
}

Response:
{
  "token": "<JWT_TOKEN>",
  "user": {}
}

---

### Update Profile

PATCH /api/auth/profile

Headers:
Authorization: Bearer <JWT_TOKEN>

Body:
{
  "displayName": "User Name",
  "language": "en"
}

---

# MAIL APIs

## Get Inbox

GET /api/mail/inbox

Headers:
Authorization: Bearer <JWT_TOKEN>

---

## Get Sent Messages

GET /api/mail/sent

Headers:
Authorization: Bearer <JWT_TOKEN>

---

## Get Conversation

GET /api/mail/conversation/:conversationId

Headers:
Authorization: Bearer <JWT_TOKEN>

---

## Send Mail

POST /api/mail/send

Headers:
Authorization: Bearer <JWT_TOKEN>

Content-Type:
multipart/form-data

Fields:

recipient
subject
body
attachments

Maximum attachments: 5

---

## Reply

POST /api/mail/reply

Headers:
Authorization: Bearer <JWT_TOKEN>

Content-Type:
multipart/form-data

Fields:

originalMessageId
body
attachments

---

## Mark Message as Read

PATCH /api/mail/message/:id/read

Headers:
Authorization: Bearer <JWT_TOKEN>

Body:
{
  "is_read": true
}

---

## Star / Favorite Message

PATCH /api/mail/message/:id/star

Headers:
Authorization: Bearer <JWT_TOKEN>

Body:
{
  "is_starred": true
}

---

## Get Attachment

GET /api/mail/attachment/:id

Headers:
Authorization: Bearer <JWT_TOKEN>

---

# Security

- JWT authentication is used for protected APIs.
- OTP authentication is handled using MSG91.
- Phone numbers are used as the PhoneMail identity.
- Database credentials and API keys must never be committed to GitHub.