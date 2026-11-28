import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:backend/services/token_service.dart';
import 'package:backend/services/topsoftware_api_client.dart';

typedef TopSoftwareClientFactory =
    TopSoftwareApiClient Function({
      required String username,
      required String password,
      required String token,
    });

class TopSoftwareAuthApi {
  TopSoftwareAuthApi({this._clientFactory});

  final TopSoftwareClientFactory? _clientFactory;

  static const int _maxRequestBodyBytes = 64 * 1024;

  // قراءة الطلب مع تحديد أقصى حجم مسموح.
  Future<String> _readRequestBody(Request request) async {
    final contentLength = request.headers['content-length'];

    if (contentLength != null) {
      final length = int.tryParse(contentLength);

      if (length != null && length > _maxRequestBodyBytes) {
        throw const RequestBodyTooLargeException();
      }
    }

    final builder = BytesBuilder(copy: false);

    await for (final chunk in request.read()) {
      if (builder.length + chunk.length > _maxRequestBodyBytes) {
        throw const RequestBodyTooLargeException();
      }

      builder.add(chunk);
    }

    return utf8.decode(builder.takeBytes());
  }

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
    if (_clientFactory != null) {
      return _clientFactory(
        username: username.trim(),
        password: password,
        token: token,
      );
    }

    final schema = TokenService.extractSchema(token);
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
    final body = await _readRequestBody(request);
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

        final session = await client.login();

        return _jsonResponse(200, {
          'success': true,
          'message': 'Login successful',
          'data': {'employeeNumber': session.employeeNo},
        });
      } on TimeoutException {
        return _jsonResponse(504, {
          'success': false,
          'message': 'TopSoftware server timed out. Please try again later.',
        });
      } on RequestBodyTooLargeException {
        return _jsonResponse(413, {
          'success': false,
          'message': 'Request body is too large',
        });
      } on FormatException {
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid JSON or token format',
        });
      } on TopSoftwareApiException catch (error) {
        if (error.message.startsWith('TopSoftware login failed.')) {
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
        print('LOGIN STACK TRACE:');
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
        final requestBody = await _readRequestBody(request);
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
            'message': 'Username, password, token and barcode are required',
          });
        }

        client = _createClient(
          username: username,
          password: password,
          token: token,
        );

        final item = await client.searchByBarcode(barcode);

        return _jsonResponse(200, {
          'success': true,
          'message': 'Item found successfully',
          'data': item,
        });
      } on TimeoutException {
        return _jsonResponse(504, {
          'success': false,
          'message': 'TopSoftware server timed out. Please try again later.',
        });
      } on RequestBodyTooLargeException {
        return _jsonResponse(413, {
          'success': false,
          'message': 'Request body is too large',
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
      } on TopSoftwareApiException {
        return _jsonResponse(502, {
          'success': false,
          'message': 'Barcode search service error',
        });
      } catch (_) {
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
        final requestBody = await _readRequestBody(request);
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
            'message': 'Username, password, token and blockNumber are required',
          });
        }

        client = _createClient(
          username: username,
          password: password,
          token: token,
        );

        final blockData = await client.searchBlockStat(blockNumber.trim());

        return _jsonResponse(200, {
          'success': true,
          'message': 'Block data retrieved successfully',
          'data': blockData,
        });
      } on TimeoutException {
        return _jsonResponse(504, {
          'success': false,
          'message': 'TopSoftware server timed out. Please try again later.',
        });
      } on RequestBodyTooLargeException {
        return _jsonResponse(413, {
          'success': false,
          'message': 'Request body is too large',
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
      } on TopSoftwareApiException {
        return _jsonResponse(502, {
          'success': false,
          'message': 'Block search service error',
        });
      } catch (_) {
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

class RequestBodyTooLargeException implements Exception {
  const RequestBodyTooLargeException();
}
