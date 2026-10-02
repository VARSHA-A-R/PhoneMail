**# PhoneMail**



**PhoneMail is a real-world email application that allows users to communicate using their \*\*phone numbers as email identities\*\*.**



**Instead of requiring users to remember traditional email addresses, PhoneMail uses an address format such as:**



**`9876543210@phonemail.com`**



**The project includes a Flutter mobile application, a Node.js/Express backend, and PostgreSQL database support.**



**---**



**## 🚀 Project Overview**



**PhoneMail was developed as part of the \*\*AlphaStack 7-Day Buildathon\*\*.**



**The main objective is to build an email platform that provides:**



**- Phone-number-based email identities**

**- OTP-based account creation and authentication**

**- Inbox and conversation management**

**- Sending and replying to emails**

**- File attachments**

**- Spam and Trash management**

**- Read and star message functionality**

**- Mobile application support**

**- Web/backend API support**



**---**



## 🎥 Demo Videos

### 📱 PhoneMail Mobile App
[▶️ Watch PhoneMail Mobile App Demo](demo-videos/phonemail%20phone%20app.mp4)

### 💻 PhoneMail Website
[▶️ Watch PhoneMail Website Demo](demo-videos/phonemail%20website%20.mp4)



## 🚀 Live Demo

[🌐 Open PhoneMail](YOUR_DEPLOYED_APP_URL)



**## 🛠️ Technology Stack**



**### Mobile Application**



**- Flutter**

**- Dart**

**- Android**



**### Backend**



**- Node.js**

**- Express.js**

**- REST API**

**- JSON Web Tokens (JWT)**

**- bcrypt**

**- Multer**



**### Database**



**- PostgreSQL**

**- Docker**



**### Authentication / Communication**



**- MSG91 for OTP services**

**- Email/SMS related services through backend integrations**



**### Development Tools**



**- Visual Studio Code**

**- Android SDK**

**- Flutter SDK**

**- Docker Desktop**

**- Git**

**- GitHub**



**---**



**## 🏗️ Architecture**



**```text**

&#x20;                 **┌─────────────────────┐**

&#x20;                 **│     Flutter App           │**

&#x20;                 **│    Android Client         │**

&#x20;                 **└──────────┬──────────┘**

&#x20;                               **│**

&#x20;                               **│ REST API**

&#x20;                               **▼**

&#x20;                 **┌─────────────────────┐**

&#x20;                 **│   Node.js + Express       │**

&#x20;                 **│       Backend             │**

&#x20;                 **└──────────┬──────────┘**

&#x20;                                **│**

&#x20;             **┌──────────────┴──────────────┐**

&#x20;             **│                                      │**

&#x20;             **▼                                     ▼**

&#x20;    **┌─────────────────┐          ┌─────────────────┐**

&#x20;    **│   PostgreSQL    	    │          │    External          │**

&#x20;    **│    Database          │          │    Services          │**

&#x20;    **└─────────────────┘          │ MSG91 / Email        │**

&#x20;                                       **└─────────────────┘**

**```**



**---**



**## 📁 Project Structure**



**```text**

**PhoneMail/**

**│**

**├── backend/**

**│   ├── src/**

**│   │   ├── routes/**

**│   │   │   ├── auth.js**

**│   │   │   ├── mail.js**

**│   │   │   └── profile.js**

**│   │   │**

**│   │   ├── middleware/**

**│   │   ├── db.js**

**│   │   ├── auth.js**

**│   │   ├── authMiddleware.js**

**│   │   ├── msg91.js**

**│   │   ├── resend.js**

**│   │   ├── sms.js**

**│   │   └── server.js**

**│   │**

**│   ├── .env.example**

**│   ├── package.json**

**│   └── ...**

**│**

**├── database/**

**│   ├── schema.sql**

**│   └── message\_attachments.sql**

**│**

**├── mobile/**

**│   ├── lib/**

**│   │   └── main.dart**

**│   ├── android/**

**│   ├── pubspec.yaml**

**│   └── ...**

**│**

**├── web/**

**│**

**├── docker-compose.yml**

**├── API.md**

**├── .gitignore**

**└── README.md**

**```**



**---**



**# ⚙️ Local Setup**



**## 1. Prerequisites**



**Install the following:**



**- Git**

**- Node.js**

**- npm**

**- Flutter SDK**

**- Android SDK**

**- Docker Desktop**

**- PostgreSQL (or PostgreSQL through Docker)**



**Check the installations:**



**```powershell**

**git --version**

**node --version**

**npm --version**

**flutter --version**

**docker --version**

**```**



**---**



**## 2. Clone the Repository**



**```powershell**

**git clone https://github.com/VARSHA-A-R/PhoneMail.git**

**cd PhoneMail**

**```**



**---**



**# 🗄️ Database Setup**



**PhoneMail uses PostgreSQL.**



**Docker can be used to run PostgreSQL locally.**



**Start the database using:**



**```powershell**

**docker compose up -d**

**```**



**Check the running containers:**



**```powershell**

**docker ps**

**```**



**Apply the database schema:**



**```powershell**

**Get-Content .\\database\\schema.sql | docker exec -i phonemail-postgres psql -U phonemail -d phonemail**

**```**



**If attachment-related tables are required, apply:**



**```powershell**

**Get-Content .\\database\\message\_attachments.sql | docker exec -i phonemail-postgres psql -U phonemail -d phonemail**

**```**



**---**



**# 🔐 Backend Environment Variables**



**Go to the backend folder:**



**```powershell**

**cd backend**

**```**



**Create the environment file:**



**```powershell**

**Copy-Item .env.example .env**

**```**



**Open `.env` and provide the required configuration values.**



**Example structure:**



**```env**

**PORT=3000**



**DATABASE\_URL=your\_database\_connection\_string**



**JWT\_SECRET=your\_jwt\_secret**



**MSG91\_AUTH\_TOKEN=your\_msg91\_auth\_token**



**RESEND\_API\_KEY=your\_resend\_api\_key**

**```**



**\*\*Do not commit `.env` to GitHub.\*\***



**The actual credentials should be provided separately during buildathon submission as required by the organizers.**



**---**



**# ▶️ Run the Backend**



**From the backend directory:**



**```powershell**

**npm install**

**```**



**Start the development server:**



**```powershell**

**npm run dev**

**```**



**Or:**



**```powershell**

**npm start**

**```**



**The API will normally run on:**



**```text**

**http://localhost:3000**

**```**



**The backend must be running for the mobile application to communicate with the local API.**



**---**



**# 📱 Flutter Mobile Application**



**Open another terminal:**



**```powershell**

**cd PhoneMail\\mobile**

**```**



**Install Flutter dependencies:**



**```powershell**

**flutter pub get**

**```**



**The mobile application uses an API base URL supplied through the Flutter environment configuration.**



**Create `env.json` locally if required:**



**```json**

**{**

&#x20; **"API\_BASE\_URL": "http://YOUR\_BACKEND\_IP:3000"**

**}**

**```**



**For local testing on a physical Android device, the backend computer's local network IP should be used instead of `localhost`.**



**For example:**



**```json**

**{**

&#x20; **"API\_BASE\_URL": "http://192.168.x.x:3000"**

**}**

**```**



**\*\*Do not commit `env.json` to GitHub.\*\***



**---**



**# ▶️ Run the Flutter App**



**Connect an Android device or start an Android emulator.**



**Check connected devices:**



**```powershell**

**flutter devices**

**```**



**Run the application:**



**```powershell**

**flutter run --dart-define-from-file=env.json**

**```**



**---**



**# 📦 Build the Android APK**



**For a release APK:**



**```powershell**

**cd mobile**

**flutter build apk --release --dart-define-from-file=env.json**

**```**



**The generated APK will be available at:**



**```text**

**mobile/build/app/outputs/flutter-apk/app-release.apk**

**```**



**---**



**# ✨ Main Features**



**## Authentication**



**- Phone-number-based account system**

**- OTP-based authentication**

**- JWT-based backend authentication**

**- Password-related authentication support where configured**



**## Mail**



**- Inbox**

**- Sent messages**

**- Conversations**

**- Compose message**

**- Reply to messages**

**- Message read/unread state**

**- Star messages**



**## Attachments**



**- Multiple attachments**

**- Attachment upload through the backend**

**- Attachment download**

**- File size and attachment-count restrictions**



**## Mail Organization**



**- Spam folder**

**- Trash folder**

**- Restore messages**

**- Mark messages as spam**

**- Mark messages as not spam**



**## Drafts**



**The mobile application provides local draft handling for composing messages.**



**---**



**# 🔒 Security**



**Sensitive credentials are intentionally excluded from the GitHub repository.**



**The following types of values should be stored in environment variables:**



**- Database credentials**

**- JWT secret**

**- MSG91 authentication credentials**

**- Email service API keys**

**- Other private API keys**



**Never place private API keys directly inside source code.**



**Never commit:**



**```text**

**.env**

**env.json**

**API keys**

**passwords**

**database credentials**

**private authentication tokens**

**```**



**---**



**# 🌐 Deployment**



**For production deployment, the intended architecture is:**



**```text**

**User's Phone**

&#x20;     **│**

&#x20;     **│ HTTPS**

&#x20;     **▼**

**Public Backend API**

&#x20;     **│**

&#x20;     **├──────────────► PostgreSQL**

&#x20;     **│**

&#x20;     **└──────────────► OTP / Email Services**

**```**



**The production Flutter application should use the public HTTPS backend URL instead of a local LAN address.**



**The backend environment variables should be configured through the deployment platform rather than committed to GitHub.**



**---**



**# 🧪 Development**



**## Backend**



**```powershell**

**cd backend**

**npm install**

**npm run dev**

**```**



**## Flutter**



**```powershell**

**cd mobile**

**flutter pub get**

**flutter run --dart-define-from-file=env.json**

**```**



**## Flutter APK**



**```powershell**

**flutter build apk --release --dart-define-from-file=env.json**

**```**



**## Git**



**```powershell**

**git status**

**git add -A**

**git commit -m "Update PhoneMail"**

**git push**

**```**



**---**



**# 📋 API Documentation**



**Backend API information is available in:**



**```text**

**API.md**

**```**



**The backend provides endpoints for authentication, profile management, sending and receiving messages, conversations, attachments, spam, trash, read state, and star state.**



**---**



**# 📜 License**



**This project was created for educational and buildathon purposes.**

