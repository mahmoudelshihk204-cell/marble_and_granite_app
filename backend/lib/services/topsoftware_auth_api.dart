
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:backend/services/token_service.dart';
import 'package:backend/services/topsoftware_api_client.dart';

class TopSoftwareAuthApi {
  // توحيد شكل استجابة JSON ودعم اللغة العربية.
  Response _jsonResponse(int statusCode, Map<String, dynamic> data) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  // إنشاء TopSoftware Client باستخدام بيانات المستخدم والـ Token.
  TopSoftwareApiClient _createClient({
    required String username,
    required String password,
    required String token,
  }) {
    // استخراج اسم الـ Schema من أول وآخر حرف في Token.
    final schema = TokenService.extractSchema(token);

    // فك تشفير الجزء الأوسط واستخراج BaseURL.
    final baseUrl = TokenService.decryptBaseUrl(token);

    return TopSoftwareApiClient(
      baseUrl: baseUrl,
      username: username.trim(),
      password: password,
      schema: schema,
    );
  }

  // قراءة والتحقق من بيانات المستخدم القادمة في JSON.
  Future<Map<String, String>?> _readUserData(Request request) async {
    final body = await request.readAsString();
    final dynamic decoded = jsonDecode(body);

    if (decoded is! Map) {
      return null;
    }

    final username = decoded['username'];
    final password = decoded['password'];
    final token = decoded['token'];

    if (username is! String ||
        password is! String ||
        token is! String ||
        username.trim().isEmpty ||
        password.isEmpty ||
        token.trim().isEmpty) {
      return null;
    }

    return {
      'username': username.trim(),
      'password': password,
      'token': token.trim(),
    };
  }

  Router get router {
    final router = Router();

    // ==========================================
    // 1. تسجيل دخول المستخدم.
    // ==========================================
    router.post('/api/auth/login', (Request request) async {
      TopSoftwareApiClient? client;

      try {
        final userData = await _readUserData(request);

        if (userData == null) {
          return _jsonResponse(400, {
            'success': false,
            'message': 'Invalid login data',
          });
        }

        client = _createClient(
          username: userData['username']!,
          password: userData['password']!,
          token: userData['token']!,
        );

        // تنفيذ تسجيل الدخول على TopSoftware الأصلي.
        final session = await client.login();

        return _jsonResponse(200, {
          'success': true,
          'message': 'Login successful',
          'data': {
            'employeeNumber': session.employeeNo,
          },
        });
      } on FormatException {
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid JSON or token format',
        });
      } on TopSoftwareApiException catch (error) {
        print('TopSoftware login error: $error');

        if (error.message.startsWith('Login failed:')) {
          return _jsonResponse(401, {
            'success': false,
            'message': 'Invalid username or password',
          });
        }

        return _jsonResponse(502, {
          'success': false,
          'message': 'TopSoftware login service error',
        });
      } catch (error, stackTrace) {
        print('LOGIN ERROR: $error');
        print(stackTrace);

        return _jsonResponse(500, {
          'success': false,
          'message': 'Internal server error',
        });
      } finally {
        client?.close();
      }
    });

    // ==========================================
    // 2. البحث عن صنف باستخدام الباركود.
    // ==========================================
    router.post('/api/items/search/barcode', (Request request) async {
      TopSoftwareApiClient? client;

      try {
        // قراءة بيانات الطلب مرة واحدة.
        final requestBody = await request.readAsString();
        final dynamic body = jsonDecode(requestBody);

        if (body is! Map) {
          return _jsonResponse(400, {
            'success': false,
            'message': 'Invalid request format',
          });
        }

        final username = body['username'];
        final password = body['password'];
        final token = body['token'];
        final barcode = body['barcode'];

        // التحقق من بيانات الدخول والباركود.
        if (username is! String ||
            password is! String ||
            token is! String ||
            barcode is! String ||
            username.trim().isEmpty ||
            password.isEmpty ||
            token.trim().isEmpty ||
            barcode.trim().isEmpty) {
          return _jsonResponse(400, {
            'success': false,
            'message':
                'Username, password, token and barcode are required',
          });
        }

        // إنشاء Client خاص بالمستخدم.
        client = _createClient(
          username: username,
          password: password,
          token: token,
        );

        // البحث على سيرفر TopSoftware الأصلي.
        // الدالة بتعمل Login وتحصل على Session ثم تبحث بالباركود.
        final item = await client.searchByBarcode(barcode);

        return _jsonResponse(200, {
          'success': true,
          'message': 'Item found successfully',
          'data': item,
        });
      } on FormatException {
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid JSON or token format',
        });
      } on ArgumentError {
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid barcode',
        });
      } on TopSoftwareApiException catch (error) {
        print('TopSoftware barcode error: $error');

        return _jsonResponse(502, {
          'success': false,
          'message': 'Barcode search service error',
        });
      } catch (error, stackTrace) {
        print('BARCODE SEARCH ERROR: $error');
        print(stackTrace);

        return _jsonResponse(500, {
          'success': false,
          'message': 'Internal server error',
        });
      } finally {
        client?.close();
      }
    });

    // ==========================================
    // 3. البحث عن تفاصيل البلوك.
    // ==========================================
    router.post('/api/blocks/search/stat', (Request request) async {
      TopSoftwareApiClient? client;

      try {
        // قراءة بيانات الطلب.
        final requestBody = await request.readAsString();
        final dynamic body = jsonDecode(requestBody);

        if (body is! Map) {
          return _jsonResponse(400, {
            'success': false,
            'message': 'Invalid request format',
          });
        }

        final username = body['username'];
        final password = body['password'];
        final token = body['token'];
        final blockNumber = body['blockNumber'];

        // التأكد من وجود كل البيانات المطلوبة.
        if (username is! String ||
            password is! String ||
            token is! String ||
            blockNumber is! String ||
            username.trim().isEmpty ||
            password.isEmpty ||
            token.trim().isEmpty ||
            blockNumber.trim().isEmpty) {
          return _jsonResponse(400, {
            'success': false,
            'message':
                'Username, password, token and blockNumber are required',
          });
        }

        // إنشاء Client خاص بالمستخدم.
        client = _createClient(
          username: username,
          password: password,
          token: token,
        );

        // البحث عن البلوك في TopSoftware.
        // الدالة بتعمل Login ثم تستدعي blockstat.
        final blockData = await client.searchBlockStat(
          blockNumber.trim(),
        );

        return _jsonResponse(200, {
          'success': true,
          'message': 'Block data retrieved successfully',
          'data': blockData,
        });
      } on FormatException {
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid JSON or token format',
        });
      } on ArgumentError {
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid block number',
        });
      } on TopSoftwareApiException catch (error) {
        print('TopSoftware block stat error: $error');

        return _jsonResponse(502, {
          'success': false,
          'message': 'Block search service error',
        });
      } catch (error, stackTrace) {
        print('BLOCK SEARCH ERROR: $error');
        print(stackTrace);

        return _jsonResponse(500, {
          'success': false,
          'message': 'Internal server error',
        });
      } finally {
        client?.close();
      }
    });

    return router;
  }
}
