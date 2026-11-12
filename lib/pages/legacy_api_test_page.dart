
import 'package:flutter/material.dart';

import '../models/legacy/legacy_item_model.dart';
import '../models/legacy/legacy_balance_model.dart';
import '../models/legacy/legacy_unit_model.dart';
import '../services/legacy/legacy_api_service.dart';

class LegacyApiTestPage extends StatefulWidget {
  const LegacyApiTestPage({super.key});

  @override
  State<LegacyApiTestPage> createState() => _LegacyApiTestPageState();
}

class _LegacyApiTestPageState extends State<LegacyApiTestPage> {
  final LegacyApiService api = LegacyApiService();

  LegacyItemModel? item;
  List<LegacyBalanceModel> balances = [];
  List<LegacyUnitModel> units = [];

  bool isLoading = false;
  String? errorMessage;

  // تحميل بيانات الصنف والأرصدة والوحدات
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // جلب بيانات الصنف بالكود الأساسي
      const itemCode = '5920';

      final itemResult = await api.getItemByCode(itemCode);

      // جلب أرصدة المخازن
      final balanceResult = await api.getBalances(itemCode);

      // جلب الوحدات والأسعار
      final unitResult = await api.getUnits(itemCode);

      if (!mounted) return;

      setState(() {
        item = itemResult;
        balances = balanceResult;
        units = unitResult;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // تحميل البيانات بمجرد فتح الشاشة
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legacy API Test'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xffC5A46D),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 10),
                        const Text('Connection Failed'),
                        const SizedBox(height: 10),
                        Text(errorMessage!),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // حالة الاتصال
                      const Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text('API Connection Successful'),
                          subtitle: Text('Connected to Dart Server'),
                        ),
                      ),

                      // بيانات الصنف
                      const Text(
                        'Item Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: item == null
                              ? const Text('Item not found')
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Item Code: ${item!.itemCode}'),
                                    Text('Name: ${item!.itemName}'),
                                    Text(
                                      'Alternate Code: ${item!.alternateCode}',
                                    ),
                                    Text('Class: ${item!.className}'),
                                    Text('Material: ${item!.materialCode}'),
                                    Text('Finish: ${item!.finishName}'),
                                    Text(
                                      'Dimensions: ${item!.x} × ${item!.y} × ${item!.z}',
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // أرصدة المخازن - بدون عرض كود المخزن
                      const Text(
                        'Warehouse Balances',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      ...balances.map(
                        (balance) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.warehouse),
                            title: Text(
                              balance.branchName ?? 'Warehouse',
                            ),
                            trailing: Text(
                              '${balance.balance ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // وحدات القياس والأسعار
                      const Text(
                        'Units and Prices',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      ...units.map(
                        (unit) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.straighten),
                            title: Text(
                              unit.unitName ?? unit.unitCode,
                            ),
                            subtitle: Text(
                              'Sale Price: ${unit.salePrice}',
                            ),
                            trailing: Icon(
                              unit.isMasterUnit
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // إعادة تحميل البيانات
                      ElevatedButton.icon(
                        onPressed: loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reload Data'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
