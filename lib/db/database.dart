import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'models.dart';
import 'admin_models.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  static Database? _db;

  Future<String> get _dbPath async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final dataDir = Directory(join(exeDir, 'data'));
    if (!dataDir.existsSync()) dataDir.createSync(recursive: true);
    return join(dataDir.path, 'bip_data.db');
  }

  Future<String> get photosDirectory async {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final dir = Directory(join(exeDir, 'photos'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = await _dbPath;
    return databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
            version: 6, onCreate: _create, onUpgrade: _upgrade));
  }

  // ── Create v2 schema from scratch ────────────────────────────────────────
  Future<void> _create(Database db, int v) async {
    await db.execute(_officersDDL);
    await db.execute(_jcoOrDDL);
    await db.execute(_leavesDDL);
    await db.execute(_ereDDL);
    await db.execute(_healthDDL);
    await db.execute(_outStrDDL);
    await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_officers_icno ON officers(ic_no)');
    await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_jco_or_armyno ON jco_or(army_no)');
  }

  // ── Upgrade v1 → v2: add new columns + new tables ────────────────────────
  Future<void> _upgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      // Officers: domicile + course grades
      for (final col in [
        'ALTER TABLE officers ADD COLUMN domicile TEXT',
        'ALTER TABLE officers ADD COLUMN c_yo_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_mmg_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_mor_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_snip_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_adp_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_atgm_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_pwt_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_jc_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_sc_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_cdo_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_qm_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_tac_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_rcl_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_rso_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_pt_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_dssc_g TEXT',
        'ALTER TABLE officers ADD COLUMN c_bsw_g TEXT',
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }

      // JCO/OR: domicile + course grades
      for (final col in [
        'ALTER TABLE jco_or ADD COLUMN domicile TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_sec_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_mmg_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_mor_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_snip_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_adp_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_atgm_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_drill_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_bmic_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_uei_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_cdo_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_qm_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_rsi_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_jlc_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_pc_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_pt_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_tpt_g TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_misc_g TEXT',
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }

      // New admin tables
      await db.execute(_leavesDDL);
      await db.execute(_ereDDL);
      await db.execute(_healthDDL);
      await db.execute(_outStrDDL);
    }
    if (oldV < 3) {
      // Add BSW course columns to JCO/OR
      for (final col in [
        'ALTER TABLE jco_or ADD COLUMN c_bsw TEXT',
        'ALTER TABLE jco_or ADD COLUMN c_bsw_g TEXT',
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }
      // Migrate old jco_present records → split into JCO / OR by rank
      try {
        await db.execute("UPDATE jco_or SET sub_cat='jco_present_jco' "
            "WHERE sub_cat='jco_present' AND rank IN ('Nb Sub','Sub','Sub Maj')");
        await db.execute("UPDATE jco_or SET sub_cat='jco_present_or' "
            "WHERE sub_cat='jco_present'");
      } catch (_) {}
    }
    if (oldV < 4) {
      // Health: replace med-cat-class grouping with Coy/Temp/Permt category
      for (final col in [
        'ALTER TABLE health_records ADD COLUMN category TEXT',
        'ALTER TABLE health_records ADD COLUMN med_cat_detail TEXT',
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }
    }
    if (oldV < 5) {
      // Health: Weight Record fields (Coy A/B/C/D/SP/HQ entries)
      for (final col in [
        'ALTER TABLE health_records ADD COLUMN ht TEXT',
        'ALTER TABLE health_records ADD COLUMN ibw TEXT',
        'ALTER TABLE health_records ADD COLUMN abw TEXT',
        'ALTER TABLE health_records ADD COLUMN pct10 TEXT',
        'ALTER TABLE health_records ADD COLUMN bmi TEXT',
        'ALTER TABLE health_records ADD COLUMN weight_class TEXT',
        'ALTER TABLE health_records ADD COLUMN age TEXT',
        'ALTER TABLE health_records ADD COLUMN w_month TEXT',
        'ALTER TABLE health_records ADD COLUMN w_value TEXT',
      ]) {
        try {
          await db.execute(col);
        } catch (_) {}
      }
    }
    if (oldV < 6) {
      // Enforce uniqueness on IC No / Army No at the database level.
      // Wrapped in try/catch: if duplicate rows already exist from before
      // this fix, index creation fails silently and the app keeps working —
      // app-level duplicate checks (officerIcNoExists/jcoArmyNoExists) still
      // protect new saves either way. Run a cleanup query first if needed.
      try {
        await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_officers_icno ON officers(ic_no)');
      } catch (_) {}
      try {
        await db.execute(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_jco_or_armyno ON jco_or(army_no)');
      } catch (_) {}
    }
  }

  // ── DDL strings ───────────────────────────────────────────────────────────
  static const _officersDDL = '''
    CREATE TABLE officers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sub_cat TEXT NOT NULL, ic_no TEXT, rank TEXT, name TEXT, blood_gp TEXT,
      dob TEXT, doc TEXT, dor TEXT, dom TEXT, tos TEXT, sos TEXT,
      cda_ac_no TEXT, i_card_no TEXT, b_day TEXT, m_ann TEXT,
      honours TEXT, med_cat TEXT, diag TEXT, due_on TEXT,
      pres_addr TEXT, permt_addr TEXT, status TEXT,
      tele_nos TEXT, email_ids TEXT, photo TEXT,
      wife TEXT, wife_bday TEXT,
      ch1n TEXT, ch1s TEXT, ch1d TEXT, ch2n TEXT, ch2s TEXT, ch2d TEXT,
      ch3n TEXT, ch3s TEXT, ch3d TEXT, ch4n TEXT, ch4s TEXT, ch4d TEXT,
      c_yo TEXT, c_mmg TEXT, c_mor TEXT, c_snip TEXT, c_adp TEXT,
      c_atgm TEXT, c_pwt TEXT, c_jc TEXT, c_sc TEXT, c_cdo TEXT,
      c_qm TEXT, c_tac TEXT, c_rcl TEXT, c_rso TEXT, c_pt TEXT,
      c_dssc TEXT, c_bsw TEXT, c_oth TEXT,
      c_yo_g TEXT, c_mmg_g TEXT, c_mor_g TEXT, c_snip_g TEXT, c_adp_g TEXT,
      c_atgm_g TEXT, c_pwt_g TEXT, c_jc_g TEXT, c_sc_g TEXT, c_cdo_g TEXT,
      c_qm_g TEXT, c_tac_g TEXT, c_rcl_g TEXT, c_rso_g TEXT, c_pt_g TEXT,
      c_dssc_g TEXT, c_bsw_g TEXT,
      p_lt TEXT, p_capt TEXT, p_maj TEXT, p_ltcol TEXT, p_col TEXT,
      p_brig TEXT, p_majgen TEXT, p_ltgen TEXT,
      sv1f TEXT, sv1t TEXT, sv2f TEXT, sv2t TEXT,
      sv3f TEXT, sv3t TEXT, sv4f TEXT, sv4t TEXT,
      cmd_f TEXT, cmd_t TEXT,
      civ_edn TEXT, domicile TEXT,
      created_at TEXT, updated_at TEXT
    )''';

  static const _jcoOrDDL = '''
    CREATE TABLE jco_or (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sub_cat TEXT NOT NULL,
      army_no TEXT, rank TEXT, name TEXT, coy TEXT,
      dob TEXT, doe TEXT, dor TEXT, tos TEXT, rr_ere_fmn TEXT,
      svc_extn TEXT, sos TEXT, return_dt TEXT,
      icard_no TEXT, honours TEXT, pan TEXT, blood_gp TEXT,
      caste TEXT, civ_edn TEXT, med_cat TEXT, aadhar TEXT,
      diag TEXT, due_on TEXT, email TEXT, pers_prob TEXT, photo TEXT,
      duration TEXT, pres_unit TEXT, kr_verify TEXT,
      marital TEXT, unit_att TEXT, rep_at TEXT, pres_loc TEXT, dt_indn TEXT,
      father TEXT, mother TEXT, wife TEXT, nok TEXT,
      ch1n TEXT, ch1s TEXT, ch1d TEXT, ch2n TEXT, ch2s TEXT, ch2d TEXT,
      ch3n TEXT, ch3s TEXT, ch3d TEXT, ch4n TEXT, ch4s TEXT, ch4d TEXT,
      av_cl TEXT, av_al TEXT, fur_lve TEXT, not_av_lve TEXT,
      rep_on TEXT, rep_mov TEXT,
      acct TEXT, bank TEXT,
      sing_acct TEXT, sing_bank TEXT, jnt_acct TEXT, jnt_bank TEXT,
      sing_code TEXT, jnt_code TEXT,
      h_tele TEXT, h_vill TEXT, h_post TEXT, h_toff TEXT,
      h_teh TEXT, h_dist TEXT, h_state TEXT, h_pin TEXT, h_nrs TEXT,
      c_sec TEXT, c_mmg TEXT, c_mor TEXT, c_snip TEXT, c_adp TEXT,
      c_atgm TEXT, c_drill TEXT, c_bmic TEXT, c_uei TEXT, c_cdo TEXT,
      c_qm TEXT, c_rsi TEXT, c_jlc TEXT, c_pc TEXT, c_pt TEXT,
      c_tpt TEXT, c_misc TEXT, c_bsw TEXT,
      c_sec_g TEXT, c_mmg_g TEXT, c_mor_g TEXT, c_snip_g TEXT, c_adp_g TEXT,
      c_atgm_g TEXT, c_drill_g TEXT, c_bmic_g TEXT, c_uei_g TEXT, c_cdo_g TEXT,
      c_qm_g TEXT, c_rsi_g TEXT, c_jlc_g TEXT, c_pc_g TEXT, c_pt_g TEXT,
      c_tpt_g TEXT, c_misc_g TEXT, c_bsw_g TEXT,
      e_mr1 TEXT, e_mr2 TEXT, e_mr3 TEXT,
      e_ace1 TEXT, e_ace2 TEXT, e_ace3 TEXT, e_aec3 TEXT,
      e_ttt1 TEXT, e_ttt2 TEXT, e_ttt3 TEXT,
      pc_umm TEXT, pc_hav TEXT, pc_nb TEXT,
      p_lnk TEXT, p_naik TEXT, p_hav TEXT, p_nbsub TEXT,
      p_sub TEXT, p_submaj TEXT, p_acp TEXT,
      e1n TEXT, e1f TEXT, e1t TEXT, e2n TEXT, e2f TEXT, e2t TEXT,
      e3n TEXT, e3f TEXT, e3t TEXT,
      d1o TEXT, d1a TEXT, d1d TEXT, d1e TEXT,
      d2o TEXT, d2a TEXT, d2d TEXT, d2e TEXT,
      d3o TEXT, d3a TEXT, d3d TEXT, d3e TEXT,
      d4o TEXT, d4a TEXT, d4d TEXT, d4e TEXT,
      d5o TEXT, d5a TEXT, d5d TEXT, d5e TEXT,
      domicile TEXT,
      created_at TEXT, updated_at TEXT
    )''';

  static const _leavesDDL = '''
    CREATE TABLE IF NOT EXISTS leave_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      army_no TEXT NOT NULL, leave_type TEXT,
      from_dt TEXT, to_dt TEXT, days TEXT,
      reporting_dt TEXT, remarks TEXT, created_at TEXT
    )''';

  static const _ereDDL = '''
    CREATE TABLE IF NOT EXISTS ere_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      army_no TEXT NOT NULL, ere_unit TEXT, appointment TEXT,
      from_dt TEXT, to_dt TEXT, return_dt TEXT,
      remarks TEXT, created_at TEXT
    )''';

  static const _healthDDL = '''
    CREATE TABLE IF NOT EXISTS health_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      army_no TEXT NOT NULL, category TEXT, med_cat TEXT, med_cat_detail TEXT, diag TEXT,
      hospital TEXT, board_dt TEXT, due_on TEXT, remarks TEXT,
      ht TEXT, ibw TEXT, abw TEXT, pct10 TEXT, bmi TEXT, weight_class TEXT, age TEXT,
      w_month TEXT, w_value TEXT,
      created_at TEXT
    )''';

  static const _outStrDDL = '''
    CREATE TABLE IF NOT EXISTS out_strength_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      army_no TEXT NOT NULL, reason TEXT, location TEXT,
      from_dt TEXT, expected_return TEXT,
      remarks TEXT, created_at TEXT
    )''';

  // ── Officers CRUD ─────────────────────────────────────────────────────────
  /// Returns true if another officer already has this IC No (excludes excludeId,
  /// so editing a record doesn't flag itself as a duplicate of itself).
  Future<bool> officerIcNoExists(String? icNo, {int? excludeId}) async {
    if (icNo == null || icNo.trim().isEmpty) return false;
    final db = await database;
    final rows = await db
        .query('officers', where: 'ic_no = ?', whereArgs: [icNo.trim()]);
    return rows.any((r) => r['id'] != excludeId);
  }

  Future<int> insertOfficer(OfficerModel m) async {
    final db = await database;
    m.createdAt = DateTime.now().toIso8601String();
    m.updatedAt = m.createdAt;
    return db.insert('officers', m.toMap()..remove('id'));
  }

  Future<int> updateOfficer(OfficerModel m) async {
    final db = await database;
    m.updatedAt = DateTime.now().toIso8601String();
    return db.update('officers', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
  }

  Future<int> deleteOfficer(int id) async =>
      (await database).delete('officers', where: 'id = ?', whereArgs: [id]);
  Future<OfficerModel?> getOfficerById(int id) async {
    final rows = await (await database)
        .query('officers', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : OfficerModel.fromMap(rows.first);
  }

  Future<List<OfficerModel>> queryOfficers({
    String? subCat,
    String? name,
    String? rank,
    String? status,
    String? bloodGp,
    String? medCat,
    String? courseField,
    String? domicile,
    String? civEdn,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];
    if (subCat != null) {
      where.add('sub_cat = ?');
      args.add(subCat);
    }
    if (name != null && name.isNotEmpty) {
      where.add('(name LIKE ? OR ic_no LIKE ?)');
      args.addAll(['%$name%', '%$name%']);
    }
    if (rank != null) {
      where.add('rank = ?');
      args.add(rank);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (bloodGp != null) {
      where.add('blood_gp = ?');
      args.add(bloodGp);
    }
    if (medCat != null) {
      where.add('med_cat = ?');
      args.add(medCat);
    }
    if (domicile != null) {
      where.add('domicile = ?');
      args.add(domicile);
    }
    if (civEdn != null) {
      where.add('civ_edn = ?');
      args.add(civEdn);
    }
    if (courseField != null)
      where.add("$courseField IS NOT NULL AND $courseField != ''");
    final rows = await db.query('officers',
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'name ASC');
    return rows.map(OfficerModel.fromMap).toList();
  }

  // ── JCO/OR CRUD ───────────────────────────────────────────────────────────
  /// Returns true if another JCO/OR record already has this Army No.
  Future<bool> jcoArmyNoExists(String? armyNo, {int? excludeId}) async {
    if (armyNo == null || armyNo.trim().isEmpty) return false;
    final db = await database;
    final rows = await db
        .query('jco_or', where: 'army_no = ?', whereArgs: [armyNo.trim()]);
    return rows.any((r) => r['id'] != excludeId);
  }

  Future<int> insertJco(JcoOrModel m) async {
    final db = await database;
    m.createdAt = DateTime.now().toIso8601String();
    m.updatedAt = m.createdAt;
    return db.insert('jco_or', m.toMap()..remove('id'));
  }

  Future<int> updateJco(JcoOrModel m) async {
    final db = await database;
    m.updatedAt = DateTime.now().toIso8601String();
    return db.update('jco_or', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
  }

  Future<int> deleteJco(int id) async =>
      (await database).delete('jco_or', where: 'id = ?', whereArgs: [id]);
  Future<JcoOrModel?> getJcoById(int id) async {
    final rows = await (await database)
        .query('jco_or', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : JcoOrModel.fromMap(rows.first);
  }

  Future<List<JcoOrModel>> queryJco({
    String? subCat,
    String? name,
    String? rank,
    String? coy,
    String? bloodGp,
    String? ageFilter,
    String? serviceExtn,
    String? courseField,
    String? domicile,
    String? civEdn,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <dynamic>[];
    if (subCat != null) {
      where.add('sub_cat = ?');
      args.add(subCat);
    }
    if (name != null && name.isNotEmpty) {
      where.add('(name LIKE ? OR army_no LIKE ?)');
      args.addAll(['%$name%', '%$name%']);
    }
    if (rank != null) {
      where.add('rank = ?');
      args.add(rank);
    }
    if (coy != null) {
      where.add('coy = ?');
      args.add(coy);
    }
    if (bloodGp != null) {
      where.add('blood_gp = ?');
      args.add(bloodGp);
    }
    if (serviceExtn != null) {
      where.add('svc_extn = ?');
      args.add(serviceExtn);
    }
    if (domicile != null) {
      where.add('domicile = ?');
      args.add(domicile);
    }
    if (civEdn != null) {
      where.add('civ_edn = ?');
      args.add(civEdn);
    }
    if (ageFilter != null) {
      final cutYear = DateTime.now().year - int.parse(ageFilter);
      where.add("CAST(substr(dob,7,4) AS INTEGER) <= ?");
      args.add(cutYear);
    }
    if (courseField != null)
      where.add("$courseField IS NOT NULL AND $courseField != ''");
    final rows = await db.query('jco_or',
        where: where.isEmpty ? null : where.join(' AND '),
        whereArgs: args.isEmpty ? null : args,
        orderBy: 'name ASC');
    return rows.map(JcoOrModel.fromMap).toList();
  }

  // ── Army No autocomplete (for admin panel) ────────────────────────────────
  Future<List<Map<String, String>>> searchArmyNo(String q) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT ic_no AS army_no, name, rank, '' AS coy FROM officers
        WHERE ic_no LIKE ? OR name LIKE ?
      UNION ALL
      SELECT army_no, name, rank, COALESCE(coy,'') AS coy FROM jco_or
        WHERE army_no LIKE ? OR name LIKE ?
      LIMIT 20
    ''', ['%$q%', '%$q%', '%$q%', '%$q%']);
    return rows
        .map((r) => {
              'army_no': r['army_no']?.toString() ?? '',
              'name': r['name']?.toString() ?? '',
              'rank': r['rank']?.toString() ?? '',
              'coy': r['coy']?.toString() ?? ''
            })
        .toList();
  }

  // ── Leave CRUD ────────────────────────────────────────────────────────────
  Future<int> insertLeave(LeaveRecord r) async {
    r.createdAt = DateTime.now().toIso8601String();
    return (await database).insert('leave_records', r.toMap()..remove('id'));
  }

  Future<List<LeaveRecord>> getLeaveByArmyNo(String armyNo) async {
    final rows = await (await database).query('leave_records',
        where: 'army_no = ?', whereArgs: [armyNo], orderBy: 'id DESC');
    return rows.map(LeaveRecord.fromMap).toList();
  }

  Future<int> deleteLeave(int id) async => (await database)
      .delete('leave_records', where: 'id = ?', whereArgs: [id]);

  // ── ERE CRUD ──────────────────────────────────────────────────────────────
  Future<int> insertEre(EreRecord r) async {
    r.createdAt = DateTime.now().toIso8601String();
    return (await database).insert('ere_records', r.toMap()..remove('id'));
  }

  Future<List<EreRecord>> getEreByArmyNo(String armyNo) async {
    final rows = await (await database).query('ere_records',
        where: 'army_no = ?', whereArgs: [armyNo], orderBy: 'id DESC');
    return rows.map(EreRecord.fromMap).toList();
  }

  Future<int> deleteEre(int id) async =>
      (await database).delete('ere_records', where: 'id = ?', whereArgs: [id]);

  // ── Health CRUD ───────────────────────────────────────────────────────────
  Future<int> insertHealth(HealthRecord r) async {
    r.createdAt = DateTime.now().toIso8601String();
    return (await database).insert('health_records', r.toMap()..remove('id'));
  }

  Future<List<HealthRecord>> getHealthByArmyNo(String armyNo) async {
    final rows = await (await database).query('health_records',
        where: 'army_no = ?', whereArgs: [armyNo], orderBy: 'id DESC');
    return rows.map(HealthRecord.fromMap).toList();
  }

  Future<int> deleteHealth(int id) async => (await database)
      .delete('health_records', where: 'id = ?', whereArgs: [id]);

  // ── Out Strength CRUD ─────────────────────────────────────────────────────
  Future<int> insertOutStr(OutStrengthRecord r) async {
    r.createdAt = DateTime.now().toIso8601String();
    return (await database)
        .insert('out_strength_records', r.toMap()..remove('id'));
  }

  Future<List<OutStrengthRecord>> getOutStrByArmyNo(String armyNo) async {
    final rows = await (await database).query('out_strength_records',
        where: 'army_no = ?', whereArgs: [armyNo], orderBy: 'id DESC');
    return rows.map(OutStrengthRecord.fromMap).toList();
  }

  Future<int> deleteOutStr(int id) async => (await database)
      .delete('out_strength_records', where: 'id = ?', whereArgs: [id]);

  // ── Parade State counts ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> getParadeState() async {
    final db = await database;
    int q(List<Map<String, dynamic>> r) =>
        r.isEmpty ? 0 : (r.first.values.first as int? ?? 0);
    return {
      'off_present': q(await db.rawQuery(
          "SELECT COUNT(*) FROM officers WHERE sub_cat='off_present'")),
      'off_ex_cos': q(await db.rawQuery(
          "SELECT COUNT(*) FROM officers WHERE sub_cat='off_ex_cos'")),
      'off_other_unit': q(await db.rawQuery(
          "SELECT COUNT(*) FROM officers WHERE sub_cat='off_other_unit'")),
      'off_retired': q(await db.rawQuery(
          "SELECT COUNT(*) FROM officers WHERE sub_cat='off_retired'")),
      'off_total': q(await db.rawQuery("SELECT COUNT(*) FROM officers")),
      'jco_present_jco': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_jco'")),
      'jco_present_or': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_or'")),
      'jco_on_ere': q(await db
          .rawQuery("SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_on_ere'")),
      'jco_retired': q(await db
          .rawQuery("SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_retired'")),
      'jco_total': q(await db.rawQuery("SELECT COUNT(*) FROM jco_or")),
      'leave_today': q(await db.rawQuery("SELECT COUNT(*) FROM leave_records")),
      'ere_total': q(await db.rawQuery("SELECT COUNT(*) FROM ere_records")),
      'health_total':
          q(await db.rawQuery("SELECT COUNT(*) FROM health_records")),
      'out_str_total':
          q(await db.rawQuery("SELECT COUNT(*) FROM out_strength_records")),

      // Present JCO breakdown by rank
      'jco_nbsub': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_jco' AND rank='Nb Sub'")),
      'jco_sub': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_jco' AND rank='Sub'")),
      'jco_submaj': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_jco' AND rank='Sub Maj'")),
      // Present OR breakdown by rank
      'or_sep': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_or' AND rank='Sep'")),
      'or_lnk': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_or' AND rank='L/Nk'")),
      'or_nk': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_or' AND rank='Nk'")),
      'or_hav': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_present_or' AND rank='Hav'")),
      // On ERE / Retired split by rank-type (JCO ranks vs OR ranks)
      'jco_on_ere_jco': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_on_ere' AND rank IN ('Nb Sub','Sub','Sub Maj')")),
      'jco_on_ere_or': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_on_ere' AND rank IN ('Sep','L/Nk','Nk','Hav')")),
      'jco_retired_jco': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_retired' AND rank IN ('Nb Sub','Sub','Sub Maj')")),
      'jco_retired_or': q(await db.rawQuery(
          "SELECT COUNT(*) FROM jco_or WHERE sub_cat='jco_retired' AND rank IN ('Sep','L/Nk','Nk','Hav')")),
      // Out Strength counts bucketed by personnel type
      'out_str_officer': q(await db.rawQuery(
          "SELECT COUNT(*) FROM out_strength_records osr WHERE EXISTS (SELECT 1 FROM officers o WHERE o.ic_no = osr.army_no)")),
      'out_str_jco': q(await db.rawQuery(
          "SELECT COUNT(*) FROM out_strength_records osr WHERE EXISTS (SELECT 1 FROM jco_or j WHERE j.army_no = osr.army_no AND j.rank IN ('Nb Sub','Sub','Sub Maj'))")),
      'out_str_or': q(await db.rawQuery(
          "SELECT COUNT(*) FROM out_strength_records osr WHERE EXISTS (SELECT 1 FROM jco_or j WHERE j.army_no = osr.army_no AND j.rank IN ('Sep','L/Nk','Nk','Hav'))")),
    };
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  Future<Map<String, int>> getCounts() async {
    final db = await database;
    final oRows = await db.rawQuery('SELECT COUNT(*) FROM officers');
    final jRows = await db.rawQuery('SELECT COUNT(*) FROM jco_or');
    final o = oRows.isNotEmpty ? (oRows.first.values.first as int? ?? 0) : 0;
    final j = jRows.isNotEmpty ? (jRows.first.values.first as int? ?? 0) : 0;
    return {'officers': o, 'jco': j};
  }
  // ── Report queries (admin-submitted records joined with soldier name) ─────

  Future<List<Map<String, dynamic>>> getLeaveReport({String? leaveType}) async {
    final db = await database;
    final where = leaveType != null ? "WHERE lr.leave_type='$leaveType'" : '';
    return db.rawQuery('''
      SELECT lr.id, lr.army_no, lr.leave_type, lr.from_dt, lr.to_dt,
             lr.days, lr.reporting_dt, lr.remarks, lr.created_at,
             COALESCE(jo.name, of.name, '—') as name,
             COALESCE(jo.rank, of.rank, '-') as rank,
             COALESCE(jo.coy, '') as coy
      FROM leave_records lr
      LEFT JOIN jco_or jo ON lr.army_no = jo.army_no
      LEFT JOIN officers of ON lr.army_no = of.ic_no
      $where
      ORDER BY lr.created_at DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getHealthReport({String? category}) async {
    final db = await database;
    final where = category != null ? "WHERE hr.category='$category'" : '';
    return db.rawQuery('''
      SELECT hr.id, hr.army_no, hr.category, hr.med_cat, hr.med_cat_detail, hr.diag, hr.hospital,
             hr.board_dt, hr.due_on, hr.remarks,
             hr.ht, hr.ibw, hr.abw, hr.pct10, hr.bmi, hr.weight_class, hr.age,
             hr.w_month, hr.w_value, hr.created_at,
             COALESCE(jo.name, of.name, '—') as name,
             COALESCE(jo.rank, of.rank, '-') as rank,
             COALESCE(jo.coy, '') as coy
      FROM health_records hr
      LEFT JOIN jco_or jo ON hr.army_no = jo.army_no
      LEFT JOIN officers of ON hr.army_no = of.ic_no
      $where
      ORDER BY hr.created_at DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getEreReport({String? status}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String().substring(0, 10);
    String filter = '';
    if (status == 'ere_active')
      filter = "AND (er.return_dt IS NULL OR er.return_dt >= '$now')";
    if (status == 'ere_done')
      filter = "AND er.return_dt IS NOT NULL AND er.return_dt < '$now'";
    return db.rawQuery('''
      SELECT er.id, er.army_no, er.ere_unit, er.appointment,
             er.from_dt, er.to_dt, er.return_dt, er.remarks, er.created_at,
             COALESCE(jo.name, of.name, '—') as name,
             COALESCE(jo.rank, of.rank, '-') as rank,
             COALESCE(jo.coy, '') as coy
      FROM ere_records er
      LEFT JOIN jco_or jo ON er.army_no = jo.army_no
      LEFT JOIN officers of ON er.army_no = of.ic_no
      WHERE 1=1 $filter
      ORDER BY er.created_at DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getOutStrReport({String? reason}) async {
    final db = await database;
    final where = reason != null ? "WHERE os.reason='$reason'" : '';
    return db.rawQuery('''
      SELECT os.id, os.army_no, os.reason, os.location,
             os.from_dt, os.expected_return, os.remarks, os.created_at,
             COALESCE(jo.name, of.name, '—') as name,
             COALESCE(jo.rank, of.rank, '-') as rank,
             COALESCE(jo.coy, '') as coy
      FROM out_strength_records os
      LEFT JOIN jco_or jo ON os.army_no = jo.army_no
      LEFT JOIN officers of ON os.army_no = of.ic_no
      $where
      ORDER BY os.created_at DESC
    ''');
  }
}
