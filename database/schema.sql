-- PhoneMail Database Schema

-- Users / PhoneMail accounts
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    email_address VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    profile_picture TEXT,
    language VARCHAR(20) DEFAULT 'English',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Conversations
CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    type VARCHAR(20) NOT NULL DEFAULT 'individual',
    subject VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Members of a conversation
CREATE TABLE IF NOT EXISTS conversation_members (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,

    FOREIGN KEY (conversation_id)
        REFERENCES conversations(id)
        ON DELETE CASCADE,

    FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    UNIQUE (conversation_id, user_id)
);


-- Emails / Messages
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,

    conversation_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,

    subject VARCHAR(255),
    body TEXT NOT NULL,

    is_read BOOLEAN DEFAULT FALSE,
    is_starred BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    is_spam BOOLEAN DEFAULT FALSE,

    reply_to_message_id INTEGER,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (conversation_id)
        REFERENCES conversations(id)
        ON DELETE CASCADE,

    FOREIGN KEY (sender_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    FOREIGN KEY (reply_to_message_id)
        REFERENCES messages(id)
        ON DELETE SET NULL
);


-- Recipients of each email
CREATE TABLE IF NOT EXISTS message_recipients (
    id SERIAL PRIMARY KEY,

    message_id INTEGER NOT NULL,
    recipient_id INTEGER,
    recipient_email VARCHAR(255) NOT NULL,

    recipient_type VARCHAR(10) NOT NULL DEFAULT 'to',

    FOREIGN KEY (message_id)
        REFERENCES messages(id)
        ON DELETE CASCADE,

    FOREIGN KEY (recipient_id)
        REFERENCES users(id)
        ON DELETE SET NULL
);


-- Attachments
CREATE TABLE IF NOT EXISTS attachments (
    id SERIAL PRIMARY KEY,

    message_id INTEGER NOT NULL,

    file_name VARCHAR(255) NOT NULL,
    file_url TEXT NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (message_id)
        REFERENCES messages(id)
        ON DELETE CASCADE
);


-- Useful indexes
CREATE INDEX IF NOT EXISTS idx_messages_conversation
ON messages(conversation_id);

CREATE INDEX IF NOT EXISTS idx_messages_sender
ON messages(sender_id);

CREATE INDEX IF NOT EXISTS idx_messages_created
ON messages(created_at);

CREATE INDEX IF NOT EXISTS idx_recipients_message
ON message_recipients(message_id);

CREATE INDEX IF NOT EXISTS idx_conversation_members_user
ON conversation_members(user_id);