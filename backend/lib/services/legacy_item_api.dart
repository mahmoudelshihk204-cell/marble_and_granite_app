// ignore_for_file: unused_element
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/services/token_service.dart';
import 'package:backend/services/topsoftware_api_client.dart';
import '../repositories/legacy_item_repository.dart';
import '../repositories/legacy_balance_repository.dart';
import '../repositories/legacy_unit_repository.dart';
import '../repositories/legacy_block_repository.dart';

class LegacyItemApi {
  final LegacyItemRepository itemRepository;
  final LegacyBalanceRepository balanceRepository;
  final LegacyUnitRepository unitRepository;
  final LegacyBlockRepository blockRepository;

  LegacyItemApi({
    required this.itemRepository,
    required this.balanceRepository,
    required this.unitRepository,
    required this.blockRepository,
  });

  // توحيد شكل استجابة JSON ودعم اللغة العربية باستخدام UTF-8.
  Response _jsonResponse(int statusCode, Map<String, dynamic> data) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  // التحقق من باركود EAN-8 واستخراج ITEM_CODE منه.
  String? _itemCodeFromEan8(String barcode) {
    final normalized = barcode.trim();

    // لازم الباركود يكون 8 أرقام ويبدأ بـ 000.
    if (!RegExp(r'^\d{8}$').hasMatch(normalized) ||
        !normalized.startsWith('000')) {
      return null;
    }

    // أول 7 أرقام هي بيانات الباركود، والرقم الأخير Check Digit.
    final digits = normalized.substring(0, 7);

    var sum = 0;

    // حساب EAN-8 Checksum باستخدام الأوزان 3 و1 بالتبادل.
    for (var i = 0; i < digits.length; i++) {
      final digit = int.parse(digits[i]);
      sum += digit * (i.isEven ? 3 : 1);
    }

    final expectedCheckDigit = (10 - sum % 10) % 10;
    final actualCheckDigit = int.parse(normalized[7]);

    if (expectedCheckDigit != actualCheckDigit) {
      return null;
    }

    // استخراج ITEM_CODE من الخانات الرابعة إلى السابعة.
    return normalized.substring(3, 7);
  }

  Router get router {
    final router = Router();
    // تسجيل دخول المستخدم باستخدام بياناته والـ Token الخاص به.
    router.post('/api/auth/login', (Request request) async {
      TopSoftwareApiClient? client;

      try {
        // قراءة البيانات المرسلة من Flutter.
        final requestBody = await request.readAsString();

        final dynamic decodedBody;

        try {
          decodedBody = jsonDecode(requestBody);
        } on FormatException {
          return _jsonResponse(400, {
            'success': false,
            'message': 'Invalid JSON request',
          });
        }

        // التأكد إن البيانات المرسلة عبارة عن JSON Object.
        if (decodedBody is! Map) {
          return _jsonResponse(400, {
            'success': false,
            'message': 'Invalid request format',
          });
        }

        final username = decodedBody['username'];
        final password = decodedBody['password'];
        final token = decodedBody['token'];

        // التأكد من وجود البيانات الثلاثة.
        if (username is! String ||
            password is! String ||
            token is! String ||
            username.trim().isEmpty ||
            password.isEmpty ||
            token.trim().isEmpty) {
          return _jsonResponse(400, {
            'success': false,
            'message': 'Username, password and token are required',
          });
        }

        // استخراج اسم الـ Schema من أول وآخر حرف في Token.
        final schema = TokenService.extractSchema(token);

        // فك تشفير الجزء الأوسط من Token واستخراج BaseURL.
        final baseUrl = TokenService.decryptBaseUrl(token);

        // إنشاء Client خاص ببيانات المستخدم الحالي.
        client = TopSoftwareApiClient(
          baseUrl: baseUrl,
          username: username.trim(),
          password: password,
          schema: schema,
        );

        // تنفيذ تسجيل الدخول على TopSoftware API الأصلي.
        final session = await client.login();

        // تسجيل الدخول نجح.
        return _jsonResponse(200, {
          'success': true,
          'message': 'Login successful',
          'data': {'employeeNumber': session.employeeNo},
        });
      } on FormatException {
        // Token غير صالح أو الجزء المشفر غير سليم.
        return _jsonResponse(400, {
          'success': false,
          'message': 'Invalid token format',
        });
      } on TopSoftwareApiException catch (error) {
        print('TopSoftware login error: $error');

        // فشل تسجيل الدخول بسبب بيانات المستخدم أو استجابة الـ API.
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
        print('========== LOGIN ERROR ==========');
        print('Error: $error');
        print('Stack Trace: $stackTrace');
        print('=================================');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Internal server error',
        });
      } finally {
        // إغلاق اتصال HTTP الخاص بالطلب بعد انتهاء تسجيل الدخول.
        client?.close();
      }
    });
    // البحث عن الأصناف باستخدام الكود البديل ITEM_CODE2.
    router.get('/api/items/search/alternate/<alternateCode>', (
      Request request,
      String alternateCode,
    ) async {
      try {
        final items = await itemRepository.findByAlternateCode(alternateCode);

        return _jsonResponse(200, {
          'success': true,
          'count': items.length,
          'data': items.map((item) => item.toJson()).toList(),
        });
      } catch (error) {
        print('Error searching items by alternate code: $error');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to search items',
        });
      }
    });

    // البحث عن الصنف باستخدام باركود EAN-8.
    router.get('/api/items/search/barcode/<barcode>', (
      Request request,
      String barcode,
    ) async {
      try {
        // التحقق من الباركود واستخراج ITEM_CODE.
        final itemCode = _itemCodeFromEan8(barcode);

        if (itemCode == null) {
          return _jsonResponse(400, {
            'success': false,
            'message': 'Invalid barcode',
          });
        }

        // استخدام Repository الموجود بالفعل لجلب بيانات الصنف.
        final item = await itemRepository.findByItemCode(itemCode);

        if (item == null) {
          return _jsonResponse(404, {
            'success': false,
            'message': 'Item not found',
          });
        }

        return _jsonResponse(200, {'success': true, 'data': item.toJson()});
      } catch (error) {
        print('Error searching item by barcode: $error');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to search item by barcode',
        });
      }
    });

    // جلب بيانات البلوك بالكامل باستخدام ITEM_CODE2.
    router.get('/api/blocks/<blockNumber>', (
      Request request,
      String blockNumber,
    ) async {
      try {
        final block = await blockRepository.findByBlockNumber(blockNumber);

        // لو البلوك مش موجود نرجع 404.
        if (block == null) {
          return _jsonResponse(404, {
            'success': false,
            'message': 'Block not found',
          });
        }

        return _jsonResponse(200, {'success': true, 'data': block});
      } catch (error) {
        print('Error fetching block: $error');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to fetch block',
        });
      }
    });

    // جلب البيانات الأساسية للصنف باستخدام ITEM_CODE.
    router.get('/api/items/<itemCode>', (
      Request request,
      String itemCode,
    ) async {
      try {
        final item = await itemRepository.findByItemCode(itemCode);

        if (item == null) {
          return _jsonResponse(404, {
            'success': false,
            'message': 'Item not found',
          });
        }

        return _jsonResponse(200, {'success': true, 'data': item.toJson()});
      } catch (error) {
        print('Error fetching legacy item: $error');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to fetch item',
        });
      }
    });

    // جلب إجمالي رصيد الخامة المرتبطة بالصنف.
    router.get('/api/items/<itemCode>/raw-material-balance', (
      Request request,
      String itemCode,
    ) async {
      try {
        // حساب إجمالي رصيد الخامة من خلال Repository.
        final balance = await balanceRepository
            .findRawMaterialBalanceByItemCode(itemCode);

        // لو الصنف غير موجود في قاعدة البيانات.
        if (balance == null) {
          return _jsonResponse(404, {
            'success': false,
            'message': 'Item not found',
          });
        }

        return _jsonResponse(200, {
          'success': true,
          'itemCode': itemCode,
          'rawMaterialBalance': balance,
        });
      } catch (error, stackTrace) {
        // طباعة الخطأ الأصلي ومكان حدوثه داخل السيرفر.
        print('========== RAW MATERIAL BALANCE ERROR ==========');
        print('Item Code: $itemCode');
        print('Error: $error');
        print('Stack Trace: $stackTrace');
        print('================================================');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to fetch raw material balance',
        });
      }
    });

    // جلب أرصدة الصنف في جميع المستودعات.
    router.get('/api/items/<itemCode>/balances', (
      Request request,
      String itemCode,
    ) async {
      try {
        final balances = await balanceRepository.findByItemCode(itemCode);

        return _jsonResponse(200, {
          'success': true,
          'count': balances.length,
          'data': balances.map((balance) => balance.toJson()).toList(),
        });
      } catch (error) {
        print('Error fetching item balances: $error');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to fetch item balances',
        });
      }
    });

    // جلب الوحدات والأسعار الخاصة بالصنف.
    router.get('/api/items/<itemCode>/units', (
      Request request,
      String itemCode,
    ) async {
      try {
        final units = await unitRepository.findByItemCode(itemCode);

        return _jsonResponse(200, {
          'success': true,
          'count': units.length,
          'data': units.map((unit) => unit.toJson()).toList(),
        });
      } catch (error) {
        print('Error fetching item units: $error');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to fetch item units',
        });
      }
    });

    return router;
  }
}
