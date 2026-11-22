
// ignore_for_file: unused_import

import 'package:oracledb/oracledb.dart';
import 'package:postgres/postgres.dart';

import 'package:backend/database/oracle_connection.dart';
import 'package:backend/database/postgres_connection.dart';

Future<void> main() async {
  final oracleDatabase = OracleDatabase();
  final postgresDatabase = PostgresDatabase();

  Connection? postgresConnection;

  try {
    // 1. فتح الاتصالين
    final oracleConnection = await oracleDatabase.connect();
    postgresConnection = await postgresDatabase.connect();

    // 2. التأكد إن جدول PostgreSQL فاضي قبل الترحيل
    final existingRows = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.plock_insx',
    );

    final existingCount = existingRows.first[0] as int;

    if (existingCount != 0) {
      throw Exception(
        'Migration stopped: PostgreSQL table is not empty.',
      );
    }

    print('\nPostgreSQL table is empty. Ready to migrate.');

    // 3. قراءة كل سجلات التصنيفات من Oracle
    const oracleQuery = '''
      SELECT
        GROUP_CODE,
        GROUP_NAME,
        SYS_DATE,
        GROUP_NAME2,
        GROUP_NAME_TR,
        GROUP_NAME_ES,
        GROUP_NAME_IT,
        GROUP_NAME_FR,
        GROUP_NAME_DE,
        GROUP_NAME_RU,
        BR_CODE,
        TYPE_NO,
        PR_TYPE,
        PR_PRICE,
        PR_CUT_SIZE,
        PR_DISC,
        COST_C2X,
        COST_C2X_NAME,
        M_TYPE,
        M_FINISH,
        UNIT_CODEX,
        GROUP_NO,
        GROUP_NO_NAME,
        PLOCK_LINK,
        PR_DISC2,
        UNIT_CODEP,
        PR_CLASS,
        HOUR_RENT,
        PROD_OUT,
        LOCAL_CO,
        COUNTRY_CODE,
        PR_PRICE2
      FROM EXP2013.PLOCK_INSX
      ORDER BY GROUP_CODE
    ''';

    final oracleResult = await oracleConnection.execute(oracleQuery);

    final rows = oracleResult.rows;

    print('Oracle records found: ${rows.length}');

    // 4. تجهيز أمر الإدخال في PostgreSQL
    const insertQuery = '''
      INSERT INTO public.plock_insx (
        group_code,
        group_name,
        sys_date,
        group_name2,
        group_name_tr,
        group_name_es,
        group_name_it,
        group_name_fr,
        group_name_de,
        group_name_ru,
        br_code,
        type_no,
        pr_type,
        pr_price,
        pr_cut_size,
        pr_disc,
        cost_c2x,
        cost_c2x_name,
        m_type,
        m_finish,
        unit_codex,
        group_no,
        group_no_name,
        plock_link,
        pr_disc2,
        unit_codep,
        pr_class,
        hour_rent,
        prod_out,
        local_co,
        country_code,
        pr_price2
      )
      VALUES (
        @group_code,
        @group_name,
        @sys_date,
        @group_name2,
        @group_name_tr,
        @group_name_es,
        @group_name_it,
        @group_name_fr,
        @group_name_de,
        @group_name_ru,
        @br_code,
        @type_no,
        @pr_type,
        @pr_price,
        @pr_cut_size,
        @pr_disc,
        @cost_c2x,
        @cost_c2x_name,
        @m_type,
        @m_finish,
        @unit_codex,
        @group_no,
        @group_no_name,
        @plock_link,
        @pr_disc2,
        @unit_codep,
        @pr_class,
        @hour_rent,
        @prod_out,
        @local_co,
        @country_code,
        @pr_price2
      )
    ''';

    // 5. نقل البيانات داخل Transaction واحدة
    await postgresConnection.runTx((transaction) async {
      for (final row in rows) {
        // تحويل سجل Oracle إلى Map
        final data = row.toMap();

        // إدخال القيم باستخدام Parameters
        await transaction.execute(
          Sql.named(insertQuery),
          parameters: {
            'group_code': data['GROUP_CODE'],
            'group_name': data['GROUP_NAME'],
            'sys_date': data['SYS_DATE'],
            'group_name2': data['GROUP_NAME2'],
            'group_name_tr': data['GROUP_NAME_TR'],
            'group_name_es': data['GROUP_NAME_ES'],
            'group_name_it': data['GROUP_NAME_IT'],
            'group_name_fr': data['GROUP_NAME_FR'],
            'group_name_de': data['GROUP_NAME_DE'],
            'group_name_ru': data['GROUP_NAME_RU'],
            'br_code': data['BR_CODE'],
            'type_no': data['TYPE_NO'],
            'pr_type': data['PR_TYPE'],
            'pr_price': data['PR_PRICE'],
            'pr_cut_size': data['PR_CUT_SIZE'],
            'pr_disc': data['PR_DISC'],
            'cost_c2x': data['COST_C2X'],
            'cost_c2x_name': data['COST_C2X_NAME'],
            'm_type': data['M_TYPE'],
            'm_finish': data['M_FINISH'],
            'unit_codex': data['UNIT_CODEX'],
            'group_no': data['GROUP_NO'],
            'group_no_name': data['GROUP_NO_NAME'],
            'plock_link': data['PLOCK_LINK'],
            'pr_disc2': data['PR_DISC2'],
            'unit_codep': data['UNIT_CODEP'],
            'pr_class': data['PR_CLASS'],
            'hour_rent': data['HOUR_RENT'],
            'prod_out': data['PROD_OUT'],
            'local_co': data['LOCAL_CO'],
            'country_code': data['COUNTRY_CODE'],
            'pr_price2': data['PR_PRICE2'],
          },
        );
      }
    });

    // 6. التأكد من عدد السجلات بعد الترحيل
    final finalResult = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.plock_insx',
    );

    final migratedCount = finalResult.first[0];

    print('\n========== MIGRATION RESULT ==========');
    print('Oracle records: ${rows.length}');
    print('PostgreSQL records: $migratedCount');
    print('======================================');

    if (migratedCount == rows.length) {
      print('Migration completed successfully!');
    } else {
      throw Exception('Record count mismatch!');
    }
  } catch (error) {
    print('\nMigration failed: $error');
    print('Check the error before trying again.');
  } finally {
    // 7. إغلاق الاتصالات
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
