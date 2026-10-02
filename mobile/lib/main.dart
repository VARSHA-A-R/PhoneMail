
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_hint_android/phone_hint_android.dart';
import 'package:sendotp_flutter_sdk/sendotp_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

/// ===============================================================
/// PHONEMAIL MOBILE
/// ===============================================================
/// Change ONLY these two values before running:
/// 1) API_BASE_URL -> the URL/IP where your PhoneMail backend is running.
/// 2) MSG91_WIDGET_ID / MSG91_AUTH_TOKEN -> your working MSG91 mobile
///    integration widget credentials.
///
/// The mobile app uses the same backend APIs as your working web client.
/// ===============================================================
const String API_BASE_URL = 'https://phonemail-backend-1bcr.onrender.com';
const String MSG91_WIDGET_ID = '3669446f744f373930313735';
const String MSG91_AUTH_TOKEN = String.fromEnvironment('MSG91_AUTH_TOKEN');
const int MAX_ATTACHMENTS = 5;
const int MAX_ATTACHMENT_SIZE = 100 * 1024 * 1024;

const Color pmBlue = Color(0xFF087FF5);
const Color pmBlueDark = Color(0xFF0667CA);
const Color pmBlueSoft = Color(0xFFEAF4FF);
const Color pmText = Color(0xFF172033);
const Color pmMuted = Color(0xFF7A8497);
const Color pmLine = Color(0xFFE9EDF3);
const Color pmBackground = Color(0xFFF7F9FC);


const Map<String, Map<String, String>> mobileTranslations = {
  'en': {
    'home': 'Home', 'drafts': 'Drafts', 'spam': 'Spam', 'trash': 'Trash',
    'profile': 'Profile & Settings', 'logout': 'Logout',
    'inbox': 'Inbox', 'sent': 'Sent', 'all': 'All', 'unread': 'Unread',
    'favorites': 'Favorites', 'attachments': 'Attachments',
    'search': 'Search phone number, sender, subject...',
    'noConversations': 'No conversations yet',
    'profilePicture': 'Tap to choose profile picture',
    'phoneNumber': 'Phone number', 'phonemailAddress': 'PhoneMail address',
    'displayName': 'Display name', 'yourName': 'Your name',
    'language': 'Language', 'save': 'Save changes', 'saving': 'Saving...',
    'compose': 'Compose', 'newEmail': 'New Email', 'to': 'To',
    'phoneOrAddress': 'Phone number or PhoneMail address',
    'writeMessage': 'Write your message...', 'attach': 'Attach',
    'emailSent': 'Email sent successfully.', 'send': 'Send', 'reply': 'Reply',
    'subject': 'Subject', 'message': 'Write your message...',
  },
  'ta': {
    'home': 'முகப்பு', 'drafts': 'வரைவுகள்', 'spam': 'ஸ்பேம்', 'trash': 'குப்பை',
    'profile': 'சுயவிவரம் & அமைப்புகள்', 'logout': 'வெளியேறு',
    'inbox': 'உள்வரும் அஞ்சல்', 'sent': 'அனுப்பியவை', 'all': 'அனைத்தும்',
    'unread': 'படிக்காதவை', 'favorites': 'பிடித்தவை', 'attachments': 'இணைப்புகள்',
    'search': 'தொலைபேசி எண், அனுப்புநர், தலைப்பைத் தேடு...',
    'noConversations': 'இன்னும் உரையாடல்கள் இல்லை',
    'profilePicture': 'சுயவிவரப் படத்தைத் தேர்ந்தெடுக்க தட்டவும்',
    'phoneNumber': 'தொலைபேசி எண்', 'phonemailAddress': 'PhoneMail முகவரி',
    'displayName': 'காட்சி பெயர்', 'yourName': 'உங்கள் பெயர்',
    'language': 'மொழி', 'save': 'மாற்றங்களைச் சேமி', 'saving': 'சேமிக்கப்படுகிறது...',
    'compose': 'புதிய அஞ்சல்', 'newEmail': 'புதிய அஞ்சல்', 'to': 'பெறுநர்',
    'phoneOrAddress': 'தொலைபேசி எண் அல்லது PhoneMail முகவரி',
    'writeMessage': 'உங்கள் செய்தியை எழுதுங்கள்...', 'attach': 'இணைக்கவும்',
    'emailSent': 'அஞ்சல் வெற்றிகரமாக அனுப்பப்பட்டது.', 'send': 'அனுப்பு',
    'reply': 'பதில்', 'subject': 'தலைப்பு', 'message': 'உங்கள் செய்தியை எழுதுங்கள்...',
  },
  'hi': {
    'home': 'होम', 'drafts': 'ड्राफ्ट', 'spam': 'स्पैम', 'trash': 'ट्रैश',
    'profile': 'प्रोफ़ाइल और सेटिंग्स', 'logout': 'लॉग आउट',
    'inbox': 'इनबॉक्स', 'sent': 'भेजे गए', 'all': 'सभी', 'unread': 'अपठित',
    'favorites': 'पसंदीदा', 'attachments': 'अटैचमेंट',
    'search': 'फ़ोन नंबर, प्रेषक, विषय खोजें...',
    'noConversations': 'अभी कोई बातचीत नहीं है',
    'profilePicture': 'प्रोफ़ाइल चित्र चुनने के लिए टैप करें',
    'phoneNumber': 'फ़ोन नंबर', 'phonemailAddress': 'PhoneMail पता',
    'displayName': 'प्रदर्शित नाम', 'yourName': 'आपका नाम',
    'language': 'भाषा', 'save': 'बदलाव सेव करें', 'saving': 'सेव किया जा रहा है...',
    'compose': 'लिखें', 'newEmail': 'नया ईमेल', 'to': 'प्राप्तकर्ता',
    'phoneOrAddress': 'फ़ोन नंबर या PhoneMail पता',
    'writeMessage': 'अपना संदेश लिखें...', 'attach': 'अटैच करें',
    'emailSent': 'ईमेल सफलतापूर्वक भेजा गया।', 'send': 'भेजें',
    'reply': 'जवाब दें', 'subject': 'विषय', 'message': 'अपना संदेश लिखें...',
  },
};

String mobileText(String language, String key) {
  return mobileTranslations[language]?[key] ?? mobileTranslations['en']![key] ?? key;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PhoneMailApp());
}

class PhoneMailApp extends StatelessWidget {
  const PhoneMailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhoneMail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: pmBlue),
        fontFamily: 'Roboto',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: pmLine, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: pmLine, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: pmBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
          ),
          labelStyle: const TextStyle(color: pmMuted),
          floatingLabelStyle: const TextStyle(
            color: pmBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const RootScreen(),
    );
  }
}

// -----------------------------------------------------------------
// Models
// -----------------------------------------------------------------

class MailMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String subject;
  final String body;
  final bool isRead;
  final bool isStarred;
  final int? replyToMessageId;
  final DateTime createdAt;
  final String senderPhone;
  final String senderEmail;
  final String senderName;
  final String recipientPhone;
  final String recipientEmail;
  final String recipientName;
  final List<AttachmentItem> attachments;

  const MailMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.subject,
    required this.body,
    required this.isRead,
    required this.isStarred,
    required this.replyToMessageId,
    required this.createdAt,
    this.senderPhone = '',
    this.senderEmail = '',
    this.senderName = '',
    this.recipientPhone = '',
    this.recipientEmail = '',
    this.recipientName = '',
    this.attachments = const [],
  });

  factory MailMessage.fromJson(
    Map<String, dynamic> j, {
    bool sent = false,
  }) {
    return MailMessage(
      id: int.tryParse('${j['id']}') ?? 0,
      conversationId: int.tryParse('${j['conversation_id'] ?? j['conversationId']}') ?? 0,
      senderId: int.tryParse('${j['sender_id'] ?? 0}') ?? 0,
      subject: '${j['subject'] ?? '(No subject)'}',
      body: '${j['body'] ?? ''}',
      isRead: j['is_read'] == true,
      isStarred: j['is_starred'] == true,
      replyToMessageId: j['reply_to_message_id'] == null
          ? null
          : int.tryParse('${j['reply_to_message_id']}'),
      createdAt: DateTime.tryParse('${j['created_at'] ?? ''}')?.toLocal() ??
          DateTime.now(),
      senderPhone: '${j['sender_phone'] ?? ''}',
      senderEmail: '${j['sender_email'] ?? ''}',
      senderName: '${j['sender_name'] ?? ''}',
      recipientPhone: '${j['recipient_phone'] ?? ''}',
      recipientEmail:
          '${j['recipient_email'] ?? j['recipient_user_email'] ?? ''}',
      recipientName: '${j['recipient_name'] ?? ''}',
      attachments: (j['attachments'] as List?)
              ?.whereType<Map>()
              .map((x) => AttachmentItem.fromJson(
                    Map<String, dynamic>.from(x),
                  ))
              .toList() ??
          const [],
    );
  }

  MailMessage copyWith({
    bool? isRead,
    bool? isStarred,
    List<AttachmentItem>? attachments,
  }) {
    return MailMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      subject: subject,
      body: body,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      replyToMessageId: replyToMessageId,
      createdAt: createdAt,
      senderPhone: senderPhone,
      senderEmail: senderEmail,
      senderName: senderName,
      recipientPhone: recipientPhone,
      recipientEmail: recipientEmail,
      recipientName: recipientName,
      attachments: attachments ?? this.attachments,
    );
  }

  String get displaySender =>
      senderName.isNotEmpty ? senderName : (senderPhone.isNotEmpty ? senderPhone : senderEmail);

  String get displayRecipient =>
      recipientName.isNotEmpty
          ? recipientName
          : (recipientPhone.isNotEmpty ? recipientPhone : recipientEmail);

  bool get hasAttachments => attachments.isNotEmpty;
}

class AttachmentItem {
  final int id;
  final int messageId;
  final String fileName;
  final String mimeType;
  final int fileSize;

  const AttachmentItem({
    required this.id,
    required this.messageId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
  });

  factory AttachmentItem.fromJson(Map<String, dynamic> j) {
    return AttachmentItem(
      id: int.tryParse('${j['id']}') ?? 0,
      messageId: int.tryParse('${j['message_id'] ?? 0}') ?? 0,
      fileName: '${j['file_name'] ?? ''}',
      mimeType: '${j['mime_type'] ?? 'application/octet-stream'}',
      fileSize: int.tryParse('${j['file_size'] ?? 0}') ?? 0,
    );
  }
}

class PickedAttachment {
  final String name;
  final Uint8List bytes;
  final String mimeType;

  PickedAttachment({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });
}

class AppUser {
  final int? id;
  final String phone;
  final String email;
  final String displayName;
  final String language;

  const AppUser({
    this.id,
    required this.phone,
    required this.email,
    required this.displayName,
    required this.language,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) {
    return AppUser(
      id: int.tryParse('${j['id'] ?? ''}'),
      phone: '${j['phone_number'] ?? j['phone'] ?? ''}',
      email: '${j['email_address'] ?? j['email'] ?? ''}',
      displayName: '${j['display_name'] ?? ''}',
      language: '${j['language'] ?? 'en'}',
    );
  }
}

class DraftItem {
  final String id;
  final String recipient;
  final String subject;
  final String body;
  final DateTime updatedAt;

  const DraftItem({
    required this.id,
    required this.recipient,
    required this.subject,
    required this.body,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipient': recipient,
        'subject': subject,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DraftItem.fromJson(Map<String, dynamic> j) => DraftItem(
        id: '${j['id'] ?? ''}',
        recipient: '${j['recipient'] ?? ''}',
        subject: '${j['subject'] ?? ''}',
        body: '${j['body'] ?? ''}',
        updatedAt: DateTime.tryParse('${j['updatedAt'] ?? ''}')?.toLocal() ?? DateTime.now(),
      );
}

Future<List<DraftItem>> loadLocalDrafts() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getStringList('phonemail_drafts') ?? [];
  final drafts = <DraftItem>[];
  for (final item in raw) {
    try {
      drafts.add(DraftItem.fromJson(Map<String, dynamic>.from(jsonDecode(item))));
    } catch (_) {}
  }
  drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return drafts;
}

Future<void> saveLocalDraft(DraftItem draft) async {
  final prefs = await SharedPreferences.getInstance();
  final drafts = await loadLocalDrafts();
  final index = drafts.indexWhere((d) => d.id == draft.id);
  if (index >= 0) {
    drafts[index] = draft;
  } else {
    drafts.insert(0, draft);
  }
  await prefs.setStringList(
    'phonemail_drafts',
    drafts.map((d) => jsonEncode(d.toJson())).toList(),
  );
}

Future<void> deleteLocalDraft(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final drafts = await loadLocalDrafts();
  drafts.removeWhere((d) => d.id == id);
  await prefs.setStringList(
    'phonemail_drafts',
    drafts.map((d) => jsonEncode(d.toJson())).toList(),
  );
}

// -----------------------------------------------------------------
// API
// -----------------------------------------------------------------

class ApiClient {
  String? token;

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

  Uri uri(String path) => Uri.parse('$API_BASE_URL$path');
Future<Map<String, dynamic>> jsonRequest(
  String method,
  String path, {
  Map<String, dynamic>? body,
}) async {
  final requestUri = uri(path);

  debugPrint('PHONEMAIL API REQUEST: $method $requestUri');

  try {
    http.Response response;

    if (method == 'GET') {
      response = await http.get(
        requestUri,
        headers: headers,
      );
    } else if (method == 'PATCH') {
      response = await http.patch(
        requestUri,
        headers: headers,
        body: jsonEncode(body ?? {}),
      );
    } else {
      response = await http.post(
        requestUri,
        headers: headers,
        body: jsonEncode(body ?? {}),
      );
    }

    debugPrint(
      'PHONEMAIL API RESPONSE: ${response.statusCode} ${response.body}',
    );

    Map<String, dynamic> data = {};

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } catch (decodeError) {
      debugPrint('PHONEMAIL JSON DECODE ERROR: $decodeError');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'Request failed (${response.statusCode}).',
      );
    }

    return data;
  } catch (e, stackTrace) {
    debugPrint('PHONEMAIL API ERROR: $e');
    debugPrint('PHONEMAIL API STACK: $stackTrace');
    rethrow;
  }
}
  Future<Map<String, dynamic>> checkPhone(String phone) async {
    return jsonRequest(
      'GET',
      '/api/auth/check-phone?phone=${Uri.encodeQueryComponent(phone)}',
    );
  }

  Future<Map<String, dynamic>> authenticate({
    required String phone,
    required String accessToken,
    required bool register,
  }) async {
    return jsonRequest(
      'POST',
      register ? '/api/auth/register' : '/api/auth/login',
      body: {
        'phone': phone,
        'accessToken': accessToken,
      },
    );
  }

  Future<List<MailMessage>> inbox() async {
    final data = await jsonRequest('GET', '/api/mail/inbox');
    return (data['messages'] as List? ?? [])
        .whereType<Map>()
        .map((x) => MailMessage.fromJson(Map<String, dynamic>.from(x)))
        .toList();
  }

  Future<List<MailMessage>> sent() async {
    final data = await jsonRequest('GET', '/api/mail/sent');
    return (data['messages'] as List? ?? [])
        .whereType<Map>()
        .map((x) => MailMessage.fromJson(
              Map<String, dynamic>.from(x),
              sent: true,
            ))
        .toList();
  }

  Future<List<MailMessage>> conversation(int conversationId) async {
    final data = await jsonRequest(
      'GET',
      '/api/mail/conversation/$conversationId',
    );
    return (data['messages'] as List? ?? [])
        .whereType<Map>()
        .map((x) => MailMessage.fromJson(Map<String, dynamic>.from(x)))
        .toList();
  }

  Future<void> markRead(int messageId) async {
    // Your current backend versions have used both forms.
    try {
      await jsonRequest(
        'PATCH',
        '/api/mail/message/$messageId/read',
        body: {'is_read': true},
      );
      return;
    } catch (_) {
      await jsonRequest(
        'PATCH',
        '/api/mail/$messageId/read',
        body: {'is_read': true},
      );
    }
  }

  Future<bool> toggleStar(int messageId) async {
    try {
      final data = await jsonRequest(
        'PATCH',
        '/api/mail/message/$messageId/star',
      );
      return data['is_starred'] == true;
    } catch (_) {
      final data = await jsonRequest(
        'PATCH',
        '/api/mail/$messageId/star',
        body: {'is_starred': true},
      );
      return data['is_starred'] == true;
    }
  }

  Future<Map<String, dynamic>> sendMail({
    required String recipient,
    required String subject,
    required String body,
    List<PickedAttachment> attachments = const [],
  }) async {
    final request = http.MultipartRequest(
      'POST',
      uri('/api/mail/send'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['recipient'] = recipient;
    request.fields['subject'] = subject;
    request.fields['body'] = body;

    for (final file in attachments) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'attachments',
          file.bytes,
          filename: file.name,
          contentType: _contentType(file.mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'Failed to send email (${response.statusCode}).',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> replyMail({
    required int originalMessageId,
    required String body,
    List<PickedAttachment> attachments = const [],
  }) async {
    final request = http.MultipartRequest(
      'POST',
      uri('/api/mail/reply'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['originalMessageId'] = '$originalMessageId';
    request.fields['body'] = body;

    for (final file in attachments) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'attachments',
          file.bytes,
          filename: file.name,
          contentType: _contentType(file.mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic> data = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        data = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        data['message']?.toString() ??
            'Failed to send reply (${response.statusCode}).',
      );
    }

    return data;
  }

  Future<List<MailMessage>> spam() async {
    final data = await jsonRequest('GET', '/api/mail/spam');
    return (data['messages'] as List? ?? [])
        .whereType<Map>()
        .map((x) => MailMessage.fromJson(Map<String, dynamic>.from(x)))
        .toList();
  }

  Future<List<MailMessage>> trash() async {
    final data = await jsonRequest('GET', '/api/mail/trash');
    return (data['messages'] as List? ?? [])
        .whereType<Map>()
        .map((x) => MailMessage.fromJson(Map<String, dynamic>.from(x)))
        .toList();
  }

  Future<void> moveToTrash(int messageId) async {
    await jsonRequest('PATCH', '/api/mail/message/$messageId/trash');
  }

  Future<void> restoreFromTrash(int messageId) async {
    await jsonRequest('PATCH', '/api/mail/message/$messageId/restore');
  }

  Future<void> markSpam(int messageId) async {
    await jsonRequest('PATCH', '/api/mail/message/$messageId/spam');
  }

  Future<void> markNotSpam(int messageId) async {
    await jsonRequest('PATCH', '/api/mail/message/$messageId/not-spam');
  }

  Future<AppUser> profile() async {
    final data = await jsonRequest('GET', '/api/auth/profile');
    return AppUser.fromJson(
      Map<String, dynamic>.from(data['user'] ?? data),
    );
  }

  Future<AppUser> updateProfile({
    required String displayName,
    required String language,
  }) async {
    final data = await jsonRequest(
      'PATCH',
      '/api/auth/profile',
      body: {
        'displayName': displayName,
        'language': language,
      },
    );
    return AppUser.fromJson(
      Map<String, dynamic>.from(data['user'] ?? data),
    );
  }

  Future<Uint8List> downloadAttachment(int id) async {
    final response = await http.get(
      uri('/api/mail/attachment/$id'),
      headers: {
        if (token != null && token!.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to download attachment.');
    }
    return response.bodyBytes;
  }

  MediaType? _contentType(String mime) {
    final parts = mime.split('/');
    if (parts.length == 2) {
      return MediaType(parts[0], parts[1]);
    }
    return null;
  }
}

// -----------------------------------------------------------------
// Root / onboarding
// -----------------------------------------------------------------

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final ApiClient api = ApiClient();

  bool loading = true;
  String? token;
  AppUser? user;
  String language = 'en';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('phonemail_token');
    final savedUser = prefs.getString('phonemail_user');
    final savedLanguage = prefs.getString('phonemail_language') ?? 'en';

    if (savedToken != null && savedUser != null) {
      try {
        final parsed = jsonDecode(savedUser);
        user = AppUser.fromJson(Map<String, dynamic>.from(parsed));
        token = savedToken;
        api.token = token;
      } catch (_) {
        await prefs.remove('phonemail_token');
        await prefs.remove('phonemail_user');
      }
    }

    language = savedLanguage;
    if (mounted) setState(() => loading = false);
  }

  Future<void> _loginCompleted(
    String newToken,
    AppUser newUser,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phonemail_token', newToken);
    await prefs.setString('phonemail_user', jsonEncode({
      'id': newUser.id,
      'phone_number': newUser.phone,
      'email_address': newUser.email,
      'display_name': newUser.displayName,
      'language': newUser.language,
    }));

    api.token = newToken;

    setState(() {
      token = newToken;
      user = newUser;
      language = newUser.language;
    });
  }

  Future<void> logout() async {
    // Logout is local because the current PhoneMail backend uses JWT auth
    // without a server-side logout endpoint. Clear every session value first,
    // then rebuild the root so the login page is shown immediately.
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove('phonemail_token'),
      prefs.remove('phonemail_user'),
    ]);

    api.token = null;

    if (!mounted) return;
    setState(() {
      token = null;
      user = null;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SplashScreen();
    }

    if (token == null || user == null) {
      final prefs = SharedPreferences.getInstance();

      return FutureBuilder<SharedPreferences>(
        future: prefs,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SplashScreen();
          }

          final onboardingComplete =
              snapshot.data!.getBool('phonemail_onboarding_complete') ?? false;

          return AuthFlow(
            api: api,
            language: language,
            initialPage: onboardingComplete ? 2 : 0,
            onComplete: _loginCompleted,
          );
        },
      );
    }

    return HomeScreen(
      api: api,
      user: user!,
      onLogout: logout,
      onUserChanged: (updated) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'phonemail_user',
          jsonEncode({
            'id': updated.id,
            'phone_number': updated.phone,
            'email_address': updated.email,
            'display_name': updated.displayName,
            'language': updated.language,
          }),
        );
        setState(() {
          user = updated;
          language = updated.language;
        });
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: BrandMark(size: 76),
      ),
    );
  }
}

class AuthFlow extends StatefulWidget {
  final ApiClient api;
  final String language;
  final int initialPage;
  final Future<void> Function(String token, AppUser user) onComplete;

  const AuthFlow({
    super.key,
    required this.api,
    required this.language,
    required this.initialPage,
    required this.onComplete,
  });

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  late int page;
  String selectedLanguage = 'en';
  bool register = false;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  bool loading = false;
  bool otpSent = false;
  String reqId = '';
  String? error;
  Timer? resendTimer;
  int resendSeconds = 25;

  @override
  void initState() {
    super.initState();
    page = widget.initialPage;
    selectedLanguage = widget.language;
    _initializeOtp();
    _requestPhoneHint();
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    resendTimer?.cancel();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  Future<void> _initializeOtp() async {
    try {
      OTPWidget.initializeWidget(
        MSG91_WIDGET_ID,
        MSG91_AUTH_TOKEN,
      );
    } catch (e) {
      debugPrint('MSG91 init error: $e');
    }
  }

  Future<void> _requestPhoneHint() async {
    if (!Platform.isAndroid) return;
    try {
      final value = await PhoneHintAndroid().getPhoneNumber();
      if (!mounted || value == null || value.isEmpty) return;

      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 10) {
        phoneController.text = digits.substring(digits.length - 10);
        setState(() {});
      }
    } catch (e) {
      debugPrint('Phone hint unavailable: $e');
    }
  }

  Future<void> _requestOnboardingPermissions() async {
    try {
      await FlutterContacts.permissions.request(
        PermissionType.readWrite,
      );
    } catch (_) {}

    try {
      await Permission.contacts.request();
    } catch (_) {}

    // SMS Retriever does not require SMS-read permission.
    // It listens through Google's SMS Retriever mechanism.
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => error = message);
  }

 Future<void> _sendOtp() async {
  debugPrint('PHONEMAIL SEND OTP: BUTTON PRESSED');

  FocusScope.of(context).unfocus();

  setState(() {
    error = null;
    loading = true;
  });

  final phone = phoneController.text.replaceAll(RegExp(r'\D'), '');

  debugPrint('PHONEMAIL SEND OTP: PHONE = $phone');

  if (phone.length != 10) {
    debugPrint('PHONEMAIL SEND OTP: INVALID PHONE');

    _showError('Enter a valid 10-digit mobile number.');
    setState(() => loading = false);
    return;
  }

  try {
    debugPrint('PHONEMAIL SEND OTP: CHECKING ACCOUNT');

    final check = await widget.api.checkPhone(phone);

    debugPrint('PHONEMAIL SEND OTP: ACCOUNT CHECK RESULT = $check');

    final exists = check['exists'] == true;

    debugPrint('PHONEMAIL SEND OTP: EXISTS = $exists');
    debugPrint('PHONEMAIL SEND OTP: REGISTER = $register');

    if (register && exists) {
      _showError('This account already exists. Please use Login.');
      setState(() => loading = false);
      return;
    }

    if (!register && !exists) {
      _showError(
        'No account exists with this number. Please create an account.',
      );
      setState(() => loading = false);
      return;
    }

    debugPrint('PHONEMAIL SEND OTP: INITIALIZING MSG91');

    await _initializeOtp();

    debugPrint('PHONEMAIL SEND OTP: MSG91 INITIALIZED');

    try {
      await SmsAutoFill().listenForCode();
    } catch (e) {
      debugPrint('PHONEMAIL SMS AUTOFILL ERROR: $e');
    }

    debugPrint('PHONEMAIL SEND OTP: CALLING MSG91');

    final response = await OTPWidget.sendOTP({
      'identifier': '91$phone',
    });

    debugPrint('PHONEMAIL SEND OTP: MSG91 RESPONSE = $response');

    if (response == null || response['type'] != 'success') {
      throw Exception(
        response?['message']?.toString() ??
            response?['error']?.toString() ??
            'Unable to send OTP.',
      );
    }

    reqId = response['message']?.toString() ?? '';

    debugPrint('PHONEMAIL SEND OTP: OTP SENT, REQ ID RECEIVED');

    setState(() {
      otpSent = true;
      page = 3;
      loading = false;
    });

    _startResendTimer();
  } catch (e, stackTrace) {
    debugPrint('PHONEMAIL SEND OTP ERROR: $e');
    debugPrint('PHONEMAIL SEND OTP STACK: $stackTrace');

    _showError(_cleanError(e));
    setState(() => loading = false);
  }
}

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    final otp = otpController.text.trim();

    if (otp.length < 4) {
      _showError('Enter the complete OTP.');
      return;
    }

    setState(() {
      error = null;
      loading = true;
    });

    try {
      final response = await OTPWidget.verifyOTP({
        'reqId': reqId,
        'otp': otp,
      });

      debugPrint('MSG91 verify response: $response');

      if (response == null || response['type'] != 'success') {
        throw Exception(
          response?['message']?.toString() ??
              response?['error']?.toString() ??
              'Invalid OTP.',
        );
      }

      final accessToken = _extractAccessToken(response);
      if (accessToken.isEmpty) {
        throw Exception('MSG91 access token was not received.');
      }

      final phone = phoneController.text.replaceAll(RegExp(r'\D'), '');
      final data = await widget.api.authenticate(
        phone: phone,
        accessToken: accessToken,
        register: register,
      );

      final newToken = '${data['token'] ?? ''}';
      if (newToken.isEmpty) {
        throw Exception('PhoneMail login token was not received.');
      }

      final newUser = AppUser.fromJson(
        Map<String, dynamic>.from(data['user'] ?? {}),
      );

      await widget.onComplete(newToken, newUser);
    } catch (e) {
      _showError(_cleanError(e));
      setState(() => loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (resendSeconds > 0 || reqId.isEmpty) return;

    setState(() {
      error = null;
      loading = true;
    });

    try {
      final response = await OTPWidget.retryOTP({
        'reqId': reqId,
      });

      debugPrint('MSG91 retry response: $response');

      if (response == null || response['type'] != 'success') {
        throw Exception(
          response?['message']?.toString() ??
              response?['error']?.toString() ??
              'Unable to resend OTP.',
        );
      }

      try {
        await SmsAutoFill().listenForCode();
      } catch (_) {}

      _startResendTimer();
      setState(() => loading = false);
    } catch (e) {
      _showError(_cleanError(e));
      setState(() => loading = false);
    }
  }

  void _startResendTimer() {
    resendTimer?.cancel();
    setState(() => resendSeconds = 25);

    resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        if (resendSeconds <= 1) {
          timer.cancel();
          setState(() => resendSeconds = 0);
        } else {
          setState(() => resendSeconds--);
        }
      },
    );
  }

  String _extractAccessToken(dynamic data) {
    if (data is String) return data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      for (final key in [
        'access-token',
        'accessToken',
        'access_token',
        'token',
        'message',
      ]) {
        final value = map[key];
        if (value is String && value.isNotEmpty && value.length > 10) {
          return value;
        }
      }
      final nested = map['data'];
      if (nested is Map) {
        return _extractAccessToken(nested);
      }
    }
    return '';
  }

  String _cleanError(Object e) {
    final text = e.toString().replaceFirst('Exception: ', '');
    if (text.toLowerCase().contains('captcha')) {
      return 'OTP session expired. Please resend the OTP and try again.';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (page) {
            0 => _languagePage(),
            1 => _termsPage(),
            2 => _phonePage(),
            _ => _otpPage(),
          },
        ),
      ),
    );
  }

  Widget _languagePage() {
    return Padding(
      key: const ValueKey('language'),
      padding: const EdgeInsets.fromLTRB(28, 45, 28, 28),
      child: Column(
        children: [
          const Spacer(),
          const BrandMark(size: 100),
          const SizedBox(height: 18),
          const BrandTitle(),
          const SizedBox(height: 14),
          const Text(
            'Your phone number.\nYour email address.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: pmMuted,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose your language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: pmText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _languageChoice('English', 'en'),
          _languageChoice('தமிழ்', 'ta'),
          _languageChoice('हिन्दी', 'hi'),
          const Spacer(),
          _primaryButton(
            label: 'Continue',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('phonemail_language', selectedLanguage);
              await _requestOnboardingPermissions();
              setState(() => page = 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _languageChoice(String title, String value) {
    final selected = selectedLanguage == value;
    return GestureDetector(
      onTap: () => setState(() => selectedLanguage = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: selected ? pmBlueSoft : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? pmBlue : pmLine,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? pmBlue : pmMuted,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: pmText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsPage() {
    return Padding(
      key: const ValueKey('terms'),
      padding: const EdgeInsets.fromLTRB(28, 25, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => setState(() => page = 0),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Spacer(),
          const Center(child: BrandMark(size: 82)),
          const SizedBox(height: 18),
          const Center(child: BrandTitle()),
          const SizedBox(height: 35),
          const Text(
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: pmText,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'PhoneMail lets you use your phone number as your email identity. '
            'By continuing, you agree to use the service responsibly and accept '
            'the PhoneMail Terms of Service and Privacy Policy.',
            style: TextStyle(
              color: pmMuted,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const Spacer(),
          _primaryButton(
            label: 'I Agree & Continue',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              await prefs.setBool(
                'phonemail_onboarding_complete',
                true,
              );

              if (!mounted) return;

              setState(() {
                page = 2;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _phonePage() {
    return Padding(
      key: const ValueKey('phone'),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 25),
      child: Column(
        children: [
          const SizedBox(height: 35),
          const BrandMark(size: 88),
          const SizedBox(height: 15),
          const BrandTitle(),
          const SizedBox(height: 35),
          Text(
            register ? 'Create your PhoneMail account' : 'Welcome back!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: pmText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            register
                ? 'Use your phone number as your email identity.'
                : 'Login securely using your phone number.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: pmMuted, fontSize: 14),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pmBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: pmLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: pmBlue, size: 17),
                    SizedBox(width: 7),
                    Text(
                      'Auto-detected number',
                      style: TextStyle(
                        color: pmBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [
                    AutofillHints.telephoneNumberDevice,
                  ],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(
                    color: pmText,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: pmBlue,
                  decoration: InputDecoration(
                    prefixText: '+91   ',
                    prefixStyle: const TextStyle(
                      color: pmText,
                      fontWeight: FontWeight.w600,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _requestPhoneHint,
                      icon: const Icon(Icons.edit_outlined, color: pmBlue),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: pmLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: pmLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: pmBlue, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: pmLine),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: pmBlue, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: pmBlue),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'You can edit or use a different number.',
                        style: TextStyle(color: pmMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            _errorBox(error!),
          ],
          const Spacer(),
          _primaryButton(
            label: loading ? 'Please wait...' : 'Send OTP  →',
            onPressed: loading ? null : _sendOtp,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: loading
                ? null
                : () {
                    setState(() {
                      register = !register;
                      error = null;
                    });
                  },
            child: Text(
              register
                  ? 'Already have an account? Login'
                  : 'New to PhoneMail? Create Account',
              style: const TextStyle(color: pmBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otpPage() {
    return Padding(
      key: const ValueKey('otp'),
      padding: const EdgeInsets.fromLTRB(22, 15, 22, 25),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: loading
                  ? null
                  : () => setState(() {
                        page = 2;
                        otpSent = false;
                        otpController.clear();
                      }),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          const BrandMark(size: 82),
          const SizedBox(height: 14),
          const BrandTitle(),
          const SizedBox(height: 35),
          const Text(
            'Verifying your number',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: pmText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We've sent an OTP to +91 ${phoneController.text}",
            textAlign: TextAlign.center,
            style: const TextStyle(color: pmMuted, fontSize: 14),
          ),
          const SizedBox(height: 28),
          PinFieldAutoFill(
            codeLength: 6,
            currentCode: otpController.text,
            onCodeChanged: (code) {
              if (code != null) {
                otpController.text = code;
                if (code.length == 6 && !loading) {
                  _verifyOtp();
                }
                setState(() {});
              }
            },
            decoration: BoxLooseDecoration(
              strokeColorBuilder:
                  const FixedColorBuilder(pmBlue),
              bgColorBuilder:
                  const FixedColorBuilder(Colors.white),
              gapSpace: 8,
              radius: const Radius.circular(9),
              strokeWidth: 1.3,
            ),
          ),
          const SizedBox(height: 22),
          TextButton(
            onPressed: resendSeconds == 0 && !loading ? _resendOtp : null,
            child: Text(
              resendSeconds == 0
                  ? 'Resend OTP'
                  : 'Resend OTP in 00:${resendSeconds.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: resendSeconds == 0 ? pmBlue : pmMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 6),
            _errorBox(error!),
          ],
          const Spacer(),
          _outlineButton(
            label: loading ? 'Verifying...' : 'Verify',
            onPressed: loading ? null : _verifyOtp,
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: pmBlue,
          disabledBackgroundColor: pmBlue.withOpacity(.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: pmBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            color: pmBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Home
// -----------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  final ApiClient api;
  final AppUser user;
  final Future<void> Function() onLogout;
  final Future<void> Function(AppUser user) onUserChanged;

  const HomeScreen({
    super.key,
    required this.api,
    required this.user,
    required this.onLogout,
    required this.onUserChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MailMessage> inbox = [];
  List<MailMessage> sent = [];
  bool loading = true;
  bool refreshing = false;
  String search = '';
  late String filter;
  int? selectedConversation;
  bool menuOpen = false;

  @override
  void initState() {
    super.initState();
    filter = mobileText(widget.user.language, 'all');
    loadAll();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.language != widget.user.language) {
      setState(() {
        filter = mobileText(widget.user.language, 'all');
      });
    }
  }

  Future<void> loadAll() async {
    if (mounted) {
      setState(() {
        if (inbox.isEmpty) loading = true;
        refreshing = true;
      });
    }

    try {
      final results = await Future.wait([
        widget.api.inbox(),
        widget.api.sent(),
      ]);

      if (!mounted) return;

      setState(() {
        inbox = results[0];
        sent = results[1];
        loading = false;
        refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        refreshing = false;
      });
      _snack(_cleanError(e));
    }
  }

  List<MailMessage> get allMessages {
    final map = <int, MailMessage>{};

    for (final m in [...inbox, ...sent]) {
      final current = map[m.id];
      if (current == null) {
        map[m.id] = m;
      } else {
        map[m.id] = current.copyWith(
          isRead: current.isRead || m.isRead,
          isStarred: current.isStarred || m.isStarred,
        );
      }
    }

    return map.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<MailMessage> get conversations {
    final grouped = <int, List<MailMessage>>{};

    for (final m in allMessages) {
      grouped.putIfAbsent(m.conversationId, () => []).add(m);
    }

    final latest = grouped.values
        .map((list) => list.reduce(
              (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
            ))
        .toList();

    latest.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return latest.where((m) {
      final text = search.toLowerCase().trim();
      if (text.isNotEmpty) {
        final haystack = [
          m.displaySender,
          m.displayRecipient,
          m.senderPhone,
          m.recipientPhone,
          m.subject,
          m.body,
        ].join(' ').toLowerCase();

        if (!haystack.contains(text)) return false;
      }

      if (filter == mobileText(widget.user.language, 'unread')) {
        final conversationMessages =
            grouped[m.conversationId] ?? [];

        return conversationMessages.any(
          (message) =>
              inbox.any((received) => received.id == message.id) &&
              !message.isRead,
        );
      }
      if (filter == mobileText(widget.user.language, 'favorites')) {
        return m.isStarred;
      }
      if (filter == mobileText(widget.user.language, 'attachments')) {
        return m.hasAttachments;
      }
      return true;
    }).toList();
  }

  Future<void> toggleStar(MailMessage mail) async {
    final newValue = !mail.isStarred;

    void localUpdate() {
      setState(() {
        inbox = inbox
            .map((m) => m.id == mail.id ? m.copyWith(isStarred: newValue) : m)
            .toList();
        sent = sent
            .map((m) => m.id == mail.id ? m.copyWith(isStarred: newValue) : m)
            .toList();
      });
    }

    localUpdate();

    try {
      // Current backend toggles the DB value. If it returns the actual state,
      // use it; otherwise the optimistic state above remains.
      final actual = await widget.api.toggleStar(mail.id);
      if (actual != newValue && mounted) {
        setState(() {
          inbox = inbox
              .map((m) => m.id == mail.id ? m.copyWith(isStarred: actual) : m)
              .toList();
          sent = sent
              .map((m) => m.id == mail.id ? m.copyWith(isStarred: actual) : m)
              .toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        inbox = inbox
            .map((m) => m.id == mail.id ? m.copyWith(isStarred: !newValue) : m)
            .toList();
        sent = sent
            .map((m) => m.id == mail.id ? m.copyWith(isStarred: !newValue) : m)
            .toList();
      });
      _snack(_cleanError(e));
    }
  }

  Future<void> moveToTrash(MailMessage mail) async {
    try {
      await widget.api.moveToTrash(mail.id);
      await loadAll();
    } catch (e) {
      _snack(_cleanError(e));
    }
  }

  Future<void> moveToSpam(MailMessage mail) async {
    try {
      await widget.api.markSpam(mail.id);
      await loadAll();
    } catch (e) {
      _snack(_cleanError(e));
    }
  }

  Future<void> openConversation(MailMessage mail) async {
    try {
      await widget.api.markRead(mail.id);

      if (mounted) {
        setState(() {
          inbox = inbox.map((m) {
            if (m.id == mail.id) {
              return m.copyWith(isRead: true);
            }
            return m;
          }).toList();
        });
      }
    } catch (_) {}

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          api: widget.api,
          conversationId: mail.conversationId,
          initialMessage: mail,
          user: widget.user,
          onChanged: loadAll,
        ),
      ),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _cleanError(Object e) =>
      e.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    if (selectedConversation != null) {
      return ConversationScreen(
        api: widget.api,
        conversationId: selectedConversation!,
        user: widget.user,
        onChanged: loadAll,
      );
    }

    final chats = conversations;

    return Scaffold(
      backgroundColor: pmBackground,
      drawer: AppDrawer(
        api: widget.api,
        user: widget.user,
        onLogout: widget.onLogout,
        onHome: () => Navigator.pop(context),
        onProfile: () async {
          Navigator.pop(context);
          final updated = await Navigator.push<AppUser>(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                api: widget.api,
                user: widget.user,
              ),
            ),
          );
          if (updated != null) {
            await widget.onUserChanged(updated);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _searchBar(),
            _filterChips(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      color: pmBlue,
                      onRefresh: loadAll,
                      child: chats.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 130),
                                Center(
                                  child: Text(
                                    mobileText(widget.user.language, 'noConversations'),
                                    style: const TextStyle(
                                      color: pmMuted,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 2, 12, 90),
                              itemCount: chats.length,
                              itemBuilder: (_, i) {
                                final mail = chats[i];

                                final conversationMessages =
                                    allMessages
                                        .where((message) => message.conversationId == mail.conversationId)
                                        .toList();

                                final isUnread = conversationMessages.any(
                                  (message) =>
                                      inbox.any((received) => received.id == message.id) &&
                                      !message.isRead,
                                );

                                return ChatCard(
                                  mail: mail,
                                  isUnread: isUnread,
                                  onTap: () => openConversation(mail),
                                  onStar: () => toggleStar(mail),
                                  onTrash: () => moveToTrash(mail),
                                  onSpam: () => moveToSpam(mail),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        onPressed: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ComposeScreen(
                api: widget.api,
                user: widget.user,
              ),
            ),
          );
          if (changed == true) loadAll();
        },
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 10),
      decoration: const BoxDecoration(
        color: pmBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
          ),
          const Text(
            'PhoneMail',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              final updated = await Navigator.push<AppUser>(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    api: widget.api,
                    user: widget.user,
                  ),
                ),
              );
              if (updated != null) await widget.onUserChanged(updated);
            },
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white,
              child: Text(
                (widget.user.displayName.isNotEmpty
                        ? widget.user.displayName
                        : widget.user.phone)
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  color: pmBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 7),
      child: TextField(
        onChanged: (v) => setState(() => search = v),
        decoration: InputDecoration(
          hintText: mobileText(widget.user.language, 'search'),
          hintStyle: const TextStyle(color: pmMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: pmMuted, size: 20),
          suffixIcon: refreshing
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: pmLine),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: pmLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: pmBlue, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    return SizedBox(
      height: 46,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        scrollDirection: Axis.horizontal,
        children: [
          _chip(mobileText(widget.user.language, 'all'), Icons.all_inbox_outlined),
          _chip(mobileText(widget.user.language, 'unread'), Icons.mark_email_unread_outlined),
          _chip(mobileText(widget.user.language, 'favorites'), Icons.star_border_rounded),
          _chip(mobileText(widget.user.language, 'attachments'), Icons.attach_file_rounded),
        ],
      ),
    );
  }

  Widget _chip(String title, IconData icon) {
    final selected = filter == title;
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => filter = title),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : pmMuted,
            ),
            const SizedBox(width: 4),
            Text(title),
          ],
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : pmMuted,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        selectedColor: pmBlue,
        backgroundColor: Colors.white,
        side: const BorderSide(color: pmLine),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  final MailMessage mail;
  final bool isUnread;
  final VoidCallback onTap;
  final VoidCallback onStar;
  final VoidCallback onTrash;
  final VoidCallback onSpam;

  const ChatCard({
    super.key,
    required this.mail,
    required this.isUnread,
    required this.onTap,
    required this.onStar,
    required this.onTrash,
    required this.onSpam,
  });

  @override
  Widget build(BuildContext context) {
    final title = mail.displaySender.isNotEmpty
        ? mail.displaySender
        : mail.displayRecipient;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: pmLine.withOpacity(.65)),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: pmBlueSoft,
          child: Text(
            (title.isEmpty ? 'U' : title.substring(0, 1)).toUpperCase(),
            style: const TextStyle(
              color: pmBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: pmText,
                  fontWeight:
                    isUnread ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              _time(mail.createdAt),
              style: const TextStyle(
                color: pmMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text(
              mail.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: pmText,
                fontWeight:
                    isUnread ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              mail.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: pmMuted,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
        trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onStar,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                icon: Icon(
                  mail.isStarred
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: mail.isStarred ? pmBlue : pmMuted,
                  size: 22,
                ),
              ),

              SizedBox(
                width: 32,
                height: 36,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    color: pmMuted,
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'trash') {
                      onTrash();
                    }

                    if (value == 'spam') {
                      onSpam();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'trash',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 8),
                          Text('Move to Trash'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'spam',
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_gmailerrorred_outlined,
                          ),
                          SizedBox(width: 8),
                          Text('Report Spam'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isUnread)
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: const BoxDecoration(
                    color: pmBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
      ),
    );
  }

  static String _time(DateTime date) {
    final now = DateTime.now();
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;

    if (sameDay) {
      final h = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
      final m = date.minute.toString().padLeft(2, '0');
      return '$h:$m ${date.hour >= 12 ? 'PM' : 'AM'}';
    }
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

// -----------------------------------------------------------------
// Drawer
// -----------------------------------------------------------------

class AppDrawer extends StatelessWidget {
  final ApiClient api;
  final AppUser user;
  final Future<void> Function() onLogout;
  final VoidCallback onHome;
  final VoidCallback onProfile;

  const AppDrawer({
    super.key,
    required this.api,
    required this.user,
    required this.onLogout,
    required this.onHome,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
              color: pmBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      (user.displayName.isNotEmpty
                              ? user.displayName
                              : user.phone)
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: pmBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName.isEmpty ? 'PhoneMail user' : user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _item(context, Icons.home_outlined, mobileText(user.language, 'home'), onHome),
            _item(context, Icons.drafts_outlined, mobileText(user.language, 'drafts'), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => DraftsScreen(api: api, user: user)));
            }),
            _item(context, Icons.report_gmailerrorred_outlined, mobileText(user.language, 'spam'), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => MailFolderScreen(api: api, user: user, folder: MailFolder.spam)));
            }),
            _item(context, Icons.delete_outline_rounded, mobileText(user.language, 'trash'), () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => MailFolderScreen(api: api, user: user, folder: MailFolder.trash)));
            }),
            const Divider(height: 30),
            _item(context, Icons.person_outline, mobileText(user.language, 'profile'), onProfile),
            const Spacer(),
            _item(
              context,
              Icons.logout_rounded,
              mobileText(user.language, 'logout'),
              () async {
                Navigator.pop(context);
                await onLogout();
              },
              danger: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool danger = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: danger ? Colors.red : pmText),
      title: Text(
        title,
        style: TextStyle(
          color: danger ? Colors.red : pmText,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}

// -----------------------------------------------------------------
// Conversation
// -----------------------------------------------------------------

class ConversationScreen extends StatefulWidget {
  final ApiClient api;
  final int conversationId;
  final MailMessage? initialMessage;
  final AppUser user;
  final Future<void> Function()? onChanged;

  const ConversationScreen({
    super.key,
    required this.api,
    required this.conversationId,
    this.initialMessage,
    required this.user,
    this.onChanged,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<MailMessage> messages = [];
  bool loading = true;
  bool sending = false;

  final replyController = TextEditingController();
  final List<PickedAttachment> replyAttachments = [];

  @override
  void initState() {
    super.initState();
    loadConversation();
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  Future<void> loadConversation() async {
    try {
      final data = await widget.api.conversation(widget.conversationId);

      if (!mounted) return;

      setState(() {
        messages = data;
        loading = false;
      });

      for (final m in data) {
        if (!m.isRead && m.senderId != widget.user.id) {
          try {
            await widget.api.markRead(m.id);
          } catch (_) {}
        }
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(e)),
        ),
      );
    }
  }

  Future<void> pickReplyAttachments() async {
    debugPrint('PHONEMAIL ATTACHMENT: + BUTTON PRESSED');

    if (sending) {
      debugPrint('PHONEMAIL ATTACHMENT: SENDING IS TRUE');
      return;
    }

    if (replyAttachments.length >= MAX_ATTACHMENTS) {
      debugPrint('PHONEMAIL ATTACHMENT: MAXIMUM ATTACHMENTS REACHED');

      _snack(
        'Maximum $MAX_ATTACHMENTS attachments are allowed.',
      );

      return;
    }

    try {
      debugPrint('PHONEMAIL ATTACHMENT: OPENING FILE PICKER');

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: true,
      );

      debugPrint(
        'PHONEMAIL ATTACHMENT: FILE PICKER RESULT = $result',
      );

      if (result == null) {
        debugPrint('PHONEMAIL ATTACHMENT: USER CANCELLED');

        return;
      }

      debugPrint(
        'PHONEMAIL ATTACHMENT: FILES SELECTED = ${result.files.length}',
      );

      for (final file in result.files) {
        if (replyAttachments.length >= MAX_ATTACHMENTS) {
          break;
        }

        debugPrint(
          'PHONEMAIL ATTACHMENT: READING FILE = ${file.name}',
        );

        final bytes = file.bytes ??
            (file.path == null
                ? null
                : await File(file.path!).readAsBytes());

        if (bytes == null) {
          debugPrint(
            'PHONEMAIL ATTACHMENT: UNABLE TO READ ${file.name}',
          );

          _snack(
            'Unable to read ${file.name}.',
          );

          continue;
        }

        debugPrint(
          'PHONEMAIL ATTACHMENT: SIZE = ${bytes.length} BYTES',
        );

        if (bytes.length > MAX_ATTACHMENT_SIZE) {
          debugPrint(
            'PHONEMAIL ATTACHMENT: FILE TOO LARGE',
          );

          _snack(
            '${file.name} is larger than 100 MB.',
          );

          continue;
        }

        replyAttachments.add(
          PickedAttachment(
            name: file.name,
            bytes: bytes,
            mimeType: _mimeForName(file.name),
          ),
        );

        debugPrint(
          'PHONEMAIL ATTACHMENT: ADDED ${file.name}',
        );
      }

      if (mounted) {
        setState(() {});
      }

      debugPrint(
        'PHONEMAIL ATTACHMENT: TOTAL = ${replyAttachments.length}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'PHONEMAIL ATTACHMENT ERROR: $e',
      );

      debugPrint(
        'PHONEMAIL ATTACHMENT STACK: $stackTrace',
      );

      if (mounted) {
        _snack(
          'Unable to open attachments: ${_cleanError(e)}',
        );
      }
    }
  }

  Future<void> reply() async {
    final body = replyController.text.trim();

    if (body.isEmpty && replyAttachments.isEmpty) {
      _snack(
        'Write a reply or attach a file.',
      );
      return;
    }

    final candidates = messages
        .where(
          (m) => m.senderId != widget.user.id,
        )
        .toList();

    if (candidates.isEmpty) {
      _snack(
        'There is no incoming message to reply to.',
      );
      return;
    }

    final original = candidates.last;

    final hasExistingReply = messages.any(
      (m) => m.replyToMessageId == original.id,
    );

    if (hasExistingReply) {
      _snack(
        'This message has already been replied to.',
      );
      return;
    }

    setState(() => sending = true);

    try {
      await widget.api.replyMail(
        originalMessageId: original.id,
        body: body,
        attachments: replyAttachments,
      );

      replyController.clear();
      replyAttachments.clear();

      await loadConversation();
      await widget.onChanged?.call();
    } catch (e) {
      _snack(
        _cleanError(e),
      );
    } finally {
      if (mounted) {
        setState(() => sending = false);
      }
    }
  }

  Future<void> openTraditionalReply(
    MailMessage message,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TraditionalReplyScreen(
          api: widget.api,
          user: widget.user,
          original: message,
        ),
      ),
    );

    if (changed == true) {
      await loadConversation();
      await widget.onChanged?.call();
    }
  }

  void _snack(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  String _cleanError(Object e) {
    return e.toString().replaceFirst(
          'Exception: ',
          '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final title = messages.isNotEmpty
        ? (messages.first.senderName.isNotEmpty
            ? messages.first.senderName
            : messages.first.senderPhone)
        : (widget.initialMessage?.displaySender ??
            'Conversation');

    return Scaffold(
      backgroundColor: pmBackground,
      appBar: AppBar(
        backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conversation View',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      16,
                      12,
                      15,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final message = messages[i];
                      final mine =
                          message.senderId == widget.user.id;

                      return MessageBubble(
                        message: message,
                        mine: mine,
                        onReplyTraditional: mine
                            ? null
                            : () => openTraditionalReply(
                                  message,
                                ),
                        api: widget.api,
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.fromLTRB(
                    10,
                    8,
                    10,
                    12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: pmLine,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (replyAttachments.isNotEmpty)
                              SizedBox(
                                height: 38,
                                child: ListView.builder(
                                  scrollDirection:
                                      Axis.horizontal,
                                  itemCount:
                                      replyAttachments.length,
                                  itemBuilder: (_, i) {
                                    final file =
                                        replyAttachments[i];

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                        right: 6,
                                      ),
                                      child: Chip(
                                        label:
                                            ConstrainedBox(
                                          constraints:
                                              const BoxConstraints(
                                            maxWidth: 130,
                                          ),
                                          child: Text(
                                            file.name,
                                            overflow:
                                                TextOverflow
                                                    .ellipsis,
                                          ),
                                        ),
                                        deleteIcon:
                                            const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        onDeleted: () {
                                          setState(
                                            () => replyAttachments
                                                .removeAt(i),
                                          );
                                        },
                                        visualDensity:
                                            VisualDensity
                                                .compact,
                                      ),
                                    );
                                  },
                                ),
                              ),

                            TextField(
                              controller: replyController,
                              minLines: 1,
                              maxLines: 5,
                              decoration: InputDecoration(
                                hintText:
                                    'Type your message here...',
                                prefixIcon: IconButton(
                                  onPressed: sending
                                      ? null
                                      : () {
                                          debugPrint(
                                            'PHONEMAIL ATTACHMENT: ICON CLICKED',
                                          );

                                          pickReplyAttachments();
                                        },
                                  icon: const Icon(
                                    Icons
                                        .add_circle_outline,
                                    color: pmBlue,
                                  ),
                                  tooltip:
                                      'Attach files',
                                ),
                                filled: true,
                                fillColor: pmBackground,
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    22,
                                  ),
                                  borderSide:
                                      BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 7),

                      CircleAvatar(
                        radius: 23,
                        backgroundColor: pmBlue,
                        child: IconButton(
                          onPressed:
                              sending ? null : reply,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}



class MessageBubble extends StatelessWidget {
  final MailMessage message;
  final bool mine;
  final VoidCallback? onReplyTraditional;
  final ApiClient api;

  const MessageBubble({
    super.key,
    required this.message,
    required this.mine,
    required this.onReplyTraditional,
    required this.api,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onReplyTraditional,
      onTap: message.body.length > 500
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TraditionalMessageScreen(
                    message: message,
                  ),
                ),
              );
            }
          : null,
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 330),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 9),
          decoration: BoxDecoration(
            color: mine ? pmBlueSoft : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(17),
              topRight: const Radius.circular(17),
              bottomLeft: Radius.circular(mine ? 17 : 4),
              bottomRight: Radius.circular(mine ? 4 : 17),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!mine && message.subject.isNotEmpty)
                Text(
                  message.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: pmText,
                    fontSize: 13,
                  ),
                ),
              if (!mine) const SizedBox(height: 7),
              Text(
                message.body,
                style: const TextStyle(
                  color: pmText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              if (message.attachments.isNotEmpty) ...[
                const SizedBox(height: 10),
                ...message.attachments.map(
                  (a) => AttachmentTile(
                    attachment: a,
                    api: api,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _time(message.createdAt),
                  style: TextStyle(
                    color: mine ? pmBlue : pmMuted,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _time(DateTime date) {
    final h = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    return '$h:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
}

class TraditionalMessageScreen extends StatelessWidget {
  final MailMessage message;

  const TraditionalMessageScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        title: const Text('Email'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            message.subject,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: pmText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'From: ${message.displaySender}',
            style: const TextStyle(color: pmMuted),
          ),
          const Divider(height: 28),
          Text(
            message.body,
            style: const TextStyle(
              color: pmText,
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class AttachmentTile extends StatelessWidget {
  final AttachmentItem attachment;
  final ApiClient api;

  const AttachmentTile({
    super.key,
    required this.attachment,
    required this.api,
  });

  Future<void> _open(BuildContext context) async {
    try {
      final bytes = await api.downloadAttachment(attachment.id);
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final safeName = attachment.fileName.replaceAll(
        RegExp(r'[\\/:*?"<>|]'),
        '_',
      );
      final file = File('${dir.path}/$safeName');
      await file.writeAsBytes(bytes);
      await OpenFilex.open(file.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _open(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: pmLine),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.picture_as_pdf_outlined,
              color: pmBlue,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                attachment.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: pmText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(
              Icons.download_outlined,
              color: pmMuted,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Compose
// -----------------------------------------------------------------

class ComposeScreen extends StatefulWidget {
  final ApiClient api;
  final AppUser user;
  final DraftItem? draft;

  const ComposeScreen({
    super.key,
    required this.api,
    required this.user,
    this.draft,
  });

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final recipient = TextEditingController();
  late String draftId;
  final subject = TextEditingController();
  final body = TextEditingController();

  final List<PickedAttachment> attachments = [];
  bool sending = false;

  @override
  void initState() {
    super.initState();
    draftId = widget.draft?.id ?? DateTime.now().microsecondsSinceEpoch.toString();
    if (widget.draft != null) {
      recipient.text = widget.draft!.recipient;
      subject.text = widget.draft!.subject;
      body.text = widget.draft!.body;
    }
  }

  Future<void> saveDraft() async {
    if (recipient.text.trim().isEmpty && subject.text.trim().isEmpty && body.text.trim().isEmpty) {
      return;
    }
    await saveLocalDraft(DraftItem(
      id: draftId,
      recipient: recipient.text.trim(),
      subject: subject.text.trim(),
      body: body.text,
      updatedAt: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    recipient.dispose();
    subject.dispose();
    body.dispose();
    super.dispose();
  }

  Future<void> pickAttachments() async {
    if (attachments.length >= MAX_ATTACHMENTS) {
      _snack('Maximum $MAX_ATTACHMENTS attachments are allowed.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );

    if (result == null) return;

    for (final file in result.files) {
      if (attachments.length >= MAX_ATTACHMENTS) break;

      final bytes = file.bytes ??
          (file.path == null ? null : await File(file.path!).readAsBytes());

      if (bytes == null) {
        _snack('Unable to read ${file.name}.');
        continue;
      }

      if (bytes.length > MAX_ATTACHMENT_SIZE) {
        _snack('${file.name} is larger than 100 MB.');
        continue;
      }

      attachments.add(
        PickedAttachment(
          name: file.name,
          bytes: bytes,
          mimeType: _mimeForName(file.name),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  Future<void> send() async {
    if (recipient.text.trim().isEmpty) {
      _snack('Enter a recipient phone number or PhoneMail address.');
      return;
    }
    if (body.text.trim().isEmpty && attachments.isEmpty) {
      _snack('Write your message or attach a file.');
      return;
    }

    setState(() => sending = true);

    try {
      await widget.api.sendMail(
        recipient: recipient.text.trim(),
        subject: subject.text.trim(),
        body: body.text.trim(),
        attachments: attachments,
      );

      await deleteLocalDraft(draftId);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mobileText(widget.user.language, 'emailSent'))),
        );
      }
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        saveDraft();
      },
      child: Scaffold(
        backgroundColor: pmBackground,
        appBar: AppBar(
          backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        title: Text(
          mobileText(widget.user.language, 'newEmail'),
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _field(
            controller: recipient,
            label: mobileText(widget.user.language, 'to'),
            hint: mobileText(widget.user.language, 'phoneOrAddress'),
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 10),
          _field(
            controller: subject,
            label: mobileText(widget.user.language, 'subject'),
            hint: mobileText(widget.user.language, 'subject'),
            icon: Icons.subject_outlined,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: body,
            minLines: 12,
            maxLines: 18,
            decoration: InputDecoration(
              hintText: mobileText(widget.user.language, 'writeMessage'),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: pmLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: pmLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: pmBlue, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: pickAttachments,
                icon: const Icon(Icons.attach_file_rounded),
                label: Text('${mobileText(widget.user.language, 'attach')} (${attachments.length}/$MAX_ATTACHMENTS)'),
              ),
            ],
          ),
          ...attachments.asMap().entries.map(
                (entry) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.insert_drive_file_outlined,
                    color: pmBlue,
                  ),
                  title: Text(entry.value.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => attachments.removeAt(entry.key));
                    },
                  ),
                ),
              ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: sending ? null : () async {
              await saveDraft();
              if (mounted) {
                Navigator.pop(context, false);
              }
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Draft'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: sending ? null : send,
              style: FilledButton.styleFrom(
                backgroundColor: pmBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.send_rounded),
              label: Text(
                sending ? 'Sending...' : 'Send',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: pmBlue),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: pmLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: pmLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: pmBlue, width: 1.5),
        ),
      ),
    );
  }
}

class TraditionalReplyScreen extends StatefulWidget {
  final ApiClient api;
  final AppUser user;
  final MailMessage original;

  const TraditionalReplyScreen({
    super.key,
    required this.api,
    required this.user,
    required this.original,
  });

  @override
  State<TraditionalReplyScreen> createState() =>
      _TraditionalReplyScreenState();
}

class _TraditionalReplyScreenState extends State<TraditionalReplyScreen> {
  final body = TextEditingController();
  final List<PickedAttachment> attachments = [];
  bool sending = false;

  @override
  void dispose() {
    body.dispose();
    super.dispose();
  }

  Future<void> pickAttachments() async {
    if (attachments.length >= MAX_ATTACHMENTS) {
      _snack('Maximum $MAX_ATTACHMENTS attachments are allowed.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;

    for (final file in result.files) {
      if (attachments.length >= MAX_ATTACHMENTS) break;
      final bytes = file.bytes ??
          (file.path == null ? null : await File(file.path!).readAsBytes());
      if (bytes == null) {
        _snack('Unable to read ${file.name}.');
        continue;
      }
      if (bytes.length > MAX_ATTACHMENT_SIZE) {
        _snack('${file.name} is larger than 100 MB.');
        continue;
      }
      attachments.add(PickedAttachment(
        name: file.name,
        bytes: bytes,
        mimeType: _mimeForName(file.name),
      ));
    }
    if (mounted) setState(() {});
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> send() async {
    if (body.text.trim().isEmpty && attachments.isEmpty) {
      _snack('Write your reply or attach a file.');
      return;
    }

    setState(() => sending = true);

    try {
      await widget.api.replyMail(
        originalMessageId: widget.original.id,
        body: body.text.trim(),
        attachments: attachments,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pmBackground,
      appBar: AppBar(
        backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        title: const Text('Reply'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: pmLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to',
                  style: TextStyle(
                    color: pmMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.original.displaySender,
                  style: const TextStyle(
                    color: pmText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.original.subject,
                  style: const TextStyle(color: pmMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: body,
            minLines: 14,
            maxLines: 20,
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: pmLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: pmLine),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: sending ? null : pickAttachments,
            icon: const Icon(Icons.attach_file_rounded),
            label: Text('Attach (${attachments.length}/$MAX_ATTACHMENTS)'),
          ),
          ...attachments.asMap().entries.map(
            (entry) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined, color: pmBlue),
              title: Text(entry.value.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => attachments.removeAt(entry.key)),
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: sending ? null : send,
              style: FilledButton.styleFrom(
                backgroundColor: pmBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.send_rounded),
              label: Text(sending ? 'Sending...' : 'Send Reply'),
            ),
          ),
        ],
      ),
    );
  }
}

enum MailFolder { spam, trash }

class MailFolderScreen extends StatefulWidget {
  final ApiClient api;
  final AppUser user;
  final MailFolder folder;

  const MailFolderScreen({
    super.key,
    required this.api,
    required this.user,
    required this.folder,
  });

  @override
  State<MailFolderScreen> createState() => _MailFolderScreenState();
}

class _MailFolderScreenState extends State<MailFolderScreen> {
  List<MailMessage> messages = [];
  bool loading = true;

  String get title => widget.folder == MailFolder.spam
      ? mobileText(widget.user.language, 'spam')
      : mobileText(widget.user.language, 'trash');

  Future<void> load() async {
    setState(() => loading = true);
    try {
      messages = widget.folder == MailFolder.spam
          ? await widget.api.spam()
          : await widget.api.trash();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> _restore(MailMessage message) async {
    try {
      if (widget.folder == MailFolder.spam) {
        await widget.api.markNotSpam(message.id);
      } else {
        await widget.api.restoreFromTrash(message.id);
      }
      await load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pmBackground,
      appBar: AppBar(
        backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: RefreshIndicator(
        color: pmBlue,
        onRefresh: load,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : messages.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 150),
                      Center(child: Text('This folder is empty.')),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final message = messages[index];
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: pmLine),
                        ),
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConversationScreen(
                                api: widget.api,
                                conversationId: message.conversationId,
                                initialMessage: message,
                                user: widget.user,
                              ),
                            ),
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: pmBlueSoft,
                            child: Icon(Icons.mail_outline, color: pmBlue),
                          ),
                          title: Text(
                            message.displaySender.isNotEmpty
                                ? message.displaySender
                                : message.displayRecipient,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${message.subject}\n${message.body}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            tooltip: widget.folder == MailFolder.spam
                                ? 'Not spam'
                                : 'Restore',
                            icon: Icon(
                              widget.folder == MailFolder.spam
                                  ? Icons.mark_email_read_outlined
                                  : Icons.restore_from_trash_outlined,
                              color: pmBlue,
                            ),
                            onPressed: () => _restore(message),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class DraftsScreen extends StatefulWidget {
  final ApiClient api;
  final AppUser user;

  const DraftsScreen({
    super.key,
    required this.api,
    required this.user,
  });

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  List<DraftItem> drafts = [];
  bool loading = true;

  Future<void> load() async {
    final result = await loadLocalDrafts();
    if (mounted) {
      setState(() {
        drafts = result;
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> _open(DraftItem draft) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComposeScreen(
          api: widget.api,
          user: widget.user,
          draft: draft,
        ),
      ),
    );
    load();
  }

  Future<void> _delete(DraftItem draft) async {
    await deleteLocalDraft(draft.id);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pmBackground,
      appBar: AppBar(
        backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        title: Text(mobileText(widget.user.language, 'drafts')),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : drafts.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 150),
                    Center(child: Text('No drafts.')),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: drafts.length,
                  itemBuilder: (_, index) {
                    final draft = drafts[index];
                    final preview = draft.body.trim().isNotEmpty
                        ? draft.body.trim()
                        : '(No message)';
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: pmLine),
                      ),
                      child: ListTile(
                        onTap: () => _open(draft),
                        leading: const CircleAvatar(
                          backgroundColor: pmBlueSoft,
                          child: Icon(Icons.drafts_outlined, color: pmBlue),
                        ),
                        title: Text(
                          draft.recipient.isEmpty
                              ? 'Draft'
                              : draft.recipient,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${draft.subject.isEmpty ? '(No subject)' : draft.subject}\n$preview',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _delete(draft),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// -----------------------------------------------------------------
// Profile
// -----------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  final ApiClient api;
  final AppUser user;

  const ProfileScreen({
    super.key,
    required this.api,
    required this.user,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController name;
  late String language;
  XFile? profileImage;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.user.displayName);
    language = widget.user.language.isEmpty ? 'en' : widget.user.language;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> pickProfile() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null && mounted) {
      setState(() => profileImage = image);
    }
  }

  Future<void> save() async {
    setState(() => saving = true);
    try {
      final updated = await widget.api.updateProfile(
        displayName: name.text.trim(),
        language: language,
      );
      if (mounted) Navigator.pop(context, updated);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pmBackground,
      appBar: AppBar(
        backgroundColor: pmBlue,
        foregroundColor: Colors.white,
        title: Text(mobileText(widget.user.language, 'profile')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: pickProfile,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: pmBlueSoft,
                backgroundImage: profileImage == null
                    ? null
                    : FileImage(File(profileImage!.path)),
                child: profileImage == null
                    ? Text(
                        (name.text.isNotEmpty ? name.text : widget.user.phone)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: pmBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              mobileText(widget.user.language, 'profilePicture'),
              style: const TextStyle(color: pmMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 25),
          _label(mobileText(widget.user.language, 'phoneNumber')),
          _readonly(widget.user.phone),
          const SizedBox(height: 14),
          _label(mobileText(widget.user.language, 'phonemailAddress')),
          _readonly(
            widget.user.email.isNotEmpty
                ? widget.user.email
                : '${widget.user.phone}@phonemail.com',
          ),
          const SizedBox(height: 14),
          _label(mobileText(widget.user.language, 'displayName')),
          TextField(
            controller: name,
            decoration: _decoration(mobileText(widget.user.language, 'yourName')),
          ),
          const SizedBox(height: 14),
          _label(mobileText(widget.user.language, 'language')),
          DropdownButtonFormField<String>(
            value: language,
            decoration: _decoration(mobileText(widget.user.language, 'language')),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ta', child: Text('தமிழ்')),
              DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
            ],
            onChanged: (v) => setState(() => language = v ?? 'en'),
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: saving ? null : save,
              style: FilledButton.styleFrom(
                backgroundColor: pmBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(saving ? mobileText(widget.user.language, 'saving') : mobileText(widget.user.language, 'save')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: pmText,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _readonly(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: pmLine),
      ),
      child: Text(
        value,
        style: const TextStyle(color: pmMuted),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: pmLine),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: pmLine),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: pmBlue, width: 1.5),
      ),
    );
  }
}

// -----------------------------------------------------------------
// Branding/helpers
// -----------------------------------------------------------------

class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: pmBlue.withOpacity(.18),
          width: 1.3,
        ),
      ),
      child: Center(
        child: Container(
          width: size * .58,
          height: size * .68,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * .12),
            border: Border.all(color: pmText, width: 2.2),
          ),
          child: Center(
            child: Container(
              width: size * .40,
              height: size * .30,
              decoration: BoxDecoration(
                color: pmBlue,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          color: pmText,
        ),
        children: [
          TextSpan(text: 'Phone'),
          TextSpan(
            text: 'Mail',
            style: TextStyle(color: pmBlue),
          ),
        ],
      ),
    );
  }
}

Widget _errorBox(String text) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFFD1D1)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFFC62828),
        fontSize: 12,
      ),
    ),
  );
}

String _mimeForName(String name) {
  final ext = name.toLowerCase().split('.').last;
  const map = {
    'pdf': 'application/pdf',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'txt': 'text/plain',
    'csv': 'text/csv',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'zip': 'application/zip',
  };
  return map[ext] ?? 'application/octet-stream';
}
