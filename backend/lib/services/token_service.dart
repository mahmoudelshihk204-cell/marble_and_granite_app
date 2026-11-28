import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class TokenService {
  // قراءة مفتاح AES من متغيرات بيئة السيرفر.
  static Uint8List _loadKeyBytes() {
    final String aesKey = Platform.environment['TOPSOFTWARE_AES_KEY'] ?? '';

    if (aesKey.isEmpty) {
      throw StateError('Encryption configuration is unavailable');
    }

    final keyBytes = Uint8List.fromList(utf8.encode(aesKey));

    if (keyBytes.length != 16) {
      throw StateError('Invalid encryption configuration');
    }

    return keyBytes;
  }

  // استخراج اسم Schema من أول وآخر رقم في Token.
  static String extractSchema(String token) {
    final cleanToken = token.trim();

    if (cleanToken.length < 3 ||
        !RegExp(r'^\d').hasMatch(cleanToken) ||
        !RegExp(r'\d$').hasMatch(cleanToken)) {
      throw const FormatException('Invalid token format');
    }

    return 'EXP20${cleanToken[0]}${cleanToken[cleanToken.length - 1]}';
  }

  // استخراج الجزء المشفر من Token.
  static String extractEncryptedPart(String token) {
    final cleanToken = token.trim();

    if (cleanToken.length < 3) {
      throw const FormatException('Invalid token format');
    }

    return cleanToken.substring(1, cleanToken.length - 1);
  }

  // فك AES-128-ECB مع إزالة PKCS7 Padding.
  static String decryptBaseUrl(String token) {
    final keyBytes = _loadKeyBytes();

    final encryptedBytes = base64.decode(extractEncryptedPart(token));

    if (encryptedBytes.isEmpty || encryptedBytes.length % 16 != 0) {
      throw const FormatException('Invalid encrypted token length');
    }

    final cipher = AESEngine()..init(false, KeyParameter(keyBytes));

    final decryptedBytes = Uint8List(encryptedBytes.length);

    for (var offset = 0; offset < encryptedBytes.length; offset += 16) {
      cipher.processBlock(encryptedBytes, offset, decryptedBytes, offset);
    }

    final paddingLength = decryptedBytes.last;

    if (paddingLength < 1 || paddingLength > 16) {
      throw const FormatException('Invalid PKCS7 padding');
    }

    for (
      var i = decryptedBytes.length - paddingLength;
      i < decryptedBytes.length;
      i++
    ) {
      if (decryptedBytes[i] != paddingLength) {
        throw const FormatException('Invalid PKCS7 padding');
      }
    }

    final plainBytes = decryptedBytes.sublist(
      0,
      decryptedBytes.length - paddingLength,
    );

    return utf8.decode(plainBytes);
  }

  // اختبار فك التشفير ومقارنة النتيجة بالعنوان المتوقع.
  static bool testToken(String token, String expectedBaseUrl) {
    final decryptedUrl = decryptBaseUrl(token);
    return decryptedUrl == expectedBaseUrl;
  }
}
