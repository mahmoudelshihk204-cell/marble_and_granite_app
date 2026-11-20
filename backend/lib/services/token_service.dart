import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class TokenService {
  // استخراج اسم الـ Schema من أول وآخر حرف في الـ Token
  static String extractSchema(String token) {
    final cleanToken = token.trim();

    if (cleanToken.length < 3 ||
        !RegExp(r'^\d').hasMatch(cleanToken) ||
        !RegExp(r'\d$').hasMatch(cleanToken)) {
      throw const FormatException('Invalid token format');
    }

    return 'EXP20${cleanToken[0]}${cleanToken[cleanToken.length - 1]}';
  }

  // استخراج الجزء المشفر من الـ Token
  static String extractEncryptedPart(String token) {
    final cleanToken = token.trim();

    if (cleanToken.length < 3) {
      throw const FormatException('Invalid token format');
    }

    return cleanToken.substring(1, cleanToken.length - 1);
  }

  // فك تشفير Base64 ثم AES-128-ECB وإزالة PKCS7 Padding
  static String decryptBaseUrl(String token) {
    // قراءة المفتاح من متغيرات بيئة السيرفر
    final key = Platform.environment['TOKEN_AES_KEY'];

    if (key == null || key.isEmpty) {
      throw StateError('TOKEN_AES_KEY is not configured');
    }

    final keyBytes = Uint8List.fromList(utf8.encode(key));

    // التأكد إن المفتاح 16 بايت بالضبط
    if (keyBytes.length != 16) {
      throw StateError('Invalid AES-128 key length');
    }

    // تحويل الجزء المشفر من Base64 إلى bytes
    final encryptedBytes = base64.decode(extractEncryptedPart(token));

    if (encryptedBytes.isEmpty || encryptedBytes.length % 16 != 0) {
      throw const FormatException('Invalid encrypted token length');
    }

    // إعداد AES للعمل بوضع ECB وفك التشفير
    final cipher = AESEngine()..init(false, KeyParameter(keyBytes));

    final decryptedBytes = Uint8List(encryptedBytes.length);

    // فك تشفير كل Block (حجمه 16 بايت)
    for (var offset = 0; offset < encryptedBytes.length; offset += 16) {
      cipher.processBlock(encryptedBytes, offset, decryptedBytes, offset);
    }

    // قراءة قيمة PKCS7 Padding من آخر byte
    final paddingLength = decryptedBytes.last;

    if (paddingLength < 1 || paddingLength > 16) {
      throw const FormatException('Invalid PKCS7 padding');
    }

    // التأكد إن كل bytes الخاصة بالـ Padding صحيحة
    for (
      var i = decryptedBytes.length - paddingLength;
      i < decryptedBytes.length;
      i++
    ) {
      if (decryptedBytes[i] != paddingLength) {
        throw const FormatException('Invalid PKCS7 padding');
      }
    }

    // إزالة الـ Padding وإرجاع النص الأصلي
    final plainBytes = decryptedBytes.sublist(
      0,
      decryptedBytes.length - paddingLength,
    );

    return utf8.decode(plainBytes);
  }

  // اختبار فك التشفير ومقارنة النتيجة بالـ Base URL المتوقع
  static bool testToken(String token, String expectedBaseUrl) {
    final decryptedUrl = decryptBaseUrl(token);
    return decryptedUrl == expectedBaseUrl;
  }
}
