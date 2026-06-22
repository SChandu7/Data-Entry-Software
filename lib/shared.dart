import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ───── Palette (v2 — Navy / Gold / Steel-Blue professional theme) ──────────
const Color kBg = Color(0xFFEDF1F5); // cool light page background
const Color kSurface = Colors.white;
const Color kHeader = Color(0xFF132238); // dark section headers
const Color kSlate = Color(0xFF132238); // primary navy — base of the UI
const Color kNavyDeep = Color(0xFF0C1726); // deepest navy, app bar / emphasis
const Color kGold = Color(0xFFC9962E); // primary accent — selection, CTAs
const Color kGoldSoft = Color(0x26C9962E); // translucent gold for tints/badges
const Color kAccentBlue =
    Color(0xFF2F72B0); // secondary accent — links, info, charts
const Color kAccentBlueSoft = Color(0x222F72B0);
const Color kBorder = Color(0xFFD7DCE4);
const Color kInk = Color(0xFF16212E);
const Color kInkSoft = Color(0xFF5B6675);
const Color kField = Color(0xFFF2F4F8);
const Color kDanger = Color(0xFFB3261E);
const Color kSilver1 = Color(0xFFEEF1F5);
const Color kSilver2 = Color(0xFFDDE2E9);

// Card elevation used throughout for a refined, lifted look instead of flat borders.
const List<BoxShadow> kCardShadow = [
  BoxShadow(color: Color(0x14132238), blurRadius: 10, offset: Offset(0, 3)),
];
const double kRadius = 8.0;

// ───── Options lists ───────────────────────────────────────────────────────
const kOfficerRanks = [
  'Lt',
  'Capt',
  'Maj',
  'Lt Col',
  'Col',
  'Brig',
  'Maj Gen',
  'Lt Gen'
];
const kJcoRanks = ['Sep', 'L/Nk', 'Nk', 'Hav', 'Nb Sub', 'Sub', 'Sub Maj'];
const kJcoOnlyRanks = ['Nb Sub', 'Sub', 'Sub Maj'];
const kOrOnlyRanks = ['Sep', 'L/Nk', 'Nk', 'Hav'];
const kAllRanks = [...kOfficerRanks, ...kJcoRanks];
const kBlood = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
const kSex = ['M', 'F'];
const kYesNo = ['Yes', 'No'];
const kPassFail = ['Pass', 'Fail', '-'];
const kOfficerStatus = [
  'Present',
  'On Leave',
  'On Course',
  'ERE',
  'Attached',
  'Retired'
];
const kEntryColour = ['Black', 'Red'];
const kMaritalStatus = ['Married', 'Single', 'Widowed', 'Divorced'];
const kCoys = ['A', 'B', 'C', 'D', 'SP', 'HQ'];

// ───── Text styles ─────────────────────────────────────────────────────────
const kLabelStyle = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: .4,
    color: kInkSoft);
const kFieldStyle = TextStyle(fontSize: 13, color: kInk);
const kSectionTitle = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    letterSpacing: .6,
    color: Colors.white);

// ───── Input decoration factory ────────────────────────────────────────────
InputDecoration kDec([String? hint]) => InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: kField,
      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFADB2BB)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: kBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: kGold, width: 1.6)),
    );

// ───── buildAppTheme ───────────────────────────────────────────────────────
ThemeData buildAppTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kBg,
      colorScheme: ColorScheme.fromSeed(
          seedColor: kSlate,
          primary: kSlate,
          secondary: kGold,
          surface: kSurface),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: kField,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: kGold, width: 1.6)),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: kSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );

// ───── SectionHeader (gradient navy bar with accent stripe + optional icon) ─
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color accentColor;
  const SectionHeader(this.title,
      {super.key, this.icon, this.accentColor = kGold});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [kNavyDeep, kHeader]),
        border: Border(bottom: BorderSide(color: accentColor, width: 2.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: accentColor),
          const SizedBox(width: 8),
        ],
        Text(title.toUpperCase(), style: kSectionTitle),
      ]),
    );
  }
}

// ───── CardSection (accent left-edge stripe, elevated card) ───────────────
class CardSection extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Color accentColor;
  const CardSection(
      {super.key,
      required this.title,
      required this.child,
      this.icon,
      this.accentColor = kGold});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: kCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(width: 4, color: accentColor),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SectionHeader(title, icon: icon, accentColor: accentColor),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ])),
      ])),
    );
  }
}

// ───── SubLabel ─────────────────────────────────────────────────────────────
class SubLabel extends StatelessWidget {
  final String text;
  const SubLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 3, height: 13, color: kGold),
        const SizedBox(width: 7),
        Text(text.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
                color: kSlate)),
      ]),
    );
  }
}

// ───── PhotoBox ─────────────────────────────────────────────────────────────
class PhotoBox extends StatelessWidget {
  final String? photoPath;
  final VoidCallback? onTap;
  const PhotoBox({super.key, this.photoPath, this.onTap});
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (photoPath != null && photoPath!.isNotEmpty) {
      final f = File(photoPath!);
      child = f.existsSync()
          ? Image.file(f, fit: BoxFit.cover, width: 124, height: 152)
          : _placeholder();
    } else {
      child = _placeholder();
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 124,
        height: 152,
        decoration: BoxDecoration(
          color: kField,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(kRadius),
          boxShadow: kCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  Widget _placeholder() => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 28, color: kInkSoft),
          SizedBox(height: 6),
          Text('Photo', style: TextStyle(fontSize: 11, color: kInkSoft)),
        ],
      );
}

// ───── ComingSoon ───────────────────────────────────────────────────────────
class ComingSoon extends StatelessWidget {
  final String label;
  const ComingSoon({super.key, required this.label});
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.construction_outlined,
          size: 56, color: Color(0xFFB6BCC6)),
      const SizedBox(height: 14),
      Text(label,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: kInk)),
      const SizedBox(height: 6),
      const Text('This data card will be added soon.',
          style: TextStyle(color: kInkSoft)),
    ]));
  }
}

// ───── BipFooter ────────────────────────────────────────────────────────────
// A data-entry card (Officer / JCO Present / On ERE / Retired) implements
// this on its State so a single, screen-pinned BipFooter in home_screen.dart
// can drive whichever card is currently active.
abstract class CardController {
  bool get isEditing;
  bool get isSaving;
  Future<void> doSave();
  Future<void> doDelete();
  void doClear();
}

class BipFooter extends StatelessWidget {
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final VoidCallback onFind;
  final VoidCallback onPrint;
  final VoidCallback onExit;

  const BipFooter({
    super.key,
    required this.isEditing,
    required this.isSaving,
    required this.onSave,
    required this.onDelete,
    required this.onClear,
    required this.onFind,
    required this.onPrint,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(color: kBorder)),
        boxShadow: [
          BoxShadow(
              color: Color(0x14132238), blurRadius: 10, offset: Offset(0, -3))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        _btn('Find', Icons.search, onFind),
        const SizedBox(width: 8),
        _btn('Print', Icons.print_outlined, onPrint),
        const SizedBox(width: 8),
        _btn('Clear', Icons.refresh, onClear),
        const Spacer(),
        if (isEditing) ...[
          _btn('Delete', Icons.delete_outline, onDelete, danger: true),
          const SizedBox(width: 8),
        ],
        _saveBtn(),
        const SizedBox(width: 8),
        _btn('Exit', Icons.power_settings_new, onExit, danger: true),
      ]),
    );
  }

  Widget _saveBtn() {
    return FilledButton.icon(
      onPressed: isSaving ? null : onSave,
      icon: isSaving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: kInk))
          : Icon(isEditing ? Icons.update : Icons.save_outlined,
              size: 18, color: kInk),
      label: Text(isEditing ? 'Update' : 'Save',
          style: const TextStyle(color: kInk, fontWeight: FontWeight.w800)),
      style: FilledButton.styleFrom(
        backgroundColor: kGold,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius)),
        elevation: 2,
      ),
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback cb,
      {bool danger = false}) {
    final c = danger ? kDanger : kSlate;
    return OutlinedButton.icon(
      onPressed: cb,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: c,
        side: BorderSide(color: c, width: 1.2),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

// ───── Date picker helper ────────────────────────────────────────────────────
Future<void> pickDate(BuildContext ctx, TextEditingController ctrl) async {
  DateTime initial;
  try {
    initial = ctrl.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(ctrl.text)
        : DateTime.now();
  } catch (_) {
    initial = DateTime.now();
  }
  final d = await showDatePicker(
    context: ctx,
    initialDate: initial,
    firstDate: DateTime(1940),
    lastDate: DateTime(2100),
  );
  if (d != null) ctrl.text = DateFormat('dd-MM-yyyy').format(d);
}

// ───── Confirm dialog ────────────────────────────────────────────────────────
Future<bool> confirmDialog(
    BuildContext ctx, String title, String message) async {
  final ok = await showDialog<bool>(
    context: ctx,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: kDanger),
          onPressed: () => Navigator.pop(c, true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  return ok == true;
}

// ───── Snackbar helper ────────────────────────────────────────────────────────
void showSnack(BuildContext ctx, String msg, {bool error = false}) {
  ScaffoldMessenger.of(ctx)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? kDanger : kSlate,
    ));
}

// ───── New constants v2 ────────────────────────────────────────────────────
const kEducation = [
  'Non-Metric',
  'Metric',
  'Intermediate',
  'Graduate',
  'Post Graduate'
];
const kDomicile = ['India', 'Nepal'];
const kCourseGrade = ['-', 'AX(I)', 'AX'];
const kLeaveTypes = [
  'Annual Leave',
  'Casual Leave',
  'Sick Leave',
  'Maternity',
  'Paternity',
  'Special'
];
const kOutReasons = [
  'On Course',
  'On ERE',
  'On Leave',
  'Hospitalised',
  'Attached',
  'Out Station'
];

// ── Nominal sub-heading constants ──────────────────────────────────────────
class NomSub {
  static const officers = 'nom_officers';
  static const aCoy = 'nom_a_coy';
  static const bCoy = 'nom_b_coy';
  static const cCoy = 'nom_c_coy';
  static const dCoy = 'nom_d_coy';
  static const spCoy = 'nom_sp_coy';
  static const hqCoy = 'nom_hq_coy';
  static const jcos = 'nom_jcos';
  static const u30 = 'nom_u30';
  static const o30 = 'nom_o30';
  static const o40 = 'nom_o40';
  static const o50 = 'nom_o50';
  static const bloodGroup = 'nom_blood';
  static String label(String s) {
    const m = {
      'nom_officers': 'Officers',
      'nom_a_coy': 'A Coy',
      'nom_b_coy': 'B Coy',
      'nom_c_coy': 'C Coy',
      'nom_d_coy': 'D Coy',
      'nom_sp_coy': 'SP Coy',
      'nom_hq_coy': 'HQ Coy',
      'nom_jcos': 'JCOs',
      'nom_u30': 'Under 30 Yrs',
      'nom_o30': 'Over 30 Yrs',
      'nom_o40': 'Over 40 Yrs',
      'nom_o50': 'Over 50 Yrs',
      'nom_blood': 'Blood Group'
    };
    return m[s] ?? s;
  }
}

// ── Course sub-heading constants ───────────────────────────────────────────
class CrsSub {
  static const sec = 'crs_sec';
  static const mmg = 'crs_mmg';
  static const mor = 'crs_mor';
  static const snip = 'crs_snip';
  static const adp = 'crs_adp';
  static const atgm = 'crs_atgm';
  static const drill = 'crs_drill';
  static const bmic = 'crs_bmic';
  static const uei = 'crs_uei';
  static const cdo = 'crs_cdo';
  static const qm = 'crs_qm';
  static const rsi = 'crs_rsi';
  static const jlc = 'crs_jlc';
  static const pc = 'crs_pc';
  static const pt = 'crs_pt';
  static const tpt = 'crs_tpt';
  static const misc = 'crs_misc';
  static const bsw = 'crs_bsw';
  // DB column for each
  static String dbCol(String s) {
    const m = {
      'crs_sec': 'c_sec',
      'crs_mmg': 'c_mmg',
      'crs_mor': 'c_mor',
      'crs_snip': 'c_snip',
      'crs_adp': 'c_adp',
      'crs_atgm': 'c_atgm',
      'crs_drill': 'c_drill',
      'crs_bmic': 'c_bmic',
      'crs_uei': 'c_uei',
      'crs_cdo': 'c_cdo',
      'crs_qm': 'c_qm',
      'crs_rsi': 'c_rsi',
      'crs_jlc': 'c_jlc',
      'crs_pc': 'c_pc',
      'crs_pt': 'c_pt',
      'crs_tpt': 'c_tpt',
      'crs_misc': 'c_misc',
      'crs_bsw': 'c_bsw'
    };
    return m[s] ?? 'c_misc';
  }

  static String gradeCol(String s) => '${dbCol(s)}_g';
  static String label(String s) {
    const m = {
      'crs_sec': 'Sec Cdr',
      'crs_mmg': 'MMG AGL',
      'crs_mor': 'MOR',
      'crs_snip': 'Sniper',
      'crs_adp': 'ADP',
      'crs_atgm': 'ATGM',
      'crs_drill': 'Drill',
      'crs_bmic': 'BMIC',
      'crs_uei': 'UEI',
      'crs_cdo': 'CDO',
      'crs_qm': 'QM',
      'crs_rsi': 'RSI',
      'crs_jlc': 'JLC',
      'crs_pc': 'PC',
      'crs_pt': 'PT',
      'crs_tpt': 'TPT',
      'crs_misc': 'Misc',
      'crs_bsw': 'BSW'
    };
    return m[s] ?? s;
  }

  static const all = [
    sec,
    mmg,
    mor,
    snip,
    adp,
    atgm,
    drill,
    bmic,
    uei,
    cdo,
    qm,
    rsi,
    jlc,
    pc,
    pt,
    tpt,
    misc,
    bsw
  ];
}

// ── Admin sub-heading labels ───────────────────────────────────────────────
class AdminSub {
  static const leave = 'adm_leave';
  static const health = 'adm_health';
  static const ere = 'adm_ere';
  static const outStr = 'adm_out';
  static const firing = 'adm_firing';
  static const cpt = 'adm_cpt';
  static const filterEngine = 'adm_filter';
  static String label(String s) {
    const m = {
      'adm_leave': 'Leave',
      'adm_health': 'Health',
      'adm_ere': 'ERE',
      'adm_out': 'Out Strength',
      'adm_firing': 'Firing',
      'adm_cpt': 'CPT',
      'adm_filter': 'Filter Engine'
    };
    return m[s] ?? s;
  }

  static const all = [filterEngine, leave, health, ere, outStr, firing, cpt];
}

// ── Leave sub-heading constants ────────────────────────────────────────────
class LeaveSub {
  static const all = 'lv_all';
  static const annual = 'lv_annual';
  static const casual = 'lv_casual';
  static const sick = 'lv_sick';
  static const maternity = 'lv_mat';
  static const paternity = 'lv_pat';
  static const special = 'lv_special';
  static const allSubs = [
    all,
    annual,
    casual,
    sick,
    maternity,
    paternity,
    special
  ];
  static String label(String s) {
    const m = {
      'lv_all': 'All Leaves',
      'lv_annual': 'Annual Leave',
      'lv_casual': 'Casual Leave',
      'lv_sick': 'Sick Leave',
      'lv_mat': 'Maternity',
      'lv_pat': 'Paternity',
      'lv_special': 'Special Leave'
    };
    return m[s] ?? s;
  }

  static String? dbVal(String s) {
    const m = {
      'lv_annual': 'Annual Leave',
      'lv_casual': 'Casual Leave',
      'lv_sick': 'Sick Leave',
      'lv_mat': 'Maternity',
      'lv_pat': 'Paternity',
      'lv_special': 'Special'
    };
    return m[s]; // null = All
  }
}

// ── Health sub-heading constants ───────────────────────────────────────────
class HealthSub {
  static const coyA = 'hl_coy_a';
  static const coyB = 'hl_coy_b';
  static const coyC = 'hl_coy_c';
  static const coyD = 'hl_coy_d';
  static const sp = 'hl_sp';
  static const hq = 'hl_hq';
  static const tempLmc = 'hl_temp';
  static const permtLmc = 'hl_permt';
  static const allSubs = [coyA, coyB, coyC, coyD, sp, hq, tempLmc, permtLmc];
  static String label(String s) {
    const m = {
      'hl_coy_a': 'Coy A',
      'hl_coy_b': 'Coy B',
      'hl_coy_c': 'Coy C',
      'hl_coy_d': 'Coy D',
      'hl_sp': 'SP',
      'hl_hq': 'HQ',
      'hl_temp': 'Temp LMC',
      'hl_permt': 'Permt LMC'
    };
    return m[s] ?? s;
  }

  // Maps a sub-heading key to the value stored in health_records.category
  static String dbVal(String s) {
    const m = {
      'hl_coy_a': 'A',
      'hl_coy_b': 'B',
      'hl_coy_c': 'C',
      'hl_coy_d': 'D',
      'hl_sp': 'SP',
      'hl_hq': 'HQ',
      'hl_temp': 'Temp',
      'hl_permt': 'Permt'
    };
    return m[s] ?? s;
  }
}

// ── Health record category options (admin entry dropdown) ─────────────────
const kHealthCategory = ['A', 'B', 'C', 'D', 'SP', 'HQ', 'Temp', 'Permt'];
String healthCategoryLabel(String v) {
  const m = {
    'A': 'Coy A',
    'B': 'Coy B',
    'C': 'Coy C',
    'D': 'Coy D',
    'SP': 'SP',
    'HQ': 'HQ',
    'Temp': 'Temp LMC',
    'Permt': 'Permt LMC'
  };
  return m[v] ?? v;
}

// True when the category is a normal company (Weight Record form),
// false when it's Temp/Permt LMC (diagnosis-style form).
bool isWeightCategory(String? v) => v != null && !['Temp', 'Permt'].contains(v);

const kWeightClass = ['Normal', 'Overweight', 'Obese', 'Underweight'];
const kMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

// ── ERE sub-heading constants ──────────────────────────────────────────────
class EreSub {
  static const all = 'ere_all';
  static const active = 'ere_active';
  static const completed = 'ere_done';
  static const allSubs = [all, active, completed];
  static String label(String s) {
    const m = {
      'ere_all': 'All ERE',
      'ere_active': 'Currently On ERE',
      'ere_done': 'ERE Completed'
    };
    return m[s] ?? s;
  }
}

// ── Out Strength sub-heading constants ─────────────────────────────────────
class OutStrSub {
  static const all = 'os_all';
  static const course = 'os_course';
  static const ere = 'os_ere';
  static const leave = 'os_leave';
  static const hospital = 'os_hosp';
  static const attached = 'os_att';
  static const outStation = 'os_out';
  static const allSubs = [
    all,
    course,
    ere,
    leave,
    hospital,
    attached,
    outStation
  ];
  static String label(String s) {
    const m = {
      'os_all': 'All',
      'os_course': 'On Course',
      'os_ere': 'On ERE',
      'os_leave': 'On Leave',
      'os_hosp': 'Hospitalised',
      'os_att': 'Attached',
      'os_out': 'Out Station'
    };
    return m[s] ?? s;
  }

  static String? dbVal(String s) {
    const m = {
      'os_course': 'On Course',
      'os_ere': 'On ERE',
      'os_leave': 'On Leave',
      'os_hosp': 'Hospitalised',
      'os_att': 'Attached',
      'os_out': 'Out Station'
    };
    return m[s];
  }
}

// ── Miscellaneous: Firing & CPT ─────────────────────────────────────────────
const kFiringResults = ['MM', 'FC', 'SS', 'Fail'];
const kCptResults = ['Super Ex', 'Ex', 'Good', 'Sat', 'Fail'];

class MiscSub {
  static const firing = 'misc_firing';
  static const cpt = 'misc_cpt';
  static const allSubs = [firing, cpt];
  static String label(String s) {
    const m = {'misc_firing': 'Firing', 'misc_cpt': 'CPT'};
    return m[s] ?? s;
  }
}
