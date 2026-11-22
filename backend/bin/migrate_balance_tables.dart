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

    // 2. التأكد إن الجدولين فاضيين قبل الترحيل
    final branchCountResult = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.branch',
    );

    final balanceCountResult = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.invmas_bal',
    );

    final branchCount = branchCountResult.first[0] as int;
    final balanceCount = balanceCountResult.first[0] as int;

    if (branchCount != 0 || balanceCount != 0) {
      throw Exception(
        'Migration stopped: One or both PostgreSQL tables are not empty.',
      );
    }

    print('\nBoth PostgreSQL tables are empty. Ready to migrate.');

    // ==========================================
    // 3. قراءة بيانات الفروع من Oracle
    // ==========================================

    const branchQuery = '''
      SELECT
        GROUP_CODE,
        GROUP_NAME,
        GROUP_MGR,
        BR_CODE,
        ACTIV_CODE,
        SYS_DATE,
        S_DELEV,
        AUTO_MANUAL,
        GROUP_NAME_TR,
        GROUP_NAME_ES,
        GROUP_NAME_IT,
        GROUP_NAME_FR,
        GROUP_NAME_DE,
        GROUP_NAME_RU,
        GROUP_NAME2,
        MOV,
        DEF_GROUP_CODE,
        LINK_CODE,
        SALE_TAX,
        PUR_TAX,
        PRT_REM,
        IMAGE_HED,
        IMAGE_FOD,
        IMAGE_COVER,
        DEAL_ITEM_EXP,
        CUST_EMAIL,
        CUST_EMAIL_PASS,
        COMM_NO,
        TAX_NO,
        TAX_EMAIL,
        MSG_SUB,
        MSG_BODY,
        LOCAL_CO_CODE,
        BRAN_CODE_TYPE,
        ORDER_NO,
        RES,
        IND_COST
      FROM EXP2013.BRANCH
      ORDER BY GROUP_CODE
    ''';

    final branchResult = await oracleConnection.execute(branchQuery);
    final branchRows = branchResult.rows;

    print('Oracle BRANCH records: ${branchRows.length}');

    // ==========================================
    // 4. قراءة أرصدة الأصناف من Oracle
    // ==========================================

    const balanceQuery = '''
      SELECT
        ITEM_CODE,
        BRAN_CODE,
        RAIS,
        RE_DEM,
        SYS_DATE,
        BAL,
        NBAL
      FROM EXP2013.INVMAS_BAL
      ORDER BY ITEM_CODE, BRAN_CODE
    ''';

    final balanceResult = await oracleConnection.execute(balanceQuery);
    final balanceRows = balanceResult.rows;

    print('Oracle INVMAS_BAL records: ${balanceRows.length}');

    // ==========================================
    // 5. تجهيز أوامر الإدخال في PostgreSQL
    // ==========================================

    const branchInsertQuery = '''
      INSERT INTO public.branch (
        group_code,
        group_name,
        group_mgr,
        br_code,
        activ_code,
        sys_date,
        s_delev,
        auto_manual,
        group_name_tr,
        group_name_es,
        group_name_it,
        group_name_fr,
        group_name_de,
        group_name_ru,
        group_name2,
        mov,
        def_group_code,
        link_code,
        sale_tax,
        pur_tax,
        prt_rem,
        image_hed,
        image_fod,
        image_cover,
        deal_item_exp,
        cust_email,
        cust_email_pass,
        comm_no,
        tax_no,
        tax_email,
        msg_sub,
        msg_body,
        local_co_code,
        bran_code_type,
        order_no,
        res,
        ind_cost
      )
      VALUES (
        @group_code,
        @group_name,
        @group_mgr,
        @br_code,
        @activ_code,
        @sys_date,
        @s_delev,
        @auto_manual,
        @group_name_tr,
        @group_name_es,
        @group_name_it,
        @group_name_fr,
        @group_name_de,
        @group_name_ru,
        @group_name2,
        @mov,
        @def_group_code,
        @link_code,
        @sale_tax,
        @pur_tax,
        @prt_rem,
        @image_hed,
        @image_fod,
        @image_cover,
        @deal_item_exp,
        @cust_email,
        @cust_email_pass,
        @comm_no,
        @tax_no,
        @tax_email,
        @msg_sub,
        @msg_body,
        @local_co_code,
        @bran_code_type,
        @order_no,
        @res,
        @ind_cost
      )
    ''';

    const balanceInsertQuery = '''
      INSERT INTO public.invmas_bal (
        item_code,
        bran_code,
        rais,
        re_dem,
        sys_date,
        bal,
        nbal
      )
      VALUES (
        @item_code,
        @bran_code,
        @rais,
        @re_dem,
        @sys_date,
        @bal,
        @nbal
      )
    ''';

    // ==========================================
    // 6. ترحيل الجدولين داخل Transaction واحدة
    // ==========================================

    await postgresConnection.runTx((transaction) async {
      // أولاً: ترحيل بيانات الفروع
      print('\nMigrating BRANCH...');

      for (final row in branchRows) {
        final data = row.toMap();

        await transaction.execute(
          Sql.named(branchInsertQuery),
          parameters: {
            'group_code': data['GROUP_CODE'],
            'group_name': data['GROUP_NAME'],
            'group_mgr': data['GROUP_MGR'],
            'br_code': data['BR_CODE'],
            'activ_code': data['ACTIV_CODE'],
            'sys_date': data['SYS_DATE'],
            's_delev': data['S_DELEV'],
            'auto_manual': data['AUTO_MANUAL'],
            'group_name_tr': data['GROUP_NAME_TR'],
            'group_name_es': data['GROUP_NAME_ES'],
            'group_name_it': data['GROUP_NAME_IT'],
            'group_name_fr': data['GROUP_NAME_FR'],
            'group_name_de': data['GROUP_NAME_DE'],
            'group_name_ru': data['GROUP_NAME_RU'],
            'group_name2': data['GROUP_NAME2'],
            'mov': data['MOV'],
            'def_group_code': data['DEF_GROUP_CODE'],
            'link_code': data['LINK_CODE'],
            'sale_tax': data['SALE_TAX'],
            'pur_tax': data['PUR_TAX'],
            'prt_rem': data['PRT_REM'],
            'image_hed': data['IMAGE_HED'],
            'image_fod': data['IMAGE_FOD'],
            'image_cover': data['IMAGE_COVER'],
            'deal_item_exp': data['DEAL_ITEM_EXP'],
            'cust_email': data['CUST_EMAIL'],
            'cust_email_pass': data['CUST_EMAIL_PASS'],
            'comm_no': data['COMM_NO'],
            'tax_no': data['TAX_NO'],
            'tax_email': data['TAX_EMAIL'],
            'msg_sub': data['MSG_SUB'],
            'msg_body': data['MSG_BODY'],
            'local_co_code': data['LOCAL_CO_CODE'],
            'bran_code_type': data['BRAN_CODE_TYPE'],
            'order_no': data['ORDER_NO'],
            'res': data['RES'],
            'ind_cost': data['IND_COST'],
          },
        );
      }

      print('BRANCH migration completed inside transaction.');

      // ثانياً: ترحيل أرصدة الأصناف
      print('\nMigrating INVMAS_BAL...');

      for (final row in balanceRows) {
        final data = row.toMap();

        await transaction.execute(
          Sql.named(balanceInsertQuery),
          parameters: {
            'item_code': data['ITEM_CODE'],
            'bran_code': data['BRAN_CODE'],
            'rais': data['RAIS'],
            're_dem': data['RE_DEM'],
            'sys_date': data['SYS_DATE'],
            'bal': data['BAL'],
            'nbal': data['NBAL'],
          },
        );
      }

      print('INVMAS_BAL migration completed inside transaction.');
    });

    // ==========================================
    // 7. التأكد من عدد السجلات بعد الترحيل
    // ==========================================

    final finalBranchResult = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.branch',
    );

    final finalBalanceResult = await postgresConnection.execute(
      'SELECT COUNT(*) FROM public.invmas_bal',
    );

    final migratedBranchCount = finalBranchResult.first[0];
    final migratedBalanceCount = finalBalanceResult.first[0];

    print('\n========== MIGRATION RESULT ==========');
    print('Oracle BRANCH records: ${branchRows.length}');
    print('PostgreSQL BRANCH records: $migratedBranchCount');
    print('--------------------------------------');
    print('Oracle INVMAS_BAL records: ${balanceRows.length}');
    print('PostgreSQL INVMAS_BAL records: $migratedBalanceCount');
    print('======================================');

    if (migratedBranchCount == branchRows.length &&
        migratedBalanceCount == balanceRows.length) {
      print('\nSUCCESS: Both tables migrated successfully!');
    } else {
      throw Exception('Migration record count mismatch!');
    }
  } catch (error) {
    print('\nMigration failed: $error');
    print('Check the error before trying again.');
  } finally {
    // 8. إغلاق الاتصالات
    if (postgresConnection != null) {
      await postgresConnection.close();
    }

    await oracleDatabase.close();
  }
}
