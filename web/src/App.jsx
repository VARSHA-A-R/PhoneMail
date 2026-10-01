import { useEffect, useRef, useState } from "react";

import "./App.css";



const API_URL = "http://localhost:3000";



const MSG91_WIDGET_ID = "366a61646f62313137393333";

const MSG91_TOKEN_AUTH =

  import.meta.env.VITE_MSG91_TOKEN_AUTH || "";



function extractAccessToken(data) {

  if (!data) {

    return null;

  }



  if (typeof data === "string") {

    return data;

  }



  if (typeof data.message === "string") {

    return data.message;

  }



  if (typeof data.accessToken === "string") {

    return data.accessToken;

  }



  if (typeof data.access_token === "string") {

    return data.access_token;

  }



  if (typeof data.token === "string") {

    return data.token;

  }



  if (

    data.data &&

    typeof data.data === "object"

  ) {

    return (

      data.data.accessToken ||

      data.data.access_token ||

      data.data.token ||

      data.data.message ||

      null

    );

  }



  return null;

}




const translations = {
  en: {
    inbox: "Inbox", sent: "Sent", unread: "Unread", favorites: "Favorites", attachments: "Attachments",
    compose: "Compose", refresh: "Refresh", searchMail: "Search mail", logout: "Logout",
    profile: "Profile", settings: "Settings", displayName: "Display name", language: "Language",
    save: "Save changes", cancel: "Cancel", newMessage: "New Message", to: "To: phone number or PhoneMail address",
    subject: "Subject", writeMessage: "Write your message...", sendingAs: "Sending as", send: "Send",
    sending: "Sending...", yourInboxEmpty: "Your inbox is empty", sentEmpty: "No sent messages yet",
    emptyInboxText: "When you receive messages, they will appear here.", emptySentText: "Messages you send will appear here.",
    composeEmail: "Compose an email", all: "All", messages: "messages", attachFiles: "Attach files", filesSelected: "files selected", removeFile: "Remove", unknownSender: "Unknown sender",
    scamTitle: "Scam Detection", scamText: "Suspicious messages will be identified automatically.",
    accountProfile: "Account profile", phoneNumber: "Phone number", phonemailAddress: "PhoneMail address",
    profileSaved: "Profile updated successfully.", settingsSaved: "Settings saved successfully.", reply: "Reply",
    emailSent: "Email sent successfully.", yourPhoneMailAddress: "Your PhoneMail address",
    secureFooter: "PhoneMail • Secure communication using your phone number",
    mobileNumber: "Mobile number", enterMobile: "Enter mobile number", continue: "Continue",
    createAccount: "Create Account", login: "Login", loginTitle: "Login to PhoneMail", registerTitle: "Create your PhoneMail account",
    authSubtitle: "Your phone number. Your email address.", usePhoneIdentity: "Use your phone number as your email identity.",
    sendingOtp: "Sending OTP...", verifyOtp: "Verify OTP", verifying: "Verifying...", otpSent: "OTP sent successfully. Please check your mobile.",
    verifyOtpTitle: "Verify OTP", otpDescription: "Enter the OTP sent to your mobile number.", enterOtp: "Enter OTP", changeNumber: "← Change mobile number",
    accountCreated: "Account created successfully.", loginSuccessful: "Login successful.",
    languageEnglish: "English", languageTamil: "தமிழ்", languageHindi: "हिन्दी", noSubject: "(No subject)"
  },
  ta: {
    inbox: "உள்வரும் அஞ்சல்", sent: "அனுப்பியவை", unread: "படிக்காதவை", favorites: "பிடித்தவை", attachments: "இணைப்புகள்",
    compose: "புதிய அஞ்சல்", refresh: "புதுப்பி", searchMail: "அஞ்சலைத் தேடு", logout: "வெளியேறு",
    profile: "சுயவிவரம்", settings: "அமைப்புகள்", displayName: "காட்சி பெயர்", language: "மொழி",
    save: "மாற்றங்களைச் சேமி", cancel: "ரத்து செய்", newMessage: "புதிய செய்தி", to: "பெறுநர்: தொலைபேசி எண் அல்லது PhoneMail முகவரி",
    subject: "தலைப்பு", writeMessage: "உங்கள் செய்தியை எழுதுங்கள்...", sendingAs: "அனுப்புபவர்", send: "அனுப்பு",
    sending: "அனுப்பப்படுகிறது...", yourInboxEmpty: "உங்கள் உள்வரும் அஞ்சல் காலியாக உள்ளது", sentEmpty: "அனுப்பிய செய்திகள் இல்லை",
    emptyInboxText: "நீங்கள் பெறும் செய்திகள் இங்கே தோன்றும்.", emptySentText: "நீங்கள் அனுப்பும் செய்திகள் இங்கே தோன்றும்.",
    composeEmail: "அஞ்சல் எழுதுங்கள்", all: "அனைத்தும்", messages: "செய்திகள்", attachFiles: "கோப்புகளை இணைக்கவும்", filesSelected: "கோப்புகள் தேர்ந்தெடுக்கப்பட்டன", removeFile: "அகற்று", unknownSender: "தெரியாத அனுப்புநர்",
    scamTitle: "மோசடி கண்டறிதல்", scamText: "சந்தேகத்திற்கிடமான செய்திகள் தானாக அடையாளம் காணப்படும்.",
    accountProfile: "கணக்கு சுயவிவரம்", phoneNumber: "தொலைபேசி எண்", phonemailAddress: "PhoneMail முகவரி",
    profileSaved: "சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது.", settingsSaved: "அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன.", reply: "பதில்",
    emailSent: "அஞ்சல் வெற்றிகரமாக அனுப்பப்பட்டது.", yourPhoneMailAddress: "உங்கள் PhoneMail முகவரி",
    secureFooter: "PhoneMail • உங்கள் தொலைபேசி எண்ணைப் பயன்படுத்தி பாதுகாப்பான தொடர்பு",
    mobileNumber: "மொபைல் எண்", enterMobile: "மொபைல் எண்ணை உள்ளிடவும்", continue: "தொடரவும்",
    createAccount: "கணக்கை உருவாக்கு", login: "உள்நுழை", loginTitle: "PhoneMail-ல் உள்நுழைக", registerTitle: "உங்கள் PhoneMail கணக்கை உருவாக்குங்கள்",
    authSubtitle: "உங்கள் தொலைபேசி எண். உங்கள் மின்னஞ்சல் முகவரி.", usePhoneIdentity: "உங்கள் தொலைபேசி எண்ணை மின்னஞ்சல் அடையாளமாகப் பயன்படுத்துங்கள்.",
    sendingOtp: "OTP அனுப்பப்படுகிறது...", verifyOtp: "OTP சரிபார்", verifying: "சரிபார்க்கப்படுகிறது...", otpSent: "OTP அனுப்பப்பட்டது. உங்கள் மொபைலைச் சரிபார்க்கவும்.",
    verifyOtpTitle: "OTP சரிபார்ப்பு", otpDescription: "உங்கள் மொபைலுக்கு அனுப்பப்பட்ட OTP-ஐ உள்ளிடவும்.", enterOtp: "OTP-ஐ உள்ளிடவும்", changeNumber: "← மொபைல் எண்ணை மாற்று",
    accountCreated: "கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது.", loginSuccessful: "உள்நுழைவு வெற்றிகரமாக முடிந்தது.",
    languageEnglish: "English", languageTamil: "தமிழ்", languageHindi: "हिन्दी", noSubject: "(தலைப்பு இல்லை)"
  },
  hi: {
    inbox: "इनबॉक्स", sent: "भेजे गए", unread: "अपठित", favorites: "पसंदीदा", attachments: "अटैचमेंट",
    compose: "लिखें", refresh: "रिफ्रेश", searchMail: "मेल खोजें", logout: "लॉग आउट",
    profile: "प्रोफ़ाइल", settings: "सेटिंग्स", displayName: "प्रदर्शित नाम", language: "भाषा",
    save: "बदलाव सेव करें", cancel: "रद्द करें", newMessage: "नया संदेश", to: "प्रति: फ़ोन नंबर या PhoneMail पता",
    subject: "विषय", writeMessage: "अपना संदेश लिखें...", sendingAs: "इस नाम से भेज रहे हैं", send: "भेजें",
    sending: "भेजा जा रहा है...", yourInboxEmpty: "आपका इनबॉक्स खाली है", sentEmpty: "अभी कोई भेजा गया संदेश नहीं है",
    emptyInboxText: "आपको प्राप्त संदेश यहाँ दिखाई देंगे।", emptySentText: "आपके भेजे गए संदेश यहाँ दिखाई देंगे।",
    composeEmail: "ईमेल लिखें", all: "सभी", messages: "संदेश", attachFiles: "फ़ाइलें संलग्न करें", filesSelected: "फ़ाइलें चुनी गईं", removeFile: "हटाएं", unknownSender: "अज्ञात प्रेषक",
    scamTitle: "स्कैम पहचान", scamText: "संदिग्ध संदेश अपने आप पहचाने जाएंगे।",
    accountProfile: "खाता प्रोफ़ाइल", phoneNumber: "फ़ोन नंबर", phonemailAddress: "PhoneMail पता",
    profileSaved: "प्रोफ़ाइल सफलतापूर्वक अपडेट हुई।", settingsSaved: "सेटिंग्स सफलतापूर्वक सेव हुईं।", reply: "जवाब दें",
    emailSent: "ईमेल सफलतापूर्वक भेजा गया।", yourPhoneMailAddress: "आपका PhoneMail पता",
    secureFooter: "PhoneMail • आपके फ़ोन नंबर से सुरक्षित संचार",
    mobileNumber: "मोबाइल नंबर", enterMobile: "मोबाइल नंबर दर्ज करें", continue: "जारी रखें",
    createAccount: "खाता बनाएं", login: "लॉगिन", loginTitle: "PhoneMail में लॉगिन करें", registerTitle: "अपना PhoneMail खाता बनाएं",
    authSubtitle: "आपका फ़ोन नंबर। आपका ईमेल पता।", usePhoneIdentity: "अपने फ़ोन नंबर को ईमेल पहचान के रूप में उपयोग करें।",
    sendingOtp: "OTP भेजा जा रहा है...", verifyOtp: "OTP सत्यापित करें", verifying: "सत्यापित किया जा रहा है...", otpSent: "OTP भेज दिया गया है। अपना मोबाइल देखें।",
    verifyOtpTitle: "OTP सत्यापन", otpDescription: "अपने मोबाइल पर भेजा गया OTP दर्ज करें।", enterOtp: "OTP दर्ज करें", changeNumber: "← मोबाइल नंबर बदलें",
    accountCreated: "खाता सफलतापूर्वक बनाया गया।", loginSuccessful: "लॉगिन सफल रहा।",
    languageEnglish: "English", languageTamil: "தமிழ்", languageHindi: "हिन्दी", noSubject: "(कोई विषय नहीं)"
  }
};

function App() {

  const [authMode, setAuthMode] =

    useState("register");



  const [phone, setPhone] = useState("");

  const [otp, setOtp] = useState("");



  const [otpSent, setOtpSent] =

    useState(false);



  const [loading, setLoading] =

    useState(false);



  const [message, setMessage] =

    useState("");



  const [error, setError] =

    useState("");



  const [user, setUser] =

    useState(null);



  const [token, setToken] =

    useState("");



  const [messages, setMessages] =

    useState([]);

  const [sentMessages, setSentMessages] =

    useState([]);

  const [profileOpen, setProfileOpen] =

    useState(false);

  const [profileName, setProfileName] =

    useState("");

  const [language, setLanguage] =

    useState("en");

  const [profileSaving, setProfileSaving] =

    useState(false);



  const [activeTab, setActiveTab] =

    useState("all");



  const [search, setSearch] =

    useState("");



  const [showCompose, setShowCompose] =

    useState(false);



  const [recipient, setRecipient] =

    useState("");



  const [subject, setSubject] =

    useState("");



  const [body, setBody] =

    useState("");



  const [sending, setSending] =

    useState(false);



  const [selectedMail, setSelectedMail] =

    useState(null);

  const [replyMode, setReplyMode] =

    useState(false);

  const [replyOriginalMessageId, setReplyOriginalMessageId] =

    useState(null);

  const [selectedFiles, setSelectedFiles] =

    useState([]);

  const [isRefreshing, setIsRefreshing] =

    useState(false);



  const captchaContainerRef =

    useRef(null);



  const msg91Initialized =

    useRef(false);



  const msg91Initializing =

    useRef(false);

  const t = translations[language] || translations.en;



  /* =====================================================

     LOAD SAVED LOGIN

  ===================================================== */



  useEffect(() => {

    const savedToken =

      sessionStorage.getItem(

        "phonemail_token"

      );



    const savedUser =

      sessionStorage.getItem(

        "phonemail_user"

      );



    if (savedToken && savedUser) {

      try {

        setToken(savedToken);

        const parsedUser = JSON.parse(savedUser);
        setUser(parsedUser);
        setProfileName(parsedUser.display_name || "");
        setLanguage(parsedUser.language || "en");

      } catch (err) {

        console.error(

          "Saved login error:",

          err

        );



        sessionStorage.removeItem(

          "phonemail_token"

        );



        sessionStorage.removeItem(

          "phonemail_user"

        );

      }

    }

  }, []);



  /* =====================================================

     LOAD INBOX

  ===================================================== */



  useEffect(() => {

    if (user && token) {

      loadInbox();
      loadSent();

    }

  }, [user, token]);



  /* =====================================================

     LOAD MSG91 SCRIPT

  ===================================================== */



  function loadMsg91Script() {

    return new Promise(

      (resolve, reject) => {

        if (

          typeof window.initSendOTP ===

          "function"

        ) {

          resolve();

          return;

        }



        const existingScript =

          document.querySelector(

            'script[src*="otp-provider.js"]'

          );



        if (existingScript) {

          if (

            typeof window.initSendOTP ===

            "function"

          ) {

            resolve();

            return;

          }



          existingScript.addEventListener(

            "load",

            () => {

              resolve();

            },

            { once: true }

          );



          existingScript.addEventListener(

            "error",

            () => {

              reject(

                new Error(

                  "Unable to load MSG91 OTP service."

                )

              );

            },

            { once: true }

          );



          return;

        }



        const script =

          document.createElement(

            "script"

          );



        script.src =

          "https://verify.msg91.com/otp-provider.js";



        script.async = true;



        script.onload = () => {

          console.log(

            "MSG91 OTP script loaded."

          );



          resolve();

        };



        script.onerror = () => {

          reject(

            new Error(

              "Unable to load MSG91 OTP service."

            )

          );

        };



        document.body.appendChild(

          script

        );

      }

    );

  }



  /* =====================================================

     INITIALIZE MSG91



     IMPORTANT:

     We initialize the widget ONCE.

     We do NOT initialize it every time

     Continue / Verify is clicked.

  ===================================================== */



  async function initializeMsg91() {

    if (msg91Initialized.current) {

      return true;

    }



    if (msg91Initializing.current) {

      return false;

    }



    if (!MSG91_TOKEN_AUTH) {

      console.error(

        "MSG91 token auth is missing."

      );



      setError(

        "MSG91 configuration is missing."

      );



      return false;

    }



    try {

      msg91Initializing.current = true;



      await loadMsg91Script();



      if (

        typeof window.initSendOTP !==

        "function"

      ) {

        throw new Error(

          "MSG91 initialization function is unavailable."

        );

      }



      /*

        Wait for the CAPTCHA container

        to actually exist in the DOM.

      */



      for (let i = 0; i < 20; i++) {

        if (

          captchaContainerRef.current

        ) {

          break;

        }



        await new Promise(

          (resolve) =>

            setTimeout(

              resolve,

              100

            )

        );

      }



      const configuration = {

        widgetId:

          MSG91_WIDGET_ID,



        tokenAuth:

          MSG91_TOKEN_AUTH,



        /*

          Identifier is optional during

          widget initialization.

          The actual phone number is

          passed to sendOtp().

        */



        identifier: "",



        exposeMethods: true,



        captchaRenderId:

          "msg91-captcha",



        success: (data) => {

          console.log(

            "MSG91 success response:",

            data

          );

        },



        failure: (error) => {

          console.error(

            "MSG91 failure response:",

            error

          );

        },

      };



      console.log(

        "Initializing MSG91 widget..."

      );



      window.initSendOTP(

        configuration

      );



      /*

        Wait until MSG91 exposes

        sendOtp() and verifyOtp().

      */



      for (let i = 0; i < 50; i++) {

        if (

          typeof window.sendOtp ===

            "function" &&

          typeof window.verifyOtp ===

            "function"

        ) {

          msg91Initialized.current =

            true;



          console.log(

            "MSG91 OTP methods are ready."

          );



          msg91Initializing.current =

            false;



          return true;

        }



        await new Promise(

          (resolve) =>

            setTimeout(

              resolve,

              200

            )

        );

      }



      throw new Error(

        "MSG91 OTP methods were not initialized."

      );

    } catch (err) {

      msg91Initializing.current =

        false;



      console.error(

        "MSG91 initialization error:",

        err

      );



      setError(

        err.message ||

          "Unable to initialize OTP service."

      );



      return false;

    }

  }



  /* =====================================================

     INITIALIZE CAPTCHA WHEN AUTH PAGE OPENS

  ===================================================== */



  useEffect(() => {

    if (user || otpSent) {

      return;

    }



    const timer =

      setTimeout(() => {

        initializeMsg91();

      }, 500);



    return () => {

      clearTimeout(timer);

    };

  }, [user, otpSent]);



  /* =====================================================

     SEND OTP

  ===================================================== */



  async function handleSendOtp(e) {

    e.preventDefault();



    setError("");

    setMessage("");



    if (!phone) {

      setError(

        "Please enter your mobile number."

      );



      return;

    }



    if (phone.length !== 10) {

      setError(

        "Please enter a valid 10-digit mobile number."

      );



      return;

    }



    try {

      /*
        Check the PhoneMail account before sending OTP.
        This prevents an existing account from receiving
        an OTP from the Create Account page, and prevents
        an unregistered number from receiving an OTP from
        the Login page.
      */
      const accountCheckResponse = await fetch(
        `${API_URL}/api/auth/check-phone?phone=${encodeURIComponent(phone)}`
      );

      const accountCheckData = await accountCheckResponse.json();

      if (!accountCheckResponse.ok) {
        throw new Error(
          accountCheckData.message ||
            "Unable to check the account."
        );
      }

      if (authMode === "register" && accountCheckData.exists) {
        setError(
          "This account already exists. Please login with this number."
        );
        setLoading(false);
        return;
      }

      if (authMode === "login" && !accountCheckData.exists) {
        setError(
          "No account exists with this number. Please create an account first."
        );
        setLoading(false);
        return;
      }

      setLoading(true);



      /*

        Make sure MSG91 has finished

        initializing before sendOtp().

      */



      const ready =

        await initializeMsg91();



      if (!ready) {

        throw new Error(

          "MSG91 OTP service is not ready."

        );

      }



      if (

        typeof window.sendOtp !==

        "function"

      ) {

        throw new Error(

          "MSG91 sendOtp function is unavailable."

        );

      }



      const identifier =

        `91${phone}`;



      console.log(

        "Sending OTP to:",

        identifier

      );



      window.sendOtp(

        identifier,



        (response) => {

          console.log(

            "OTP sent successfully:",

            response

          );



          setOtpSent(true);



          setMessage(

            "OTP sent successfully. Please check your mobile."

          );



          setLoading(false);

        },



        (response) => {

          console.error(

            "MSG91 OTP send failed:",

            response

          );



          setError(

            response?.message ||

              response?.error ||

              "Failed to send OTP."

          );



          setLoading(false);

        }

      );

    } catch (err) {

      console.error(

        "OTP send error:",

        err

      );



      setError(

        err.message ||

          "Failed to send OTP."

      );



      setLoading(false);

    }

  }



  /* =====================================================

     VERIFY OTP

  ===================================================== */



  async function handleVerifyOtp(e) {

    e.preventDefault();



    setError("");

    setMessage("");



    if (!otp) {

      setError(

        "Please enter the OTP."

      );



      return;

    }



    if (otp.length < 4) {

      setError(

        "Please enter the complete OTP."

      );



      return;

    }



    try {

      setLoading(true);



      /*

        Do NOT reinitialize the CAPTCHA.

        Just make sure MSG91 is ready.

      */



      const ready =

        await initializeMsg91();



      if (!ready) {

        throw new Error(

          "MSG91 OTP service is not ready."

        );

      }



      if (

        typeof window.verifyOtp !==

        "function"

      ) {

        throw new Error(

          "MSG91 verifyOtp function is unavailable."

        );

      }



      console.log(

        "Verifying OTP..."

      );



      window.verifyOtp(

        otp,



        async (response) => {

          try {

            console.log(

              "OTP verified:",

              response

            );



            const accessToken =

              extractAccessToken(

                response

              );



            if (!accessToken) {

              throw new Error(

                "MSG91 access token was not received."

              );

            }



            console.log(

              "MSG91 access token received."

            );



            const endpoint =

              authMode === "register"

                ? "/api/auth/register"

                : "/api/auth/login";



            const apiResponse =

              await fetch(

                `${API_URL}${endpoint}`,

                {

                  method: "POST",



                  headers: {

                    "Content-Type":

                      "application/json",

                  },



                  body: JSON.stringify({

                    phone,

                    accessToken,

                  }),

                }

              );



            const data =

              await apiResponse.json();



            if (!apiResponse.ok) {

              throw new Error(

                data.message ||

                  "Authentication failed."

              );

            }



            console.log(

              "PhoneMail authentication successful:",

              data

            );



            sessionStorage.setItem(

              "phonemail_token",

              data.token

            );



            sessionStorage.setItem(

              "phonemail_user",

              JSON.stringify(

                data.user

              )

            );



            setToken(data.token);



            setUser(data.user);



            setMessage(

              authMode === "register"

                ? t.accountCreated

                : t.loginSuccessful

            );



            setLoading(false);

          } catch (err) {

            console.error(

              "PhoneMail authentication error:",

              err

            );



            setError(

              err.message ||

                "Authentication failed."

            );



            setLoading(false);

          }

        },



        (response) => {

          console.error(

            "OTP verification failed:",

            response

          );



          setError(

            response?.message ||

              response?.error ||

              "Invalid OTP."

          );



          setLoading(false);

        }

      );

    } catch (err) {

      console.error(

        "OTP verification error:",

        err

      );



      setError(

        err.message ||

          "OTP verification failed."

      );



      setLoading(false);

    }

  }



  /* =====================================================

     LOAD INBOX

  ===================================================== */



  async function loadInbox() {

    try {

      const response =

        await fetch(

          `${API_URL}/api/mail/inbox`,

          {

            headers: {

              Authorization:

                `Bearer ${token}`,

            },

          }

        );



      if (!response.ok) {

        if (

          response.status === 401

        ) {

          handleLogout();

        }



        return;

      }



      const data =

        await response.json();



      setMessages(

        data.messages || []

      );

    } catch (err) {

      console.error(

        "Inbox loading error:",

        err

      );

    }

  }



  /* =====================================================

     LOAD SENT MAIL

  ===================================================== */

  async function loadSent() {
    try {
      const response = await fetch(
        `${API_URL}/api/mail/sent`,
        {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      if (!response.ok) {
        if (response.status === 401) {
          handleLogout();
        }
        return;
      }

      const data = await response.json();
      setSentMessages(data.messages || []);
    } catch (err) {
      console.error("Sent mail loading error:", err);
    }
  }



  /* =====================================================

     UPDATE PROFILE

  ===================================================== */

  async function handleSaveProfile(e) {
    e.preventDefault();
    setError("");
    setMessage("");

    try {
      setProfileSaving(true);

      const response = await fetch(
        `${API_URL}/api/auth/profile`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            displayName: profileName,
            language,
          }),
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          data.message || "Failed to update profile."
        );
      }

      setUser(data.user);
      sessionStorage.setItem(
        "phonemail_user",
        JSON.stringify(data.user)
      );
      setProfileName(data.user.display_name || "");
      setLanguage(data.user.language || "en");
      setProfileOpen(false);
      setMessage((translations[data.user.language] || translations.en).profileSaved);
    } catch (err) {
      console.error("Profile update error:", err);
      setError(err.message || "Failed to update profile.");
    } finally {
      setProfileSaving(false);
    }
  }



  /* =====================================================

     SEND EMAIL

  ===================================================== */



  async function handleSendMail(e) {
    e.preventDefault();

    setError("");
    setMessage("");

    if (!body.trim()) {
      setError("Please enter a message.");
      return;
    }

    if (!replyMode && !recipient.trim()) {
      setError("Please enter a recipient.");
      return;
    }

    if (replyMode && !replyOriginalMessageId) {
      setError("The reply target is missing. Please open the email again.");
      return;
    }

    if (selectedFiles.length > 5) {
      setError("You can attach a maximum of 5 files.");
      return;
    }

    try {
      setSending(true);
      let response;

      if (replyMode) {
        if (selectedFiles.length > 0) {
          const formData = new FormData();
          formData.append("originalMessageId", String(replyOriginalMessageId));
          formData.append("body", body.trim());

          selectedFiles.slice(0, 5).forEach((file) => {
            formData.append("attachments", file);
          });

          response = await fetch(`${API_URL}/api/mail/reply`, {
            method: "POST",
            headers: { Authorization: `Bearer ${token}` },
            body: formData,
          });
        } else {
          response = await fetch(`${API_URL}/api/mail/reply`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
              originalMessageId: replyOriginalMessageId,
              body: body.trim(),
            }),
          });
        }
      } else {
        const formData = new FormData();
        formData.append("recipient", recipient.trim());
        formData.append("subject", subject.trim());
        formData.append("body", body.trim());

        selectedFiles.slice(0, 5).forEach((file) => {
          formData.append("attachments", file);
        });

        response = await fetch(`${API_URL}/api/mail/send`, {
          method: "POST",
          headers: { Authorization: `Bearer ${token}` },
          body: formData,
        });
      }

      const data = await response.json();

      if (!response.ok) {
        throw new Error(
          data.message ||
            (replyMode ? "Failed to send reply." : "Failed to send email.")
        );
      }

      setMessage(replyMode ? "Reply sent successfully." : t.emailSent);
      setRecipient("");
      setSubject("");
      setBody("");
      setSelectedFiles([]);
      setReplyMode(false);
      setReplyOriginalMessageId(null);
      setShowCompose(false);

      await loadInbox();
      await loadSent();
    } catch (err) {
      console.error("Send mail error:", err);
      setError(
        err.message ||
          (replyMode ? "Failed to send reply." : "Failed to send email.")
      );
    } finally {
      setSending(false);
    }
  }



  /* =====================================================

     OPEN MAIL / STAR / REPLY

  ===================================================== */



  function handleOpenMail(mail) {
    setSelectedMail(mail);

    if (activeTab !== "sent") {
      setMessages((currentMessages) =>
        currentMessages.map((item) =>
          item.id === mail.id ? { ...item, is_read: true } : item
        )
      );
    }
  }



  function handleCloseMail() {
    setSelectedMail(null);
  }



  async function handleToggleStar(mail) {
    const newStarred = !mail.is_starred;

    // Update the UI immediately
    setMessages((currentMessages) =>
      currentMessages.map((item) =>
        item.id === mail.id
          ? { ...item, is_starred: newStarred }
          : item
      )
    );

    setSelectedMail((currentMail) =>
      currentMail && currentMail.id === mail.id
        ? { ...currentMail, is_starred: newStarred }
        : currentMail
    );

    // Save the favorite status in the database
    try {
      const response = await fetch(
        `${API_URL}/api/mail/${mail.id}/star`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({
            is_starred: newStarred,
          }),
        }
      );

      if (!response.ok) {
        throw new Error("Failed to save favorite status.");
      }
    } catch (err) {
      console.error("Favorite update error:", err);

      // Revert UI if database update failed
      setMessages((currentMessages) =>
        currentMessages.map((item) =>
          item.id === mail.id
            ? { ...item, is_starred: !newStarred }
            : item
        )
      );

      setSelectedMail((currentMail) =>
        currentMail && currentMail.id === mail.id
          ? { ...currentMail, is_starred: !newStarred }
          : currentMail
      );
    }
  }



  function handleReply(mail) {
    const alreadyReplied = sentMessages.some(
      (sentMail) =>
        String(sentMail.reply_to_message_id || "") ===
        String(mail.id)
    );

    if (alreadyReplied) {
      setError("You have already replied to this email.");
      return;
    }

    const replyAddress =
      mail.sender_email || mail.sender_phone || "";

    setRecipient(replyAddress);
    setSubject(
      mail.subject
        ? mail.subject.startsWith("Re:")
          ? mail.subject
          : `Re: ${mail.subject}`
        : "Re:"
    );
    setBody("");
    setSelectedFiles([]);
    setReplyMode(true);
    setReplyOriginalMessageId(mail.id);
    setSelectedMail(null);
    setShowCompose(true);
  }



  /* =====================================================

     LOGOUT

  ===================================================== */



  function handleLogout() {

    sessionStorage.removeItem(

      "phonemail_token"

    );



    sessionStorage.removeItem(

      "phonemail_user"

    );



    setToken("");

    setUser(null);



    setMessages([]);

    setSelectedMail(null);
    setSelectedFiles([]);
    setReplyMode(false);
    setReplyOriginalMessageId(null);



    setPhone("");

    setOtp("");



    setOtpSent(false);



    setMessage("");

    setError("");



    setAuthMode("login");

  }



  /* =====================================================

     LOGIN / REGISTER SWITCH

  ===================================================== */



  function switchAuthMode(mode) {

    setAuthMode(mode);



    setOtpSent(false);



    setOtp("");



    setError("");



    setMessage("");



    setPhone("");

  }



  async function handleRefresh() {
    if (isRefreshing) return;

    setIsRefreshing(true);
    try {
      await loadInbox();
      await loadSent();
    } finally {
      setTimeout(() => setIsRefreshing(false), 350);
    }
  }


  /* =====================================================

     FILTER MESSAGES

  ===================================================== */



  function hasAlreadyReplied(mail) {
    return sentMessages.some(
      (sentMail) =>
        String(sentMail.reply_to_message_id || "") ===
        String(mail.id)
    );
  }



  const currentMailbox =
    activeTab === "sent" ? sentMessages : messages;

  const filteredMessages =

    currentMailbox.filter((mail) => {

      const searchText =

        search

          .trim()

          .toLowerCase();



      const matchesSearch =

        !searchText ||

        (mail.sender_name || "")

          .toLowerCase()

          .includes(searchText) ||

        (mail.sender_email || "")

          .toLowerCase()

          .includes(searchText) ||

        (mail.subject || "")

          .toLowerCase()

          .includes(searchText) ||

        (mail.body || "")

          .toLowerCase()

          .includes(searchText);



      if (!matchesSearch) {

        return false;

      }



      if (

        activeTab === "sent"

      ) {

        return true;

      }

      if (

        activeTab === "unread"

      ) {

        return !mail.is_read;

      }



      if (

        activeTab === "favorites"

      ) {

        return mail.is_starred;

      }



      if (

        activeTab === "attachments"

      ) {

        return false;

      }



      return true;

    });



  /* =====================================================

     AUTH PAGE

  ===================================================== */



  if (!user || !token) {

    return (

      <div className="auth-page">



        <div className="auth-card">



          <div className="auth-logo">

            ✉

          </div>



          <h1>

            PhoneMail

          </h1>



          <p className="auth-subtitle">

            Your phone number. Your email address.

          </p>



          <div className="auth-switch">



            <button

              type="button"

              className={

                authMode === "login"

                  ? "active"

                  : ""

              }

              onClick={() =>

                switchAuthMode(

                  "login"

                )

              }

            >

              Login

            </button>



            <button

              type="button"

              className={

                authMode === "register"

                  ? "active"

                  : ""

              }

              onClick={() =>

                switchAuthMode(

                  "register"

                )

              }

            >

              Create Account

            </button>



          </div>



          <form

            className="auth-form"

            onSubmit={

              otpSent

                ? handleVerifyOtp

                : handleSendOtp

            }

          >



            <h2>

              {authMode === "register"

                ? t.registerTitle

                : t.loginTitle}

            </h2>



            <p className="auth-subtitle">

              Use your phone number as your email identity.

            </p>



            {!otpSent && (

              <>

                <label className="auth-label">

                  Mobile number

                </label>



                <div className="phone-input">



                  <span className="phone-prefix">

                    +91

                  </span>



                  <input

                    type="tel"

                    inputMode="numeric"

                    maxLength="10"

                    placeholder={t.enterMobile}

                    value={phone}

                    onChange={(e) =>

                      setPhone(

                        e.target.value.replace(

                          /\D/g,

                          ""

                        )

                      )

                    }

                  />



                </div>



                {/* =================================================

                    REAL MSG91 hCAPTCHA

                ================================================= */}



                <div

                  id="msg91-captcha"

                  ref={

                    captchaContainerRef

                  }

                />



                <button

                  className="auth-button"

                  type="submit"

                  disabled={loading}

                >

                  {loading

                    ? "Sending OTP..."

                    : t.continue}

                </button>



              </>

            )}



            {otpSent && (

              <div className="otp-section">



                <label className="auth-label otp-label">

                  Verify OTP

                </label>



                <p className="otp-description">

                  Enter the OTP sent to your mobile number.

                </p>



                <input

                  className="otp-input"

                  type="text"

                  inputMode="numeric"

                  maxLength="6"

                  placeholder={t.enterOtp}

                  value={otp}

                  onChange={(e) =>

                    setOtp(

                      e.target.value.replace(

                        /\D/g,

                        ""

                      )

                    )

                  }

                />



                <button

                  className="auth-button verify-button"

                  type="submit"

                  disabled={loading}

                >

                  {loading

                    ? "Verifying..."

                    : t.verifyOtp}

                </button>



                <button

                  type="button"

                  className="change-number-button"

                  onClick={() => {

                    setOtpSent(false);

                    setOtp("");

                    setError("");

                    setMessage("");

                  }}

                >

                  ← Change mobile number

                </button>



              </div>

            )}



          </form>



          {message && (

            <div className="auth-message">

              {message}

            </div>

          )}



          {error && (

            <div className="auth-error">

              {error}

            </div>

          )}



          {!otpSent &&

            phone.length === 10 && (

              <div className="email-preview">



                <div className="email-preview-label">

                  {t.yourPhoneMailAddress}

                </div>



                <div className="email-preview-address">

                  {phone}@phonemail.com

                </div>



              </div>

            )}



          <div className="auth-footer">

            {t.secureFooter}

          </div>



        </div>



      </div>

    );

  }



  /* =====================================================

     MAIN MAIL APP

  ===================================================== */



  return (

    <div className="mail-app" style={{ animation: isRefreshing ? "phonemailRefreshBlink 0.35s ease-in-out 1" : "none" }}>
      <style>{`
        @keyframes phonemailRefreshBlink {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.72; }
        }
      `}</style>



      <header className="mail-header">



        <div className="brand">



          <div className="brand-logo">

            ✉

          </div>



          <div>

            <strong>

              PhoneMail

            </strong>



            <span>

              {user.email_address}

            </span>

          </div>



        </div>



        <div className="search-box">



          <span>⌕</span>



          <input

            type="text"

            placeholder={t.searchMail}

            value={search}

            onChange={(e) =>

              setSearch(

                e.target.value

              )

            }

          />



        </div>



        <button
          type="button"
          className="profile-button"
          onClick={() => {
            setProfileName(user.display_name || "");
            setLanguage(user.language || "en");
            setProfileOpen(true);
          }}
        >
          👤 {user.display_name || t.profile}
        </button>



        <button

          className="logout-button"

          onClick={handleLogout}

        >

          {t.logout}

        </button>



      </header>



      <div className="mail-layout">



        <aside className="mail-sidebar">



          <button

            className="compose-button"

            onClick={() =>

              setShowCompose(true)

            }

          >

            ✚ {t.compose}

          </button>



          <button

            className={

              activeTab === "all"

                ? "sidebar-item active"

                : "sidebar-item"

            }

            onClick={() =>

              setActiveTab("all")

            }

          >

            📥 {t.inbox}

          </button>



          <button

            className={

              activeTab === "sent"

                ? "sidebar-item active"

                : "sidebar-item"

            }

            onClick={() =>

              setActiveTab("sent")

            }

          >

            📤 {t.sent}

          </button>



          <button

            className={

              activeTab === "unread"

                ? "sidebar-item active"

                : "sidebar-item"

            }

            onClick={() =>

              setActiveTab("unread")

            }

          >

            ● {t.unread}

          </button>



          <button

            className={

              activeTab === "favorites"

                ? "sidebar-item active"

                : "sidebar-item"

            }

            onClick={() =>

              setActiveTab("favorites")

            }

          >

            ⭐ {t.favorites}

          </button>



          <button

            className={

              activeTab ===

              "attachments"

                ? "sidebar-item active"

                : "sidebar-item"

            }

            onClick={() =>

              setActiveTab(

                "attachments"

              )

            }

          >

            📎 {t.attachments}

          </button>



          <div className="sidebar-scam">



            <strong>

              🛡 {t.scamTitle}

            </strong>



            <span>

              {t.scamText}

            </span>



          </div>



        </aside>



        <main className="mail-content">



          <div className="mail-title-row">



            <div>



              <h2>

                {activeTab === "sent" ? t.sent : t.inbox}

              </h2>



              <p>

                {filteredMessages.length} messages

              </p>



            </div>



            <button
              className="refresh-button"
              onClick={handleRefresh}
              disabled={isRefreshing}
              style={{
                opacity: isRefreshing ? 0.65 : 1,
                transition: "opacity 0.12s ease",
              }}
            >
              ↻ {t.refresh}
            </button>



          </div>



          <div className="mail-tabs">



            <button

              className={

                activeTab === "all"

                  ? "active"

                  : ""

              }

              onClick={() =>

                setActiveTab("all")

              }

            >

              {t.all}

            </button>



            <button

              className={

                activeTab === "sent"

                  ? "active"

                  : ""

              }

              onClick={() =>

                setActiveTab("sent")

              }

            >

              {t.sent}

            </button>



            <button

              className={

                activeTab === "unread"

                  ? "active"

                  : ""

              }

              onClick={() =>

                setActiveTab("unread")

              }

            >

              {t.unread}

            </button>



            <button

              className={

                activeTab ===

                "favorites"

                  ? "active"

                  : ""

              }

              onClick={() =>

                setActiveTab(

                  "favorites"

                )

              }

            >

              {t.favorites}

            </button>



            <button

              className={

                activeTab ===

                "attachments"

                  ? "active"

                  : ""

              }

              onClick={() =>

                setActiveTab(

                  "attachments"

                )

              }

            >

              {t.attachments}

            </button>



          </div>



          {message && (

            <div className="mail-success">

              {message}

            </div>

          )}



          {error && (

            <div className="mail-error">

              {error}

            </div>

          )}



          <div className="message-list">



            {filteredMessages.length ===

            0 ? (

              <div className="empty-inbox">



                <div className="empty-icon">

                  ✉

                </div>



                <h3>

                  {activeTab === "sent" ? t.sentEmpty : t.yourInboxEmpty}

                </h3>



                <p>

                  {activeTab === "sent" ? t.emptySentText : t.emptyInboxText}

                </p>



                <button

                  onClick={() =>

                    setShowCompose(true)

                  }

                >

                  {t.composeEmail}

                </button>



              </div>

            ) : (

              filteredMessages.map(

                (mail) => (

                  <div

                    className={

                      mail.is_read

                        ? "message-row"

                        : "message-row unread"

                    }

                    key={mail.id}

                    onClick={() => handleOpenMail(mail)}

                    style={{ cursor: "pointer" }}

                  >



                    <div className="sender-avatar">

                      {(

                        mail.sender_name ||

                        mail.sender_phone ||

                        "U"

                      )

                        .charAt(0)

                        .toUpperCase()}

                    </div>



                    <div className="message-main">



                      <div className="message-top">



                        <strong>

                          {activeTab === "sent"
                          ? (mail.recipient_name || mail.recipient_user_email || mail.recipient_phone || "Unknown recipient")
                          : (mail.sender_name || mail.sender_email || mail.sender_phone)}

                        </strong>



                        <span>

                          {new Date(

                            mail.created_at

                          ).toLocaleTimeString(

                            [],

                            {

                              hour:

                                "2-digit",

                              minute:

                                "2-digit",

                            }

                          )}

                        </span>



                      </div>



                      <div className="message-subject">

                        {activeTab === "sent" ? `To: ${mail.recipient_name || mail.recipient_user_email || mail.recipient_phone || "Unknown recipient"}` : (mail.subject || t.noSubject)}

                      </div>

                      {activeTab === "sent" && (
                        <div className="message-subject">
                          {mail.subject || t.noSubject}
                        </div>
                      )}



                      <div className="message-preview">

                        {mail.body}

                      </div>

                      {activeTab !== "sent" && hasAlreadyReplied(mail) && (
                        <div
                          style={{
                            marginTop: "6px",
                            fontSize: "12px",
                            fontWeight: 700,
                            color: "#6b5dd3",
                          }}
                        >
                          You have already replied.
                        </div>
                      )}



                    </div>



                    {activeTab !== "sent" && (
                      <div

                        className="message-star"

                        onClick={(e) => {
                          e.stopPropagation();
                          handleToggleStar(mail);
                        }}

                        style={{ cursor: "pointer" }}
                      >

                        {mail.is_starred

                          ? "★"

                          : "☆"}

                      </div>
                    )}



                  </div>

                )

              )

            )}



          </div>



        </main>



      </div>



      {profileOpen && (
        <div
          style={{
            position: "fixed",
            inset: 0,
            zIndex: 300,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            padding: "20px",
            background: "rgba(30, 20, 60, 0.35)",
          }}
          onClick={() => setProfileOpen(false)}
        >
          <div
            className="settings-content"
            style={{ width: "100%", maxWidth: "520px" }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="settings-section">
              <div className="settings-row">
                <div>
                  <h3>{t.accountProfile}</h3>
                  <p>{user.email_address}</p>
                </div>
                <button
                  type="button"
                  onClick={() => setProfileOpen(false)}
                  style={{ border: "none", background: "transparent", fontSize: "24px", cursor: "pointer" }}
                >
                  ×
                </button>
              </div>
            </div>

            <form onSubmit={handleSaveProfile}>
              <div className="settings-section">
                <div className="settings-row">
                  <div>
                    <strong>{t.displayName}</strong>
                    <p>{t.displayName}</p>
                  </div>
                  <input
                    type="text"
                    value={profileName}
                    onChange={(e) => setProfileName(e.target.value)}
                    maxLength={50}
                    placeholder={t.displayName}
                    style={{ maxWidth: "230px" }}
                  />
                </div>
              </div>

              <div className="settings-section">
                <div className="settings-row">
                  <div>
                    <strong>{t.language}</strong>
                    <p>{t.language}</p>
                  </div>
                  <select
                    value={language}
                    onChange={(e) => setLanguage(e.target.value)}
                    style={{ maxWidth: "230px" }}
                  >
                    <option value="en">{t.languageEnglish}</option>
                    <option value="ta">{t.languageTamil}</option>
                    <option value="hi">{t.languageHindi}</option>
                  </select>
                </div>
              </div>

              <div className="settings-section">
                <div className="settings-row">
                  <div>
                    <strong>{t.phoneNumber}</strong>
                    <p>{user.phone_number}</p>
                  </div>
                  <span>{t.phonemailAddress}</span>
                </div>
              </div>

              <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px", paddingTop: "10px" }}>
                <button
                  type="button"
                  onClick={() => setProfileOpen(false)}
                  style={{ padding: "10px 16px", borderRadius: "9px", border: "1px solid #ddd", background: "#fff", cursor: "pointer" }}
                >
                  {t.cancel}
                </button>
                <button
                  type="submit"
                  disabled={profileSaving}
                  style={{ padding: "10px 18px", borderRadius: "9px", border: "none", background: "linear-gradient(135deg, #4f46e5, #7c3aed)", color: "#fff", fontWeight: 700, cursor: "pointer" }}
                >
                  {profileSaving ? t.sending : t.save}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}



      {selectedMail && (

        <div
          style={{
            position: "fixed",
            inset: 0,
            zIndex: 200,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            padding: "20px",
            background: "rgba(30, 20, 60, 0.35)",
          }}
          onClick={handleCloseMail}
        >
          <div
            style={{
              width: "100%",
              maxWidth: "700px",
              maxHeight: "85vh",
              overflowY: "auto",
              background: "#ffffff",
              color: "#17152b",
              borderRadius: "18px",
              boxShadow: "0 25px 60px rgba(30, 20, 60, 0.25)",
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "15px 18px",
                background: "linear-gradient(135deg, #4f46e5, #7c3aed)",
                color: "#ffffff",
              }}
            >
              <strong>{selectedMail.subject || t.noSubject}</strong>
              <button
                type="button"
                onClick={handleCloseMail}
                style={{
                  border: "none",
                  background: "transparent",
                  color: "#ffffff",
                  fontSize: "24px",
                  cursor: "pointer",
                }}
              >
                ×
              </button>
            </div>

            <div style={{ padding: "22px" }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "space-between",
                  marginBottom: "20px",
                }}
              >
                <div>
                  <strong>
                    {activeTab === "sent"
                      ? (selectedMail.recipient_name || selectedMail.recipient_user_email || selectedMail.recipient_phone || "Unknown recipient")
                      : (selectedMail.sender_name || selectedMail.sender_email || selectedMail.sender_phone || t.unknownSender)}
                  </strong>
                  <div
                    style={{
                      marginTop: "4px",
                      color: "#777184",
                      fontSize: "13px",
                    }}
                  >
                    {activeTab === "sent"
                      ? (selectedMail.recipient_user_email || selectedMail.recipient_phone)
                      : (selectedMail.sender_email || selectedMail.sender_phone)}
                  </div>
                </div>

                {activeTab !== "sent" && <button
                  type="button"
                  onClick={() => handleToggleStar(selectedMail)}
                  style={{
                    border: "none",
                    background: "transparent",
                    fontSize: "25px",
                    cursor: "pointer",
                  }}
                >
                  {selectedMail.is_starred ? "★" : "☆"}
                </button>}
              </div>

              <div
                style={{
                  color: "#2f2a3d",
                  whiteSpace: "pre-wrap",
                  lineHeight: "1.7",
                  minHeight: "160px",
                  padding: "18px",
                  borderRadius: "12px",
                  background: "#f8f7fc",
                }}
              >
                {selectedMail.body}
              </div>

              <div
                style={{
                  display: "flex",
                  justifyContent: "flex-end",
                  marginTop: "20px",
                }}
              >
                {activeTab !== "sent" && hasAlreadyReplied(selectedMail) ? (
                  <div
                    style={{
                      width: "100%",
                      textAlign: "center",
                      padding: "10px 14px",
                      borderRadius: "9px",
                      background: "#f3f1ff",
                      color: "#5b4cc4",
                      fontWeight: 700,
                    }}
                  >
                    You have already replied to this email.
                  </div>
                ) : activeTab !== "sent" && (
                <button
                  type="button"
                  onClick={() => handleReply(selectedMail)}
                  style={{
                    padding: "10px 20px",
                    border: "none",
                    borderRadius: "9px",
                    background: "linear-gradient(135deg, #4f46e5, #7c3aed)",
                    color: "#ffffff",
                    fontWeight: 700,
                    cursor: "pointer",
                  }}
                >
                  ↩ {t.reply}
                </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}



      {showCompose && (

        <div

          className="compose-overlay"

          onClick={() => {
            setShowCompose(false);
            setSelectedFiles([]);
            setReplyMode(false);
            setReplyOriginalMessageId(null);
          }}

        >



          <div

            className="compose-modal"

            onClick={(e) =>

              e.stopPropagation()

            }

          >



            <div className="compose-header">



              <strong>

                {t.newMessage}

              </strong>



              <button

                onClick={() => {
                  setShowCompose(false);
                  setSelectedFiles([]);
                  setReplyMode(false);
                  setReplyOriginalMessageId(null);
                }}

              >

                ×

              </button>



            </div>



            <form

              onSubmit={

                handleSendMail

              }

              className="compose-form"

            >



              <input

                type="text"

                placeholder={t.to}

                value={recipient}

                readOnly={replyMode}

                onChange={(e) =>

                  setRecipient(

                    e.target.value

                  )

                }

              />



              <input

                type="text"

                placeholder={t.subject}

                value={subject}

                readOnly={replyMode}

                onChange={(e) =>

                  setSubject(

                    e.target.value

                  )

                }

              />



              <textarea

                placeholder={t.writeMessage}

                value={body}

                onChange={(e) =>

                  setBody(

                    e.target.value

                  )

                }

              />

              <div
                style={{
                  display: "flex",
                  flexDirection: "column",
                  gap: "8px",
                  padding: "8px 0",
                }}
              >
                <label
                  style={{
                    display: "inline-flex",
                    alignItems: "center",
                    gap: "8px",
                    width: "fit-content",
                    cursor: selectedFiles.length >= 5 ? "not-allowed" : "pointer",
                    fontWeight: 600,
                  }}
                >
                  <span>📎 {t.attachFiles}</span>
                  <input
                    type="file"
                    multiple
                    disabled={selectedFiles.length >= 5}
                    onChange={(e) => {
                      const incoming = Array.from(e.target.files || []);
                      setSelectedFiles((current) => {
                        const combined = [...current, ...incoming];
                        const unique = [];
                        const seen = new Set();
                        for (const file of combined) {
                          const key = `${file.name}-${file.size}-${file.lastModified}`;
                          if (!seen.has(key)) {
                            seen.add(key);
                            unique.push(file);
                          }
                        }
                        return unique.slice(0, 5);
                      });
                      e.target.value = "";
                    }}
                    style={{ display: "none" }}
                  />
                </label>

                {selectedFiles.length > 0 && (
                  <div style={{ display: "flex", flexDirection: "column", gap: "5px" }}>
                    <span style={{ fontSize: "13px", color: "#777184" }}>
                      {selectedFiles.length} {t.filesSelected} (max 5)
                    </span>
                    {selectedFiles.map((file, index) => (
                      <div
                        key={`${file.name}-${file.size}-${file.lastModified}`}
                        style={{
                          display: "flex",
                          alignItems: "center",
                          justifyContent: "space-between",
                          gap: "10px",
                          padding: "6px 9px",
                          borderRadius: "8px",
                          background: "#f5f3fb",
                          fontSize: "13px",
                        }}
                      >
                        <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
                          📄 {file.name}
                        </span>
                        <button
                          type="button"
                          onClick={() =>
                            setSelectedFiles((current) => current.filter((_, i) => i !== index))
                          }
                          style={{ border: "none", background: "transparent", cursor: "pointer", fontWeight: 700 }}
                        >
                          {t.removeFile}
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>



              <div className="compose-footer">



                <span>

                  {t.sendingAs}{" "}

                  {user.email_address}

                </span>



                <button

                  type="submit"

                  disabled={sending}

                >

                  {sending

                    ? "Sending..."

                    : t.send}

                </button>



              </div>



            </form>



          </div>



        </div>

      )}



    </div>

  );

}



export default App;