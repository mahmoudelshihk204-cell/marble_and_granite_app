
import 'package:test/test.dart';
import 'package:backend/services/token_service.dart';

void main() {
  // حط هنا الـ Token التجريبي اللي اختبرته قبل كده
  const token = '1iTBzLfStDk2RdVIeoIu3yTeNy0QMMzeceOtNa1FTnEQ=3';

  // حط هنا الـ Base URL الأصلي اللي اتشفّر داخل الـ Token
  const expectedBaseUrl = 'www.TopSoftware.127.0.0.1.net';

  group('TokenService Tests', () {
    test('Extract schema from token', () {
      expect(TokenService.extractSchema(token), 'EXP2013');
    });

    test('Decrypt token and get original Base URL', () {
      expect(
        TokenService.decryptBaseUrl(token),
        expectedBaseUrl,
      );
    });

    test('Compare decrypted URL with expected URL', () {
      expect(
        TokenService.testToken(token, expectedBaseUrl),
        isTrue,
      );
    });
  });
}
