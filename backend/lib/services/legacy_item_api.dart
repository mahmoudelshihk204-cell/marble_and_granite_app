import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../repositories/legacy_item_repository.dart';
import '../repositories/legacy_balance_repository.dart';
import '../repositories/legacy_unit_repository.dart';

class LegacyItemApi {
  final LegacyItemRepository itemRepository;
  final LegacyBalanceRepository balanceRepository;
  final LegacyUnitRepository unitRepository;

  LegacyItemApi({
    required this.itemRepository,
    required this.balanceRepository,
    required this.unitRepository,
  });

  // توحيد شكل استجابة JSON وإضافة UTF-8 لدعم اللغة العربية.
  Response _jsonResponse(
    int statusCode,
    Map<String, dynamic> data,
  ) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: {
        'content-type': 'application/json; charset=utf-8',
      },
    );
  }

  Router get router {
    final router = Router();

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

        return _jsonResponse(200, {
          'success': true,
          'data': item.toJson(),
        });
      } catch (error) {
        print('Error fetching legacy item: $error');

        return _jsonResponse(500, {
          'success': false,
          'message': 'Failed to fetch item',
        });
      }
    });

    // جلب أرصدة الصنف في جميع المستودعات.
    router.get('/api/items/<itemCode>/balances', (
      Request request,
      String itemCode,
    ) async {
      try {
        final balances =
            await balanceRepository.findByItemCode(itemCode);

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