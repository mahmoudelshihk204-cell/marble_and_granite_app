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
    // 1. فتح الاتصالين بقاعدة البيانات
    final oracleConnection = await oracleDatabase.connect();
    postgresConnection = await postgresDatabase.connect();

    // 2. التأكد إن جدول PostgreSQL فاضي قبل النقل
    final existingRows = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.invmas',
    );

    final existingCount = existingRows.first[0] as int;

    if (existingCount != 0) {
      throw Exception('Migration stopped: PostgreSQL table is not empty.');
    }

    print('\nPostgreSQL table is empty. Ready to migrate.');

    // 3. قراءة كل الأعمدة الـ52 من Oracle
    const oracleQuery = '''
      SELECT
        ITEM_CODE,
        ITEM_NAME,
        REM,
        GROUP_CODE,
        ACTIV_CODE,
        SYS_DATE,
        ITEM_CODE2,
        ITEM_NAME2,
        ITEM_EXP,
        ITEM_STOR,
        MULTI_CODE,
        ITEM_NAME_EN,
        ITEM_NAME_TR,
        ITEM_NAME_ES,
        ITEM_NAME_IT,
        ITEM_NAME_FR,
        ITEM_NAME_DE,
        ITEM_NAME_RU,
        PROD,
        REM2,
        Z,
        X,
        Y,
        M_CLASS,
        M_TYPE,
        M_NAME,
        M_FINISH,
        M_CLR,
        M_FLAG,
        BR_CODE,
        FRZ,
        ITEM_CODEX,
        SUP_CODE,
        PLOCK_LINK,
        AUTO_CR,
        DOC_ATTX1,
        DOC_ATTX2,
        M_STEL,
        EXP_PROD,
        UNIT_CODED,
        EXP_PER,
        UNIT_CODED2,
        ACTIV_FLW,
        RPLC_SPAR,
        ACC_CODE,
        CUST_TYPE,
        COST_C,
        COST_C2,
        PER_NO2,
        PART_NO,
        ITEM_TAX,
        ITEM_TAX_TYPE
      FROM EXP2013.INVMAS
      ORDER BY ITEM_CODE
    ''';

    final oracleResult = await oracleConnection.execute(oracleQuery);
    final rows = oracleResult.rows;

    print('Oracle records found: ${rows.length}');

    // 4. تجهيز أمر الإدخال في PostgreSQL
    const insertQuery = '''
      INSERT INTO public.invmas (
        item_code,
        item_name,
        rem,
        group_code,
        activ_code,
        sys_date,
        item_code2,
        item_name2,
        item_exp,
        item_stor,
        multi_code,
        item_name_en,
        item_name_tr,
        item_name_es,
        item_name_it,
        item_name_fr,
        item_name_de,
        item_name_ru,
        prod,
        rem2,
        z,
        x,
        y,
        m_class,
        m_type,
        m_name,
        m_finish,
        m_clr,
        m_flag,
        br_code,
        frz,
        item_codex,
        sup_code,
        plock_link,
        auto_cr,
        doc_attx1,
        doc_attx2,
        m_stel,
        exp_prod,
        unit_coded,
        exp_per,
        unit_coded2,
        activ_flw,
        rplc_spar,
        acc_code,
        cust_type,
        cost_c,
        cost_c2,
        per_no2,
        part_no,
        item_tax,
        item_tax_type
      )
      VALUES (
        @item_code,
        @item_name,
        @rem,
        @group_code,
        @activ_code,
        @sys_date,
        @item_code2,
        @item_name2,
        @item_exp,
        @item_stor,
        @multi_code,
        @item_name_en,
        @item_name_tr,
        @item_name_es,
        @item_name_it,
        @item_name_fr,
        @item_name_de,
        @item_name_ru,
        @prod,
        @rem2,
        @z,
        @x,
        @y,
        @m_class,
        @m_type,
        @m_name,
        @m_finish,
        @m_clr,
        @m_flag,
        @br_code,
        @frz,
        @item_codex,
        @sup_code,
        @plock_link,
        @auto_cr,
        @doc_attx1,
        @doc_attx2,
        @m_stel,
        @exp_prod,
        @unit_coded,
        @exp_per,
        @unit_coded2,
        @activ_flw,
        @rplc_spar,
        @acc_code,
        @cust_type,
        @cost_c,
        @cost_c2,
        @per_no2,
        @part_no,
        @item_tax,
        @item_tax_type
      )
    ''';

    // 5. نقل البيانات داخل Transaction واحدة
    await postgresConnection.runTx((transaction) async {
      for (final row in rows) {
        // تحويل سجل Oracle إلى Map
        final data = row.toMap();

        // إدخال قيم السجل باستخدام Parameters
        // وده بيحافظ على أمان الاستعلام وأنواع البيانات
        await transaction.execute(
          Sql.named(insertQuery),
          parameters: {
            'item_code': data['ITEM_CODE'],
            'item_name': data['ITEM_NAME'],
            'rem': data['REM'],
            'group_code': data['GROUP_CODE'],
            'activ_code': data['ACTIV_CODE'],
            'sys_date': data['SYS_DATE'],
            'item_code2': data['ITEM_CODE2'],
            'item_name2': data['ITEM_NAME2'],
            'item_exp': data['ITEM_EXP'],
            'item_stor': data['ITEM_STOR'],
            'multi_code': data['MULTI_CODE'],
            'item_name_en': data['ITEM_NAME_EN'],
            'item_name_tr': data['ITEM_NAME_TR'],
            'item_name_es': data['ITEM_NAME_ES'],
            'item_name_it': data['ITEM_NAME_IT'],
            'item_name_fr': data['ITEM_NAME_FR'],
            'item_name_de': data['ITEM_NAME_DE'],
            'item_name_ru': data['ITEM_NAME_RU'],
            'prod': data['PROD'],
            'rem2': data['REM2'],
            'z': data['Z'],
            'x': data['X'],
            'y': data['Y'],
            'm_class': data['M_CLASS'],
            'm_type': data['M_TYPE'],
            'm_name': data['M_NAME'],
            'm_finish': data['M_FINISH'],
            'm_clr': data['M_CLR'],
            'm_flag': data['M_FLAG'],
            'br_code': data['BR_CODE'],
            'frz': data['FRZ'],
            'item_codex': data['ITEM_CODEX'],
            'sup_code': data['SUP_CODE'],
            'plock_link': data['PLOCK_LINK'],
            'auto_cr': data['AUTO_CR'],
            'doc_attx1': data['DOC_ATTX1'],
            'doc_attx2': data['DOC_ATTX2'],
            'm_stel': data['M_STEL'],
            'exp_prod': data['EXP_PROD'],
            'unit_coded': data['UNIT_CODED'],
            'exp_per': data['EXP_PER'],
            'unit_coded2': data['UNIT_CODED2'],
            'activ_flw': data['ACTIV_FLW'],
            'rplc_spar': data['RPLC_SPAR'],
            'acc_code': data['ACC_CODE'],
            'cust_type': data['CUST_TYPE'],
            'cost_c': data['COST_C'],
            'cost_c2': data['COST_C2'],
            'per_no2': data['PER_NO2'],
            'part_no': data['PART_NO'],
            'item_tax': data['ITEM_TAX'],
            'item_tax_type': data['ITEM_TAX_TYPE'],
          },
        );
      }
    });

    // 6. التحقق من عدد السجلات بعد النقل
    final finalResult = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.invmas',
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

    // إظهار الخطأ للـTerminal وعدم اعتباره نجاحًا
    rethrow;
  } finally {
    // 7. إغلاق الاتصالات
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
